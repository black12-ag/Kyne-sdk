"""
=== ShegerPay Python SDK Examples ===
Verify Ethiopian bank payments with just a few lines of code
"""

from shegerpay import ShegerPay, ShegerPayError, AuthenticationError

# Initialize client with your API key
# Use sk_test_ for development, sk_live_ for production
client = ShegerPay(api_key="sk_test_your_api_key_here")

# =====================================================
# Example 1: Quick Verify (Auto-detects CBE/Telebirr)
# =====================================================

print("=== Quick Verify ===")
try:
    result = client.quick_verify(
        transaction_id="FT24352648751234",  # CBE format
        amount=100
    )
    
    if result.valid:
        print(f"✅ Payment verified!")
        print(f"   Provider: {result.provider}")
        print(f"   Amount: {result.amount} ETB")
        print(f"   Mode: {result.mode}")
    else:
        print(f"❌ Verification failed: {result.reason}")
        
except ShegerPayError as e:
    print(f"Error: {e.message}")

# =====================================================
# Example 2: Full Verify with Merchant Name
# =====================================================

print("\n=== Full Verify ===")
try:
    result = client.verify(
        provider="cbe",
        transaction_id="FT24352648751234",
        amount=100,
        merchant_name="My Shop ETB Account"
    )
    
    print(f"Status: {result.status}")
    print(f"Valid: {result.valid}")
    
except ShegerPayError as e:
    print(f"Error: {e.message}")

# =====================================================
# Example 3: Telebirr Verification
# =====================================================

print("\n=== Telebirr Verify ===")
try:
    result = client.verify(
        provider="telebirr",
        transaction_id="ABC123XYZ",
        amount=500
    )
    
    print(f"Result: {result.status}")
    
except ShegerPayError as e:
    print(f"Error: {e.message}")

# =====================================================
# Example 4: Test Mode - Simulating Failures
# =====================================================

print("\n=== Test Mode: Simulated Failure ===")
try:
    # Include "FAIL" in transaction ID to simulate failure
    result = client.quick_verify(
        transaction_id="FAIL_TEST_123",
        amount=100
    )
    
    if not result.valid:
        print(f"Expected failure: {result.reason}")
        
except ShegerPayError as e:
    print(f"Error: {e.message}")

# =====================================================
# Example 5: Get Transaction History
# =====================================================

print("\n=== Transaction History ===")
try:
    transactions = client.get_history(limit=10)
    
    for tx in transactions[:5]:
        print(f"  - {tx.external_id}: {tx.amount} ETB ({tx.status})")
        
except ShegerPayError as e:
    print(f"Error: {e.message}")

# =====================================================
# Example 6: Error Handling
# =====================================================

print("\n=== Error Handling ===")
try:
    # This will fail with invalid API key
    bad_client = ShegerPay(api_key="invalid_key")
except AuthenticationError as e:
    print(f"Authentication error: {e.message}")

# =====================================================
# Example 7: Flask Integration
# =====================================================

print("\n=== Flask Integration Example ===")
print("""
from flask import Flask, request, jsonify
from shegerpay import ShegerPay

app = Flask(__name__)
shegerpay = ShegerPay(api_key="sk_live_xxx")

@app.route('/verify-payment', methods=['POST'])
def verify_payment():
    data = request.json
    
    result = shegerpay.verify(
        transaction_id=data['transaction_id'],
        amount=data['amount'],
        provider=data.get('provider')
    )
    
    if result.valid:
        # Payment verified - fulfill order
        return jsonify({'success': True, 'message': 'Payment verified'})
    else:
        return jsonify({'success': False, 'reason': result.reason}), 400
""")

print("\n✅ All examples completed!")
