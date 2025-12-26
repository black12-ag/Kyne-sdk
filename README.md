# Kyne SDK

Official SDKs for integrating Kyne Payment Verification into your applications.

![Kyne](https://img.shields.io/badge/Kyne-Payment%20Gateway-purple)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## 🚀 Quick Start

Choose your language and start verifying payments in minutes:

### Python

```bash
pip install kyne
```

```python
from kyne import Kyne

client = Kyne(api_key="sk_test_xxx")
result = client.verify(
    transaction_id="FT24352648751234",
    amount=100,
    provider="cbe"
)

if result.valid:
    print("✅ Payment verified!")
```

### JavaScript/Node.js

```bash
npm install @kyne/sdk
```

```javascript
const Kyne = require("@kyne/sdk");

const client = new Kyne("sk_test_xxx");
const result = await client.verify({
  transactionId: "FT24352648751234",
  amount: 100,
});

if (result.valid) {
  console.log("✅ Payment verified!");
}
```

### PHP

```bash
composer require kyne/sdk
```

```php
require_once 'vendor/autoload.php';

$client = new Kyne\Kyne('sk_test_xxx');
$result = $client->verify([
    'transaction_id' => 'FT24352648751234',
    'amount' => 100
]);

if ($result->valid) {
    echo '✅ Payment verified!';
}
```

### Ruby

```bash
gem install kyne
```

```ruby
require 'kyne'

client = Kyne::Client.new('sk_test_xxx')
result = client.verify(
    transaction_id: 'FT24352648751234',
    amount: 100
)

puts '✅ Payment verified!' if result.valid?
```

### Go

```bash
go get github.com/black12-ag/kyne-sdk/go
```

```go
import "github.com/black12-ag/kyne-sdk/go"

client, _ := kyne.NewClient("sk_test_xxx")
result, _ := client.Verify(kyne.VerifyParams{
    TransactionID: "FT24352648751234",
    Amount:        100,
})

if result.Valid {
    fmt.Println("✅ Payment verified!")
}
```

---

## 📦 Supported Languages

| Language   | Package     | Status         | Installation                               |
| ---------- | ----------- | -------------- | ------------------------------------------ |
| Python     | `kyne`      | ✅ Ready       | `pip install kyne`                         |
| JavaScript | `@kyne/sdk` | ✅ Ready       | `npm install @kyne/sdk`                    |
| PHP        | `kyne/sdk`  | ✅ Ready       | `composer require kyne/sdk`                |
| Ruby       | `kyne`      | ✅ Ready       | `gem install kyne`                         |
| Go         | `kyne`      | ✅ Ready       | `go get github.com/black12-ag/kyne-sdk/go` |
| Java       | `kyne`      | 🚧 Coming Soon | -                                          |
| C#         | `Kyne`      | 🚧 Coming Soon | -                                          |

---

## ✨ Features

- ✅ **Simple API**: 3 lines of code to verify a payment
- ✅ **Ethiopian Banks**: CBE, Telebirr verification
- ✅ **Auto-detection**: Automatically detects CBE/Telebirr from transaction ID
- ✅ **Test Mode**: Simulate payments during development
- ✅ **Webhooks**: Built-in signature verification
- ✅ **Type Safety**: Full TypeScript/typing support
- ✅ **Error Handling**: Clear, actionable error messages

---

## 🧪 Test Mode

Use test keys (`sk_test_xxx`) during development:

| Transaction ID Contains | Result               |
| ----------------------- | -------------------- |
| Normal ID               | ✅ Success           |
| `FAIL` anywhere         | ❌ Simulated failure |
| `PENDING` anywhere      | ⏳ Simulated pending |

**Example:**

```python
# This will succeed
result = client.quick_verify("FT123456789", 100)

# This will fail
result = client.quick_verify("FAIL_TEST_123", 100)
```

---

## 🔐 Webhook Signature Verification

Verify webhook signatures to ensure they're from Kyne:

### Python

```python
import hmac
import hashlib

def verify_signature(payload, signature, secret):
    expected = hmac.new(
        secret.encode(),
        payload.encode(),
        hashlib.sha256
    ).hexdigest()
    return f"sha256={expected}" == signature
```

### JavaScript

```javascript
const crypto = require("crypto");

function verifySignature(payload, signature, secret) {
  const expected = crypto
    .createHmac("sha256", secret)
    .update(payload)
    .digest("hex");
  return `sha256=${expected}` === signature;
}
```

### PHP

```php
function verifySignature($payload, $signature, $secret) {
    $expected = 'sha256=' . hash_hmac('sha256', $payload, $secret);
    return hash_equals($expected, $signature);
}
```

---

## 📚 Documentation

- [Quick Start Guide](https://kyne.com/docs)
- [API Reference](https://kyne.com/docs#verification)
- [Webhook Setup](https://kyne.com/docs#webhooks)
- [Ethiopian Payment Flow](./docs/FLOW_ETHIOPIAN.md)

---

## 🛠️ API Methods

### `verify(params)`

Full verification with all options.

### `quickVerify(transactionId, amount)`

Auto-detect provider and verify with minimal params.

### `getHistory()`

Get your transaction history.

### `createWebhook(url, events)`

Create a webhook endpoint.

---

## 🆘 Support

- 📖 [Documentation](https://kyne.com/docs)
- 💬 [Discord Community](https://discord.gg/kyne)
- 📧 [support@kyne.com](mailto:support@kyne.com)
- 🐛 [GitHub Issues](https://github.com/black12-ag/Kyne-sdk/issues)

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Made with ❤️ by Kyne**
