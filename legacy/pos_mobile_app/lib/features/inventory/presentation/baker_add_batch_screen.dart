import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_strings.dart';
import '../../auth/presentation/pin_login_screen.dart';
import '../../auth/domain/user.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../inventory/domain/ledger_event.dart';
import '../../inventory/presentation/stock_notifier.dart';

class BakerAddBatchScreen extends ConsumerStatefulWidget {
  const BakerAddBatchScreen({super.key});

  @override
  ConsumerState<BakerAddBatchScreen> createState() => _BakerAddBatchScreenState();
}

class _BakerAddBatchScreenState extends ConsumerState<BakerAddBatchScreen> {
  static const _uuid = Uuid();
  List<Product> _products = CatalogRepositoryImpl.defaultProducts;
  Product? _selectedProduct = CatalogRepositoryImpl.defaultProducts.first;
  int _batchQuantity = 24; // Default +2 charolas de 12
  bool _isLoading = false;
  final TextEditingController _notesController = TextEditingController();
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  static const Map<String, int> _targetStockMap = {
    'c0000000-0000-0000-0000-000000000001': 48, // Hogaza Campesina
    'c0000000-0000-0000-0000-000000000002': 48, // Baguette
    'c0000000-0000-0000-0000-000000000003': 48, // Croissant
    'c0000000-0000-0000-0000-000000000004': 48, // Pain au Chocolat
    'c0000000-0000-0000-0000-000000000006': 38, // Tarta de Frutos
    'c0000000-0000-0000-0000-000000000007': 60, // Café Flat White
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
    try {
      final catalogRepo = ref.read(catalogRepositoryProvider);
      final prods = await catalogRepo.getProducts();

      if (mounted && prods.isNotEmpty) {
        setState(() {
          _products = prods;
          if (_selectedProduct == null || !prods.any((p) => p.id == _selectedProduct!.id)) {
            _selectedProduct = prods.first;
          }
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
    final batchCode = 'HORNADA-$todayStr-01';

    final event = LedgerEvent(
      clientEventId: _uuid.v4(),
      branchId: baker.branchId,
      terminalId: 'HORNO-PISO-01',
      eventType: LedgerEventType.bakeBatchProduced,
      userId: baker.id,
      productId: _selectedProduct!.id,
      quantityChange: _batchQuantity,
      batchNumber: batchCode,
      referenceId: batchCode,
      metadata: {
        'notes': _notesController.text.trim(),
        'station': 'Horno de Piso 01',
      },
      clientTimestamp: DateTime.now(),
    );

    await ref.read(stockNotifierProvider.notifier).recordEvent(event);
    ref.read(syncWorkerProvider).syncPendingEvents();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text(
            '✓ Se ingresaron +$_batchQuantity ${_selectedProduct!.name} ($batchCode) a vitrina.',
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
            Text('Salir de Cocina / Horno', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Deseas cerrar tu sesión de horneado y regresar al acceso con PIN, ${user?.fullName ?? "Marco"}?',
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
                      'Todas las hornadas registradas están guardadas en SQLite local.',
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
            child: const Text('Salir al PIN Pad', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final currentShelfStock = _selectedProduct != null
        ? (stockMap[_selectedProduct!.id] ?? 24)
        : 0;
    final newProjectedStock = currentShelfStock + _batchQuantity;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de Estado de Cocina
            _buildTopKitchenBar(baker, timeStr, isMobile),

            // Contenido Principal Responsive
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmber))
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sección 1: Selección de Producto Horneado
                          const Text(
                            AppStrings.selectProductToBake,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Tarjetas Horizontales de Productos
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
                                                color: AppColors.successGreen.withOpacity(0.25),
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
                                          // Miniatura
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

                                          // Título y Vitrina vs Meta
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
                                                        'Vitrina\n$shelfStock pzas',
                                                        style: const TextStyle(
                                                          color: AppColors.textMuted,
                                                          fontSize: 10,
                                                          height: 1.1,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Meta\n$targetStock pzas',
                                                        textAlign: TextAlign.right,
                                                        style: const TextStyle(
                                                          color: AppColors.textDisabled,
                                                          fontSize: 10,
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

                          // Sección 2: Registro de Hornada
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                AppStrings.batchUnits,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                'Total: +$_batchQuantity pzas (Nueva Vitrina: $newProjectedStock)',
                                style: const TextStyle(
                                  color: AppColors.successGreen,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Botones de incremento táctil
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildTrayPill(AppStrings.halfTray, 6, isHighlighted: _batchQuantity == 6),
                              _buildTrayPill(AppStrings.fullTray, 12, isHighlighted: _batchQuantity == 12),
                              _buildTrayPill(AppStrings.doubleTray, 24, isHighlighted: _batchQuantity == 24),
                              _buildTrayPill(AppStrings.fullOven, 48, isHighlighted: _batchQuantity == 48),
                              _buildResetPill(),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Notas y Código de Lote
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
                                    Text('Código Lote: ', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                    Text(
                                      'HORNADA-01',
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
                                      hintText: 'Notas de horneado (ej. Piso 2 dorado óptimo)...',
                                      hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 13),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Botón Masivo de Confirmación
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successGreen,
                                foregroundColor: Colors.black,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _recordBatch,
                              icon: const Icon(Icons.check_circle_rounded, size: 28),
                              label: Text(
                                '${AppStrings.recordBatch.toUpperCase()} (+$_batchQuantity PZAS)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopKitchenBar(User? baker, String timeStr, bool isMobile) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            onPressed: () => _confirmExit(context, baker),
            tooltip: 'Salir',
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: baker?.avatarAsset != null
                      ? Image.asset(
                          baker!.avatarAsset!,
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.soup_kitchen_rounded, color: AppColors.primaryAmber, size: 20),
                        )
                      : const Icon(Icons.soup_kitchen_rounded, color: AppColors.primaryAmber, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '${baker?.fullName ?? "Marco Rossi"} (Horno)',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            timeStr,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTrayPill(String label, int qty, {required bool isHighlighted}) {
    return InkWell(
      onTap: () => setState(() => _batchQuantity = qty),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.successGreen : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted ? AppColors.successGreen : AppColors.surfaceHighlight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isHighlighted ? Colors.black : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildResetPill() {
    return InkWell(
      onTap: () => setState(() => _batchQuantity = 0),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.alertRed.withOpacity(0.5)),
        ),
        child: const Text(
          'Limpiar (0)',
          style: TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
