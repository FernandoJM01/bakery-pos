import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../auth/domain/user.dart';
import '../../auth/data/auth_repository.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/domain/product.dart';
import '../../sync/data/background_sync_worker.dart';
import '../../pos/presentation/cashier_dashboard_screen.dart';
import '../../inventory/presentation/baker_add_batch_screen.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => CatalogRepositoryImpl());
final syncWorkerProvider = Provider<BackgroundSyncWorker>((ref) => BackgroundSyncWorker());

final currentUserProvider = StateProvider<User?>((ref) => null);

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _enteredPin = '';
  List<User> _staffList = [];
  User? _selectedUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLocalSeed();
  }

  Future<void> _initializeLocalSeed() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final catalogRepo = ref.read(catalogRepositoryProvider);
      final syncWorker = ref.read(syncWorkerProvider);

      // Non-blocking try to pull snapshot
      try {
        await syncWorker.pullSnapshot('a0000000-0000-0000-0000-000000000001');
      } catch (e) {
        debugPrint('[Seed] Backend pull skipped or offline: $e');
      }

      var staff = await authRepo.getAvailableUsers();
      if (staff.isEmpty) {
        // Offline fallback seed
        staff = [
          const User(
            id: 'b0000000-0000-0000-0000-000000000001',
            branchId: 'a0000000-0000-0000-0000-000000000001',
            username: 'cashier1',
            pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
            fullName: 'Maria Gonzalez',
            role: UserRole.cashier,
          ),
          const User(
            id: 'b0000000-0000-0000-0000-000000000002',
            branchId: 'a0000000-0000-0000-0000-000000000001',
            username: 'baker1',
            pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
            fullName: 'Marco Rossi',
            role: UserRole.localBaker,
          ),
          const User(
            id: 'b0000000-0000-0000-0000-000000000003',
            branchId: 'a0000000-0000-0000-0000-000000000001',
            username: 'manager1',
            pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
            fullName: 'Elena Rostova',
            role: UserRole.branchManager,
          ),
        ];
        await authRepo.cacheUsers(staff);
      }

      // Also verify catalog has fallback products if backend wasn't reachable
      final products = await catalogRepo.getProducts();
      if (products.isEmpty) {
        await catalogRepo.cacheProducts([
          const Product(id: 'c0000000-0000-0000-0000-000000000001', sku: 'BREAD-SOUR', name: 'Sourdough Loaf', category: 'Breads', priceCents: 650),
          const Product(id: 'c0000000-0000-0000-0000-000000000002', sku: 'BREAD-BAGU', name: 'Artisan Baguette', category: 'Breads', priceCents: 400),
          const Product(id: 'c0000000-0000-0000-0000-000000000003', sku: 'PAST-CROI', name: 'Butter Croissant', category: 'Pastries', priceCents: 325),
          const Product(id: 'c0000000-0000-0000-0000-000000000004', sku: 'PAST-CHOC', name: 'Pain au Chocolat', category: 'Pastries', priceCents: 375),
          const Product(id: 'c0000000-0000-0000-0000-000000000005', sku: 'PAST-CINN', name: 'Cinnamon Roll', category: 'Pastries', priceCents: 400),
          const Product(id: 'c0000000-0000-0000-0000-000000000006', sku: 'CAKE-ECLR', name: 'Chocolate Eclair', category: 'Cakes', priceCents: 450),
          const Product(id: 'c0000000-0000-0000-0000-000000000007', sku: 'BEV-COFF', name: 'Flat White Coffee', category: 'Beverages', priceCents: 500),
        ]);
      }

      if (mounted) {
        setState(() {
          _staffList = staff;
          _selectedUser = staff.isNotEmpty ? staff.first : null;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('[Seed] Error during local initialization: $e\n$stack');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onKeypadTap(String val) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += val;
        _errorMessage = null;
      });
      if (_enteredPin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _onClear() {
    setState(() {
      _enteredPin = '';
      _errorMessage = null;
    });
  }

  Future<void> _validatePin() async {
    if (_selectedUser == null) return;
    final authRepo = ref.read(authRepositoryProvider);
    final user = await authRepo.verifyPin(
      username: _selectedUser!.username,
      pin: _enteredPin,
    );

    if (user != null) {
      ref.read(currentUserProvider.notifier).state = user;
      if (!mounted) return;

      if (user.role == UserRole.localBaker) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BakerAddBatchScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CashierDashboardScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Default is 1234';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryAmber)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Row(
          children: [
            // Left Panel (Branding & Shift Info)
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bakery_dining, color: AppColors.primaryAmber, size: 36),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'POS BAKERY',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Artisan Oven & Offline-First Edge', style: TextStyle(color: AppColors.textMuted)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.surfaceHighlight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.storefront, color: AppColors.primaryAmber, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Downtown Oven #1 (BR-01)',
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Terminal: REG-01  •  SQLite Edge', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(color: AppColors.successGreen, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Local Edge Storage Active',
                                  style: TextStyle(color: AppColors.successGreen, fontSize: 13, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Right Panel (PIN Pad & Staff Selector)
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('STAFF QUICK LOGIN', style: TextStyle(color: AppColors.textMuted, letterSpacing: 1.5, fontSize: 14)),
                    const SizedBox(height: 16),

                    // Staff Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.surfaceHighlight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<User>(
                          value: _selectedUser,
                          dropdownColor: AppColors.surfaceCard,
                          isExpanded: true,
                          items: _staffList.map((u) {
                            return DropdownMenuItem(
                              value: u,
                              child: Row(
                                children: [
                                  Icon(
                                    u.role == UserRole.localBaker ? Icons.soup_kitchen : Icons.point_of_sale,
                                    color: AppColors.primaryAmber,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${u.fullName} (${u.role.value})',
                                      style: const TextStyle(color: AppColors.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedUser = val;
                              _enteredPin = '';
                              _errorMessage = null;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4-Digit PIN Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final filled = index < _enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled ? AppColors.primaryAmber : Colors.transparent,
                            border: Border.all(color: filled ? AppColors.primaryAmber : AppColors.surfaceHighlight, width: 2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    if (_errorMessage != null)
                      Text(_errorMessage!, style: const TextStyle(color: AppColors.alertRed, fontSize: 13)),

                    const SizedBox(height: 24),

                    // Keypad
                    _buildKeypad(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeyRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildKeyRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildKeyRow(['7', '8', '9']),
        const SizedBox(height: 12),
        _buildKeyRow(['CLEAR', '0', '⌫']),
      ],
    );
  }

  Widget _buildKeyRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: labels.map((label) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 76,
          height: 64, // Touch target > 56dp
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceCard,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                side: const BorderSide(color: AppColors.surfaceHighlight),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (label == 'CLEAR') {
                _onClear();
              } else if (label == '⌫') {
                _onBackspace();
              } else {
                _onKeypadTap(label);
              }
            },
            child: Text(
              label,
              style: TextStyle(
                fontSize: label.length > 1 ? 14 : 22,
                fontWeight: FontWeight.bold,
                color: label == 'CLEAR' ? AppColors.alertRed : (label == '⌫' ? AppColors.primaryAmber : AppColors.textPrimary),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
