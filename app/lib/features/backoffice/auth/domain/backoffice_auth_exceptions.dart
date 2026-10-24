class BackofficeAuthException implements Exception {
  const BackofficeAuthException([this.message]);
  final String? message;

  @override
  String toString() => message ?? 'BackofficeAuthException';
}

class BackofficeAuthInvalidCredentialsException
    extends BackofficeAuthException {
  const BackofficeAuthInvalidCredentialsException()
    : super('Invalid credentials');
}

class BackofficeAuthLockedException extends BackofficeAuthException {
  const BackofficeAuthLockedException({this.lockedUntil})
    : super('Account is locked');

  final DateTime? lockedUntil;
}

class BackofficeAuthGenericException extends BackofficeAuthException {
  const BackofficeAuthGenericException(super.message);
}
