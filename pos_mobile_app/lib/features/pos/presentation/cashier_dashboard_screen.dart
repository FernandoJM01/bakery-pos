import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_strings.dart';
import '../../auth/presentation/pin_login_screen.dart';
import '../../auth/domain/user.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../inventory/presentation/stock_notifier.dart';
import 'cart_notifier.dart';
import 'checkout_notifier.dart';
import 'held_tickets_notifier.dart';
import 'held_tickets_dialog.dart';
import 'receipt_preview_dialog.dart';
import 'widgets/variant_selector_dialog.dart';
import '../../promotions/presentation/promotions_dialog.dart';
import '../../promotions/presentation/promotions_notifier.dart';
import '../../../core/hardware/printer/console_printer_service.dart';
import '../../../core/hardware/printer/receipt_printer_service.dart';

class CashierDashboardScreen extends ConsumerStatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  ConsumerState<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends ConsumerState<CashierDashboardScreen> {
  String _selectedCategory = AppStrings.allCategories;
  List<Product> _allProducts = CatalogRepositoryImpl.defaultProducts;
  final List<String> _categories = [
    AppStrings.allCategories,
    AppStrings.catBreads,
    AppStrings.catViennoiserie,
    AppStrings.catCakes,
    AppStrings.catBeverages,
  ];
  String _searchQuery = '';
  String _orderType = AppStrings.takeout;
  bool _isLoading = false;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  final ReceiptPrinterService _printer = ConsolePrinterService();

