/**
 * ShegerPay Swift SDK
 * Official Swift SDK for ShegerPay Payment Verification Gateway
 * 
 * Usage:
 *   let client = ShegerPay(apiKey: "sk_test_xxx")
 *   let result = try await client.verify(transactionId: "FT123456", amount: 100)
 */

import Foundation
import CommonCrypto

// MARK: - Errors

public enum ShegerPayError: Error, LocalizedError {
    case invalidApiKey
    case missingApiKey
    case authenticationFailed
    case validationError(String)
    case networkError(Error)
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .invalidApiKey: return "Invalid API key format"
        case .missingApiKey: return "API key is required"
        case .authenticationFailed: return "Authentication failed"
        case .validationError(let msg): return msg
        case .networkError(let error): return error.localizedDescription
        case .invalidResponse: return "Invalid response from server"
        }
    }
}

// MARK: - Models

public struct VerificationResult: Codable {
    public let valid: Bool
    public let status: String
    public let provider: String?
    public let transactionId: String?
    public let amount: Double?
    public let reason: String?
    public let mode: String?
    public let payer: String?
    
    enum CodingKeys: String, CodingKey {
        case valid, status, provider, amount, reason, mode, payer
        case transactionId = "transaction_id"
    }
}

public struct PaymentLink: Codable {
    public let id: String
    public let shortCode: String
    public let paymentUrl: String
    public let qrCodeBase64: String
    public let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case shortCode = "short_code"
        case paymentUrl = "payment_url"
        case qrCodeBase64 = "qr_code_base64"
    }
}

// MARK: - ShegerPay Client

public class ShegerPay {
    private let apiKey: String
    private let baseURL: String
    private let mode: String
    private let session: URLSession
    
    public init(apiKey: String, baseURL: String = "https://api.shegerpay.com") throws {
        guard !apiKey.isEmpty else {
            throw ShegerPayError.missingApiKey
        }
        
        guard apiKey.hasPrefix("sk_test_") || apiKey.hasPrefix("sk_live_") else {
            throw ShegerPayError.invalidApiKey
        }
        
        self.apiKey = apiKey
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.mode = apiKey.hasPrefix("sk_test_") ? "test" : "live"
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Verification
    
    /// Verify a payment transaction
    public func verify(
        transactionId: String,
        amount: Double,
        provider: String? = nil,
        merchantName: String? = nil
    ) async throws -> VerificationResult {
        let detectedProvider = provider ?? (transactionId.uppercased().hasPrefix("FT") ? "cbe" : "telebirr")
        
        let params: [String: String] = [
            "provider": detectedProvider,
            "transaction_id": transactionId,
            "amount": String(amount),
            "merchant_name": merchantName ?? "ShegerPay Verification"
        ]
        
        return try await request(method: "POST", path: "/api/v1/verify", params: params)
    }
    
    /// Quick verification with auto-detected provider
    public func quickVerify(transactionId: String, amount: Double) async throws -> VerificationResult {
        let params: [String: String] = [
            "transaction_id": transactionId,
            "amount": String(amount)
        ]
        return try await request(method: "POST", path: "/api/v1/quick-verify", params: params)
    }
    
    // MARK: - Payment Links
    
    /// Create a payment link
    public func createPaymentLink(
        title: String,
        amount: Double,
        currency: String = "ETB",
        description: String? = nil
    ) async throws -> PaymentLink {
        var params: [String: Any] = [
            "title": title,
            "amount": amount,
            "currency": currency,
            "enable_cbe": true,
            "enable_telebirr": true
        ]
        
        if let desc = description {
            params["description"] = desc
        }
        
        return try await requestJSON(method: "POST", path: "/api/v1/payment-links/", json: params)
    }
    
    // MARK: - Private Methods
    
    private func request<T: Decodable>(
        method: String,
        path: String,
        params: [String: String]
    ) async throws -> T {
        var urlComponents = URLComponents(string: baseURL + path)!
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("ShegerPay-Swift-SDK/1.0", forHTTPHeaderField: "User-Agent")
        
        if method == "POST" {
            let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
                .joined(separator: "&")
            request.httpBody = body.data(using: .utf8)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ShegerPayError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw ShegerPayError.authenticationFailed
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func requestJSON<T: Decodable>(
        method: String,
        path: String,
        json: [String: Any]
    ) async throws -> T {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = method
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: json)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ShegerPayError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw ShegerPayError.authenticationFailed
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Webhook Verification
    
    /// Verify webhook signature
    public static func verifyWebhookSignature(payload: String, signature: String, secret: String) -> Bool {
        guard let keyData = secret.data(using: .utf8),
              let payloadData = payload.data(using: .utf8) else {
            return false
        }
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        keyData.withUnsafeBytes { keyBytes in
            payloadData.withUnsafeBytes { dataBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
                       keyBytes.baseAddress, keyData.count,
                       dataBytes.baseAddress, payloadData.count,
                       &digest)
            }
        }
        
        let expected = "sha256=" + digest.map { String(format: "%02x", $0) }.joined()
        return expected == signature
    }
}
