/// Kyne Dart/Flutter SDK
/// Official Dart SDK for Kyne Payment Verification Gateway
///
/// Usage:
///   final client = Kyne('sk_test_xxx');
///   final result = await client.verify('FT123456', 100.0);

library kyne;

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

// ---------- Exceptions ----------

class KyneException implements Exception {
  final String message;
  KyneException(this.message);
  @override
  String toString() => 'KyneException: $message';
}

class AuthenticationException extends KyneException {
  AuthenticationException(String message) : super(message);
}

class ValidationException extends KyneException {
  ValidationException(String message) : super(message);
}

// ---------- Models ----------

class VerificationResult {
  final bool valid;
  final String status;
  final String? provider;
  final String? transactionId;
  final double? amount;
  final String? reason;
  final String? mode;
  final String? payer;

  VerificationResult({
    required this.valid,
    required this.status,
    this.provider,
    this.transactionId,
    this.amount,
    this.reason,
    this.mode,
    this.payer,
  });

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      valid: json['valid'] ?? false,
      status: json['status'] ?? 'unknown',
      provider: json['provider'],
      transactionId: json['transaction_id'],
      amount: json['amount']?.toDouble(),
      reason: json['reason'],
      mode: json['mode'],
      payer: json['payer'],
    );
  }

  bool get isValid => valid;
}

class PaymentLink {
  final String id;
  final String shortCode;
  final String paymentUrl;
  final String qrCodeBase64;
  final String status;
  final double amount;
  final String currency;

  PaymentLink({
    required this.id,
    required this.shortCode,
    required this.paymentUrl,
    required this.qrCodeBase64,
    required this.status,
    required this.amount,
    required this.currency,
  });

  factory PaymentLink.fromJson(Map<String, dynamic> json) {
    return PaymentLink(
      id: json['id'],
      shortCode: json['short_code'],
      paymentUrl: json['payment_url'],
      qrCodeBase64: json['qr_code_base64'],
      status: json['status'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
    );
  }
}

// ---------- Kyne Client ----------

class Kyne {
  final String apiKey;
  final String baseUrl;
  final String mode;
  final http.Client _client;

  /// Create a new Kyne client
  ///
  /// [apiKey] Your secret API key (sk_test_xxx or sk_live_xxx)
  /// [baseUrl] Optional custom API base URL
  Kyne(this.apiKey, {String? baseUrl})
      : baseUrl = (baseUrl ?? 'https://api.kyne.com').replaceAll(RegExp(r'/$'), ''),
        mode = apiKey.startsWith('sk_test_') ? 'test' : 'live',
        _client = http.Client() {
    if (apiKey.isEmpty) {
      throw AuthenticationException('API key is required');
    }
    if (!apiKey.startsWith('sk_test_') && !apiKey.startsWith('sk_live_')) {
      throw AuthenticationException('Invalid API key format');
    }
  }

  // ---------- Verification ----------

  /// Verify a payment transaction
  ///
  /// [transactionId] Bank transaction reference
  /// [amount] Expected amount in ETB
  /// [provider] Optional - 'cbe' or 'telebirr' (auto-detected if not provided)
  /// [merchantName] Optional - Your bank account name
  Future<VerificationResult> verify(
    String transactionId,
    double amount, {
    String? provider,
    String? merchantName,
  }) async {
    final detectedProvider = provider ??
        (transactionId.toUpperCase().startsWith('FT') ? 'cbe' : 'telebirr');

    final params = {
      'provider': detectedProvider,
      'transaction_id': transactionId,
      'amount': amount.toString(),
      'merchant_name': merchantName ?? 'Kyne Verification',
    };

    final response = await _request('POST', '/api/v1/verify', params);
    return VerificationResult.fromJson(response);
  }

  /// Quick verification with auto-detected provider
  Future<VerificationResult> quickVerify(String transactionId, double amount) async {
    final params = {
      'transaction_id': transactionId,
      'amount': amount.toString(),
    };
    final response = await _request('POST', '/api/v1/quick-verify', params);
    return VerificationResult.fromJson(response);
  }

  // ---------- Payment Links ----------

  /// Create a payment link
  Future<PaymentLink> createPaymentLink({
    required String title,
    required double amount,
    String currency = 'ETB',
    String? description,
    bool enableCbe = true,
    bool enableTelebirr = true,
  }) async {
    final body = {
      'title': title,
      'amount': amount,
      'currency': currency,
      'enable_cbe': enableCbe,
      'enable_telebirr': enableTelebirr,
    };
    
    if (description != null) {
      body['description'] = description;
    }

    final response = await _requestJson('POST', '/api/v1/payment-links/', body);
    return PaymentLink.fromJson(response);
  }

  /// List all payment links
  Future<List<PaymentLink>> listPaymentLinks() async {
    final response = await _request('GET', '/api/v1/payment-links/', {});
    final links = response['links'] as List;
    return links.map((l) => PaymentLink.fromJson(l)).toList();
  }

  // ---------- Private Methods ----------

  Future<Map<String, dynamic>> _request(
    String method,
    String path,
    Map<String, String> params,
  ) async {
    final url = Uri.parse('$baseUrl$path');
    
    late http.Response response;
    
    if (method == 'POST') {
      response = await _client.post(
        url,
        headers: _headers(),
        body: params,
      );
    } else {
      response = await _client.get(url, headers: _headers());
    }

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$path');
    
    final response = await _client.post(
      url,
      headers: {..._headers(), 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Map<String, String> _headers() => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/x-www-form-urlencoded',
    'User-Agent': 'Kyne-Dart-SDK/1.0',
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw AuthenticationException('Invalid API key');
    }
    if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw ValidationException(error['detail'] ?? 'Validation error');
    }
    return jsonDecode(response.body);
  }

  /// Close the HTTP client
  void close() => _client.close();

  // ---------- Webhook Verification ----------

  /// Verify webhook signature
  static bool verifyWebhookSignature(String payload, String signature, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    final expected = 'sha256=$digest';
    return expected == signature;
  }
}
