# ShegerPay SDK

Official SDKs for integrating ShegerPay quickly. Current version: **2.2.0**

## What You Can Do

- Verify Ethiopian payment transactions (`/verify`, `/quick-verify`, `/verify-image`)
- Create and manage payment links
- Create, validate, and redeem reusable promo codes for payment links or your own checkout
- Verify crypto payments
- Use PayPal checkout and PayPal payout requests
- Configure webhooks and verify webhook signatures
- Read transaction history and API usage

## Auth

Use your secret key in the `X-API-Key` header.

- Test: `sk_test_...`
- Live: `sk_live_...`

## Quick Start

```python
from shegerpay import ShegerPay

client = ShegerPay(api_key="sk_test_xxx")
result = client.verify(transaction_id="FT24352648751234", amount=100, provider="cbe")

print(result.valid)
```

BOA note:

- Use transaction ID, full BOA receipt URL/full `trx`, SMS text, or receipt image/PDF
- Include sender account (`sender_account` / `senderAccount`)

Supported providers: `cbe`, `telebirr`, `boa`, `awash`, `ebirr_kaafi`, `ebirr_coop`

### Verify from screenshot (verifyImage)

```python
# Python — pass base64-encoded image
import base64

with open("receipt.png", "rb") as f:
    image_b64 = base64.b64encode(f.read()).decode()

result = client.verify_image(screenshot=image_b64, amount=500, provider="cbe")
print(result.verified)
```

```javascript
// JavaScript / TypeScript — pass a File or Blob (browser) or Buffer (Node.js)
const fs = require('fs');
const { Blob } = require('buffer');

const data = fs.readFileSync('receipt.png');
const blob = new Blob([data], { type: 'image/png' });

const result = await client.verifyImage({ screenshot: blob, amount: 500, provider: 'cbe' });
console.log(result.verified);
```

The `amount` field is optional for image verification — omit it to let the OCR extract the amount automatically:

```javascript
const result = await client.verifyImage({ screenshot: blob, provider: 'telebirr' });
```

## Promo Codes

Promo codes use the same backend for payment links and merchant-owned websites.

```ts
const promo = await client.createPromoCode({
  code: 'STARTUP20',
  discountType: 'percent',
  discountValue: 20,
  maxUses: 100,
  maxUsesPerCustomer: 1,
  minOrderAmount: 100,
});

const preview = await client.validatePromoCode({
  code: 'STARTUP20',
  amount: 500,
  provider: 'cbe',
  customerIdentifier: 'buyer@example.com',
});

// Ask the customer to pay preview.discounted_amount exactly.
const verification = await client.verify({
  transactionId: 'FT26112GCXZD05529667',
  amount: preview.discounted_amount,
  provider: 'cbe',
});

if (verification.verified) {
  await client.redeemPromoCode({
    code: 'STARTUP20',
    amount: 500,
    transactionId: verification.transactionId || 'FT26112GCXZD05529667',
    orderId: 'order_1001',
    customerIdentifier: 'buyer@example.com',
  });
}
```

Management and redemption require a secret key. Redemption is idempotent by transaction/order, so safe retries do not consume another use.

## Payment Links: Knowing When The Merchant Website Should Approve

Use `payment_link.order.verified` as the server-to-server approval event. Buyer redirects are helpful for UX, but your backend should trust the webhook or the order-status API.

```ts
// 1. Create a payment link with a webhook and redirect URL.
const link = await client.createPaymentLink({
  title: 'Order #1001',
  amount: 500,
  currency: 'ETB',
  redirectUrl: 'https://merchant.example/success',
  webhookUrl: 'https://merchant.example/shegerpay/webhook',
});

// 2. On webhook: mark your website order paid when event is payment_link.order.verified.
// data includes order_id, checkout_session_id, short_code, amount, currency,
// provider, transaction_id, promo_code, discount_amount, verified_at, signature.

// 3. Optional fallback: poll order status from your frontend/backend.
const status = await client.getPaymentLinkOrderStatus(link.shortCode, 'ord_EXAMPLE');
```

Redirect URLs include signed params: `checkout_session_id`, `order_id`, `short_code`, `amount`, `currency`, `status=paid`, and `signature`.

## Install

