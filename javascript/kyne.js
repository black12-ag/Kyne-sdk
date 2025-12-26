/**
 * Kyne JavaScript SDK
 * Official JavaScript/Node.js SDK for Kyne Payment Verification Gateway
 */

class KyneError extends Error {
    constructor(message, statusCode = null) {
        super(message);
        this.name = 'KyneError';
        this.statusCode = statusCode;
    }
}

class AuthenticationError extends KyneError {
    constructor(message) {
        super(message, 401);
        this.name = 'AuthenticationError';
    }
}

class ValidationError extends KyneError {
    constructor(message) {
        super(message, 400);
        this.name = 'ValidationError';
    }
}

class Kyne {
    /**
     * Create a Kyne client
     * @param {string} apiKey - Your secret API key (sk_test_xxx or sk_live_xxx)
     * @param {Object} options - Optional configuration
     * @param {string} options.baseUrl - Custom API base URL
     * @param {number} options.timeout - Request timeout in milliseconds
     */
    constructor(apiKey, options = {}) {
        if (!apiKey) {
            throw new AuthenticationError('API key is required');
        }
        
        if (!apiKey.startsWith('sk_test_') && !apiKey.startsWith('sk_live_')) {
            throw new AuthenticationError('Invalid API key format. Must start with sk_test_ or sk_live_');
        }
        
        this.apiKey = apiKey;
        this.baseUrl = (options.baseUrl || 'https://api.kyne.com').replace(/\/$/, '');
        this.timeout = options.timeout || 30000;
        this.mode = apiKey.startsWith('sk_test_') ? 'test' : 'live';
    }
    
    /**
     * Verify a payment transaction
     * @param {Object} params - Verification parameters
     * @param {string} params.transactionId - Bank transaction reference
     * @param {number} params.amount - Expected amount in ETB
     * @param {string} [params.provider] - Payment provider (cbe, telebirr). Auto-detected if not provided.
     * @param {string} [params.merchantName] - Your registered bank account name
     * @returns {Promise<Object>} Verification result
     * 
     * @example
     * const result = await client.verify({
     *     transactionId: 'FT24352648751234',
     *     amount: 100,
     *     provider: 'cbe'
     * });
     */
    async verify(params) {
        const { transactionId, amount, provider, merchantName, subProvider } = params;
        
        if (!transactionId) {
            throw new ValidationError('transactionId is required');
        }
        if (!amount) {
            throw new ValidationError('amount is required');
        }
        
        // Auto-detect provider
        let detectedProvider = provider;
        if (!detectedProvider) {
            detectedProvider = transactionId.toUpperCase().startsWith('FT') ? 'cbe' : 'telebirr';
        }
        
        const data = new URLSearchParams();
        data.append('provider', detectedProvider);
        data.append('transaction_id', transactionId);
        data.append('amount', amount.toString());
        data.append('merchant_name', merchantName || 'Kyne Verification');
        
        if (subProvider) {
            data.append('sub_provider', subProvider);
        }
        
        return this._request('POST', '/api/v1/verify', data);
    }
    
    /**
     * Quick verification with auto-detected provider
     * @param {string} transactionId - Bank transaction reference
     * @param {number} amount - Expected amount
     * @returns {Promise<Object>} Verification result
     */
    async quickVerify(transactionId, amount) {
        const data = new URLSearchParams();
        data.append('transaction_id', transactionId);
        data.append('amount', amount.toString());
        
        return this._request('POST', '/api/v1/quick-verify', data);
    }
    
    /**
     * Get transaction history
     * @param {number} [limit=50] - Maximum number of transactions
     * @returns {Promise<Array>} List of transactions
     */
    async getHistory(limit = 50) {
        return this._request('GET', '/api/v1/history');
    }
    
    /**
     * Create a webhook endpoint
     * @param {Object} params - Webhook parameters
     * @param {string} params.url - Webhook URL
     * @param {Array<string>} params.events - Events to subscribe to
     * @returns {Promise<Object>} Created webhook with secret
     */
    async createWebhook(params) {
        const { url, events } = params;
        
        if (!url) {
            throw new ValidationError('url is required');
        }
        if (!events || events.length === 0) {
            throw new ValidationError('events are required');
        }
        
        return this._request('POST', '/api/v1/webhooks/', {
            url,
            events
        }, true);
    }
    
    /**
     * List all webhooks
     * @returns {Promise<Array>} List of webhooks
     */
    async listWebhooks() {
        return this._request('GET', '/api/v1/webhooks/');
    }
    
    /**
     * Delete a webhook
     * @param {string} webhookId - Webhook ID to delete
     * @returns {Promise<Object>} Deletion result
     */
    async deleteWebhook(webhookId) {
        return this._request('DELETE', `/api/v1/webhooks/${webhookId}`);
    }
    
    /**
     * Internal request method
     */
    async _request(method, path, data = null, isJson = false) {
        const url = `${this.baseUrl}${path}`;
        
        const headers = {
            'Authorization': `Bearer ${this.apiKey}`,
            'User-Agent': 'Kyne-JavaScript-SDK/1.0'
        };
        
        const options = {
            method,
            headers
        };
        
        if (data) {
            if (isJson) {
                headers['Content-Type'] = 'application/json';
                options.body = JSON.stringify(data);
            } else {
                headers['Content-Type'] = 'application/x-www-form-urlencoded';
                options.body = data.toString();
            }
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
                throw new ValidationError(error.detail || 'Validation error');
            }
            
            if (response.status >= 500) {
                throw new KyneError('Server error', response.status);
            }
            
            return response.json();
            
        } catch (error) {
            if (error.name === 'AbortError') {
                throw new KyneError('Request timed out');
            }
            if (error instanceof KyneError) {
                throw error;
            }
            throw new KyneError(`Request failed: ${error.message}`);
        }
    }
}

/**
 * Verify webhook signature
 * @param {string} payload - Raw request body
 * @param {string} signature - X-Kyne-Signature header value
 * @param {string} secret - Your webhook secret
 * @returns {boolean} Whether signature is valid
 */
async function verifyWebhookSignature(payload, signature, secret) {
    // For Node.js
    if (typeof require !== 'undefined') {
        const crypto = require('crypto');
        const expected = crypto
            .createHmac('sha256', secret)
            .update(payload)
            .digest('hex');
        return `sha256=${expected}` === signature;
    }
    
    // For browser with Web Crypto API
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

// Export for different module systems
if (typeof module !== 'undefined' && module.exports) {
    // CommonJS
    module.exports = { Kyne, KyneError, AuthenticationError, ValidationError, verifyWebhookSignature };
} else if (typeof window !== 'undefined') {
    // Browser
    window.Kyne = Kyne;
    window.verifyWebhookSignature = verifyWebhookSignature;
}

// ES Modules
export { Kyne, KyneError, AuthenticationError, ValidationError, verifyWebhookSignature };
export default Kyne;
