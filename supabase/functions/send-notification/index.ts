import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Mengirim push notification ke pengguna tertentu (atau semua) via Firebase
// Cloud Messaging HTTP v1. Wajib menyetel FCM_SERVICE_ACCOUNT_JSON di secrets.
const SERVICE_ACCOUNT = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON") || "";

function aud(projectId: string) {
  return `https://oauth2.googleapis.com/token`;
}

async function getAccessToken(): Promise<string> {
  const sa = JSON.parse(SERVICE_ACCOUNT);
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const claimSet = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: aud(sa.project_id),
    iat: now,
    exp: now + 3600,
  };

  const b64 = (o: unknown) =>
    btoa(JSON.stringify(o)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

  const unsigned = `${b64(header)}.${b64(claimSet)}`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    convertPemToBinary(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );

  const signature = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

  const assertion = `${unsigned}.${signature}`;

  const tokenResp = await fetch(aud(sa.project_id), {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  const data = await tokenResp.json();
  return data.access_token;
}

function convertPemToBinary(pem: string): ArrayBuffer {
  const base64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const raw = atob(base64);
  const bytes = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);
  return bytes.buffer;
}

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

    if (!SERVICE_ACCOUNT) {
      throw new Error(
        "FCM_SERVICE_ACCOUNT_JSON belum disetel di Supabase Secrets.",
      );
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

    const sa = JSON.parse(SERVICE_ACCOUNT);
    const accessToken = await getAccessToken();
    let sent = 0;

    for (const row of tokens) {
      const message = {
        message: {
          token: row.token,
          notification: { title, body: body || "" },
          data: (payload as Record<string, string>) || {},
        },
      };
      const resp = await fetch(
        `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${accessToken}`,
          },
          body: JSON.stringify(message),
        },
      );
      if (resp.ok) sent++;
    }

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