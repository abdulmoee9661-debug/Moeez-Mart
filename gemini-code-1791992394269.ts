// Supabase Edge Function: /supabase/functions/process-jazzcash-payment/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createHmac } from "https://deno.land/std@0.168.0/node/crypto.ts";

const JAZZCASH_MERCHANT_ID = Deno.env.get("JAZZCASH_MERCHANT_ID");
const JAZZCASH_PASSWORD = Deno.env.get("JAZZCASH_PASSWORD");
const JAZZCASH_INTEGERITY_SALT = Deno.env.get("JAZZCASH_INTEGERITY_SALT");
const JAZZCASH_POST_URL = Deno.env.get("JAZZCASH_POST_URL") || "https://sandbox.jazzcash.com.pk/CustomerPortal/transactionpay/pay";

serve(async (req) => {
  try {
    const { orderId, amount, customerPhone } = await req.json();

    // Verification Step: If production credentials aren't supplied, switch to gracefully handled sandbox mode
    if (!JAZZCASH_MERCHANT_ID || JAZZCASH_MERCHANT_ID === "YOUR_MERCHANT_ID") {
      return new Response(
        JSON.stringify({
          status: "PENDING_CONFIGURATION",
          message: "JazzCash integration is operating in preview setup mode. Real payments require active JazzCash Merchant Credentials.",
          orderId
        }),
        { headers: { "Content-Type": "application/json" }, status: 200 }
      );
    }

    const txnRefNum = `MM-${orderId.substring(0, 8)}-${Date.now()}`;
    const expiryDateTime = new Date(Date.now() + 3600 * 1000).toISOString().replace(/[-T:\.Z]/g, "").substring(0, 14);

    const postData: Record<string, string> = {
      pp_Version: "1.1",
      pp_TxnType: "MWALLET",
      pp_Language: "EN",
      pp_MerchantID: JAZZCASH_MERCHANT_ID,
      pp_Password: JAZZCASH_PASSWORD!,
      pp_RefNum: txnRefNum,
      pp_Amount: Math.round(amount * 100).toString(), // PKR converted to paisas
      pp_TxnCurrency: "PKR",
      pp_TxnDateTime: expiryDateTime.substring(0, 14),
      pp_BillReference: `INV-${orderId.substring(0, 6)}`,
      pp_Description: "Order Payment at Moeez Mart",
      pp_MobileNumber: customerPhone,
      pp_SecureHash: ""
    };

    // Calculate Secure Hash
    const sortedKeys = Object.keys(postData).sort();
    let hashString = JAZZCASH_INTEGERITY_SALT + "&";
    sortedKeys.forEach((key) => {
      if (postData[key] !== "" && key !== "pp_SecureHash") {
        hashString += `${postData[key]}&`;
      }
    });
    hashString = hashString.slice(0, -1); // Remove trailing ampersand

    const secureHash = createHmac("sha256", JAZZCASH_INTEGERITY_SALT!)
      .update(hashString)
      .digest("hex")
      .toUpperCase();

    postData.pp_SecureHash = secureHash;

    return new Response(
      JSON.stringify({ status: "SUCCESS", postUrl: JAZZCASH_POST_URL, payload: postData }),
      { headers: { "Content-Type": "application/json" }, status: 200 }
    );
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});