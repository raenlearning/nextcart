import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sendPushToTokens } from "../_shared/fcm.ts";

// Dihubungkan ke Database Webhook Supabase pada tabel `orders`
// (event UPDATE). Mengirim push notification ke pembeli ketika status
// pesanan berubah.
//
// Setup di Dashboard > Database > Webhooks:
//   - Table : orders
//   - Events: UPDATE
//   - URL   : https://<ref>.supabase.co/functions/v1/order-notify
//   - Headers: Authorization: Bearer <anon key>
//              x-webhook-secret: <nilai WEBHOOK_SECRET yang sama>

const WEBHOOK_SECRET = Deno.env.get("WEBHOOK_SECRET") || "";

function statusLabel(status: string): string {
  switch (status) {
    case "waiting_payment":
      return "Menunggu Pembayaran";
    case "processing":
      return "Diproses";
    case "delivered":
      return "Dikirim";
    case "completed":
      return "Selesai";
    case "cancelled":
      return "Dibatalkan";
    default:
      return status;
  }
}

serve(async (req) => {
  try {
    if (req.method === "OPTIONS") {
      return new Response("ok", {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers":
            "authorization, x-client-info, apiKey, content-type, x-webhook-secret",
        },
      });
    }

    if (req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
      });
    }

    const payload = await req.json();
    const { table, record, old_record } = payload;

    if (table !== "orders" || !record) {
      return new Response(JSON.stringify({ received: true, skipped: true }), {
        status: 200,
      });
    }

    const newStatus = record.status as string | undefined;
    const oldStatus = old_record?.status as string | undefined;
    if (!newStatus || (newStatus && newStatus === oldStatus)) {
      return new Response(JSON.stringify({ received: true, skipped: true }), {
        status: 200,
      });
    }

    const userId = record.user_id as string | undefined;
    if (!userId) {
      return new Response(JSON.stringify({ received: true, skipped: true }), {
        status: 200,
      });
    }

    const title = "Status Pesanan Diperbarui";
    const body = `Pesanan kamu sekarang berstatus: ${statusLabel(newStatus)}.`;

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: tokens } = await supabase
      .from("push_tokens")
      .select("token")
      .eq("user_id", userId);

    const tokenList = (tokens as { token: string }[] | null)?.map(
      (row) => row.token,
    ) ?? [];

    let sent = 0;
    if (tokenList.length > 0) {
      sent = await sendPushToTokens(tokenList, title, body, {
        order_id: String(record.id),
        status: newStatus,
      });
    }

    return new Response(JSON.stringify({ sent }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("order-notify error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
});
