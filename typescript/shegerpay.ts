/**
 * ShegerPay TypeScript SDK
 * Official TypeScript/JavaScript SDK for ShegerPay Payment Verification Gateway
 * 
 * @example
 * import { ShegerPay } from '@shegerpay/sdk';
 * 
 * const client = new ShegerPay('sk_test_xxx');
 * const result = await client.verify({ transactionId: 'FT123456', amount: 100 });
 */

// ============================================
// Types & Interfaces
// ============================================

export interface ShegerPayConfig {
  apiKey: string;
  baseUrl?: string;
  timeout?: number;
}

export interface VerifyParams {
  transactionId: string;
  amount: number;
  provider?: 'cbe' | 'telebirr' | 'awash' | 'boa' | 'ebirr_kaafi' | 'ebirr_coop';
  merchantName?: string;
}

export interface VerificationResult {
  valid: boolean;
  status: 'verified' | 'failed' | 'pending' | 'error';
  provider?: string;
  transactionId?: string;
  amount?: number;
  payer?: string;
  receiver?: string;
  mode: 'test' | 'live';
  errorCode?: string;
  message?: string;
  suggestion?: string;
}

export interface PaymentLinkParams {
  title: string;
  amount: number;
  currency?: 'ETB' | 'USD';
  description?: string;
  enableCbe?: boolean;
  enableTelebirr?: boolean;
  enableCrypto?: boolean;
  expiresInHours?: number;
}

export interface PaymentLink {
  id: string;
  shortCode: string;
  url: string;
  qrCode: string;
  title: string;
  amount: number;
  currency: string;
  status: 'active' | 'inactive' | 'expired';
}

export interface WebhookParams {
  url: string;
  events: string[];
  secret?: string;
}

export interface Webhook {
  id: string;
  url: string;
  events: string[];
  secret: string;
  createdAt: string;
}

export interface CryptoPaymentParams {
  amountUsd: number;
  currency: 'USDT' | 'BTC' | 'ETH' | 'TRX';
  walletAddress: string;
  chain?: 'TRON' | 'ETH' | 'BSC' | 'BTC';
}

export interface CryptoPayment {
  referenceId: string;
  paymentAmount: string;
  currency: string;
  walletAddress: string;
  qrCode: string;
  expiresAt: string;
}

export interface TelegramConfig {
  botToken: string;
  chatId: string;
  notifyOnPayment?: boolean;
  notifyOnSecurity?: boolean;
}

export interface HealthStatus {
  status: 'healthy' | 'degraded' | 'unhealthy';
  version: string;
  timestamp: string;
  services: Record<string, string>;
  providers: Record<string, string>;
  encryption: {
    atRest: string;
    inTransit: string;
    apiKeys: string;
  };
}

export interface ProviderStatus {
  overallStatus: 'operational' | 'partial_outage' | 'major_outage';
  providersOnline: string;
  updatedAt: string;
  providers: Array<{
    id: string;
    name: string;
    status: 'online' | 'offline';
    avgResponseMs: number;
    successRate: number;
    lastSuccess: string;
  }>;
}

// ============================================
// Error Classes
// ============================================

export class ShegerPayError extends Error {
  statusCode: number;
  errorCode?: string;
  suggestion?: string;

  constructor(message: string, statusCode: number = 400, errorCode?: string, suggestion?: string) {
    super(message);
    this.name = 'ShegerPayError';
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.suggestion = suggestion;
  }
}

export class AuthenticationError extends ShegerPayError {
  constructor(message: string = 'Invalid API key') {
    super(message, 401, 'AUTH_002');
    this.name = 'AuthenticationError';
  }
}

export class ValidationError extends ShegerPayError {
  constructor(message: string) {
    super(message, 400, 'VAL_001');
    this.name = 'ValidationError';
  }
}

// ============================================
// Main Client
// ============================================

export class ShegerPay {
  private apiKey: string;
  private baseUrl: string;
  private timeout: number;
  readonly mode: 'test' | 'live';

  constructor(apiKey: string, config?: Partial<ShegerPayConfig>) {
    if (!apiKey) {
      throw new AuthenticationError('API key is required');
    }
    
    if (!apiKey.startsWith('sk_test_') && !apiKey.startsWith('sk_live_')) {
      throw new AuthenticationError('Invalid API key format. Must start with sk_test_ or sk_live_');
    }

    this.apiKey = apiKey;
    this.baseUrl = (config?.baseUrl || 'https://api.shegerpay.com').replace(/\/$/, '');
    this.timeout = config?.timeout || 30000;
    this.mode = apiKey.startsWith('sk_test_') ? 'test' : 'live';
  }

  // ============================================
  // Ethiopian Payment Verification
  // ============================================

