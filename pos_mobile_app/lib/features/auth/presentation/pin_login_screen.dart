import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../auth/domain/user.dart';
import '../../auth/data/auth_repository.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../sync/data/background_sync_worker.dart';
import '../../pos/presentation/cashier_dashboard_screen.dart';
import '../../inventory/presentation/baker_add_batch_screen.dart';
import '../../inventory/presentation/manager_reconciliation_screen.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => CatalogRepositoryImpl());
final syncWorkerProvider = Provider<BackgroundSyncWorker>((ref) => BackgroundSyncWorker());

final currentUserProvider = StateProvider<User?>((ref) => null);

class StaffMemberInfo {
  final User user;
  final String shiftName;
  final String shiftTime;
  final IconData icon;

  const StaffMemberInfo({
    required this.user,
    required this.shiftName,
    required this.shiftTime,
    required this.icon,
  });
}

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  static const List<StaffMemberInfo> _defaultStaffList = [
    StaffMemberInfo(
      user: User(
        id: 'b0000000-0000-0000-0000-000000000001',
        branchId: 'a0000000-0000-0000-0000-000000000001',
        username: 'cashier1',
        pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
        fullName: 'Maria Gonzalez',
        role: UserRole.cashier,
      ),
      shiftName: 'Morning Register',
      shiftTime: '07:00 - 15:00',
      icon: Icons.point_of_sale_rounded,
    ),
    StaffMemberInfo(
      user: User(
        id: 'b0000000-0000-0000-0000-000000000002',
        branchId: 'a0000000-0000-0000-0000-000000000001',
        username: 'baker1',
        pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
        fullName: 'Marco Rossi',
        role: UserRole.localBaker,
      ),
      shiftName: 'Deck Oven Bake',
      shiftTime: '05:00 - 13:00',
      icon: Icons.soup_kitchen_rounded,
    ),
    StaffMemberInfo(
      user: User(
        id: 'b0000000-0000-0000-0000-000000000003',
        branchId: 'a0000000-0000-0000-0000-000000000001',
        username: 'manager1',
        pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', // 1234
        fullName: 'Elena Rostova',
        role: UserRole.branchManager,
      ),
      shiftName: 'Store Management',
      shiftTime: 'All Day',
      icon: Icons.badge_rounded,
    ),
  ];

  String _enteredPin = '';
  late StaffMemberInfo _selectedStaff;
  String? _errorMessage;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedStaff = _defaultStaffList.first;
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _keyboardFocusNode.dispose();
    super.dispose();
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
    final authRepo = ref.read(authRepositoryProvider);
    final user = await authRepo.verifyPin(
      username: _selectedStaff.user.username,
      pin: _enteredPin,
    );

    if (user != null) {
      ref.read(currentUserProvider.notifier).state = user;
      if (!mounted) return;

      if (user.role == UserRole.localBaker) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BakerAddBatchScreen()),
        );
      } else if (user.role == UserRole.branchManager) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ManagerReconciliationScreen(manager: user)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CashierDashboardScreen()),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'Incorrect PIN. Try 1234';
          _enteredPin = '';
        });
      }
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final keyChar = event.character;
      if (keyChar != null && RegExp(r'^[0-9]$').hasMatch(keyChar)) {
        _onKeypadTap(keyChar);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _onBackspace();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _onClear();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(_currentTime);

    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Top Enterprise POS Header Bar
              _buildTopHeader(timeStr),

              // 2. Main Content Split View
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left 50% — On-Shift Bakery Staff Directory
                      Expanded(
                        flex: 5,
                        child: _buildStaffDirectory(),
                      ),

                      const SizedBox(width: 28),

                      // Right 50% — High-Tactile PIN Pad Terminal Card
                      Expanded(
                        flex: 5,
                        child: _buildPinTerminal(),
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
  }

  Widget _buildTopHeader(String timeStr) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
      ),
      child: Row(
        children: [
          // Bakery Logo & Branch Name
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bakery_dining_rounded, color: AppColors.primaryAmber, size: 24),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'ARTISAN BAKERY',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Downtown Oven #1 (BR-01)',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Live Clock
          Text(
            timeStr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(width: 12),

          // Terminal Identifier
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: const Text(
              'REG-01',
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),

          const SizedBox(width: 10),

          // Edge Sync Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreenBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Local Edge Online',
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

  Widget _buildStaffDirectory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'On-Shift Bakery Staff',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tap your profile card below to activate PIN login',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: ListView.separated(
            itemCount: _defaultStaffList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final staff = _defaultStaffList[index];
              final isSelected = _selectedStaff.user.id == staff.user.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedStaff = staff;
                    _enteredPin = '';
                    _errorMessage = null;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surfaceElevated : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryAmber : AppColors.surfaceHighlight,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryAmber.withValues(alpha: 0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Avatar Icon Circle
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryAmber.withValues(alpha: 0.2)
                              : AppColors.surfaceHighlight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          staff.icon,
                          color: isSelected ? AppColors.primaryAmber : AppColors.textMuted,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name & Role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff.user.fullName,
                              style: TextStyle(
                                color: isSelected ? AppColors.textPrimary : AppColors.textPrimary.withValues(alpha: 0.9),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${staff.user.role.value} • ${staff.shiftName}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                      // Shift Duration Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighlight.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          staff.shiftTime,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPinTerminal() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceHighlight),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Selected Staff Badge & Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_selectedStaff.icon, color: AppColors.primaryAmber, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedStaff.user.fullName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _selectedStaff.user.role.value,
                    style: const TextStyle(
                      color: AppColors.primaryAmber,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // PIN prompt label
          const Text(
            'ENTER 4-DIGIT PIN',
            style: TextStyle(
              color: AppColors.textMuted,
              letterSpacing: 2.0,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          // 4 Glowing PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < _enteredPin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppColors.primaryAmber : Colors.transparent,
                  border: Border.all(
                    color: isFilled ? AppColors.primaryAmber : AppColors.surfaceHighlight,
                    width: 2.5,
                  ),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: AppColors.primaryAmber.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.alertRed,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ] else
            const SizedBox(height: 24),

          const Spacer(),

          // Tactile Numeric Keypad
          _buildKeypad(),

          const Spacer(),
        ],
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

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        final isClear = key == 'CLEAR';
        final isBackspace = key == '⌫';

        Color bgColor = AppColors.surfaceElevated;
        Color textColor = AppColors.textPrimary;
        Border? border = Border.all(color: AppColors.surfaceHighlight, width: 1.2);

        if (isClear) {
          bgColor = AppColors.alertRed.withValues(alpha: 0.85);
          textColor = Colors.white;
          border = null;
        } else if (isBackspace) {
          bgColor = AppColors.surfaceHighlight;
          textColor = AppColors.primaryAmber;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 84,
          height: 64, // Touch target >= 64dp
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: textColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: border != null ? border.top : BorderSide.none,
              ),
            ),
            onPressed: () {
              if (isClear) {
                _onClear();
              } else if (isBackspace) {
                _onBackspace();
              } else {
                _onKeypadTap(key);
              }
            },
            child: isBackspace
                ? const Icon(Icons.backspace_rounded, size: 24)
                : Text(
                    key,
                    style: TextStyle(
                      fontSize: isClear ? 13 : 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: isClear ? 1.0 : 0.0,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }
}
