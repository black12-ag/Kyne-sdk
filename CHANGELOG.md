# ShegerPay SDK Changelog

All SDKs follow semantic versioning. Breaking changes increment the major version.

## [2.2.0] — 2026-05-12

### Added
- `verifyImage()` — verify payment from receipt screenshot (base64 or URL) across all SDKs
- `getProviders()` — list supported payment providers and their status
- Payment links API (`createPaymentLink`, `listPaymentLinks`, `deletePaymentLink`) now in all SDKs
- Webhook helpers (`createWebhook`, `listWebhooks`, `deleteWebhook`, `testWebhook`) in Python + PHP
- `verifyWebhookSignature()` static method for HMAC verification in all SDKs
- **WordPress/WooCommerce plugin** — `sdk/wordpress/shegerpay-woocommerce/`

### Changed
- `amount` is now optional in `verify()` and `quickVerify()` across all SDKs — useful for lookup-only checks
- Consistent versioning across all SDKs (all now at 2.2.0)
- PHP SDK: amount no longer throws ValidationException when omitted

### Fixed
- `proxy/verify.php`: secret key now loaded from `SHEGERPAY_PROXY_KEY` env var instead of hardcoded

---

## [2.1.0] — 2026-04-01

### Added
- Crypto payment support (USDT TRC-20, BEP-20)
- PayPal subscription and wallet APIs (Python, PHP, TypeScript)
- Multi-currency wallet
- Refunds and disputes API

---

## [2.0.0] — 2026-01-15

### Added
- Payment links API
- Webhook management
- OCR/image verification (Python, TypeScript)
- Android and iOS native SDKs

---

## [1.0.0] — 2025-10-01

### Added
- Initial release: verify, quickVerify, history
- Ethiopian bank support: CBE, Telebirr, BOA, Awash
