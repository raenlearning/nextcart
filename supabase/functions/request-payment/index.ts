import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { 
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apiKey, content-type',
      } 
    })
  }

  try {
    const rawKey = Deno.env.get('MIDTRANS_SERVER_KEY') || '';
    const MIDTRANS_SERVER_KEY = rawKey.trim().replace(/['"]/g, ''); 


    if (!MIDTRANS_SERVER_KEY) {
      throw new Error("Secret MIDTRANS_SERVER_KEY tidak ditemukan di Supabase Vault!");
    }

    const { order_id, gross_amount, customer_name, customer_email } = await req.json();
    
    // Encode Server Key ke Base64 dengan aman
    const authHeader = btoa(MIDTRANS_SERVER_KEY + ':');

    const response = await fetch('https://app.sandbox.midtrans.com/snap/v1/transactions', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Basic ${authHeader}`
      },
      body: JSON.stringify({
        transaction_details: {
          order_id: order_id,
          gross_amount: gross_amount
        },
        customer_details: {
          first_name: customer_name,
          email: customer_email
        }
      })
    });

    const data = await response.json();
    return new Response(JSON.stringify(data), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      status: response.status
    });

  } catch (error) {
    return new Response(JSON.stringify({ error_messages: [error.message] }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      status: 400
    });
  }
})