import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile_app/core/constants/app_colors.dart';
import 'package:pos_mobile_app/features/auth/domain/user.dart';
import 'staff_management_notifier.dart';
import 'staff_form_dialog.dart';

class StaffManagementView extends ConsumerStatefulWidget {
  const StaffManagementView({super.key});

  @override
  ConsumerState<StaffManagementView> createState() => _StaffManagementViewState();
}

class _StaffManagementViewState extends ConsumerState<StaffManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddStaffDialog() {
    showDialog(
      context: context,
      builder: (_) => StaffFormDialog(
        onSave: ({required fullName, required username, required pin, required role, avatarAsset}) {
          ref.read(staffManagementProvider.notifier).addUser(
                fullName: fullName,
                username: username,
                pin: pin,
                role: role,
                avatarAsset: avatarAsset,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.successGreen,
              content: Text('✓ Empleado $fullName registrado con éxito'),
            ),
          );
        },
      ),
    );
  }

  void _openEditStaffDialog(User user) {
    showDialog(
      context: context,
      builder: (_) => StaffFormDialog(
        staffToEdit: user,
        onSave: ({required fullName, required username, required pin, required role, avatarAsset}) {
          ref.read(staffManagementProvider.notifier).updateUser(
                user.copyWith(
                  fullName: fullName,
                  role: role,
                  avatarAsset: avatarAsset,
                ),
                newPin: pin.isNotEmpty ? pin : null,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryAmber,
              content: Text('✓ Datos de $fullName actualizados'),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffManagementProvider);
    final users = staffState.filteredUsers;

    return Column(
      children: [
        // Tab header: Empleados & Auditoría
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight)),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceHighlight),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    color: AppColors.primaryAmber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(
                        children: [
                          const Icon(Icons.people_alt_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text('Directorio (${staffState.users.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          const Icon(Icons.security_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text('Bitácora de Auditoría (${staffState.auditLogs.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _openAddStaffDialog,
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Nuevo Empleado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),

        // Contenido de Tabs
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStaffDirectory(users, staffState.selectedFilterRole),
              _buildAuditLogList(staffState.auditLogs),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaffDirectory(List<User> users, UserRole? selectedFilterRole) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filtros por rol
          Row(
            children: [
              _buildRoleFilterChip(null, 'Todos', selectedFilterRole == null),
              const SizedBox(width: 8),
              _buildRoleFilterChip(UserRole.cashier, 'Cajeros', selectedFilterRole == UserRole.cashier),
              const SizedBox(width: 8),
              _buildRoleFilterChip(UserRole.localBaker, 'Panaderos', selectedFilterRole == UserRole.localBaker),
              const SizedBox(width: 8),
              _buildRoleFilterChip(UserRole.branchManager, 'Gerencia', selectedFilterRole == UserRole.branchManager),
              const SizedBox(width: 8),
              _buildRoleFilterChip(UserRole.globalAdmin, 'Administradores', selectedFilterRole == UserRole.globalAdmin),
            ],
          ),
          const SizedBox(height: 20),

          // Tabla / Tarjetas de Empleados
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceHighlight),
              itemBuilder: (context, idx) {
                final user = users[idx];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(user.avatarAsset ?? 'assets/users/maria_gonzalez.jpg'),
                        backgroundColor: AppColors.surfaceHighlight,
                      ),
                      const SizedBox(width: 16),

                      // Nombre y usuario
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user.isActive ? AppColors.successGreenBg : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    user.isActive ? 'ACTIVO' : 'INACTIVO',
                                    style: TextStyle(
                                      color: user.isActive ? AppColors.successGreen : AppColors.textDisabled,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${user.username} • Sucursal Centro (Horno Principal)',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Badge de Rol
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildRoleBadge(user.role),
                        ),
                      ),

                      // Botones de acción
                      IconButton(
                        tooltip: 'Editar Datos & PIN',
                        icon: const Icon(Icons.edit_rounded, color: AppColors.primaryAmber, size: 20),
                        onPressed: () => _openEditStaffDialog(user),
                      ),
                      IconButton(
                        tooltip: user.isActive ? 'Suspender Empleado' : 'Reactivar Empleado',
                        icon: Icon(
                          user.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                          color: user.isActive ? AppColors.successGreen : AppColors.textDisabled,
                          size: 28,
                        ),
                        onPressed: () => ref.read(staffManagementProvider.notifier).toggleUserStatus(user.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogList(List<dynamic> logs) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceHighlight),
          itemBuilder: (context, idx) {
            final log = logs[idx];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _categoryColor(log.category).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_categoryIcon(log.category), color: _categoryColor(log.category), size: 18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              log.action,
                              style: TextStyle(
                                color: _categoryColor(log.category),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              dateFormat.format(log.timestamp),
                              style: const TextStyle(color: AppColors.textDisabled, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log.details,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Responsable: ${log.userName}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleFilterChip(UserRole? role, String label, bool isSelected) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : AppColors.textMuted,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: AppColors.surfaceCard,
      selectedColor: AppColors.primaryAmber,
      checkmarkColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? AppColors.primaryAmber : AppColors.surfaceHighlight),
      ),
      onSelected: (_) => ref.read(staffManagementProvider.notifier).setFilterRole(role),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color color;
    Color bg;
    String text;

    switch (role) {
      case UserRole.globalAdmin:
        color = const Color(0xFFEF4444);
        bg = const Color(0x22EF4444);
        text = 'Administrador';
        break;
      case UserRole.branchManager:
        color = const Color(0xFF3B82F6);
        bg = const Color(0x223B82F6);
        text = 'Gerente de Sucursal';
        break;
      case UserRole.localBaker:
        color = AppColors.primaryAmber;
        bg = const Color(0x22E89838);
        text = 'Maestro Panadero';
        break;
      case UserRole.cashier:
        color = AppColors.successGreen;
        bg = AppColors.successGreenBg;
        text = 'Cajero / POS';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'CAJA':
        return AppColors.successGreen;
      case 'PRODUCCION':
        return AppColors.primaryAmber;
      case 'AUTH':
        return const Color(0xFF3B82F6);
      case 'RH':
        return const Color(0xFFA855F7);
      default:
        return AppColors.textMuted;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'CAJA':
        return Icons.point_of_sale_rounded;
      case 'PRODUCCION':
        return Icons.bakery_dining_rounded;
      case 'AUTH':
        return Icons.lock_open_rounded;
      case 'RH':
        return Icons.badge_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
