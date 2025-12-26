<?php
/**
 * Kyne PHP SDK
 * Official PHP SDK for Kyne Payment Verification Gateway
 * 
 * @package Kyne
 * @version 1.0.0
 * @author Kyne <support@kyne.com>
 * @license MIT
 */

namespace Kyne;

class KyneException extends \Exception {}
class AuthenticationException extends KyneException {}
class ValidationException extends KyneException {}

/**
 * Verification result object
 */
class VerificationResult {
    public bool $valid;
    public string $status;
    public ?string $provider;
    public ?string $transactionId;
    public ?float $amount;
    public ?string $reason;
    public ?string $mode;
    
    public function __construct(array $data) {
        $this->valid = $data['valid'] ?? false;
        $this->status = $data['status'] ?? 'unknown';
        $this->provider = $data['provider'] ?? null;
        $this->transactionId = $data['transaction_id'] ?? null;
        $this->amount = $data['amount'] ?? null;
        $this->reason = $data['reason'] ?? null;
        $this->mode = $data['mode'] ?? null;
    }
}

/**
 * Kyne Payment Verification Client
 */
class Kyne {
    private string $apiKey;
    private string $baseUrl;
    private int $timeout;
    private string $mode;
    
    const DEFAULT_BASE_URL = 'https://api.kyne.com';
    
    /**
     * Create a new Kyne client
     * 
     * @param string $apiKey Your secret API key (sk_test_xxx or sk_live_xxx)
     * @param array $options Optional configuration
     */
    public function __construct(string $apiKey, array $options = []) {
        if (empty($apiKey)) {
            throw new AuthenticationException('API key is required');
        }
        
        if (!str_starts_with($apiKey, 'sk_test_') && !str_starts_with($apiKey, 'sk_live_')) {
            throw new AuthenticationException('Invalid API key format');
        }
        
        $this->apiKey = $apiKey;
        $this->baseUrl = rtrim($options['base_url'] ?? self::DEFAULT_BASE_URL, '/');
        $this->timeout = $options['timeout'] ?? 30;
        $this->mode = str_starts_with($apiKey, 'sk_test_') ? 'test' : 'live';
    }
    
    /**
     * Verify a payment transaction
     * 
     * @param array $params Verification parameters
     * @return VerificationResult
     */
    public function verify(array $params): VerificationResult {
        $transactionId = $params['transaction_id'] ?? null;
        $amount = $params['amount'] ?? null;
        $provider = $params['provider'] ?? null;
        $merchantName = $params['merchant_name'] ?? 'Kyne Verification';
        
        if (!$transactionId) {
            throw new ValidationException('transaction_id is required');
        }
        if (!$amount) {
            throw new ValidationException('amount is required');
        }
        
        // Auto-detect provider
        if (!$provider) {
            $provider = strtoupper(substr($transactionId, 0, 2)) === 'FT' ? 'cbe' : 'telebirr';
        }
        
        $data = [
            'provider' => $provider,
            'transaction_id' => $transactionId,
            'amount' => $amount,
            'merchant_name' => $merchantName,
        ];
        
        if (isset($params['sub_provider'])) {
            $data['sub_provider'] = $params['sub_provider'];
        }
        
        $response = $this->request('POST', '/api/v1/verify', $data);
        return new VerificationResult($response);
    }
    
    /**
     * Quick verification with auto-detected provider
     * 
     * @param string $transactionId Bank transaction reference
     * @param float $amount Expected amount
     * @return VerificationResult
     */
    public function quickVerify(string $transactionId, float $amount): VerificationResult {
        $response = $this->request('POST', '/api/v1/quick-verify', [
            'transaction_id' => $transactionId,
            'amount' => $amount,
        ]);
        return new VerificationResult($response);
    }
    
    /**
     * Get transaction history
     * 
     * @param int $limit Maximum number of transactions
     * @return array
     */
    public function getHistory(int $limit = 50): array {
        return $this->request('GET', '/api/v1/history');
    }
    
    /**
     * Make API request
     */
    private function request(string $method, string $path, array $data = []): array {
        $url = $this->baseUrl . $path;
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, $this->timeout);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->apiKey,
            'Content-Type: application/x-www-form-urlencoded',
            'User-Agent: Kyne-PHP-SDK/1.0',
        ]);
        
        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
        }
        
        $response = curl_exec($ch);
        $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($statusCode === 401) {
            throw new AuthenticationException('Invalid API key');
        }
        
        if ($statusCode === 400) {
            $error = json_decode($response, true);
            throw new ValidationException($error['detail'] ?? 'Validation error');
        }
        
        return json_decode($response, true) ?? [];
    }
    
    /**
     * Verify webhook signature
     * 
     * @param string $payload Raw request body
     * @param string $signature X-Kyne-Signature header
     * @param string $secret Your webhook secret
     * @return bool
     */
    public static function verifyWebhookSignature(string $payload, string $signature, string $secret): bool {
        $expected = 'sha256=' . hash_hmac('sha256', $payload, $secret);
        return hash_equals($expected, $signature);
    }
}