  // Para control responsive en móviles: 0 = Catálogo, 1 = Ticket/Carrito
  int _mobileTab = 0;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
    _loadCatalog();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    try {
      final catalogRepo = ref.read(catalogRepositoryProvider);
      final products = await catalogRepo.getProducts();

      if (mounted && products.isNotEmpty) {
        setState(() {
          _allProducts = products;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processSale(int tenderedCents) async {
    final cart = ref.read(cartNotifierProvider);
    if (cart.isEmpty) return;

    // Tomar snapshot inmediato de los productos y montos para el recibo
    final itemsSnapshot = List<CartItem>.from(cart.itemsList);
    final subtotal = cart.subtotalCents;
    final tax = cart.taxCents;
    final total = cart.totalCents;

    final cashier = ref.read(currentUserProvider) ??
        const User(
          id: 'b0000000-0000-0000-0000-000000000001',
          branchId: 'a0000000-0000-0000-0000-000000000001',
          username: 'cashier1',
          pinHash: '',
          fullName: 'Maria Gonzalez',
          role: UserRole.cashier,
        );

    final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);
    final result = await checkoutNotifier.processCashCheckout(
      cashTenderedCents: tenderedCents,
      cashier: cashier,
      terminalId: 'REG-01',
    );

    if (result.isSuccess) {
      // Limpiar ticket de forma inmediata para el siguiente cliente
      ref.read(cartNotifierProvider.notifier).clearCart();

      // Imprimir via protocolo ESC/POS en background
      _printReceipt(
        orderId: result.orderId,
        cashierName: cashier.fullName,
        items: itemsSnapshot,
        subtotal: subtotal,
        tax: tax,
        total: total,
        tenderedCents: tenderedCents,
        changeDueCents: result.changeDueCents,
      );

      // Trigger background sync
      ref.read(syncWorkerProvider).syncPendingEvents();

      if (mounted) {
        // Mostrar Modal Interactivo de Recibo Digital
        _showReceiptDialog(
          orderId: result.orderId,
          cashierName: cashier.fullName,
          items: itemsSnapshot,
          subtotal: subtotal,
          tax: tax,
          total: total,
          tenderedCents: tenderedCents,
          changeDueCents: result.changeDueCents,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertRed,
            content: Text(result.errorMessage ?? 'Error al procesar la venta'),
          ),
        );
      }
    }
  }

  Future<void> _printReceipt({
    required String orderId,
    required String cashierName,
    required List<CartItem> items,
    required int subtotal,
    required int tax,
    required int total,
    required int tenderedCents,
    required int changeDueCents,
  }) async {
    await _printer.printReceipt(
      branchName: AppStrings.branchDowntown,
      receiptNumber: orderId,
      cashierName: cashierName,
      timestamp: DateTime.now(),
      items: items
          .map((i) => ReceiptLineItem(
                name: i.product.name,
                quantity: i.quantity,
                unitPriceCents: i.product.priceCents,
                totalPriceCents: i.itemTotalCents,
              ))
          .toList(),
      subtotalCents: subtotal,
      taxCents: tax,
      totalCents: total,
      paymentMethod: 'EFECTIVO',
      cashTenderedCents: tenderedCents,
      changeDueCents: changeDueCents,
    );
  }

  void _showReceiptDialog({
    required String orderId,
    required String cashierName,
    required List<CartItem> items,
    required int subtotal,
    required int tax,
    required int total,
    required int tenderedCents,
    required int changeDueCents,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ReceiptPreviewDialog(
        orderId: orderId,
        cashierName: cashierName,
        items: items,
        subtotalCents: subtotal,
        taxCents: tax,
        totalCents: total,
        cashTenderedCents: tenderedCents,
        changeDueCents: changeDueCents,
        onPrint: () {
          _printReceipt(
            orderId: orderId,
            cashierName: cashierName,
            items: items,
            subtotal: subtotal,
            tax: tax,
            total: total,
            tenderedCents: tenderedCents,
            changeDueCents: changeDueCents,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.successGreen,
              content: Text('Ticket enviado a impresora térmica ESC/POS'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onNewSale: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _onProductTap(Product product) {
    if (product.hasVariants) {
      showDialog(
        context: context,
        builder: (_) => VariantSelectorDialog(
          product: product,
          onSelectVariant: (variant) {
            ref.read(cartNotifierProvider.notifier).addProduct(product, variant: variant);
          },
        ),
      );
    } else {
      ref.read(cartNotifierProvider.notifier).addProduct(product);
    }
  }

  void _handleHoldOrder() {
    final cart = ref.read(cartNotifierProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primaryAmber,
          content: Text('Agrega al menos un producto al ticket antes de pausar.'),
        ),
      );
      return;
    }

    final controller = TextEditingController();
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
            Icon(Icons.pause_circle_filled_rounded, color: AppColors.primaryAmber, size: 24),
            SizedBox(width: 10),
            Text(AppStrings.holdOrder, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.holdOrderPrompt,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'ej. Cliente con prisa, Mesa 2',
                hintStyle: const TextStyle(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAmber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final label = controller.text.trim();
              final cashier = ref.read(currentUserProvider)?.fullName ?? 'Maria Gonzalez';
              ref.read(heldTicketsNotifierProvider.notifier).parkCart(
                    label: label.isEmpty ? 'Orden Pausada' : label,
                    cashierName: cashier,
                    items: cart.itemsList,
                    totalCents: cart.totalCents,
                  );
              ref.read(cartNotifierProvider.notifier).clearCart();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.successGreen,
                  content: Text(AppStrings.orderParkedSuccess),
                ),
              );
            },
            child: const Text(AppStrings.save, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showHeldOrdersDialog() {
    final heldTickets = ref.watch(heldTicketsNotifierProvider);
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final liveHeld = ref.watch(heldTicketsNotifierProvider);
          return HeldTicketsDialog(
            heldTickets: liveHeld,
            onResume: (ticket) {
              ref.read(heldTicketsNotifierProvider.notifier).resumeTicket(ticket.id);
              ref.read(cartNotifierProvider.notifier).restoreItems(ticket.items);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.successGreen,
                  content: Text(AppStrings.orderResumedSuccess),
                ),
              );
            },
            onDelete: (id) {
              ref.read(heldTicketsNotifierProvider.notifier).deleteTicket(id);
            },
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context, User? user) {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.logoutPrompt} (${user?.fullName ?? "Maria Gonzalez"})',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded, color: AppColors.primaryAmber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.itemsStaySafe,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    final cashier = ref.watch(currentUserProvider);
    final stockMap = ref.watch(stockNotifierProvider);
    final cart = ref.watch(cartNotifierProvider);
    final heldTickets = ref.watch(heldTicketsNotifierProvider);
    final timeStr = DateFormat('hh:mm a').format(_currentTime);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final filteredProducts = _allProducts.where((p) {
      final matchesCategory = _selectedCategory == AppStrings.allCategories ||
          _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            // Barra Superior Principal
            _buildTopBar(cashier, timeStr, heldTickets.length, isMobile),

            // Contenido Principal Responsive
            Expanded(
              child: isMobile
                  ? (_mobileTab == 0
                      ? Column(
                          children: [
                            _buildCategoryBar(),
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmber))
                                  : _buildProductGrid(filteredProducts, stockMap, isMobile),
                            ),
                          ],
                        )
                      : _buildTicketSidebar(cart, isMobile))
                  : Row(
                      children: [
                        // Panel Izquierdo: Catálogo de productos (60%)
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildCategoryBar(),
                              Expanded(
                                child: _isLoading
                                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmber))
                                    : _buildProductGrid(filteredProducts, stockMap, false),
                              ),
                            ],
                          ),
                        ),

                        // Divisor Vertical
                        Container(width: 1, color: AppColors.surfaceHighlight),

                        // Panel Derecho: Sidebar del Ticket (40%)
                        Expanded(
                          flex: 4,
                          child: _buildTicketSidebar(cart, false),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      // Barra Inferior Móvil para alternar entre Catálogo y Ticket
      bottomNavigationBar: isMobile
          ? Container(
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(top: BorderSide(color: AppColors.surfaceHighlight)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _mobileTab = 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grid_view_rounded, color: _mobileTab == 0 ? AppColors.primaryAmber : AppColors.textMuted),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.allCategories,
                            style: TextStyle(
                              color: _mobileTab == 0 ? AppColors.primaryAmber : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: _mobileTab == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _mobileTab = 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Badge(
                            label: Text('${cart.itemCount}'),
                            isLabelVisible: cart.itemCount > 0,
                            backgroundColor: AppColors.primaryAmber,
                            textColor: Colors.black,
                            child: Icon(Icons.shopping_cart_rounded, color: _mobileTab == 1 ? AppColors.primaryAmber : AppColors.textMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppStrings.currentOrder} (\$${(cart.totalCents / 100).toStringAsFixed(2)})',
                            style: TextStyle(
                              color: _mobileTab == 1 ? AppColors.primaryAmber : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: _mobileTab == 1 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildTopBar(User? cashier, String timeStr, int heldCount, bool isMobile) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
      ),
      child: Row(
        children: [
          // Botón de Cerrar Sesión
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            tooltip: AppStrings.logOut,
            onPressed: () => _confirmLogout(context, cashier),
          ),

          const SizedBox(width: 4),

          // Avatar y Nombre de Cajero
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: cashier?.avatarAsset != null
                      ? Image.asset(
                          cashier!.avatarAsset!,
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 20, color: AppColors.primaryAmber),
                        )
                      : const Icon(Icons.person_rounded, size: 20, color: AppColors.primaryAmber),
                ),
                const SizedBox(width: 8),
                Text(
                  '${cashier?.fullName ?? "Maria Gonzalez"}${isMobile ? "" : " (Caja 01)"}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Botón de Órdenes en Espera con Badge
          InkWell(
            onTap: _showHeldOrdersDialog,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: heldCount > 0 ? AppColors.primaryAmber.withOpacity(0.18) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: heldCount > 0 ? AppColors.primaryAmber : AppColors.surfaceHighlight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pause_circle_outline_rounded,
                    color: heldCount > 0 ? AppColors.primaryAmber : AppColors.textMuted,
                    size: 18,
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.heldOrders,
                      style: TextStyle(
                        color: heldCount > 0 ? AppColors.primaryAmber : AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (heldCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAmber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$heldCount',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Selector de Tipo de Orden: Para Llevar / Mesa
          if (!isMobile)
            InkWell(
              onTap: () {
                setState(() {
                  _orderType = _orderType == AppStrings.takeout ? AppStrings.dineIn : AppStrings.takeout;
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primaryAmber.withOpacity(0.6)),
                ),
                child: Text(
                  '[$_orderType]',
                  style: const TextStyle(
                    color: AppColors.primaryAmber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          const SizedBox(width: 10),

          // Buscador Rápido
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceHighlight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: isMobile ? 'Buscar...' : AppStrings.searchPlaceholder,
                        hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _searchQuery = ''),
                      child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 16),
                    ),
                ],
              ),
            ),
          ),

          if (!isMobile) ...[
            const SizedBox(width: 14),
            // Badge Edge Synced
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successGreenBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Sincronizado',
                    style: TextStyle(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Reloj
            Text(
              timeStr,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, idx) {
          final cat = _categories[idx];
          final isSelected = cat.toLowerCase() == _selectedCategory.toLowerCase();

          return InkWell(
            onTap: () => setState(() => _selectedCategory = cat),
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
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryAmber : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products, Map<String, int> stockMap, bool isMobile) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No hay productos que coincidan', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    final crossAxisCount = isMobile ? 2 : (MediaQuery.of(context).size.width > 1200 ? 4 : 3);

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 0.95 : 1.05,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, idx) {
        final product = products[idx];
        final stock = stockMap[product.id] ?? 24;
        final isSoldOut = stock <= 0;
        final isLowStock = stock > 0 && stock <= 5;

        return InkWell(
          onTap: isSoldOut
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.alertRed,
                      content: Text('¡${product.name} está AGOTADO!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              : () => _onProductTap(product),
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: isSoldOut ? 0.55 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSoldOut ? AppColors.alertRed.withOpacity(0.3) : AppColors.surfaceHighlight,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagen del Producto
                  Expanded(
                    flex: 6,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        product.imageAsset != null
                            ? Image.asset(
                                product.imageAsset!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildImagePlaceholder(product),
                              )
                            : _buildImagePlaceholder(product),
                        if (product.hasVariants)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.primaryAmber.withOpacity(0.5), width: 0.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.tune_rounded, color: AppColors.primaryAmber, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.variants.length} Sabores',
                                    style: const TextStyle(
                                      color: AppColors.primaryAmber,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (isSoldOut)
                          Container(
                            color: Colors.black.withOpacity(0.55),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.alertRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'AGOTADO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Info del producto: Nombre, Precio y Stock
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${(product.priceCents / 100).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.primaryAmber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              _buildStockPill(stock, isSoldOut, isLowStock),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder(Product product) {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Icon(
          product.category == AppStrings.catBeverages ? Icons.coffee_rounded : Icons.bakery_dining_rounded,
          color: AppColors.primaryAmber,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildStockPill(int stock, bool isSoldOut, bool isLowStock) {
    Color bg;
    Color text;
    String label;

    if (isSoldOut) {
      bg = AppColors.alertRedBg;
      text = AppColors.alertRed;
      label = '✕ Agotado';
    } else if (isLowStock) {
      bg = AppColors.primaryAmber.withOpacity(0.18);
      text = AppColors.primaryAmber;
      label = '● $stock restan';
    } else {
      bg = AppColors.successGreenBg;
      text = AppColors.successGreen;
      label = '● $stock pzas';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTicketSidebar(CartState cart, bool isMobile) {
    return Container(
      color: AppColors.surfaceCard,
      child: Column(
        children: [
          // Encabezado del Ticket
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '${AppStrings.orderNumber}104',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${cart.itemCount} art.)',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Botón de Pausar Orden
                    IconButton(
                      icon: const Icon(Icons.pause_circle_outline_rounded, color: AppColors.primaryAmber),
                      tooltip: AppStrings.holdOrder,
                      onPressed: cart.isEmpty ? null : _handleHoldOrder,
                    ),
                    // Menú de opciones
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                      color: AppColors.surfaceElevated,
                      onSelected: (val) {
                        if (val == 'clear') {
                          ref.read(cartNotifierProvider.notifier).clearCart();
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'clear',
                          child: Text(AppStrings.clear, style: TextStyle(color: AppColors.alertRed)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceHighlight),

          // Lista de Artículos
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.shopping_basket_outlined, color: AppColors.textDisabled, size: 48),
                        SizedBox(height: 12),
                        Text(AppStrings.emptyCartTitle, style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                        SizedBox(height: 4),
                        Text(AppStrings.emptyCartSubtitle, style: TextStyle(color: AppColors.textDisabled, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: cart.itemsList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceHighlight),
                    itemBuilder: (context, idx) {
                      final item = cart.itemsList[idx];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            // Nombre del Producto y Variante
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.selectedVariant != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        '• ${item.selectedVariant!.name}',
                                        style: const TextStyle(
                                          color: AppColors.primaryAmber,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Controles de Cantidad [-] [Qty] [+]
                            Container(
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.surfaceHighlight),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => ref
                                        .read(cartNotifierProvider.notifier)
                                        .removeProduct(item.cartKey),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.remove_rounded, color: AppColors.textMuted, size: 16),
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => ref
                                        .read(cartNotifierProvider.notifier)
                                        .addProduct(item.product, variant: item.selectedVariant),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.add_rounded, color: AppColors.primaryAmber, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Precio del Artículo
                            SizedBox(
                              width: 60,
                              child: Text(
                                '\$${(item.itemTotalCents / 100).toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const Divider(height: 1, color: AppColors.surfaceHighlight),

          // Resumen de Totales y Cobro
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(AppStrings.subtotal, style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    Text(
                      '\$${(cart.subtotalCents / 100).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(AppStrings.taxVat, style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    Text(
                      '\$${(cart.taxCents / 100).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Botón de Promociones y Descuentos
                InkWell(
                  onTap: () => showDialog(context: context, builder: (_) => const PromotionsDialog()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryAmber.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.local_offer_rounded, color: AppColors.primaryAmber, size: 16),
                            SizedBox(width: 8),
                            Text('Aplicar Combo o Descuento', style: TextStyle(color: AppColors.primaryAmber, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppColors.primaryAmber, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.total,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${(cart.totalCents / 100).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Presets Rápidos de Efectivo
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Cobro rápido en efectivo:',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _buildTenderChip('${AppStrings.exactCash} \$${(cart.totalCents / 100).toStringAsFixed(2)}', cart.totalCents, cart),
                    const SizedBox(width: 6),
                    _buildTenderChip('\$25.00', 2500, cart),
                    const SizedBox(width: 6),
                    _buildTenderChip('\$30.00', 3000, cart),
                    const SizedBox(width: 6),
                    _buildTenderChip('\$50.00', 5000, cart),
                  ],
                ),

                const SizedBox(height: 14),

                // Botón Principal de Cobro
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAmber,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: cart.isEmpty ? null : () => _processSale(cart.totalCents),
                    child: Text(
                      '${AppStrings.tenderCash.toUpperCase()} (\$${(cart.totalCents / 100).toStringAsFixed(2)})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenderChip(String label, int amountCents, CartState cart) {
    final isEnabled = !cart.isEmpty && amountCents >= cart.totalCents;

    return Expanded(
      child: InkWell(
        onTap: isEnabled ? () => _processSale(amountCents) : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.surfaceElevated : AppColors.surfaceHighlight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isEnabled ? AppColors.surfaceHighlight : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
