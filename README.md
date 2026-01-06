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

## 📦 Supported Languages (10)

| Language         | Package             | Installation                                    | Status   |
| ---------------- | ------------------- | ----------------------------------------------- | -------- |
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

## 📚 Documentation

| Doc                                               | Description                    |
| ------------------------------------------------- | ------------------------------ |
| [Integration Guide](../docs/INTEGRATION_GUIDE.md) | 5-minute quick start           |
| [API Reference](../docs/API_REFERENCE.md)         | Complete API documentation     |
| [Ethiopian Flow](../docs/FLOW_ETHIOPIAN.md)       | CBE/Telebirr verification flow |

---

## 🆘 Support

- 📖 [Documentation](https://shegerpay.com/docs)
- 💬 [Discord](https://discord.gg/shegerpay)
- 📧 [support@shegerpay.com](mailto:support@shegerpay.com)
- 🐛 [GitHub Issues](https://github.com/black12-ag/ShegerPay-sdk/issues)

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Made with ❤️ by ShegerPay**
