# ShegerPay SDK

Official SDKs for integrating ShegerPay Payment Verification into your applications.

![ShegerPay](https://img.shields.io/badge/ShegerPay-Payment%20Gateway-purple)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Languages](https://img.shields.io/badge/Languages-10-orange)

## 🚀 Quick Start

**3 lines to verify a payment:**

```python
from shegerpay import ShegerPay

client = ShegerPay(api_key="sk_test_xxx")
result = client.verify("FT24352648751234", 100)  # ✅ Done!
```

---

## 📦 Supported Languages (11)

| Language         | Package             | Installation                                    | Status   |
| ---------------- | ------------------- | ----------------------------------------------- | -------- |
| **TypeScript**   | `@shegerpay/sdk`    | `npm install @shegerpay/sdk`                    | ✅ Ready |
| **Python**       | `shegerpay`         | `pip install shegerpay`                         | ✅ Ready |
| **JavaScript**   | `@shegerpay/sdk`    | `npm install @shegerpay/sdk`                    | ✅ Ready |
| **PHP**          | `shegerpay/sdk`     | `composer require shegerpay/sdk`                | ✅ Ready |
| **Ruby**         | `shegerpay`         | `gem install shegerpay`                         | ✅ Ready |
| **Go**           | `shegerpay`         | `go get github.com/black12-ag/shegerpay-sdk/go` | ✅ Ready |
| **Java**         | `com.shegerpay:sdk` | Maven                                           | ✅ Ready |
| **C#**           | `ShegerPay.SDK`     | `dotnet add package ShegerPay.SDK`              | ✅ Ready |
| **Kotlin**       | `com.shegerpay:sdk` | Gradle                                          | ✅ Ready |
| **Swift**        | `ShegerPay`         | Swift Package Manager                           | ✅ Ready |
| **Dart/Flutter** | `shegerpay`         | `dart pub add shegerpay`                        | ✅ Ready |

---

## 💻 Code Examples

### Python

```python
from shegerpay import ShegerPay

client = ShegerPay(api_key="sk_test_xxx")
result = client.verify(transaction_id="FT24352648751234", amount=100)

if result.valid:
    print("✅ Payment verified!")
```

### JavaScript/Node.js

```javascript
const ShegerPay = require("@shegerpay/sdk");

const client = new ShegerPay("sk_test_xxx");
const result = await client.verify({
  transactionId: "FT24352648751234",
  amount: 100,
});

if (result.valid) console.log("✅ Payment verified!");
```

### PHP

```php
$client = new ShegerPay\Client('sk_test_xxx');
$result = $client->verify([
    'transaction_id' => 'FT24352648751234',
    'amount' => 100
]);

if ($result->valid) echo '✅ Payment verified!';
```

### Ruby

```ruby
client = ShegerPay::Client.new('sk_test_xxx')
result = client.verify(transaction_id: 'FT24352648751234', amount: 100)

puts '✅ Payment verified!' if result.valid?
```

### Go

```go
client, _ := shegerpay.NewClient("sk_test_xxx")
result, _ := client.Verify(shegerpay.VerifyParams{
    TransactionID: "FT24352648751234",
    Amount: 100,
})

if result.Valid {
    fmt.Println("✅ Payment verified!")
}
```

### Java

```java
ShegerPayClient client = new ShegerPay("sk_test_xxx");
VerificationResult result = client.verify("FT24352648751234", 100);

if (result.isValid()) {
    System.out.println("✅ Payment verified!");
}
```

### C#

```csharp
using ShegerPay.SDK;

var client = new ShegerPayClient("sk_test_xxx");
var result = await client.VerifyAsync("FT24352648751234", 100);

if (result.Valid) Console.WriteLine("✅ Payment verified!");
```

### Kotlin

```kotlin
val client = ShegerPay("sk_test_xxx")
val result = client.verify("FT24352648751234", 100.0)

if (result.valid) println("✅ Payment verified!")
```

### Swift

```swift
let client = try ShegerPay(apiKey: "sk_test_xxx")
let result = try await client.verify(transactionId: "FT24352648751234", amount: 100)

if result.valid { print("✅ Payment verified!") }
```

### Dart/Flutter

```dart
final client = ShegerPay('sk_test_xxx');
final result = await client.verify('FT24352648751234', 100);

if (result.valid) print('✅ Payment verified!');
```

---

## ✨ Features

- ✅ **Simple API** - 3 lines to verify a payment
- ✅ **Ethiopian Banks** - CBE & Telebirr verification
- ✅ **Auto-detection** - Automatically detects bank from transaction ID
- ✅ **Payment Links** - Create QR codes for customers
- ✅ **Webhooks** - Real-time payment notifications
- ✅ **Telegram Alerts** - Configure Telegram notifications for payments
- ✅ **Monitoring** - Health checks, provider status, API metrics
- ✅ **Error Codes** - Standardized error responses with suggestions
- ✅ **Test Mode** - Simulate payments during development
- ✅ **Type Safety** - Full TypeScript/typing support

---

## 🧪 Test Mode

Use `sk_test_` keys during development:

| Transaction ID | Result     |
| -------------- | ---------- |
| `FT123456`     | ✅ Success |
| `FAIL_TEST`    | ❌ Failure |
| `PENDING_123`  | ⏳ Pending |

---

## 🔐 Webhook Signature Verification

All SDKs include webhook verification:

```python
# Python
from shegerpay import ShegerPay

is_valid = ShegerPay.verify_webhook_signature(
    payload=request.body,
    signature=request.headers['X-ShegerPay-Signature'],
    secret='whsec_xxx'
)
```

```javascript
// JavaScript
const isValid = ShegerPay.verifyWebhookSignature(
  payload,
  req.headers["x-shegerpay-signature"],
  "whsec_xxx"
);
```

---

## � Security Best Practices

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
result = client.verify('FT123456', 100)
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
| `AUTH_001` | Missing API key       | Add `Authorization` header      |
| `AUTH_002` | Invalid API key       | Check key in Dashboard          |
| `TX_001`   | Transaction not found | Verify transaction ID           |
| `TX_002`   | Amount mismatch       | Check expected vs actual amount |
| `PROV_001` | Bank timeout          | Retry after 30 seconds          |
| `SUB_001`  | Limit exceeded        | Upgrade plan                    |

```python
try:
    result = client.verify('FT123', 100)
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
- 💬 [Telegram](https://t.me/shegerpay0)
- 📧 [support@shegerpay.com](mailto:support@shegerpay.com)
- 🐛 [GitHub Issues](https://github.com/black12-ag/ShegerPay/issues)

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Made with ❤️ by ShegerPay**
