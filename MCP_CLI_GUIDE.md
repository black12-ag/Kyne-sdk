# ShegerPay MCP Server & CLI Tool - Complete Guide

## Table of Contents
1. [MCP Server (Model Context Protocol)](#mcp-server)
2. [CLI Tool (Command-Line Interface)](#cli-tool)
3. [Publishing to npm](#publishing-to-npm)
4. [Integration with AI Assistants](#integration-with-ai-assistants)

---

## MCP Server (Model Context Protocol)

### Overview
The ShegerPay MCP Server enables AI assistants like Claude Desktop, Cline, and Vibe Coder to directly interact with ShegerPay's payment gateway through natural language. No coding required!

**Location:** `/mcp/shegerpay-mcp/`

### Features
- 🤖 **40+ AI Tools** - Full API access through natural language
- 🔐 **Secure** - API key-based authentication
- ⚡ **Real-time** - Instant payment verification and crypto prices
- 🎯 **Best for Vibe Coder** - Perfect integration with AI coding assistants

### Installation

#### For End Users

```bash
npm install -g @shegerpay/mcp-server
```

#### For Development

```bash
cd /Users/munirkabir/Desktop/payment/mcp/shegerpay-mcp
npm install
npm run build
```

### Configuration

#### Claude Desktop
Add to `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "shegerpay": {
      "command": "npx",
      "args": ["-y", "@shegerpay/mcp-server"],
      "env": {
        "SHEGERPAY_API_KEY": "sk_test_your_api_key_here"
      }
    }
  }
}
```

#### Cline (VS Code Extension)
Add to Cline MCP settings:

```json
{
  "shegerpay": {
    "command": "npx",
    "args": ["-y", "@shegerpay/mcp-server"],
    "env": {
      "SHEGERPAY_API_KEY": "sk_test_your_api_key_here"
    }
  }
}
```

#### Vibe Coder
Add to Vibe Coder MCP configuration:

```json
{
  "mcpServers": {
    "shegerpay": {
      "command": "npx",
      "args": ["-y", "@shegerpay/mcp-server"],
      "env": {
        "SHEGERPAY_API_KEY": "sk_test_your_api_key_here"
      }
    }
  }
}
```

### Usage Examples

Once configured, interact with ShegerPay using natural language:

**Payment Verification:**
- "Verify transaction FT241227ABC123 for 500 ETB"
- "Show me my payment history from last week"
- "Quick verify this Telebirr payment: TB123456789"

**Crypto Operations:**
- "What's the current USDT price?"
- "Create a crypto payment for $100 in USDT TRC20"
- "Verify crypto transaction 0x123abc..."

**Payment Links:**
- "Create a payment link for 1000 ETB titled 'Product Invoice'"
- "Show analytics for payment link link_abc123"
- "List all my active payment links"

**Account Management:**
- "Show my wallet balances"
- "Generate a new test API key"
- "What's my API usage this month?"

### Available Tools (40+ tools)

#### Core Verification (3 tools)
- `verify_payment` - Verify Ethiopian bank payment
- `quick_verify` - Auto-detect and verify
- `get_payment_history` - Retrieve verification history

#### Crypto (4 tools)
- `get_crypto_prices` - Get all crypto prices
- `get_crypto_price` - Get specific crypto price
- `create_crypto_payment` - Generate crypto payment intent
- `verify_crypto_payment` - Verify blockchain transaction

#### PayPal (5 tools)
- `create_paypal_order` - Create PayPal order
- `capture_paypal_order` - Capture payment
- `refund_payment` - Process refund
- `list_saved_cards` - Get vaulted cards
- `charge_saved_card` - One-click payment

#### Payment Links (4 tools)
- `create_payment_link` - Generate payment link
- `list_payment_links` - List all links
- `get_payment_link_analytics` - Link analytics
- `delete_payment_link` - Delete link

#### Webhooks (4 tools)
- `create_webhook` - Register webhook
- `list_webhooks` - List webhooks
- `test_webhook` - Test endpoint
- `delete_webhook` - Delete webhook

#### Wallets (4 tools)
- `get_wallet_balances` - All balances
- `convert_currency` - Currency conversion
- `request_payout` - Request withdrawal
- `list_payouts` - List payout requests

#### Transactions (2 tools)
- `get_transaction_history` - Complete history
- `export_transactions` - Export to CSV/JSON

#### API Keys (3 tools)
- `generate_api_key` - Create new key
- `list_api_keys` - List all keys
- `revoke_api_key` - Delete key

#### Account (3 tools)
- `get_account_settings` - Account info
- `get_subscription_status` - Plan details
- `get_usage_stats` - Usage metrics

#### Admin (3 tools - requires admin privileges)
- `admin_get_platform_stats` - Platform metrics
- `admin_list_users` - All users
- `admin_approve_payout` - Approve payouts

---

## CLI Tool (Command-Line Interface)

### Overview
Official command-line interface for ShegerPay. Perfect for developers, automation, scripts, and terminal enthusiasts.

**Location:** `/cli/shegerpay-cli/`

### Features
- ⚡ **Fast & Lightweight** - Minimal dependencies
- 🎨 **Beautiful Output** - Colored tables and formatted data
- 📊 **JSON Export** - Machine-readable output with `--json` flag
- 📱 **QR Code Display** - Terminal QR codes for payment links & crypto
- 🔄 **Progress Indicators** - Spinners show operation status

### Installation

#### For End Users

```bash
npm install -g @shegerpay/cli
```

After installation, use `shegerpay` or `sp` command:

```bash
shegerpay --help
sp --help
```

#### For Development

```bash
cd /Users/munirkabir/Desktop/payment/cli/shegerpay-cli
npm install
npm run build
node dist/index.js --help
```

### Configuration

```bash
# Set API key
shegerpay config set sk_test_your_api_key_here

# Or use environment variable
export SHEGERPAY_API_KEY=sk_test_your_api_key_here

# View configuration
shegerpay config get
```

### Command Reference

#### Payment Verification

```bash
# Verify Ethiopian bank payment
shegerpay verify payment FT241227ABC123 --amount 500 --provider cbe

# Quick verify (auto-detect provider)
shegerpay verify quick TB123456789

# Get payment history
shegerpay verify history --limit 20 --status verified
```

#### Cryptocurrency

```bash
# Get current crypto prices
shegerpay crypto prices

# Create crypto payment
shegerpay crypto create -a 100 -c USD --crypto USDT_TRC20

# Verify crypto transaction
shegerpay crypto verify ref_abc123 0x123abc...
```

#### Payment Links

```bash
# Create payment link
shegerpay links create -t "Product Invoice" -a 1000 -c ETB

# List payment links
shegerpay links list --status active

# Get link analytics
shegerpay links analytics link_abc123

# Delete payment link
shegerpay links delete link_abc123
```

#### Webhooks

```bash
# Create webhook
shegerpay webhooks create https://myapp.com/webhook -e payment.verified refund.created

# List webhooks
shegerpay webhooks list

# Test webhook
shegerpay webhooks test https://myapp.com/webhook payment.verified

# Delete webhook
shegerpay webhooks delete webhook_123

# List available events
shegerpay webhooks events
```

#### Wallet Management

```bash
# Get wallet balances
shegerpay wallet balance

# Convert currency
shegerpay wallet convert -f USD -t ETB -a 100
```

#### Transactions

```bash
# List transaction history
shegerpay transactions list --limit 50 --status verified
shegerpay tx list --provider cbe  # Alias
```

#### API Key Management

```bash
# Generate new API key
shegerpay keys generate test --name "Development"

# List all API keys
shegerpay keys list

# Revoke API key
shegerpay keys revoke key_abc123
```

#### Account

```bash
# Get subscription status
shegerpay account subscription

# Get API usage statistics
shegerpay account usage
```

#### Payouts

```bash
# Request payout
shegerpay payouts request -a 5000 -c ETB -d dest_123 -m bank

# List payouts
shegerpay payouts list --status pending
```

### Global Options

```bash
-j, --json    Output results as JSON (available on most commands)
-h, --help    Display help for command
-V, --version Display version number
```

---

## Publishing to npm

### Prerequisites

1. **npm Account**: Create an account at [npmjs.com](https://www.npmjs.com)
2. **npm Login**: Run `npm login` and enter your credentials
3. **Organization**: Create `@shegerpay` organization on npm (or use your own)

### Publishing MCP Server

```bash
cd /Users/munirkabir/Desktop/payment/mcp/shegerpay-mcp

# Build the project
npm run build

# Test locally
npm link
# Test in another terminal: npx @shegerpay/mcp-server

# Publish to npm
npm publish --access public

# For updates
npm version patch  # or minor, major
npm publish
```

### Publishing CLI Tool

```bash
cd /Users/munirkabir/Desktop/payment/cli/shegerpay-cli

# Build the project
npm run build

# Test locally
npm link
shegerpay --help

# Publish to npm
npm publish --access public

# For updates
npm version patch  # or minor, major
npm publish
```

### Package Naming

**MCP Server:**
- Package name: `@shegerpay/mcp-server`
- Binary: `shegerpay-mcp`
- Repository: https://github.com/shegerpay/shegerpay-mcp

**CLI Tool:**
- Package name: `@shegerpay/cli`
- Binary: `shegerpay` and `sp`
- Repository: https://github.com/shegerpay/shegerpay-cli

---

## Integration with AI Assistants

### Vibe Coder (Recommended)

Vibe Coder provides the best integration experience with MCP servers.

1. Install Vibe Coder
2. Configure MCP server in Vibe Coder settings
3. Restart Vibe Coder
4. Start using natural language commands!

### Claude Desktop

Claude Desktop is the official desktop app from Anthropic.

1. Download Claude Desktop from [claude.ai](https://claude.ai)
2. Add configuration to `claude_desktop_config.json`
3. Restart Claude Desktop
4. The ShegerPay tools will appear in the tools menu

### Cline (VS Code)

Cline is a powerful AI coding assistant extension for VS Code.

1. Install Cline extension from VS Code marketplace
2. Configure MCP servers in Cline settings
3. Reload VS Code
4. Access ShegerPay through Cline's command palette

---

## Troubleshooting

### MCP Server Issues

**"SHEGERPAY_API_KEY environment variable is required"**
- Solution: Add `SHEGERPAY_API_KEY` to your MCP configuration

**"ShegerPay API Error: Unauthorized"**
- Solution: Check your API key is valid and not revoked
- Generate a new key at https://shegerpay.com/dashboard/settings/api-keys

**"Cannot find module '@shegerpay/mcp-server'"**
- Solution: Run `npm install -g @shegerpay/mcp-server` or wait for npm to sync

### CLI Tool Issues

**"Error: No API key configured"**
- Solution: Run `shegerpay config set sk_test_your_key`
- Or set environment variable: `export SHEGERPAY_API_KEY=sk_test_your_key`

**"command not found: shegerpay"**
- Solution: Reinstall globally: `npm install -g @shegerpay/cli`
- Or check npm global bin path: `npm config get prefix`

**"Connection Error"**
- Solution: Check internet connection
- Verify API URL: `shegerpay config get`

---

## Support

- **Documentation**: [shegerpay.com/docs](https://shegerpay.com/docs)
- **Email**: support@shegerpay.com
- **Telegram**: [@shegerpay0](https://t.me/shegerpay0)
- **Telegram Channel**: [@shegerPa](https://t.me/shegerPa)
- **GitHub Issues**:
  - MCP Server: https://github.com/shegerpay/shegerpay-mcp/issues
  - CLI Tool: https://github.com/shegerpay/shegerpay-cli/issues

---

## License

Both the MCP Server and CLI Tool are licensed under MIT License.

**Made with ❤️ by the ShegerPay Team**
