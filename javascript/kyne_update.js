class KyneSDK {
    constructor(apiClient) {
        this.apiClient = apiClient;
    }

    _request(method, url, data = null, auth = true) {
        return this.apiClient.request(method, url, data, auth);
    }

    // ============================================
    // MULTI-CURRENCY WALLET METHODS
    // ============================================

    /**
     * Get multi-currency wallet balances
     * @returns {Promise<Object>} Wallet balances
     */
    async getWalletBalance() {
        return this._request('GET', '/api/v1/wallets/balances');
    }

    /**
     * Convert currency within wallet
     * @param {Object} params - Conversion parameters
     * @param {string} params.fromCurrency - Source currency code
     * @param {string} params.toCurrency - Target currency code
     * @param {number} params.amount - Amount to convert
     * @returns {Promise<Object>} Conversion result
     */
    async convertCurrency(params) {
        const { fromCurrency, toCurrency, amount } = params;
        return this._request('POST', '/api/v1/wallets/convert', {
            from_currency: fromCurrency,
            to_currency: toCurrency,
            amount
        }, true);
    }

    /**
     * Get wallet transaction history
     * @param {string} [currency] - Filter by currency
     * @param {number} [limit=20] - Max records
     * @returns {Promise<Array>} Transaction history
     */
    async getWalletHistory(currency = null, limit = 20) {
        const params = new URLSearchParams({ limit: limit.toString() });
        if (currency) params.append('currency', currency);
        return this._request('GET', '/api/v1/wallets/transactions?' + params.toString());
    }

    // ============================================
    // REFUND METHODS
    // ============================================

    /**
     * Request a refund
     * @param {string} transactionId - Transaction ID
     * @param {number} [amount] - Specific amount (optional)
     * @param {string} [reason] - Refund reason
     * @returns {Promise<Object>} Refund request details
     */
    async createRefund(transactionId, amount = null, reason = null) {
        const data = { transaction_id: transactionId };
        if (amount) data.amount = amount;
        if (reason) data.reason = reason;
        return this._request('POST', '/api/v1/refunds/request', data, true);
    }

    /**
     * Get refund details
     * @param {string} refundId - Refund ID
     * @returns {Promise<Object>} Refund details
     */
    async getRefund(refundId) {
        return this._request('GET', `/api/v1/refunds/${refundId}`);
    }

    /**
     * List refunds
     * @param {string} [status] - Filter by status
     * @param {number} [limit=20] - Max records
     * @returns {Promise<Array>} List of refunds
     */
    async listRefunds(status = null, limit = 20) {
        const params = new URLSearchParams({ limit: limit.toString() });
        if (status) params.append('status', status);
        return this._request('GET', '/api/v1/refunds?' + params.toString());
    }

    /**
     * Approve a pending refund
     * @param {string} refundId - Refund ID
     * @returns {Promise<Object>} Approval result
     */
    async approveRefund(refundId) {
        return this._request('POST', `/api/v1/refunds/${refundId}/approve`, {}, true);
    }

    /**
     * Reject a pending refund
     * @param {string} refundId - Refund ID
     * @param {string} reason - Rejection reason
     * @returns {Promise<Object>} Rejection result
     */
    async rejectRefund(refundId, reason) {
        return this._request('POST', `/api/v1/refunds/${refundId}/reject`, { reason }, true);
    }

    // ============================================
    // DISPUTE METHODS
    // ============================================

    /**
     * List disputes
     * @param {string} [status] - Filter by status
     * @param {number} [limit=20] - Max records
     * @returns {Promise<Array>} List of disputes
     */
    async listDisputes(status = null, limit = 20) {
        const params = new URLSearchParams({ limit: limit.toString() });
        if (status) params.append('status', status);
        return this._request('GET', '/api/v1/disputes?' + params.toString());
    }

    /**
     * Get dispute details
     * @param {string} disputeId - Dispute ID
     * @returns {Promise<Object>} Dispute details
     */
    async getDispute(disputeId) {
        return this._request('GET', `/api/v1/disputes/${disputeId}`);
    }

    /**
     * Respond to a dispute
     * @param {string} disputeId - Dispute ID
     * @param {string} message - Response message
     * @param {Array<string>} [evidence] - URLs of evidence
     * @returns {Promise<Object>} Response result
     */
    async respondToDispute(disputeId, message, evidence = []) {
        return this._request('POST', `/api/v1/disputes/${disputeId}/respond`, {
            message,
            evidence_urls: evidence
        }, true);
    }

    // ============================================
    // ANALYTICS METHODS
    // ============================================

    async getApiUsage() {
        return this._request('GET', '/api/v1/analytics/api-usage');
    }

    async getWebhookLogs(limit = 20) {
        return this._request('GET', `/api/v1/analytics/webhook-logs?limit=${limit}`);
    }
}

module.exports = KyneSDK;
