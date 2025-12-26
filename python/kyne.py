"""
Kyne Python SDK
Official Python SDK for Kyne Payment Verification Gateway
"""

import requests
from typing import Optional, Dict, Any, List
from dataclasses import dataclass
from enum import Enum


class Provider(Enum):
    """Supported payment providers"""
    CBE = "cbe"
    TELEBIRR = "telebirr"
    BANK_TRANSFER = "bank_transfer"


@dataclass
class VerificationResult:
    """Result of a payment verification"""
    valid: bool
    status: str
    provider: Optional[str] = None
    transaction_id: Optional[str] = None
    amount: Optional[float] = None
    reason: Optional[str] = None
    mode: Optional[str] = None
    payer: Optional[str] = None
    
    @classmethod
    def from_response(cls, data: Dict[str, Any]) -> 'VerificationResult':
        return cls(
            valid=data.get('valid', False),
            status=data.get('status', 'unknown'),
            provider=data.get('provider'),
            transaction_id=data.get('transaction_id'),
            amount=data.get('amount'),
            reason=data.get('reason'),
            mode=data.get('mode'),
            payer=data.get('payer')
        )


@dataclass 
class Transaction:
    """A verified transaction record"""
    id: str
    provider: str
    external_id: str
    amount: float
    status: str
    created_at: str
    mode: str


class KyneError(Exception):
    """Base exception for Kyne SDK"""
    def __init__(self, message: str, status_code: int = None):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)


class AuthenticationError(KyneError):
    """Raised when API key is invalid"""
    pass


class ValidationError(KyneError):
    """Raised when request validation fails"""
    pass


class Kyne:
    """
    Kyne Payment Verification Client
    
    Usage:
        client = Kyne(api_key="sk_test_xxx")
        result = client.verify(provider="cbe", transaction_id="FT123", amount=100)
    """
    
    DEFAULT_BASE_URL = "https://api.kyne.com"
    
    def __init__(
        self, 
        api_key: str,
        base_url: Optional[str] = None,
        timeout: int = 30
    ):
        """
        Initialize Kyne client.
        
        Args:
            api_key: Your secret API key (sk_test_xxx or sk_live_xxx)
            base_url: Optional custom API base URL
            timeout: Request timeout in seconds
        """
        if not api_key:
            raise AuthenticationError("API key is required")
        
        if not api_key.startswith(("sk_test_", "sk_live_")):
            raise AuthenticationError("Invalid API key format. Must start with sk_test_ or sk_live_")
        
        self.api_key = api_key
        self.base_url = (base_url or self.DEFAULT_BASE_URL).rstrip('/')
        self.timeout = timeout
        self.mode = "test" if api_key.startswith("sk_test_") else "live"
        
        self._session = requests.Session()
        self._session.headers.update({
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'Kyne-Python-SDK/1.0'
        })
    
    def verify(
        self,
        transaction_id: str,
        amount: float,
        provider: str = None,
        merchant_name: str = None,
        sub_provider: str = None
    ) -> VerificationResult:
        """
        Verify a payment transaction.
        
        Args:
            transaction_id: Bank transaction reference (e.g., FT123456789)
            amount: Expected amount in ETB
            provider: Payment provider (cbe, telebirr, bank_transfer). Auto-detected if not provided.
            merchant_name: Your registered bank account name
            sub_provider: Sub-provider for bank transfers (e.g., Payoneer)
            
        Returns:
            VerificationResult with valid=True if payment is verified
            
        Example:
            result = client.verify(
                provider="cbe",
                transaction_id="FT24352648751234",
                amount=100,
                merchant_name="My Shop"
            )
        """
        # Auto-detect provider if not specified
        if not provider:
            if transaction_id.upper().startswith("FT"):
                provider = "cbe"
            else:
                provider = "telebirr"
        
        data = {
            'provider': provider,
            'transaction_id': transaction_id,
            'amount': amount,
        }
        
        if merchant_name:
            data['merchant_name'] = merchant_name
        else:
            data['merchant_name'] = 'Kyne Verification'
            
        if sub_provider:
            data['sub_provider'] = sub_provider
        
        response = self._request('POST', '/api/v1/verify', data=data)
        return VerificationResult.from_response(response)
    
    def quick_verify(self, transaction_id: str, amount: float) -> VerificationResult:
        """
        Quick verification with auto-detected provider.
        
        Automatically detects CBE (FT...) or Telebirr from transaction ID format.
        
        Args:
            transaction_id: Bank transaction reference
            amount: Expected amount
            
        Returns:
            VerificationResult
        """
        data = {
            'transaction_id': transaction_id,
            'amount': amount
        }
        
        response = self._request('POST', '/api/v1/quick-verify', data=data)
        return VerificationResult.from_response(response)
    
    def get_history(self, limit: int = 50) -> List[Transaction]:
        """
        Get transaction history.
        
        Args:
            limit: Maximum number of transactions to return
            
        Returns:
            List of Transaction objects
        """
        response = self._request('GET', '/api/v1/history')
        
        transactions = []
        for tx in response:
            transactions.append(Transaction(
                id=tx.get('id'),
                provider=tx.get('provider'),
                external_id=tx.get('external_id'),
                amount=tx.get('amount'),
                status=tx.get('status'),
                created_at=tx.get('created_at'),
                mode=tx.get('mode')
            ))
        
        return transactions
    
    def _request(
        self, 
        method: str, 
        path: str, 
        data: Dict = None,
        params: Dict = None
    ) -> Dict[str, Any]:
        """Make API request"""
        url = f"{self.base_url}{path}"
        
        try:
            response = self._session.request(
                method=method,
                url=url,
                data=data,
                params=params,
                timeout=self.timeout
            )
            
            if response.status_code == 401:
                raise AuthenticationError("Invalid API key", status_code=401)
            
            if response.status_code == 400:
                error = response.json()
                raise ValidationError(error.get('detail', 'Validation error'), status_code=400)
            
            if response.status_code >= 500:
                raise KyneError("Server error", status_code=response.status_code)
            
            return response.json()
            
        except requests.exceptions.Timeout:
            raise KyneError("Request timed out")
        except requests.exceptions.ConnectionError:
            raise KyneError("Connection error")


# Convenience function
def verify(api_key: str, transaction_id: str, amount: float, **kwargs) -> VerificationResult:
    """
    Quick verification without creating a client.
    
    Usage:
        import kyne
        result = kyne.verify("sk_test_xxx", "FT123456", 100)
    """
    client = Kyne(api_key)
    return client.verify(transaction_id=transaction_id, amount=amount, **kwargs)


__version__ = "1.0.0"
__all__ = ['Kyne', 'VerificationResult', 'Transaction', 'Provider', 'KyneError', 'verify']
