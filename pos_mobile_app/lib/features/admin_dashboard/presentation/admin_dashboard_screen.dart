import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_strings.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/pin_login_screen.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../promotions/domain/promotion_rule.dart';
import '../../promotions/presentation/promotions_dialog.dart';
import '../../admin_catalog/presentation/admin_product_form_dialog.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final User? admin;

  const AdminDashboardScreen({
    super.key,
    this.admin,
  });

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  // Pestaña activa: 0 = Resumen Ejecutivo, 1 = Catálogo & Precios, 2 = Reportes de Ventas
  int _activeTab = 0;

  // Catálogo reactivo administrable localmente
  List<Product> _catalogProducts = List.from(CatalogRepositoryImpl.defaultProducts);

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _openCreateProductDialog() {
    showDialog(
      context: context,
      builder: (_) => AdminProductFormDialog(
        onSave: (newProduct) {
          setState(() {
            _catalogProducts = [newProduct, ..._catalogProducts];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.successGreen,
              content: Text('✓ Producto "${newProduct.name}" agregado al catálogo'),
            ),
          );
        },
      ),
    );
  }

  void _openEditProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (_) => AdminProductFormDialog(
        productToEdit: product,
        onSave: (updated) {
          setState(() {
            final idx = _catalogProducts.indexWhere((p) => p.id == updated.id);
            if (idx != -1) {
              _catalogProducts[idx] = updated;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.successGreen,
              content: Text('✓ Producto "${updated.name}" actualizado con éxito'),
            ),
          );
        },
      ),
    );
  }

  void _openPromotionsDialog() {
    showDialog(
      context: context,
      builder: (_) => const PromotionsDialog(),
    );
  }

  void _confirmLogout(BuildContext context, User? admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.surfaceHighlight),
        ),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.primaryAmber, size: 24),
            SizedBox(width: 10),
            Text(AppStrings.confirmLogout, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          '¿Deseas salir del Backoffice Ejecutivo y volver al acceso con PIN, ${admin?.fullName ?? "Administrador"}?',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PinLoginScreen()),
              );
            },
            child: const Text(AppStrings.logOut, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(_currentTime);
    final adminName = widget.admin?.fullName ?? 'Elena Rostova';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra Superior Ejecutiva
            _buildTopExecutiveBar(timeStr, adminName, isMobile),

            // 2. Barra de Navegación de Pestañas Backoffice
            _buildNavigationTabs(),

            // 3. Contenido Principal Dinámico
            Expanded(
              child: _activeTab == 0
                  ? _buildOverviewTab(isMobile)
                  : (_activeTab == 1 ? _buildCatalogManagementTab(isMobile) : _buildReportsTab(isMobile)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExecutiveBar(String timeStr, String adminName, bool isMobile) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14.0 : 24.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            tooltip: AppStrings.logOut,
            onPressed: () => _confirmLogout(context, widget.admin),
          ),
          const SizedBox(width: 8),

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_rounded, color: AppColors.primaryAmber, size: 22),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'PANADERÍA ARTESANAL • BACKOFFICE EJECUTIVO',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Sucursal Centro (Horno Principal) • Modo Administrador',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          if (!isMobile) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceHighlight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryAmber, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    adminName,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],

          Text(
            timeStr,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight)),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Panel General', Icons.dashboard_rounded),
          const SizedBox(width: 16),
          _buildTabItem(1, 'Catálogo y Precios', Icons.inventory_2_rounded),
          const SizedBox(width: 16),
          _buildTabItem(2, 'Reportes y Auditoría', Icons.analytics_rounded),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAmber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _openPromotionsDialog,
            icon: const Icon(Icons.local_offer_rounded, size: 16),
            label: const Text('Combos y Promociones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final isSelected = _activeTab == index;

    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryAmber : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primaryAmber : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primaryAmber : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjetas de Métricas Ejecutivas (KPIs)
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: constraints.maxWidth < 600 ? 1.4 : 1.7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildKpiCard('VENTAS DEL DÍA', '\$1,450.00', '+18.4% vs ayer', Icons.payments_rounded, AppColors.successGreen),
                  _buildKpiCard('TICKET PROMEDIO', '\$8.40', '2.8 art. por venta', Icons.receipt_long_rounded, AppColors.primaryAmber),
                  _buildKpiCard('TOTAL PEDIDOS', '64', '52 Mostrador / 12 Mesa', Icons.shopping_bag_rounded, AppColors.primaryAmber),
                  _buildKpiCard('MARGEN BRUTO', '68.2%', 'Meta: ≥ 65.0%', Icons.pie_chart_rounded, AppColors.successGreen),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Gráfica de Tendencia Horaria + Top 5 Más Vendidos
          isMobile
              ? Column(
                  children: [
                    _buildHourlyTrendCard(),
                    const SizedBox(height: 16),
                    _buildTopSellersCard(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildHourlyTrendCard()),
                    const SizedBox(width: 18),
                    Expanded(flex: 4, child: _buildTopSellersCard()),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String subtitle, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyTrendCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  'Afluencia y Ventas por Hora',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Pico: 08:00 - 11:00 hrs',
                style: TextStyle(color: AppColors.primaryAmber, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Simulación visual elegante de barras por hora
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildHourlyBar('07:00', 30, '\$90'),
                _buildHourlyBar('08:00', 75, '\$240'),
                _buildHourlyBar('09:00', 95, '\$310'),
                _buildHourlyBar('10:00', 80, '\$280'),
                _buildHourlyBar('11:00', 60, '\$190'),
                _buildHourlyBar('12:00', 45, '\$145'),
                _buildHourlyBar('13:00', 35, '\$110'),
                _buildHourlyBar('14:00', 25, '\$85'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyBar(String hour, double height, String amount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            const SizedBox(height: 6),
            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.primaryAmber, Color(0xFFF3A646)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(hour, style: const TextStyle(color: AppColors.textDisabled, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellersCard() {
    final topList = [
      {'name': 'Croissant de Mantequilla', 'qty': '84 pzas', 'revenue': '\$273.00'},
      {'name': 'Hogaza Campesina Masa Madre', 'qty': '38 pzas', 'revenue': '\$247.00'},
      {'name': 'Café Flat White', 'qty': '46 tazas', 'revenue': '\$230.00'},
      {'name': 'Pain au Chocolat', 'qty': '42 pzas', 'revenue': '\$157.50'},
      {'name': 'Tarta de Frutos Rojos', 'qty': '24 pzas', 'revenue': '\$108.00'},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 Productos Más Vendidos',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          ...topList.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${topList.indexOf(item) + 1}',
                        style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name']!,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item['qty']!,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item['revenue']!,
                      style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCatalogManagementTab(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Catálogo Activo (${_catalogProducts.length} productos)',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _openCreateProductDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nuevo Producto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceHighlight),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _catalogProducts.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceHighlight),
                itemBuilder: (context, idx) {
                  final p = _catalogProducts[idx];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: AppColors.surfaceElevated,
                        child: p.imageAsset != null
                            ? Image.asset(
                                p.imageAsset!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.bakery_dining_rounded, color: AppColors.primaryAmber),
                              )
                            : const Icon(Icons.bakery_dining_rounded, color: AppColors.primaryAmber),
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      'SKU: ${p.sku} • Categoría: ${p.category}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${(p.priceCents / 100).toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppColors.textMuted, size: 20),
                          tooltip: 'Editar',
                          onPressed: () => _openEditProductDialog(p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.alertRed, size: 20),
                          tooltip: 'Eliminar',
                          onPressed: () {
                            setState(() {
                              _catalogProducts.removeAt(idx);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auditoría y Reportes de Venta',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: const [
                          Icon(Icons.description_rounded, color: AppColors.primaryAmber, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Historial de Cortes Z (Cierres de Turno)',
                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryAmber,
                        side: const BorderSide(color: AppColors.primaryAmber),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.successGreen,
                            content: Text('✓ Reporte Z exportado a PDF/Excel con éxito'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Exportar Todo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildReportRow('CORTE-Z-20261012-1400', 'Elena Rostova (Gerencia)', '\$945.50', 'Cuadrada (\$0.00)'),
                const Divider(height: 20, color: AppColors.surfaceHighlight),
                _buildReportRow('CORTE-Z-20261011-1900', 'Maria Gonzalez (Caja 01)', '\$845.50', 'Sobrante (+\$10.00)'),
                const Divider(height: 20, color: AppColors.surfaceHighlight),
                _buildReportRow('CORTE-Z-20261010-1830', 'Elena Rostova (Gerencia)', '\$1,120.00', 'Cuadrada (\$0.00)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String id, String cashier, String total, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(id, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 3),
            Text(cashier, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
        Row(
          children: [
            Text(total, style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successGreenBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
