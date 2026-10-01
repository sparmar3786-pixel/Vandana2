import os

class AngelOneDataSource:
    """Server-side SmartAPI boundary. Credentials are environment-only."""
    def __init__(self):
        self.api_key = os.getenv("ANGEL_API_KEY")
        self.client_id = os.getenv("ANGEL_CLIENT_ID")
        self.pin = os.getenv("ANGEL_PIN")
        self.totp_secret = os.getenv("ANGEL_TOTP_SECRET")
        self._client = None

    @property
    def configured(self) -> bool:
        return all((self.api_key, self.client_id, self.pin, self.totp_secret))

    def connect(self):
        if not self.configured:
            raise RuntimeError("ANGEL_CREDENTIALS_NOT_CONFIGURED")
        try:
            from SmartApi import SmartConnect
            import pyotp
        except ImportError as exc:
            raise RuntimeError("SMARTAPI_DEPENDENCY_MISSING") from exc
        self._client = SmartConnect(api_key=self.api_key)
        otp = pyotp.TOTP(self.totp_secret).now()
        self._client.generateSession(self.client_id, self.pin, otp)
        return self._client

    def disconnect(self):
        if self._client:
            try:
                self._client.terminateSession(self.client_id)
            finally:
                self._client = None