  /**
   * Verify a payment transaction
   */
  async verify(params: VerifyParams): Promise<VerificationResult> {
    const { transactionId, amount, provider, merchantName } = params;
    
    if (!transactionId) throw new ValidationError('transactionId is required');
    if (!amount) throw new ValidationError('amount is required');
    
    // Auto-detect provider
    const detectedProvider = provider || (transactionId.toUpperCase().startsWith('FT') ? 'cbe' : 'telebirr');
    
    return this.request<VerificationResult>('POST', '/api/v1/verify', {
      provider: detectedProvider,
      transaction_id: transactionId,
      amount,
      merchant_name: merchantName || 'ShegerPay Verification'
    });
  }

  /**
   * Quick verification with auto-detected provider
   */
  async quickVerify(transactionId: string, amount: number): Promise<VerificationResult> {
    return this.request<VerificationResult>('POST', '/api/v1/quick-verify', {
      transaction_id: transactionId,
      amount
    });
  }

  // ============================================
  // Payment Links
  // ============================================

  /**
   * Create a payment link
   */
  async createPaymentLink(params: PaymentLinkParams): Promise<PaymentLink> {
    const { title, amount, currency, description, enableCbe, enableTelebirr, enableCrypto, expiresInHours } = params;
    
    if (!title) throw new ValidationError('title is required');
    if (!amount) throw new ValidationError('amount is required');
    
    return this.request<PaymentLink>('POST', '/api/v1/payment-links/', {
      title,
      amount,
      currency: currency || 'ETB',
      description,
      enable_cbe: enableCbe !== false,
      enable_telebirr: enableTelebirr !== false,
      enable_crypto: enableCrypto || false,
      expires_in_hours: expiresInHours || 24
    });
  }

  /**
   * List all payment links
   */
  async listPaymentLinks(): Promise<PaymentLink[]> {
    const response = await this.request<{ links: PaymentLink[] }>('GET', '/api/v1/payment-links/');
    return response.links || [];
  }

  /**
   * Delete a payment link
   */
  async deletePaymentLink(linkId: string): Promise<{ success: boolean }> {
    return this.request('DELETE', `/api/v1/payment-links/${linkId}`);
  }

  // ============================================
  // Webhooks
  // ============================================

  /**
   * Create a webhook endpoint
   */
  async createWebhook(params: WebhookParams): Promise<Webhook> {
    const { url, events } = params;
    
    if (!url) throw new ValidationError('url is required');
    if (!events || events.length === 0) throw new ValidationError('events are required');
    
    return this.request<Webhook>('POST', '/api/v1/webhooks/', { url, events });
  }

  /**
   * List all webhooks
   */
  async listWebhooks(): Promise<Webhook[]> {
    return this.request<Webhook[]>('GET', '/api/v1/webhooks/');
  }

  /**
   * Delete a webhook
   */
  async deleteWebhook(webhookId: string): Promise<{ success: boolean }> {
    return this.request('DELETE', `/api/v1/webhooks/${webhookId}`);
  }

  /**
   * Test a webhook
   */
  async testWebhook(webhookId: string): Promise<{ success: boolean; statusCode: number }> {
    return this.request('POST', '/api/v1/webhooks/test', { webhook_id: webhookId });
  }

  // ============================================
  // Crypto Payments
  // ============================================

  /**
   * Get crypto prices
   */
  async getCryptoPrices(symbol?: string): Promise<Record<string, number>> {
    if (symbol) {
      return this.request('GET', `/api/v1/crypto/rate/${symbol.toUpperCase()}`);
    }
    return this.request('GET', '/api/v1/crypto/rates');
  }

  /**
   * Create a crypto payment intent
   */
  async createCryptoPayment(params: CryptoPaymentParams): Promise<CryptoPayment> {
    const { amountUsd, currency, walletAddress, chain } = params;
    
    if (!amountUsd) throw new ValidationError('amountUsd is required');
    if (!currency) throw new ValidationError('currency is required');
    if (!walletAddress) throw new ValidationError('walletAddress is required');
    
    return this.request<CryptoPayment>('POST', '/api/v1/crypto/generate-intent', {
      amount_usd: amountUsd,
      currency: currency.toUpperCase(),
      wallet_address: walletAddress,
      chain: chain || 'TRON'
    });
  }

  /**
   * Verify a crypto payment
   */
  async verifyCryptoPayment(referenceId: string, transactionHash?: string): Promise<VerificationResult> {
    if (!referenceId) throw new ValidationError('referenceId is required');
    
    return this.request<VerificationResult>('POST', '/api/v1/crypto/verify-reference', {
      reference_id: referenceId,
      transaction_hash: transactionHash
    });
  }

  // ============================================
  // Monitoring & Health
  // ============================================

  /**
   * Get detailed API health status
   */
  async getHealth(): Promise<HealthStatus> {
    return this.request<HealthStatus>('GET', '/api/v1/monitoring/health');
  }

