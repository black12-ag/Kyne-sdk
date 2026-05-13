/**
 * ShegerPay Swift SDK v2.2.0
 * Official Swift SDK for ShegerPay Payment Verification Gateway
 *
 * Usage:
 *   let client = ShegerPay(apiKey: "sk_test_xxx")
 *   let result = try await client.verify(transactionId: "FT123456", amount: 100, provider: "cbe")
 *   let imageResult = try await client.verifyImage("base64_or_url", provider: "cbe", amount: 100)
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
    public let verified: Bool?
    public let valid: Bool
    public let status: String
    public let provider: String?
    public let transactionId: String?
    public let amount: Double?
    public let reason: String?
    public let mode: String?
    public let payer: String?
    
    enum CodingKeys: String, CodingKey {
        case verified, valid, status, provider, amount, reason, mode, payer
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
        merchantName: String? = nil,
        senderAccount: String? = nil
    ) async throws -> VerificationResult {
        let detectedProvider = provider ?? (transactionId.lowercased().contains("cs.bankofabyssinia.com/slip/?trx=") ? "boa" : nil)
        guard let detectedProvider else {
            throw ShegerPayError.validationError("provider is required for ambiguous transaction references. Pass provider explicitly or use quickVerify().")
        }
        
        var params: [String: String] = [
            "provider": detectedProvider,
            "transaction_id": transactionId,
            "amount": String(amount),
            "merchant_name": merchantName ?? "ShegerPay Verification"
        ]
        if let senderAccount, !senderAccount.isEmpty {
            params["sender_account"] = senderAccount
        }
        
        return try await request(method: "POST", path: "/api/v1/verify", params: params)
    }
    
    /// Quick verification with auto-detected provider
    public func quickVerify(
        transactionId: String,
        amount: Double,
        expectedProvider: String? = nil,
        senderAccount: String? = nil
    ) async throws -> VerificationResult {
        var params: [String: String] = [
            "transaction_id": transactionId,
            "amount": String(amount)
        ]
        if let expectedProvider, !expectedProvider.isEmpty {
            params["expected_provider"] = expectedProvider
        }
        if let senderAccount, !senderAccount.isEmpty {
            params["sender_account"] = senderAccount
        }
        return try await request(method: "POST", path: "/api/v1/quick-verify", params: params)
    }
    
    // MARK: - Image Verification

    /// Verify payment from a receipt screenshot (base64 encoded string or public URL)
    public func verifyImage(
        _ image: String,
        provider: String? = nil,
        amount: Double? = nil,
        merchantName: String = "ShegerPay Verification"
    ) async throws -> VerificationResult {
        var params: [String: Any] = ["image": image, "merchant_name": merchantName]
        if let provider, !provider.isEmpty { params["provider"] = provider }
        if let amount { params["amount"] = amount }
        return try await requestJSON(method: "POST", path: "/api/v1/verify/image", json: params)
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

    // MARK: - Promo Codes

    public func createPromoCode(_ params: [String: Any]) async throws -> [String: Any] {
        try await requestDictionary(method: "POST", path: "/api/v1/promo-codes/", json: promoPayload(params))
    }

    public func listPromoCodes() async throws -> [[String: Any]] {
        try await requestArray(method: "GET", path: "/api/v1/promo-codes/", json: nil)
    }

    public func updatePromoCode(_ codeId: String, params: [String: Any]) async throws -> [String: Any] {
        try await requestDictionary(method: "PATCH", path: "/api/v1/promo-codes/\(codeId)", json: promoPayload(params))
    }

    public func deletePromoCode(_ codeId: String) async throws -> [String: Any] {
        try await requestDictionary(method: "DELETE", path: "/api/v1/promo-codes/\(codeId)", json: nil)
    }

    public func validatePromoCode(code: String, amount: Double, options: [String: Any] = [:]) async throws -> [String: Any] {
        var body = options
        body["code"] = code
        body["amount"] = amount
        return try await requestDictionary(method: "POST", path: "/api/v1/promo-codes/validate", json: body)
    }

    public func redeemPromoCode(code: String, amount: Double, transactionId: String, options: [String: Any] = [:]) async throws -> [String: Any] {
        var body = options
        body["code"] = code
        body["amount"] = amount
        body["transaction_id"] = transactionId
        return try await requestDictionary(method: "POST", path: "/api/v1/promo-codes/redeem", json: body)
    }

    public func applyPaymentLinkCoupon(shortCode: String, code: String, amount: Double? = nil, quantity: Int = 1, provider: String? = nil, customerIdentifier: String? = nil) async throws -> [String: Any] {
        var body: [String: Any] = ["code": code, "quantity": quantity]
        if let amount { body["amount"] = amount }
        if let provider { body["provider"] = provider }
        if let customerIdentifier { body["customer_identifier"] = customerIdentifier }
        return try await requestDictionary(method: "POST", path: "/api/v1/payment-links/\(shortCode)/apply-coupon", json: body)
    }

    public func getPaymentLinkOrderStatus(shortCode: String, orderId: String) async throws -> [String: Any] {
        return try await requestDictionary(
            method: "GET",
            path: "/api/v1/payment-links/\(shortCode)/orders/\(orderId)/status",
            json: nil
        )
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
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("ShegerPay-Swift-SDK/2.2.0", forHTTPHeaderField: "User-Agent")
        
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
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
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

    private func requestDictionary(
        method: String,
        path: String,
        json: [String: Any]?
    ) async throws -> [String: Any] {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let json, method != "GET", method != "DELETE" {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ShegerPayError.invalidResponse
        }
        if httpResponse.statusCode == 401 {
            throw ShegerPayError.authenticationFailed
        }
        if httpResponse.statusCode == 204 {
            return [:]
        }
        if !(200...299).contains(httpResponse.statusCode) {
            throw ShegerPayError.validationError(String(data: data, encoding: .utf8) ?? "ShegerPay request failed")
        }
        return (try JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    private func requestArray(
        method: String,
        path: String,
        json: [String: Any]?
    ) async throws -> [[String: Any]] {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let json, method != "GET", method != "DELETE" {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ShegerPayError.invalidResponse
        }
        if httpResponse.statusCode == 401 {
            throw ShegerPayError.authenticationFailed
        }
        if !(200...299).contains(httpResponse.statusCode) {
            throw ShegerPayError.validationError(String(data: data, encoding: .utf8) ?? "ShegerPay request failed")
        }
        return (try JSONSerialization.jsonObject(with: data)) as? [[String: Any]] ?? []
    }

    private func promoPayload(_ params: [String: Any]) -> [String: Any] {
        Dictionary(uniqueKeysWithValues: params.map { (snakeCase($0.key), $0.value) })
    }

    private func snakeCase(_ value: String) -> String {
        value.reduce(into: "") { output, character in
            if character.isUppercase {
                output.append("_")
                output.append(character.lowercased())
            } else {
                output.append(character)
            }
        }
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

    public static func verifyRedirectSignature(params: [String: Any], signature: String, secret: String) -> Bool {
        let amountValue = Double("\(params["amount"] ?? "0")") ?? 0
        let amount = String(format: "%.2f", amountValue)
        let payload = [
            "\(params["checkout_session_id"] ?? params["checkoutSessionId"] ?? "")",
            "\(params["order_id"] ?? params["orderId"] ?? "")",
            "\(params["short_code"] ?? params["shortCode"] ?? "")",
            amount,
            "\(params["currency"] ?? "ETB")",
            "\(params["status"] ?? "paid")"
        ].joined(separator: "|")
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
        let expected = digest.map { String(format: "%02x", $0) }.joined()
        return expected == signature.replacingOccurrences(of: "sha256=", with: "")
    }
}
