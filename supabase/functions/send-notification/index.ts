import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sendPushToTokens } from "../_shared/fcm.ts";

// Mengirim push notification ke pengguna tertentu (atau semua) via Firebase
// Cloud Messaging HTTP v1. Wajib menyetel FCM_SERVICE_ACCOUNT_JSON di secrets.

serve(async (req) => {
  try {
    if (req.method === "OPTIONS") {
      return new Response("ok", {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers":
            "authorization, x-client-info, apiKey, content-type",
        },
      });
    }

    const { user_id, title, body, data: payload } = await req.json();
    if (!user_id || !title) {
      throw new Error("Parameter user_id dan title wajib diisi.");
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: tokens } = await supabase
      .from("push_tokens")
      .select("token")
      .eq("user_id", user_id);

    if (!tokens || tokens.length === 0) {
      console.log("Tidak ada push token untuk user ini.");
      return new Response(JSON.stringify({ sent: 0 }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    const tokenList = (tokens as { token: string }[]).map((row) => row.token);
    const sent = await sendPushToTokens(
      tokenList,
      title,
      body || "",
      (payload as Record<string, string>) || {},
    );

    return new Response(JSON.stringify({ sent }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Send notification error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
});
