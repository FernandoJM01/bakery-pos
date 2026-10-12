import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../auth/presentation/pin_login_screen.dart';
import '../../auth/domain/user.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../inventory/presentation/stock_notifier.dart';
import 'cart_notifier.dart';
import 'checkout_notifier.dart';
import '../../../core/hardware/printer/console_printer_service.dart';
import '../../../core/hardware/printer/receipt_printer_service.dart';

class CashierDashboardScreen extends ConsumerStatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  ConsumerState<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends ConsumerState<CashierDashboardScreen> {
  String _selectedCategory = 'All';
  List<Product> _allProducts = CatalogRepositoryImpl.defaultProducts;
  List<String> _categories = ['All', 'Breads', 'Viennoiserie', 'Cakes', 'Beverages'];
  String _searchQuery = '';
  String _orderType = 'Takeout'; // Takeout or Dine-in
  bool _isLoading = false;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  final ReceiptPrinterService _printer = ConsolePrinterService();

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
      // Print receipt via ESC/POS protocol
      await _printer.printReceipt(
        branchName: 'Downtown Bakery Oven #1',
        receiptNumber: result.orderId,
        cashierName: cashier.fullName,
        timestamp: DateTime.now(),
        items: cart.itemsList
            .map((i) => ReceiptLineItem(
                  name: i.product.name,
                  quantity: i.quantity,
                  unitPriceCents: i.product.priceCents,
                  totalPriceCents: i.itemTotalCents,
                ))
            .toList(),
        subtotalCents: cart.subtotalCents,
        taxCents: cart.taxCents,
        totalCents: cart.totalCents,
        paymentMethod: 'CASH',
        cashTenderedCents: tenderedCents,
        changeDueCents: result.changeDueCents,
      );

      // Background sync trigger
      ref.read(syncWorkerProvider).syncPendingEvents();

