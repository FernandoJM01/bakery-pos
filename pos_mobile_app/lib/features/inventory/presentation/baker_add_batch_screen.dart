import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../auth/presentation/pin_login_screen.dart';
import '../../auth/domain/user.dart';
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
  int _batchQuantity = 24; // Default +2 trays of 12
  bool _isLoading = true;
  final TextEditingController _notesController = TextEditingController();
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  // Standard target daily stock levels per product
  static const Map<String, int> _targetStockMap = {
    'c0000000-0000-0000-0000-000000000001': 48, // Sourdough
    'c0000000-0000-0000-0000-000000000002': 48, // Baguette
    'c0000000-0000-0000-0000-000000000003': 48, // Croissant
    'c0000000-0000-0000-0000-000000000004': 48, // Pain au Choc
    'c0000000-0000-0000-0000-000000000006': 38, // Berry Tart
    'c0000000-0000-0000-0000-000000000007': 60, // Coffee
  };

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final catalogRepo = ref.read(catalogRepositoryProvider);
    final prods = await catalogRepo.getProducts();

    if (mounted) {
      setState(() {
        _products = prods;
        _selectedProduct = prods.isNotEmpty ? prods.first : null;
        _isLoading = false;
      });
    }
  }

  Future<void> _recordBatch() async {
    if (_selectedProduct == null || _batchQuantity <= 0) return;

    final baker = ref.read(currentUserProvider) ??
        const User(
          id: 'b0000000-0000-0000-0000-000000000002',
          branchId: 'a0000000-0000-0000-0000-000000000001',
          username: 'baker1',
          pinHash: '',
          fullName: 'Marco Rossi',
          role: UserRole.localBaker,
        );

    final todayStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final batchCode = 'BATCH-$todayStr-01';

    final event = LedgerEvent(
      clientEventId: _uuid.v4(),
      branchId: baker.branchId,
      terminalId: 'DECK-OVEN-01',
      eventType: LedgerEventType.bakeBatchProduced,
      userId: baker.id,
      productId: _selectedProduct!.id,
      quantityChange: _batchQuantity,
      batchNumber: batchCode,
      referenceId: batchCode,
      metadata: {
        'notes': _notesController.text.trim(),
        'station': 'Deck Oven 01',
      },
      clientTimestamp: DateTime.now(),
    );

    // 1. Optimistic immediate state update and local SQLite persistent write
    await ref.read(stockNotifierProvider.notifier).recordEvent(event);

    // 2. Trigger background sync to NestJS cloud
    ref.read(syncWorkerProvider).syncPendingEvents();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text(
            '✓ Recorded +$_batchQuantity ${_selectedProduct!.name} (Batch: $batchCode) to shelf!',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      setState(() {
        _notesController.clear();
      });
    }
  }

  void _confirmExit(BuildContext context, User? user) {
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
            Text('Exit Kitchen Console', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to leave the oven production station and return to the PIN terminal, ${user?.fullName ?? "Marco"}?',
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
                  Icon(Icons.soup_kitchen_rounded, color: AppColors.primaryAmber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All previously recorded batches remain saved in SQLite ledger.',
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
              backgroundColor: AppColors.primaryAmber,
              foregroundColor: AppColors.backgroundDeep,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PinLoginScreen()),
              );
            },
            child: const Text('Exit to PIN Pad', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baker = ref.watch(currentUserProvider);
    final stockMap = ref.watch(stockNotifierProvider);
    final timeStr = DateFormat('hh:mm a').format(_currentTime);

    final currentShelfStock = _selectedProduct != null
        ? (stockMap[_selectedProduct!.id] ?? 24)
        : 0;
    final newProjectedStock = currentShelfStock + _batchQuantity;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Kitchen Status Bar
            _buildTopKitchenBar(baker, timeStr),

            // 2. Main Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmber))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Select Baked Product to Restock
                          const Text(
                            'Select Baked Product to Restock',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Horizontal Product Touch Tiles
                          SizedBox(
                            height: 160,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _products.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (context, idx) {
                                final product = _products[idx];
                                final isSelected = _selectedProduct?.id == product.id;
                                final shelfStock = stockMap[product.id] ?? 24;
                                final targetStock = _targetStockMap[product.id] ?? 48;

                                return InkWell(
                                  onTap: () => setState(() => _selectedProduct = product),
                                  borderRadius: BorderRadius.circular(16),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 168,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceCard,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppColors.successGreen : AppColors.surfaceHighlight,
                                        width: isSelected ? 2.5 : 1.0,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.successGreen.withValues(alpha: 0.25),
                                                blurRadius: 14,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Product Thumbnail
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
                                                        size: 32,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.bakery_dining_rounded,
                                                      color: AppColors.primaryAmber,
                                                      size: 32,
                                                    ),
                                            ),
                                          ),

                                          // Product Title & Shelf vs Target
                                          Expanded(
                                            flex: 4,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: TextStyle(
                                                      color: isSelected ? AppColors.successGreen : AppColors.textPrimary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Shelf\n$shelfStock',
                                                        style: const TextStyle(
                                                          color: AppColors.textMuted,
                                                          fontSize: 11,
                                                          height: 1.1,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Target\n$targetStock',
                                                        textAlign: TextAlign.right,
                                                        style: const TextStyle(
                                                          color: AppColors.textDisabled,
                                                          fontSize: 11,
                                                          height: 1.1,
                                                        ),
                                                      ),
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
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section 2: Batch Production Entry
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Batch Production Entry',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                'Total: +$_batchQuantity pcs (New Stock: $newProjectedStock)',
                                style: const TextStyle(
                                  color: AppColors.successGreen,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Tactile Preset Increment Pills
                          Row(
                            children: [
                              _buildTrayPill('+1 Half Tray', 6, isHighlighted: _batchQuantity == 6),
                              const SizedBox(width: 10),
                              _buildTrayPill('+1 Full Tray', 12, isHighlighted: _batchQuantity == 12),
                              const SizedBox(width: 10),
                              _buildTrayPill('+2 Trays', 24, isHighlighted: _batchQuantity == 24),
                              const SizedBox(width: 10),
                              _buildTrayPill('+1 Deck Oven', 48, isHighlighted: _batchQuantity == 48),
                              const SizedBox(width: 10),
                              _buildResetPill(),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Lot Code & Oven Notes Inputs
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.surfaceHighlight),
                                ),
                                child: Row(
                                  children: const [
                                    Text('Lot code: ', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                    Text(
                                      'BATCH-20261011-01',
                                      style: TextStyle(
                                        color: AppColors.primaryAmber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceCard,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.surfaceHighlight),
                                  ),
                                  child: TextField(
                                    controller: _notesController,
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    decoration: const InputDecoration(
                                      hintText: 'Oven notes (optional, e.g. Deck 2 golden bake)...',
                                      hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 13),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // 72dp Massive Confirmation Bar
                          SizedBox(
                            width: double.infinity,
                            height: 64, // Touch target >= 64dp
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successGreen,
                                foregroundColor: Colors.black,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_rounded, size: 26),
                              label: Text(
                                '✓ CONFIRM & RECORD BATCH TO SHELF (+$_batchQuantity ${_selectedProduct?.name ?? ""})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: (_selectedProduct == null || _batchQuantity <= 0)
                                  ? null
                                  : _recordBatch,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopKitchenBar(User? baker, String timeStr) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            tooltip: 'Back to PIN Terminal',
            onPressed: () => _confirmExit(context, baker),
          ),
          const SizedBox(width: 8),
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
                  child: baker?.avatarAsset != null
                      ? Image.asset(
                          baker!.avatarAsset!,
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.soup_kitchen_rounded, size: 18, color: AppColors.primaryAmber),
                        )
                      : const Icon(Icons.soup_kitchen_rounded, size: 18, color: AppColors.primaryAmber),
                ),
                const SizedBox(width: 8),
                Text(
                  '${baker?.fullName ?? "Marco Rossi"} (Deck Oven 01)',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: const Text(
              'Shift: Morning Deck Bake',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),

          const Spacer(),

          // Clock
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 6),
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

          const SizedBox(width: 18),

          // Edge Local Online Pill
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
                  'Edge Local Online',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrayPill(String label, int amount, {bool isHighlighted = false}) {
    return InkWell(
      onTap: () => setState(() => _batchQuantity = amount),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.primaryAmber
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted ? AppColors.primaryAmber : AppColors.surfaceHighlight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isHighlighted ? Colors.black : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.black.withValues(alpha: 0.2)
                    : AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$amount',
                style: TextStyle(
                  color: isHighlighted ? Colors.black : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetPill() {
    return InkWell(
      onTap: () => setState(() => _batchQuantity = 0),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: const Text(
          'Reset',
          style: TextStyle(
            color: AppColors.alertRed,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
