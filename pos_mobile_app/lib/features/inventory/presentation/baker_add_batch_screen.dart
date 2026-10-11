import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../auth/presentation/pin_login_screen.dart';
import '../../catalog/domain/product.dart';
import '../../inventory/domain/ledger_event.dart';
import '../../inventory/presentation/stock_notifier.dart';

class BakerAddBatchScreen extends ConsumerStatefulWidget {
  const BakerAddBatchScreen({super.key});

  @override
  ConsumerState<BakerAddBatchScreen> createState() => _BakerAddBatchScreenState();
}

class _BakerAddBatchScreenState extends ConsumerState<BakerAddBatchScreen> {
  static const _uuid = Uuid();
  List<Product> _products = [];
  Product? _selectedProduct;
  int _batchQuantity = 24; // Default 2 trays of 12
  bool _isLoading = true;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final catalogRepo = ref.read(catalogRepositoryProvider);
    final prods = await catalogRepo.getProducts();
    setState(() {
      _products = prods;
      _selectedProduct = prods.isNotEmpty ? prods.first : null;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _recordBatch() async {
    if (_selectedProduct == null || _batchQuantity <= 0) return;

    final baker = ref.read(currentUserProvider);
    if (baker == null) return;

    final todayStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final batchCode = 'BATCH-$todayStr-${_uuid.v4().substring(0, 4).toUpperCase()}';

    final event = LedgerEvent(
      clientEventId: _uuid.v4(),
      branchId: baker.branchId,
      terminalId: 'OVEN-STATION-01',
      eventType: LedgerEventType.bakeBatchProduced,
      userId: baker.id,
      productId: _selectedProduct!.id,
      quantityChange: _batchQuantity, // Stock increment
      batchNumber: batchCode,
      referenceId: batchCode,
      metadata: {
        'notes': _notesController.text.trim(),
        'station': 'Main Deck Oven',
      },
      clientTimestamp: DateTime.now(),
    );

    // Write to local SQLite and update stock immediately
    await ref.read(stockNotifierProvider.notifier).recordEvent(event);

    // Trigger background sync in non-blocking manner
    ref.read(syncWorkerProvider).syncPendingEvents();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text(
            'Recorded +$_batchQuantity ${_selectedProduct!.name} (Batch: $batchCode)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      setState(() {
        _notesController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baker = ref.watch(currentUserProvider);
    final stockMap = ref.watch(stockNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.soup_kitchen, color: AppColors.primaryAmber),
            const SizedBox(width: 8),
            Text('BAKERY OVEN STATION', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Baker: ${baker?.fullName ?? "Marco R."}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
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
          : Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. SELECT FRESH PRODUCT TO RESTOCK',
                    style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Product Grid
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final product = _products[idx];
                        final isSelected = _selectedProduct?.id == product.id;
                        final stock = stockMap[product.id] ?? 0;

                        return InkWell(
                          onTap: () => setState(() => _selectedProduct = product),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          child: Container(
                            width: 180,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceHighlight : AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryAmber : AppColors.surfaceHighlight,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.primaryAmber : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text('Category: ${product.category}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                const Spacer(),
                                Text('Current Stock: $stock', style: const TextStyle(color: AppColors.successGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    '2. BATCH QUANTITY ENTRY',
                    style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  // Big Quantity Indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.surfaceHighlight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adding to shelf: ${_selectedProduct?.name ?? ""}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '+$_batchQuantity pcs',
                              style: const TextStyle(color: AppColors.primaryAmber, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Quick Increment Pills (Large Touch Targets >= 56dp)
                            _buildIncrementButton('+1 Tray (12)', 12),
                            const SizedBox(width: 8),
                            _buildIncrementButton('+2 Trays (24)', 24),
                            const SizedBox(width: 8),
                            _buildIncrementButton('+1 Oven (48)', 48),
                            const SizedBox(width: 8),
                            _buildIncrementButton('+1', 1),
                            const SizedBox(width: 8),
                            _buildIncrementButton('+5', 5),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surfaceHighlight,
                                foregroundColor: AppColors.alertRed,
                                minimumSize: const Size(64, 56), // Touch target >= 56dp
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => setState(() => _batchQuantity = 0),
                              child: const Text('RESET', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      hintText: 'Optional notes (e.g. Deck Oven 2, Golden Bake, High Hydration)...',
                      hintStyle: const TextStyle(color: AppColors.textDisabled),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        borderSide: const BorderSide(color: AppColors.surfaceHighlight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        borderSide: const BorderSide(color: AppColors.surfaceHighlight),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Massive Confirm Button (Height: 72dp)
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.massiveTouchTarget, // 72dp touch target
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 32),
                      label: Text(
                        '✓ CONFIRM & RECORD BATCH TO SHELF (+$_batchQuantity ${_selectedProduct?.name ?? ""})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      onPressed: (_selectedProduct == null || _batchQuantity <= 0) ? null : _recordBatch,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildIncrementButton(String label, int amount) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceHighlight,
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(64, 56), // Touch target >= 56dp
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => setState(() => _batchQuantity += amount),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