| Language | Install |
| --- | --- |
| TypeScript / JavaScript | `npm install @shegerpay/sdk@2.2.0` |
| Python | `pip install shegerpay` |
| PHP | `composer require shegerpay/sdk` |
| Ruby | `gem install shegerpay` |
| Go | `go get github.com/shegerpay/sdk-go` |
| Java / Kotlin | `com.shegerpay:sdk` |
| C# | `dotnet add package ShegerPay.SDK` |
| Swift (iOS) | Swift Package Manager (`ShegerPaySDK`) |
| Dart / Flutter | `dart pub add shegerpay` |
| WordPress / WooCommerce | [See WordPress Plugin](#wordpress--woocommerce-plugin) — zip & upload, no coding needed |

---

## WordPress / WooCommerce Plugin

Accept Ethiopian bank payments in your WooCommerce store — **no coding required**.

### What it does
- Adds a **"Pay with Ethiopian Bank"** option at WooCommerce checkout
- Customer chooses provider, enters transaction ID/SMS/slip URL, or uploads receipt image/PDF for OCR
- BOA checkout includes a required sender-account field
- Plugin calls ShegerPay API instantly and auto-verifies the payment
- Optional ShegerPay promo-code field validates discounts server-side with provider/customer context and redeems once after verified payment
- Order marked complete automatically on success

### Install in 3 steps

**1 — Download / zip the plugin**

```bash
cd sdk/wordpress
zip -r shegerpay-woocommerce.zip shegerpay-woocommerce/
```

Or [download directly from GitHub](https://github.com/black12-ag/ShegerPay/tree/main/sdk/wordpress/shegerpay-woocommerce).

**2 — Upload to WordPress**

WordPress Admin → **Plugins → Add New → Upload Plugin** → choose the zip → Install → Activate

**3 — Configure**

WooCommerce → **Settings → Payments → ShegerPay** → paste your API key → Save

### Requirements
- WordPress 6.0+
- WooCommerce 6.0+
- PHP 7.4+
- ShegerPay API key (get one free at [shegerpay.com](https://shegerpay.com))

### Plugin files
```
sdk/wordpress/shegerpay-woocommerce/
  shegerpay-woocommerce.php          ← main plugin file
  includes/
    class-shegerpay-gateway.php      ← WooCommerce payment gateway
    class-shegerpay-api.php          ← API wrapper
  assets/                            ← logo/icons
  readme.txt                         ← WordPress plugin directory format
```

---

## Public Scope

The SDK intentionally focuses on public, stable endpoints.

- Non-PayPal international account setup is private/assisted
- Wallet conversion across private rails is not part of public SDK usage

## Webhook Signature Check

```javascript
const ok = await ShegerPay.verifyWebhookSignature(
  payload,
  req.headers["x-shegerpay-signature"],
  "whsec_xxx"
);
```

## Docs and Support

- Docs: https://shegerpay.com/docs
- API base URL: `https://api.shegerpay.com/api/v1`
- Support: support@shegerpay.com

---

## 🔒 Security Best Practices

### API Key Security

| ✅ DO                                   | ❌ DON'T                           |
| --------------------------------------- | ---------------------------------- |
| Store API keys in environment variables | Hard-code keys in source code      |
| Use `sk_test_` keys in development      | Use `sk_live_` keys in development |
| Rotate keys if compromised              | Share keys across projects         |
| Use server-side verification only       | Expose keys in client-side code    |

```bash
# Store keys securely
export SHEGERPAY_API_KEY="sk_live_xxx"
```

```python
# Read from environment
import os
client = ShegerPay(os.getenv('SHEGERPAY_API_KEY'))
```

### Webhook Security

**Always verify webhook signatures before processing:**

```python
# Python
is_valid = ShegerPay.verify_webhook_signature(
    payload=request.body,
    signature=request.headers['X-ShegerPay-Signature'],
    secret=os.getenv('WEBHOOK_SECRET')  # Store securely!
)

if not is_valid:
    return Response(status=401)  # Reject invalid signatures
```

### HTTPS Only

- All API calls use HTTPS (TLS 1.3)
- Never disable SSL verification
- Verify you're connecting to `api.shegerpay.com`

---

## 👤 User Guide: What You Need to Do

### Step 1: Get API Keys

1. Sign up at [shegerpay.com](https://shegerpay.com)
2. Go to Dashboard → API Keys
3. Generate a **test key** (`sk_test_xxx`) for development
4. Generate a **live key** (`sk_live_xxx`) for production

### Step 2: Add Your Bank Account

1. Go to Dashboard → Linked Accounts
2. Add your CBE/Telebirr account details
3. Your account will be used for verification matching

### Step 3: Integrate the SDK

```python
# Install
pip install shegerpay

# Use
from shegerpay import ShegerPay
client = ShegerPay('sk_test_xxx')
result = client.verify(transaction_id='FT123456', amount=100, provider='cbe')
```

### Step 4: Set Up Webhooks (Recommended)

1. Create webhook: Dashboard → Webhooks → Add
2. Enter your endpoint URL
3. Copy the webhook secret
4. Handle events in your server

### Step 5: Go Live

1. Test thoroughly with `sk_test_` keys
2. Switch to `sk_live_` key
3. Remove test transaction IDs
4. Monitor Dashboard for live transactions

---

## ⚠️ Error Handling

All SDKs return standardized error codes:

| Error Code | Meaning               | What to Do                      |
| ---------- | --------------------- | ------------------------------- |
| `AUTH_001` | Missing API key       | Add `X-API-Key` header          |
| `AUTH_002` | Invalid API key       | Check key in Dashboard          |
| `TX_001`   | Transaction not found | Verify transaction ID           |
| `TX_002`   | Amount mismatch       | Check expected vs actual amount |
| `PROV_001` | Bank timeout          | Retry after 30 seconds          |
| `SUB_001`  | Limit exceeded        | Upgrade plan                    |

```python
try:
    result = client.verify(transaction_id='FT123', amount=100, provider='cbe')
except ShegerPayError as e:
    print(f"Error: {e.error_code}")
    print(f"Message: {e.message}")
    print(f"Fix: {e.suggestion}")
```

---

## 📚 Documentation

| Doc                                                        | Description                    |
| ---------------------------------------------------------- | ------------------------------ |
| [API Reference](https://shegerpay.com/docs/api)            | Complete API documentation     |
| [Integration Guide](https://shegerpay.com/docs/quickstart) | 5-minute quick start           |
| [Webhook Guide](https://shegerpay.com/docs/webhooks)       | Set up real-time notifications |
| [Security Guide](https://shegerpay.com/docs/security)      | Best practices                 |

---

## 🆘 Support

- 📖 [Documentation](https://shegerpay.com/docs)
- 💬 [Telegram](https://t.me/shegerpay_0)
- 📧 [support@shegerpay.com](mailto:support@shegerpay.com)
- 🐛 [GitHub Issues](https://github.com/black12-ag/ShegerPay/issues)

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Made with ❤️ by ShegerPay**
