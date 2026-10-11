import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../auth/presentation/pin_login_screen.dart';
import '../../catalog/domain/product.dart';
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
  String _selectedCategory = 'ALL';
  List<Product> _allProducts = [];
  List<String> _categories = ['ALL'];
  bool _isLoading = true;
  final ReceiptPrinterService _printer = ConsolePrinterService();

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    final catalogRepo = ref.read(catalogRepositoryProvider);
    final products = await catalogRepo.getProducts();
    final categories = await catalogRepo.getCategories();

    setState(() {
      _allProducts = products;
      _categories = categories;
      _isLoading = false;
    });
  }

  void _showCheckoutDialog() {
    final cart = ref.read(cartNotifierProvider);
    if (cart.isEmpty) return;

    final cashier = ref.read(currentUserProvider);
    if (cashier == null) return;

    int tenderedCents = cart.totalCents; // default exact cash

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final changeCents = tenderedCents - cart.totalCents;
          final isTenderValid = changeCents >= 0;

          return AlertDialog(
            backgroundColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              side: const BorderSide(color: AppColors.surfaceHighlight),
            ),
            title: Row(
              children: [
                const Icon(Icons.payments, color: AppColors.primaryAmber, size: 28),
                const SizedBox(width: 12),
                Text('CASH CHECKOUT', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDeep,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount Due:', style: TextStyle(color: AppColors.textMuted)),
                            Text(
                              '\$${(cart.totalCents / 100).toStringAsFixed(2)}',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.surfaceHighlight, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Cash Tendered:', style: TextStyle(color: AppColors.textMuted)),
                            Text(
                              '\$${(tenderedCents / 100).toStringAsFixed(2)}',
                              style: const TextStyle(color: AppColors.primaryAmber, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Change Due:', style: TextStyle(color: AppColors.textMuted)),
                            Text(
                              isTenderValid ? '\$${(changeCents / 100).toStringAsFixed(2)}' : 'INSUFFICIENT',
                              style: TextStyle(
                                color: isTenderValid ? AppColors.successGreen : AppColors.alertRed,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('QUICK TENDER PRESETS', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildPresetChip('Exact (\$${(cart.totalCents / 100).toStringAsFixed(2)})', cart.totalCents, () {
                        setDialogState(() => tenderedCents = cart.totalCents);
                      }),
                      _buildPresetChip('\$10.00', 1000, () {
                        setDialogState(() => tenderedCents = 1000);
                      }),
                      _buildPresetChip('\$20.00', 2000, () {
                        setDialogState(() => tenderedCents = 2000);
                      }),
                      _buildPresetChip('\$50.00', 5000, () {
                        setDialogState(() => tenderedCents = 5000);
                      }),
                      _buildPresetChip('\$100.00', 10000, () {
                        setDialogState(() => tenderedCents = 10000);
                      }),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(140, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: !isTenderValid
                    ? null
                    : () async {
                        final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);
                        final result = await checkoutNotifier.processCashCheckout(
                          cashTenderedCents: tenderedCents,
                          cashier: cashier,
                          terminalId: 'REG-01',
                        );

                        if (result.isSuccess) {
                          // Print receipt via ESC/POS abstraction
                          await _printer.printReceipt(
                            branchName: 'Downtown Bakery Oven #1',
                            receiptNumber: result.orderId,
                            cashierName: cashier.fullName,
                            timestamp: DateTime.now(),
                            items: cart.itemsList.map((i) => ReceiptLineItem(
                              name: i.product.name,
                              quantity: i.quantity,
                              unitPriceCents: i.product.priceCents,
                              totalPriceCents: i.itemTotalCents,
                            )).toList(),
                            subtotalCents: cart.subtotalCents,
                            taxCents: cart.taxCents,
                            totalCents: cart.totalCents,
                            paymentMethod: 'CASH',
                            cashTenderedCents: tenderedCents,
                            changeDueCents: result.changeDueCents,
                          );

                          // Trigger background sync in non-blocking manner
                          ref.read(syncWorkerProvider).syncPendingEvents();

                          if (context.mounted) {
                            Navigator.of(dialogCtx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.successGreen,
                                content: Text('Order ${result.orderId} Completed! Change: \$${(result.changeDueCents / 100).toStringAsFixed(2)}'),
                              ),
                            );
                          }
                        }
                      },
                child: const Text('CONFIRM SALE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPresetChip(String label, int cents, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppColors.surfaceHighlight,
      labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cashier = ref.watch(currentUserProvider);
    final stockMap = ref.watch(stockNotifierProvider);
    final cart = ref.watch(cartNotifierProvider);

    final filteredProducts = _selectedCategory == 'ALL'
        ? _allProducts
        : _allProducts.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.bakery_dining, color: AppColors.primaryAmber),
            const SizedBox(width: 8),
            Text('REG-01', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Cashier: ${cashier?.fullName ?? "Maria G."}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.primaryAmber),
            tooltip: 'Trigger Sync',
            onPressed: () async {
              final res = await ref.read(syncWorkerProvider).syncPendingEvents();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: res.isSuccess ? AppColors.successGreen : AppColors.warningOrange,
                    content: Text(res.message ?? 'Sync done'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.alertRed),
            tooltip: 'Sign Out / Switch Staff',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PinLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmber))
          : Row(
              children: [
                // Left Panel: Categories & Catalog Grid (flex 65)
                Expanded(
                  flex: 65,
                  child: Column(
                    children: [
                      // Categories bar
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final cat = _categories[idx];
                            final isSelected = cat == _selectedCategory;
                            return ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: AppColors.primaryAmber,
                              backgroundColor: AppColors.surfaceCard,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                            );
                          },
                        ),
                      ),

                      // Product Grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.15,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final stock = stockMap[product.id] ?? 0;
                            final isOutOfStock = stock <= 0;

                            return Card(
                              color: isOutOfStock ? AppColors.surfaceCard.withOpacity(0.5) : AppColors.surfaceCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                side: BorderSide(
                                  color: isOutOfStock ? AppColors.surfaceHighlight : AppColors.surfaceHighlight,
                                ),
                              ),
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                onTap: isOutOfStock
                                    ? () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.alertRed,
                                            content: Text('${product.name} is OUT OF STOCK'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    : () {
                                        ref.read(cartNotifierProvider.notifier).addProduct(product);
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product.name,
                                              style: TextStyle(
                                                color: isOutOfStock ? AppColors.textMuted : AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        '\$${(product.priceCents / 100).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isOutOfStock ? AppColors.textMuted : AppColors.primaryAmber,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Stock badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isOutOfStock
                                              ? AppColors.alertRed.withOpacity(0.2)
                                              : (stock <= 5
                                                  ? AppColors.warningOrange.withOpacity(0.2)
                                                  : AppColors.successGreen.withOpacity(0.2)),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isOutOfStock
                                              ? 'OUT OF STOCK'
                                              : (stock <= 5 ? '$stock left (Low)' : '$stock in stock'),
                                          style: TextStyle(
                                            color: isOutOfStock
                                                ? AppColors.alertRed
                                                : (stock <= 5 ? AppColors.warningOrange : AppColors.successGreen),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Panel: Ticket Cart & Pay Bar (flex 35)
                Expanded(
                  flex: 35,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border(left: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
                    ),
                    child: Column(
                      children: [
                        // Cart Header
                        Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CURRENT TICKET (${cart.itemCount})',
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                              if (!cart.isEmpty)
                                TextButton(
                                  onPressed: () => ref.read(cartNotifierProvider.notifier).clearCart(),
                                  child: const Text('Clear', style: TextStyle(color: AppColors.alertRed)),
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.surfaceHighlight),

                        // Cart Items List
                        Expanded(
                          child: cart.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shopping_basket_outlined, color: AppColors.textDisabled, size: 48),
                                      SizedBox(height: 12),
                                      Text('Cart is empty', style: TextStyle(color: AppColors.textMuted)),
                                      Text('Tap products to add', style: TextStyle(color: AppColors.textDisabled, fontSize: 12)),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: cart.itemsList.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceHighlight),
                                  itemBuilder: (context, idx) {
                                    final item = cart.itemsList[idx];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(item.product.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                                Text(
                                                  '\$${(item.product.priceCents / 100).toStringAsFixed(2)} ea',
                                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Stepper buttons (min 48dp target)
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.textMuted),
                                            onPressed: () => ref.read(cartNotifierProvider.notifier).removeProduct(item.product.id),
                                          ),
                                          Text('${item.quantity}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryAmber),
                                            onPressed: () => ref.read(cartNotifierProvider.notifier).addProduct(item.product),
                                          ),
                                          SizedBox(
                                            width: 65,
                                            child: Text(
                                              '\$${(item.itemTotalCents / 100).toStringAsFixed(2)}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Ticket Summary & Pay Button
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          decoration: const BoxDecoration(
                            color: AppColors.backgroundDeep,
                            border: Border(top: BorderSide(color: AppColors.surfaceHighlight)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal', style: TextStyle(color: AppColors.textMuted)),
                                  Text('\$${(cart.subtotalCents / 100).toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textPrimary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tax (8%)', style: TextStyle(color: AppColors.textMuted)),
                                  Text('\$${(cart.taxCents / 100).toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textPrimary)),
                                ],
                              ),
                              const Divider(height: 16, color: AppColors.surfaceHighlight),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('TOTAL DUE', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text(
                                    '\$${(cart.totalCents / 100).toStringAsFixed(2)}',
                                    style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold, fontSize: 24),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: AppDimensions.largeTouchTarget, // 64dp touch target
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryAmber,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                                    elevation: 2,
                                  ),
                                  icon: const Icon(Icons.point_of_sale, size: 28),
                                  label: Text(
                                    cart.isEmpty ? 'CART EMPTY' : 'PAY CASH (\$${(cart.totalCents / 100).toStringAsFixed(2)})',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: cart.isEmpty ? null : _showCheckoutDialog,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
