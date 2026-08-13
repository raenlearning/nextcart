// Helper bersama untuk mengirim push notification via Firebase Cloud
// Messaging HTTP v1. Butuh secret: FCM_SERVICE_ACCOUNT_JSON (JSON service
// account dari Firebase, sebagai string tunggal).

const SERVICE_ACCOUNT = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON") || "";

function aud() {
  return "https://oauth2.googleapis.com/token";
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

async function getAccessToken(): Promise<string> {
  const sa = JSON.parse(SERVICE_ACCOUNT);
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const claimSet = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: aud(),
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

  const tokenResp = await fetch(aud(), {
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

/**
 * Kirim push notification ke daftar token FCM.
 * @returns jumlah token yang berhasil dikirim.
 */
export async function sendPushToTokens(
  tokens: string[],
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<number> {
  if (!SERVICE_ACCOUNT) {
    throw new Error("FCM_SERVICE_ACCOUNT_JSON belum disetel di Supabase Secrets.");
  }
  const sa = JSON.parse(SERVICE_ACCOUNT);
  const accessToken = await getAccessToken();
  let sent = 0;

  for (const token of tokens) {
    const message = {
      message: {
        token,
        notification: { title, body },
        data,
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

  return sent;
}
