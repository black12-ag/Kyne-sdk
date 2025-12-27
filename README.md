# Kyne SDK

Official SDKs for integrating Kyne Payment Verification into your applications.

![Kyne](https://img.shields.io/badge/Kyne-Payment%20Gateway-purple)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Languages](https://img.shields.io/badge/Languages-10-orange)

## 🚀 Quick Start

**3 lines to verify a payment:**

```python
from kyne import Kyne

client = Kyne(api_key="sk_test_xxx")
result = client.verify("FT24352648751234", 100)  # ✅ Done!
```

---

## 📦 Supported Languages (10)

| Language         | Package        | Installation                               | Status   |
| ---------------- | -------------- | ------------------------------------------ | -------- |
| **Python**       | `kyne`         | `pip install kyne`                         | ✅ Ready |
| **JavaScript**   | `@kyne/sdk`    | `npm install @kyne/sdk`                    | ✅ Ready |
| **PHP**          | `kyne/sdk`     | `composer require kyne/sdk`                | ✅ Ready |
| **Ruby**         | `kyne`         | `gem install kyne`                         | ✅ Ready |
| **Go**           | `kyne`         | `go get github.com/black12-ag/kyne-sdk/go` | ✅ Ready |
| **Java**         | `com.kyne:sdk` | Maven                                      | ✅ Ready |
| **C#**           | `Kyne.SDK`     | `dotnet add package Kyne.SDK`              | ✅ Ready |
| **Kotlin**       | `com.kyne:sdk` | Gradle                                     | ✅ Ready |
| **Swift**        | `Kyne`         | Swift Package Manager                      | ✅ Ready |
| **Dart/Flutter** | `kyne`         | `dart pub add kyne`                        | ✅ Ready |

---

## 💻 Code Examples

### Python

```python
from kyne import Kyne

client = Kyne(api_key="sk_test_xxx")
result = client.verify(transaction_id="FT24352648751234", amount=100)

if result.valid:
    print("✅ Payment verified!")
```

### JavaScript/Node.js

```javascript
const Kyne = require("@kyne/sdk");

const client = new Kyne("sk_test_xxx");
const result = await client.verify({
  transactionId: "FT24352648751234",
  amount: 100,
});

if (result.valid) console.log("✅ Payment verified!");
```

### PHP

```php
$client = new Kyne\Kyne('sk_test_xxx');
$result = $client->verify([
    'transaction_id' => 'FT24352648751234',
    'amount' => 100
]);

if ($result->valid) echo '✅ Payment verified!';
```

### Ruby

```ruby
client = Kyne::Client.new('sk_test_xxx')
result = client.verify(transaction_id: 'FT24352648751234', amount: 100)

puts '✅ Payment verified!' if result.valid?
```

### Go

```go
client, _ := kyne.NewClient("sk_test_xxx")
result, _ := client.Verify(kyne.VerifyParams{
    TransactionID: "FT24352648751234",
    Amount: 100,
})

if result.Valid {
    fmt.Println("✅ Payment verified!")
}
```

### Java

```java
Kyne client = new Kyne("sk_test_xxx");
VerificationResult result = client.verify("FT24352648751234", 100);

if (result.isValid()) {
    System.out.println("✅ Payment verified!");
}
```

### C#

```csharp
using Kyne.SDK;

var client = new KyneClient("sk_test_xxx");
var result = await client.VerifyAsync("FT24352648751234", 100);

if (result.Valid) Console.WriteLine("✅ Payment verified!");
```

### Kotlin

```kotlin
val client = Kyne("sk_test_xxx")
val result = client.verify("FT24352648751234", 100.0)

if (result.valid) println("✅ Payment verified!")
```

### Swift

```swift
let client = try Kyne(apiKey: "sk_test_xxx")
let result = try await client.verify(transactionId: "FT24352648751234", amount: 100)

if result.valid { print("✅ Payment verified!") }
```

### Dart/Flutter

```dart
final client = Kyne('sk_test_xxx');
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
from kyne import Kyne

is_valid = Kyne.verify_webhook_signature(
    payload=request.body,
    signature=request.headers['X-Kyne-Signature'],
    secret='whsec_xxx'
)
```

```javascript
// JavaScript
const isValid = Kyne.verifyWebhookSignature(
  payload,
  req.headers["x-kyne-signature"],
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

- 📖 [Documentation](https://kyne.com/docs)
- 💬 [Discord](https://discord.gg/kyne)
- 📧 [support@kyne.com](mailto:support@kyne.com)
- 🐛 [GitHub Issues](https://github.com/black12-ag/Kyne-sdk/issues)

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Made with ❤️ by Kyne**