      if (mounted) {
        _showSuccessDialog(result.orderId, result.changeDueCents);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertRed,
            content: Text(result.errorMessage ?? 'Sale failed'),
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String orderId, int changeDueCents) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceHighlight),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 28),
            SizedBox(width: 10),
            Text(
              'Sale Completed!',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Reference: $orderId', style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceHighlight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Change Due:', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  Text(
                    '\$${(changeDueCents / 100).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primaryAmber,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAmber,
              foregroundColor: Colors.black,
              minimumSize: const Size(120, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('NEW SALE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
            Text('Confirm Logout', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to end your current session and return to the PIN terminal, ${user?.fullName ?? "Maria"}?',
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
                      'Unfinished cart items will remain safe on Register 01.',
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
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
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
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final timeStr = DateFormat('hh:mm a').format(_currentTime);

    final filteredProducts = _allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' ||
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
            // 1. Top POS Master Bar (Matching Screen 2 Render)
            _buildTopBar(cashier, timeStr),

            // 2. Main Content: Catalog Grid (60%) + Ticket Sidebar (40%)
            Expanded(
              child: Row(
                children: [
                  // Left Catalog Area
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        // Category Horizontal Bar
                        _buildCategoryBar(),

                        // Product Cards Grid
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(color: AppColors.primaryAmber),
                                )
                              : _buildProductGrid(filteredProducts, stockMap),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider
                  Container(width: 1, color: AppColors.surfaceHighlight),

                  // Right Order Ticket Sidebar
                  Expanded(
                    flex: 4,
                    child: _buildTicketSidebar(cart),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(User? cashier, String timeStr) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
      ),
      child: Row(
        children: [
          // Drawer / Logout Icon
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            tooltip: 'Switch Staff / Logout',
            onPressed: () => _confirmLogout(context, cashier),
          ),

          const SizedBox(width: 8),

          // Cashier Profile Pill with Avatar
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
                  '${cashier?.fullName ?? "Maria Gonzalez"} (Register 01)',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Order Type Toggle Chip [Takeout]
          InkWell(
            onTap: () {
              setState(() {
                _orderType = _orderType == 'Takeout' ? 'Dine-In' : 'Takeout';
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.6)),
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

          const SizedBox(width: 14),

          // Quick Search Input
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
                      decoration: const InputDecoration(
                        hintText: 'Quick Search...',
                        hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 13),
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

          const SizedBox(width: 14),

          // Edge Synced Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreenBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
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
                  'Edge Synced',
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

          // Clock
          Text(
            timeStr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
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

  Widget _buildProductGrid(List<Product> products, Map<String, int> stockMap) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No bakery items match search', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.05,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (context, idx) {
        final product = products[idx];
        final stock = stockMap[product.id] ?? 24; // Default initial stock
        final isSoldOut = stock <= 0;
        final isLowStock = stock > 0 && stock <= 5;

        return InkWell(
          onTap: isSoldOut
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.alertRed,
                      content: Text('${product.name} is currently SOLD OUT!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              : () {
                  ref.read(cartNotifierProvider.notifier).addProduct(product);
                },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Asset or Placeholder
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      color: AppColors.surfaceElevated,
                      child: product.imageAsset != null
                          ? Image.asset(
                              product.imageAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.bakery_dining_rounded,
                                color: AppColors.primaryAmber,
                                size: 40,
                              ),
                            )
                          : const Icon(
                              Icons.bakery_dining_rounded,
                              color: AppColors.primaryAmber,
                              size: 40,
                            ),
                    ),
                  ),

                  // Product Details (Title, Amber Price, Stock Badge)
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                              // Stock pill
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

  Widget _buildStockPill(int stock, bool isSoldOut, bool isLowStock) {
    Color bg;
    Color text;
    String label;

    if (isSoldOut) {
      bg = AppColors.alertRedBg;
      text = AppColors.alertRed;
      label = '✕ Sold Out';
    } else if (isLowStock) {
      bg = AppColors.primaryAmber.withValues(alpha: 0.18);
      text = AppColors.primaryAmber;
      label = '● $stock left - Low';
    } else {
      bg = AppColors.successGreenBg;
      text = AppColors.successGreen;
      label = '● $stock in stock';
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

  Widget _buildTicketSidebar(CartState cart) {
    return Container(
      color: AppColors.surfaceCard,
      child: Column(
        children: [
          // Ticket Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Order #104',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${cart.itemCount} items)',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
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
                      child: Text('Clear Ticket', style: TextStyle(color: AppColors.alertRed)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceHighlight),

          // Scrollable Line Items List
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_basket_outlined, color: AppColors.textDisabled, size: 48),
                        SizedBox(height: 12),
                        Text('Ticket is Empty', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                        SizedBox(height: 4),
                        Text('Tap bakery products to add', style: TextStyle(color: AppColors.textDisabled, fontSize: 12)),
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
                            // Product Name
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Stepper Controls [-] [Qty] [+]
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
                                        .removeProduct(item.product.id),
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
                                        .addProduct(item.product),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.add_rounded, color: AppColors.primaryAmber, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Item Price
                            SizedBox(
                              width: 58,
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

          // Order Totals Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
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
                    const Text('8% tax', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    Text(
                      '\$${(cart.taxCents / 100).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total due',
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

                // Quick 1-Tap Cash Tender Presets Bar
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quick 1-tap cash tender',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _buildTenderChip('Exact \$${(cart.totalCents / 100).toStringAsFixed(2)}', cart.totalCents, cart),
                    const SizedBox(width: 6),
                    _buildTenderChip('\$25.00', 2500, cart),
                    const SizedBox(width: 6),
                    _buildTenderChip('\$30.00', 3000, cart),
                    const SizedBox(width: 6),
                    _buildTenderChip('\$50.00', 5000, cart),
                  ],
                ),

                const SizedBox(height: 14),

                // Massive Complete Cash Sale Button (Height: 60dp)
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
                      'COMPLETE CASH SALE (\$${(cart.totalCents / 100).toStringAsFixed(2)})',
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
            color: isEnabled ? AppColors.surfaceElevated : AppColors.surfaceHighlight.withValues(alpha: 0.3),
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