  /**
   * Get provider status and uptime
   */
  async getProviderStatus(): Promise<ProviderStatus> {
    return this.request<ProviderStatus>('GET', '/api/v1/monitoring/providers');
  }

  /**
   * Get API usage metrics
   */
  async getMetrics(): Promise<Record<string, any>> {
    return this.request('GET', '/api/v1/monitoring/metrics');
  }

  /**
   * Get system uptime data
   */
  async getUptime(): Promise<Record<string, any>> {
    return this.request('GET', '/api/v1/monitoring/uptime');
  }

  // ============================================
  // Notifications
  // ============================================

  /**
   * Get notification settings
   */
  async getNotificationSettings(): Promise<Record<string, any>> {
    return this.request('GET', '/api/v1/notifications/settings');
  }

  /**
   * Configure Telegram notifications
   */
  async configureTelegram(config: TelegramConfig): Promise<{ success: boolean; testSent: boolean }> {
    const { botToken, chatId, notifyOnPayment, notifyOnSecurity } = config;
    
    if (!botToken) throw new ValidationError('botToken is required');
    if (!chatId) throw new ValidationError('chatId is required');
    
    return this.request('POST', '/api/v1/notifications/telegram/configure', {
      bot_token: botToken,
      chat_id: chatId,
      notify_on_payment: notifyOnPayment !== false,
      notify_on_security: notifyOnSecurity !== false
    });
  }

  /**
   * Send test Telegram notification
   */
  async testTelegram(): Promise<{ success: boolean; message: string }> {
    return this.request('POST', '/api/v1/notifications/telegram/test', {});
  }

  /**
   * Disable Telegram notifications
   */
  async disableTelegram(): Promise<{ success: boolean }> {
    return this.request('DELETE', '/api/v1/notifications/telegram');
  }

  // ============================================
  // Wallet & Transactions
  // ============================================

  /**
   * Get wallet balances
   */
  async getWalletBalance(): Promise<Record<string, number>> {
    return this.request('GET', '/api/v1/wallets/balances');
  }

  /**
   * Get transaction history
   */
  async listTransactions(filters?: { status?: string; provider?: string; limit?: number }): Promise<any[]> {
    const params = new URLSearchParams(filters as any).toString();
    return this.request('GET', `/api/v1/transactions/history${params ? '?' + params : ''}`);
  }

  /**
   * Get current subscription
   */
  async getSubscription(): Promise<Record<string, any>> {
    return this.request('GET', '/api/v1/subscriptions/current');
  }

  /**
   * Get API usage stats
   */
  async getUsage(): Promise<Record<string, any>> {
    return this.request('GET', '/api/v1/subscriptions/usage');
  }

  // ============================================
  // Internal Request Method
  // ============================================

  private async request<T>(method: string, path: string, body?: Record<string, any>): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    
    const headers: Record<string, string> = {
      'Authorization': `Bearer ${this.apiKey}`,
      'Content-Type': 'application/json',
      'User-Agent': 'ShegerPay-TypeScript-SDK/1.0'
    };

    const options: RequestInit = {
      method,
      headers
    };

    if (body && method !== 'GET') {
      options.body = JSON.stringify(body);
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.timeout);

      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (response.status === 401) {
        throw new AuthenticationError('Invalid API key');
      }

      if (response.status === 400) {
        const error = await response.json();
        throw new ValidationError(error.detail || error.message || 'Validation error');
      }

      if (response.status >= 500) {
        throw new ShegerPayError('Server error', response.status, 'GEN_001');
      }

      return response.json() as Promise<T>;
    } catch (error: any) {
      if (error.name === 'AbortError') {
        throw new ShegerPayError('Request timed out', 408, 'GEN_002');
      }
      if (error instanceof ShegerPayError) {
        throw error;
      }
      throw new ShegerPayError(`Request failed: ${error.message}`, 500);
    }
  }
}

// ============================================
// Webhook Verification Helper
// ============================================

/**
 * Verify webhook signature
 */
export async function verifyWebhookSignature(
  payload: string,
  signature: string,
  secret: string
): Promise<boolean> {
  // Node.js environment
  if (typeof require !== 'undefined') {
    const crypto = require('crypto');
    const expected = crypto
      .createHmac('sha256', secret)
      .update(payload)
      .digest('hex');
    return `sha256=${expected}` === signature;
  }

  // Browser with Web Crypto API
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secret);
  const data = encoder.encode(payload);

  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const signatureBuffer = await crypto.subtle.sign('HMAC', key, data);
  const expected = Array.from(new Uint8Array(signatureBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');

  return `sha256=${expected}` === signature;
}

// ============================================
// Exports
// ============================================

export default ShegerPay;
