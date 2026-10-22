import '../../../core/storage/local_database.dart';

class TillSession {
  const TillSession({
    required this.staff,
    required this.permissions,
    required this.isOffline,
    this.accessToken,
    this.accessTokenExpiresAt,
  });

  final StaffEntry staff;
  final List<String> permissions;
  final bool isOffline;
  final String? accessToken;
  final DateTime? accessTokenExpiresAt;

  bool hasPermission(String permission) => permissions.contains(permission);
}

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
