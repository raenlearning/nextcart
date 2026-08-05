import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { crypto } from "https://deno.land/std@0.168.0/crypto/mod.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apiKey, content-type",
      },
    });
  }

  try {
    const rawKey = Deno.env.get("MIDTRANS_SERVER_KEY") || "";
    const MIDTRANS_SERVER_KEY = rawKey.trim().replace(/['"]/g, "");

    if (!MIDTRANS_SERVER_KEY) {
      throw new Error("Secret MIDTRANS_SERVER_KEY tidak ditemukan!");
    }

    const notification = await req.json();

    const {
      order_id,
      status_code,
      gross_amount,
      signature_key,
      transaction_status,
      payment_type,
      transaction_id,
      fraud_status,
    } = notification;

    const rawSignature =
      order_id + status_code + gross_amount + MIDTRANS_SERVER_KEY;
    const encoder = new TextEncoder();
    const data = encoder.encode(rawSignature);
    const hashBuffer = await crypto.subtle.digest("SHA-512", data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const calculatedSignature = hashArray
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");

    if (calculatedSignature !== signature_key) {
      console.error("Signature tidak valid!", {
        calculatedSignature,
        signature_key,
      });
      return new Response(JSON.stringify({ error: "Invalid signature" }), {
        status: 403,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      });
    }

    let paymentStatus = "pending";
    let orderStatus = "pending";

    if (transaction_status === "capture") {
      if (fraud_status === "accept") {
        paymentStatus = "settlement";
        orderStatus = "processing";
      } else if (fraud_status === "challenge") {
        paymentStatus = "challenge";
        orderStatus = "pending";
      }
    } else if (transaction_status === "settlement") {
      paymentStatus = "settlement";
      orderStatus = "processing";
    } else if (transaction_status === "pending") {
      paymentStatus = "pending";
      orderStatus = "waiting_payment";
    } else if (
      transaction_status === "deny" ||
      transaction_status === "cancel" ||
      transaction_status === "expire"
    ) {
      paymentStatus = "failed";
      orderStatus = "cancelled";
    } else if (transaction_status === "refund") {
      paymentStatus = "refunded";
      orderStatus = "cancelled";
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: paymentRow, error: findError } = await supabase
      .from("payments")
      .select("id, order_id")
      .eq("midtrans_id", order_id)
      .maybeSingle();

    if (findError || !paymentRow) {
      console.error("Payment record tidak ditemukan untuk order_id:", order_id);
      return new Response(JSON.stringify({ error: "Payment not found" }), {
        status: 404,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      });
    }

    await supabase
      .from("payments")
      .update({
        status: paymentStatus,
        method: payment_type,
        midtrans_transaction_id: transaction_id, // kolom baru, bukan menimpa midtrans_id
        paid_at:
          paymentStatus === "settlement" ? new Date().toISOString() : null,
      })
      .eq("id", paymentRow.id);

    await supabase
      .from("orders")
      .update({ status: orderStatus })
      .eq("id", paymentRow.order_id);

    if (paymentStatus === "settlement") {
      const { data: orderItems } = await supabase
        .from("order_items")
        .select("product_id, quantity")
        .eq("order_id", paymentRow.order_id);

      if (orderItems) {
        for (const item of orderItems) {
          await supabase.rpc("deduct_product_stock", {
            p_product_id: item.product_id,
            p_quantity: item.quantity,
          });
        }
      }
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    console.error("Webhook error:", error);
    return new Response(JSON.stringify({ error_messages: [error.message] }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      status: 400,
    });
  }
});
