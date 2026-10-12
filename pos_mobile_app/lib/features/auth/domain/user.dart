enum UserRole {
  globalAdmin('GLOBAL_ADMIN'),
  branchManager('BRANCH_MANAGER'),
  cashier('CASHIER'),
  localBaker('LOCAL_BAKER');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String val) {
    return UserRole.values.firstWhere(
      (e) => e.value == val,
      orElse: () => UserRole.cashier,
    );
  }
}

class User {
  final String id;
  final String branchId;
  final String username;
  final String pinHash;
  final String fullName;
  final UserRole role;
  final bool isActive;
  final String? avatarAsset;

  const User({
    required this.id,
    required this.branchId,
    required this.username,
    required this.pinHash,
    required this.fullName,
    required this.role,
    this.isActive = true,
    this.avatarAsset,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'branch_id': branchId,
    'username': username,
    'pin_hash': pinHash,
    'full_name': fullName,
    'role': role.value,
    'is_active': isActive ? 1 : 0,
    'avatar_asset': avatarAsset,
    'synced_at': DateTime.now().millisecondsSinceEpoch,
  };

  static const Map<String, String> _defaultUserAvatars = {
    'cashier1': 'assets/users/maria_gonzalez.jpg',
    'baker1': 'assets/users/marco_rossi.jpg',
    'manager1': 'assets/users/elena_rostova.jpg',
  };

  factory User.fromMap(Map<String, dynamic> map) {
    final username = map['username'] as String;
    final explicitAvatar = map['avatar_asset'] as String?;
    return User(
      id: map['id'] as String,
      branchId: (map['branch_id'] ?? '') as String,
      username: username,
      pinHash: map['pin_hash'] as String,
      fullName: map['full_name'] as String,
      role: UserRole.fromString(map['role'] as String),
      isActive: (map['is_active'] as int) == 1,
      avatarAsset: explicitAvatar ?? _defaultUserAvatars[username],
    );
  }
}
