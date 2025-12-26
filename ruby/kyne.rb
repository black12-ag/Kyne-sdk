# frozen_string_literal: true

# Kyne Ruby SDK
# Official Ruby SDK for Kyne Payment Verification Gateway
#
# @author Kyne <support@kyne.com>
# @version 1.0.0

require 'net/http'
require 'uri'
require 'json'
require 'openssl'

module Kyne
  VERSION = '1.0.0'
  
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class ValidationError < Error; end
  
  # Verification result
  class VerificationResult
    attr_reader :valid, :status, :provider, :transaction_id, :amount, :reason, :mode
    
    def initialize(data)
      @valid = data['valid'] || false
      @status = data['status'] || 'unknown'
      @provider = data['provider']
      @transaction_id = data['transaction_id']
      @amount = data['amount']
      @reason = data['reason']
      @mode = data['mode']
    end
    
    def valid?
      @valid
    end
  end
  
  # Kyne Payment Verification Client
  class Client
    DEFAULT_BASE_URL = 'https://api.kyne.com'
    
    # Create a new Kyne client
    #
    # @param api_key [String] Your secret API key (sk_test_xxx or sk_live_xxx)
    # @param options [Hash] Optional configuration
    def initialize(api_key, options = {})
      raise AuthenticationError, 'API key is required' if api_key.nil? || api_key.empty?
      
      unless api_key.start_with?('sk_test_', 'sk_live_')
        raise AuthenticationError, 'Invalid API key format'
      end
      
      @api_key = api_key
      @base_url = (options[:base_url] || DEFAULT_BASE_URL).chomp('/')
      @timeout = options[:timeout] || 30
      @mode = api_key.start_with?('sk_test_') ? 'test' : 'live'
    end
    
    # Verify a payment transaction
    #
    # @param params [Hash] Verification parameters
    # @return [VerificationResult]
    def verify(params)
      transaction_id = params[:transaction_id]
      amount = params[:amount]
      provider = params[:provider]
      merchant_name = params[:merchant_name] || 'Kyne Verification'
      
      raise ValidationError, 'transaction_id is required' unless transaction_id
      raise ValidationError, 'amount is required' unless amount
      
      # Auto-detect provider
      provider ||= transaction_id.upcase.start_with?('FT') ? 'cbe' : 'telebirr'
      
      data = {
        provider: provider,
        transaction_id: transaction_id,
        amount: amount,
        merchant_name: merchant_name
      }
      data[:sub_provider] = params[:sub_provider] if params[:sub_provider]
      
      response = request(:post, '/api/v1/verify', data)
      VerificationResult.new(response)
    end
    
    # Quick verification with auto-detected provider
    #
    # @param transaction_id [String] Bank transaction reference
    # @param amount [Float] Expected amount
    # @return [VerificationResult]
    def quick_verify(transaction_id, amount)
      response = request(:post, '/api/v1/quick-verify', {
        transaction_id: transaction_id,
        amount: amount
      })
      VerificationResult.new(response)
    end
    
    # Get transaction history
    #
    # @param limit [Integer] Maximum number of transactions
    # @return [Array]
    def history(limit = 50)
      request(:get, '/api/v1/history')
    end
    
    # Verify webhook signature
    #
    # @param payload [String] Raw request body
    # @param signature [String] X-Kyne-Signature header
    # @param secret [String] Your webhook secret
    # @return [Boolean]
    def self.verify_webhook_signature(payload, signature, secret)
      expected = 'sha256=' + OpenSSL::HMAC.hexdigest('SHA256', secret, payload)
      Rack::Utils.secure_compare(expected, signature)
    rescue
      expected == signature
    end
    
    private
    
    def request(method, path, data = nil)
      uri = URI.parse("#{@base_url}#{path}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = @timeout
      http.read_timeout = @timeout
      
      case method
      when :get
        request = Net::HTTP::Get.new(uri)
      when :post
        request = Net::HTTP::Post.new(uri)
        request.body = URI.encode_www_form(data) if data
        request['Content-Type'] = 'application/x-www-form-urlencoded'
      end
      
      request['Authorization'] = "Bearer #{@api_key}"
      request['User-Agent'] = 'Kyne-Ruby-SDK/1.0'
      
      response = http.request(request)
      
      case response.code.to_i
      when 401
        raise AuthenticationError, 'Invalid API key'
      when 400
        error = JSON.parse(response.body) rescue {}
        raise ValidationError, error['detail'] || 'Validation error'
      end
      
      JSON.parse(response.body) rescue {}
    end
  end
end
