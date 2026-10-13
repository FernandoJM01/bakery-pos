import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile_app/core/constants/app_colors.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/pin_login_screen.dart';
import '../../admin_dashboard/presentation/admin_dashboard_screen.dart';
import '../../pos/presentation/cashier_dashboard_screen.dart';
import '../../baking/presentation/bake_sheet_console_view.dart';
import '../../staff/presentation/staff_management_view.dart';
import '../../inventory/presentation/manager_reconciliation_screen.dart';
import '../../promotions/presentation/promotions_dialog.dart';

class EnterpriseShellScreen extends ConsumerStatefulWidget {
  final User user;
  final int initialIndex;

  const EnterpriseShellScreen({
    super.key,
    required this.user,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<EnterpriseShellScreen> createState() => _EnterpriseShellScreenState();
}

class _EnterpriseShellScreenState extends ConsumerState<EnterpriseShellScreen> {
  late int _selectedIndex;
  bool _isSidebarCollapsed = false;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceHighlight),
        ),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.primaryAmber, size: 24),
            SizedBox(width: 10),
            Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas salir del sistema? Tu turno y las operaciones activas quedarán resguardadas.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(currentUserProvider.notifier).state = null;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PinLoginScreen()),
              );
            },
            child: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openPromotionsModal() {
    showDialog(
      context: context,
      builder: (_) => const PromotionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Row(
        children: [
          // Barra lateral izquierda (Left Sidebar) en Tablet y Desktop
          if (!isMobile) _buildSidebar(isMobile),

          // Área principal de trabajo con TopBar
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isMobile),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      AdminDashboardScreen(admin: widget.user, initialTab: 0),
                      const CashierDashboardScreen(),
                      AdminDashboardScreen(admin: widget.user, initialTab: 1),
                      const BakeSheetConsoleView(),
                      const StaffManagementView(),
                      ManagerReconciliationScreen(manager: widget.user),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildMobileBottomNav() : null,
    );
  }

  Widget _buildSidebar(bool isMobile) {
    final width = _isSidebarCollapsed ? 76.0 : 250.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(right: BorderSide(color: AppColors.surfaceHighlight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo & Branding
          Container(
            padding: EdgeInsets.symmetric(horizontal: _isSidebarCollapsed ? 12 : 20, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryAmber.withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.bakery_dining_rounded, color: AppColors.primaryAmber, size: 22),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'MIGA & HORNO',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'Panadería Artesanal',
                          style: TextStyle(color: AppColors.primaryAmber, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menú de navegación
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: [
                _buildNavItem(0, 'Dashboard', Icons.dashboard_rounded),
                _buildNavItem(1, 'POS Caja', Icons.point_of_sale_rounded),
                _buildNavItem(2, 'Catálogo & Sabores', Icons.inventory_2_rounded),
                _buildNavItem(3, 'Horno & Producción', Icons.outdoor_grill_rounded),
                _buildNavItem(4, 'Personal & Roles', Icons.badge_rounded),
                _buildNavItem(5, 'Cortes Z & Turnos', Icons.receipt_long_rounded),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.surfaceHighlight),
                const SizedBox(height: 12),
                _buildQuickActionItem('Combos & Ofertas', Icons.local_offer_rounded, _openPromotionsModal),
              ],
            ),
          ),

          // Tarjeta de usuario activo & Logout
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.surfaceHighlight)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(widget.user.avatarAsset ?? 'assets/users/elena_rostova.jpg'),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullName,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.user.roleDisplayName,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar Sesión',
                    icon: const Icon(Icons.logout_rounded, color: AppColors.alertRed, size: 20),
                    onPressed: _confirmLogout,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _isSidebarCollapsed ? 12 : 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryAmber.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryAmber.withOpacity(0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryAmber : AppColors.textMuted, size: 20),
              if (!_isSidebarCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _isSidebarCollapsed ? 12 : 14, vertical: 12),
          child: Row(
            mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryAmber, size: 20),
              if (!_isSidebarCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryAmber,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final dateStr = '${_currentTime.day} ${months[_currentTime.month - 1]} ${_currentTime.year}';

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight)),
      ),
      child: Row(
        children: [
          if (!isMobile)
            IconButton(
              icon: Icon(_isSidebarCollapsed ? Icons.menu_open_rounded : Icons.menu_rounded, color: AppColors.textMuted),
              onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _sectionTitle(_selectedIndex),
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Text(
            '$timeStr  •  $dateStr',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          if (isMobile) ...[
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.alertRed, size: 20),
              onPressed: _confirmLogout,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      backgroundColor: AppColors.surfaceElevated,
      selectedItemColor: AppColors.primaryAmber,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_rounded), label: 'Caja'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Catálogo'),
        BottomNavigationBarItem(icon: Icon(Icons.outdoor_grill_rounded), label: 'Horno'),
        BottomNavigationBarItem(icon: Icon(Icons.badge_rounded), label: 'Personal'),
      ],
    );
  }

  String _sectionTitle(int index) {
    switch (index) {
      case 0:
        return 'Panel Ejecutivo & KPIs';
      case 1:
        return 'Punto de Venta (POS Mostrador)';
      case 2:
        return 'Catálogo de Panadería & Sabores';
      case 3:
        return 'Consola de Horno & Producción';
      case 4:
        return 'Gestión de Personal & Recursos Humanos';
      case 5:
        return 'Arqueo de Caja & Cortes Z';
      default:
        return 'Panadería Artesanal';
    }
  }
}
