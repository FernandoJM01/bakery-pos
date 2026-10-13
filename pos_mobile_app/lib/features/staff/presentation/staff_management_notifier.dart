import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user.dart';
import '../domain/audit_log_entry.dart';

class StaffState {
  final List<User> users;
  final List<AuditLogEntry> auditLogs;
  final UserRole? selectedFilterRole;

  const StaffState({
    required this.users,
    required this.auditLogs,
    this.selectedFilterRole,
  });

  List<User> get filteredUsers {
    if (selectedFilterRole == null) return users;
    return users.where((u) => u.role == selectedFilterRole).toList();
  }

  StaffState copyWith({
    List<User>? users,
    List<AuditLogEntry>? auditLogs,
    UserRole? selectedFilterRole,
    bool clearFilter = false,
  }) {
    return StaffState(
      users: users ?? this.users,
      auditLogs: auditLogs ?? this.auditLogs,
      selectedFilterRole: clearFilter ? null : (selectedFilterRole ?? this.selectedFilterRole),
    );
  }
}

class StaffManagementNotifier extends StateNotifier<StaffState> {
  StaffManagementNotifier()
      : super(
          StaffState(
            users: [
              const User(
                id: 'b0000000-0000-0000-0000-000000000004',
                branchId: 'a0000000-0000-0000-0000-000000000001',
                username: 'admin1',
                pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
                fullName: 'Mateo Vargas',
                role: UserRole.globalAdmin,
                avatarAsset: 'assets/users/elena_rostova.jpg',
              ),
              const User(
                id: 'b0000000-0000-0000-0000-000000000003',
                branchId: 'a0000000-0000-0000-0000-000000000001',
                username: 'manager1',
                pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
                fullName: 'Elena Rostova',
                role: UserRole.branchManager,
                avatarAsset: 'assets/users/elena_rostova.jpg',
              ),
              const User(
                id: 'b0000000-0000-0000-0000-000000000002',
                branchId: 'a0000000-0000-0000-0000-000000000001',
                username: 'baker1',
                pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
                fullName: 'Marco Rossi',
                role: UserRole.localBaker,
                avatarAsset: 'assets/users/marco_rossi.jpg',
              ),
              const User(
                id: 'b0000000-0000-0000-0000-000000000001',
                branchId: 'a0000000-0000-0000-0000-000000000001',
                username: 'cashier1',
                pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
                fullName: 'Maria Gonzalez',
                role: UserRole.cashier,
                avatarAsset: 'assets/users/maria_gonzalez.jpg',
              ),
            ],
            auditLogs: [
              AuditLogEntry(
                id: 'log-101',
                timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
                userId: 'manager1',
                userName: 'Elena Rostova',
                action: 'ARQUEO CORTE Z',
                details: 'Cierre Z ejecutado con balance de \$1,450.00 en caja.',
                category: 'CAJA',
              ),
              AuditLogEntry(
                id: 'log-102',
                timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
                userId: 'baker1',
                userName: 'Marco Rossi',
                action: 'HORNADA COMPLETADA',
                details: 'Hornada #H-204 (48 Conchas Tradicionales) ingresada a vitrina.',
                category: 'PRODUCCION',
              ),
              AuditLogEntry(
                id: 'log-103',
                timestamp: DateTime.now().subtract(const Duration(hours: 3)),
                userId: 'cashier1',
                userName: 'Maria Gonzalez',
                action: 'INICIO DE TURNO',
                details: 'Cajero abrió terminal 01 con fondo inicial de \$200.00.',
                category: 'AUTH',
              ),
            ],
          ),
        );

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  void setFilterRole(UserRole? role) {
    state = state.copyWith(selectedFilterRole: role, clearFilter: role == null);
  }

  void addUser({
    required String fullName,
    required String username,
    required String pin,
    required UserRole role,
    String? avatarAsset,
  }) {
    final newUser = User(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      branchId: 'a0000000-0000-0000-0000-000000000001',
      username: username.trim().toLowerCase(),
      pinHash: _hashPin(pin.trim()),
      fullName: fullName.trim(),
      role: role,
      avatarAsset: avatarAsset ?? 'assets/users/maria_gonzalez.jpg',
      isActive: true,
    );

    final newLog = AuditLogEntry(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      userId: 'admin',
      userName: 'Administración RH',
      action: 'ALTA DE USUARIO',
      details: 'Empleado ${newUser.fullName} dado de alta con rol ${newUser.roleDisplayName}.',
      category: 'RH',
    );

    state = state.copyWith(
      users: [...state.users, newUser],
      auditLogs: [newLog, ...state.auditLogs],
    );
  }

  void updateUser(User user, {String? newPin}) {
    final updatedUser = user.copyWith(
      pinHash: newPin != null && newPin.trim().isNotEmpty ? _hashPin(newPin.trim()) : user.pinHash,
    );

    final newUsers = state.users.map((u) => u.id == user.id ? updatedUser : u).toList();

    final newLog = AuditLogEntry(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      userId: 'admin',
      userName: 'Administración RH',
      action: 'MODIFICACIÓN EMPLEADO',
      details: 'Datos de ${user.fullName} actualizados.${newPin != null ? " PIN renovado." : ""}',
      category: 'RH',
    );

    state = state.copyWith(
      users: newUsers,
      auditLogs: [newLog, ...state.auditLogs],
    );
  }

  void toggleUserStatus(String userId) {
    final user = state.users.firstWhere((u) => u.id == userId);
    final updated = user.copyWith(isActive: !user.isActive);

    final newUsers = state.users.map((u) => u.id == userId ? updated : u).toList();

    final newLog = AuditLogEntry(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      userId: 'admin',
      userName: 'Administración RH',
      action: updated.isActive ? 'ACTIVACIÓN EMPLEADO' : 'SUSPENSIÓN EMPLEADO',
      details: '${user.fullName} ahora está ${updated.isActive ? "ACTIVO" : "INACTIVO"}.',
      category: 'RH',
    );

    state = state.copyWith(
      users: newUsers,
      auditLogs: [newLog, ...state.auditLogs],
    );
  }

  void logAction({
    required String userId,
    required String userName,
    required String action,
    required String details,
    String category = 'POS',
  }) {
    final newLog = AuditLogEntry(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      userId: userId,
      userName: userName,
      action: action,
      details: details,
      category: category,
    );

    state = state.copyWith(
      auditLogs: [newLog, ...state.auditLogs],
    );
  }
}

final staffManagementProvider = StateNotifierProvider<StaffManagementNotifier, StaffState>((ref) {
  return StaffManagementNotifier();
});
