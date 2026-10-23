sealed class TillAuthException implements Exception {
  const TillAuthException();
}

class TillAuthInvalidPinException extends TillAuthException {
  const TillAuthInvalidPinException();
}

class TillAuthNotAllowedException extends TillAuthException {
  const TillAuthNotAllowedException();
}

class TillAuthLockoutException extends TillAuthException {
  const TillAuthLockoutException(this.lockedUntil);
  final DateTime lockedUntil;
}

class TillAuthGenericException extends TillAuthException {
  const TillAuthGenericException(this.message);
  final String message;
}
