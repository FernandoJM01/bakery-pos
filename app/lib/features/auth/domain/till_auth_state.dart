import '../../../core/storage/local_database.dart';

export 'till_auth_exceptions.dart';

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

  TillSession copyWith({
    StaffEntry? staff,
    List<String>? permissions,
    bool? isOffline,
    String? accessToken,
    DateTime? accessTokenExpiresAt,
    bool clearAccessToken = false,
  }) {
    return TillSession(
      staff: staff ?? this.staff,
      permissions: permissions ?? this.permissions,
      isOffline: isOffline ?? this.isOffline,
      accessToken: clearAccessToken ? null : (accessToken ?? this.accessToken),
      accessTokenExpiresAt: clearAccessToken
          ? null
          : (accessTokenExpiresAt ?? this.accessTokenExpiresAt),
    );
  }
}
