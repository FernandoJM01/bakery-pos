import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_strings.dart';
import '../../auth/domain/user.dart';
import '../../auth/data/auth_repository.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../sync/data/background_sync_worker.dart';
import '../../pos/presentation/cashier_dashboard_screen.dart';
import '../../inventory/presentation/baker_add_batch_screen.dart';
import '../../inventory/presentation/manager_reconciliation_screen.dart';
import '../../shell/presentation/enterprise_shell_screen.dart';

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
        avatarAsset: 'assets/users/maria_gonzalez.jpg',
      ),
      shiftName: AppStrings.morningRegister,
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
        avatarAsset: 'assets/users/marco_rossi.jpg',
      ),
      shiftName: AppStrings.deckOvenShift,
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
        avatarAsset: 'assets/users/elena_rostova.jpg',
      ),
      shiftName: AppStrings.storeManagement,
      shiftTime: 'Todo el día',
      icon: Icons.badge_rounded,
    ),
  ];

  String _enteredPin = '';
  late StaffMemberInfo _selectedStaff;
  String? _errorMessage;
  bool _isValidating = false;
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
    if (_isValidating) return;
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
    if (_isValidating) return;
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _onClear() {
    if (_isValidating) return;
    setState(() {
      _enteredPin = '';
      _errorMessage = null;
    });
  }

  Future<void> _validatePin() async {
    if (_isValidating) return;
    setState(() => _isValidating = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.verifyPin(
        username: _selectedStaff.user.username,
        pin: _enteredPin,
      );

      if (user != null) {
        if (mounted) {
          setState(() {
            _isValidating = false;
            _enteredPin = '';
          });
        }
        ref.read(currentUserProvider.notifier).state = user;
        if (!mounted) return;

        final initialIdx = user.role == UserRole.localBaker
            ? 3
            : (user.role == UserRole.cashier ? 1 : 0);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => EnterpriseShellScreen(user: user, initialIndex: initialIdx),
          ),
        );
      } else {
        if (mounted) {
          setState(() {
            _isValidating = false;
            _errorMessage = AppStrings.pinIncorrect;
            _enteredPin = '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _errorMessage = 'Error de inicio de sesión: $e';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        body: SafeArea(
          child: Column(
            children: [
              // Barra Superior
              _buildTopHeader(timeStr, isMobile),

              // Contenido Principal
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 28.0,
                    vertical: isMobile ? 12.0 : 16.0,
                  ),
                  child: isMobile
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildStaffDirectory(isMobile),
                              const SizedBox(height: 16),
                              _buildPinTerminal(isMobile),
                            ],
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Izquierda: Directorio
                            Expanded(
                              flex: 5,
                              child: _buildStaffDirectory(isMobile),
                            ),
                            const SizedBox(width: 28),
                            // Derecha: Terminal de PIN con scroll interno por seguridad
                            Expanded(
                              flex: 5,
                              child: _buildPinTerminal(isMobile),
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

  Widget _buildTopHeader(String timeStr, bool isMobile) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 28.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bakery_dining_rounded, color: AppColors.primaryAmber, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ARTISAN BAKERY',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppStrings.branchDowntown,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Text(
            timeStr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),

          if (!isMobile) ...[
            const SizedBox(width: 12),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successGreenBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
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
                    'En Línea',
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
        ],
      ),
    );
  }

  Widget _buildStaffDirectory(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: [
        const Text(
          'Personal en Turno',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Selecciona tu perfil para ingresar con PIN',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),

        isMobile
            ? Column(
                children: _defaultStaffList.map((staff) => _buildStaffCard(staff)).toList(),
              )
            : Expanded(
                child: ListView.separated(
                  itemCount: _defaultStaffList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final staff = _defaultStaffList[index];
                    return _buildStaffCard(staff);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildStaffCard(StaffMemberInfo staff) {
    final isSelected = _selectedStaff.user.id == staff.user.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
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
                      color: AppColors.primaryAmber.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryAmber.withOpacity(0.2) : AppColors.surfaceHighlight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryAmber : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: staff.user.avatarAsset != null
                      ? Image.asset(
                          staff.user.avatarAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            staff.icon,
                            color: isSelected ? AppColors.primaryAmber : AppColors.textMuted,
                            size: 26,
                          ),
                        )
                      : Icon(
                          staff.icon,
                          color: isSelected ? AppColors.primaryAmber : AppColors.textMuted,
                          size: 26,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.user.fullName,
                      style: TextStyle(
                        color: isSelected ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_roleLabel(staff.user.role)} • ${staff.shiftName}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight.withOpacity(0.6),
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
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.cashier:
        return AppStrings.roleCashier;
      case UserRole.localBaker:
        return AppStrings.roleBaker;
      case UserRole.branchManager:
        return AppStrings.roleManager;
      case UserRole.globalAdmin:
        return AppStrings.roleAdmin;
    }
  }

  Widget _buildPinTerminal(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(18.0),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Perfil Seleccionado
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryAmber, width: 1.5),
                  ),
                  child: ClipOval(
                    child: _selectedStaff.user.avatarAsset != null
                        ? Image.asset(
                            _selectedStaff.user.avatarAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(_selectedStaff.icon, color: AppColors.primaryAmber, size: 20),
                          )
                        : Icon(_selectedStaff.icon, color: AppColors.primaryAmber, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStaff.user.fullName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _roleLabel(_selectedStaff.user.role),
                      style: const TextStyle(
                        color: AppColors.primaryAmber,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              'INGRESA TU PIN DE 4 DÍGITOS',
              style: TextStyle(
                color: AppColors.textMuted,
                letterSpacing: 1.5,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Puntos de PIN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.primaryAmber : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFilled ? AppColors.primaryAmber : AppColors.surfaceHighlight,
                      width: 2,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: AppColors.primaryAmber.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),

            if (_isValidating) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(color: AppColors.primaryAmber, strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    AppStrings.verifyingPin,
                    style: TextStyle(color: AppColors.primaryAmber, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ] else if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.alertRed, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ] else ...[
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

            // Teclado Numérico Táctil
            _buildNumericKeypad(),

            const SizedBox(height: 10),

            const Text(
              AppStrings.keyboardSupported,
              style: TextStyle(color: AppColors.textDisabled, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        children: [
          Row(
            children: [
              _buildKeypadButton('1'),
              const SizedBox(width: 10),
              _buildKeypadButton('2'),
              const SizedBox(width: 10),
              _buildKeypadButton('3'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildKeypadButton('4'),
              const SizedBox(width: 10),
              _buildKeypadButton('5'),
              const SizedBox(width: 10),
              _buildKeypadButton('6'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildKeypadButton('7'),
              const SizedBox(width: 10),
              _buildKeypadButton('8'),
              const SizedBox(width: 10),
              _buildKeypadButton('9'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSpecialKeypadButton(
                label: 'C',
                onTap: _onClear,
                color: AppColors.alertRed,
              ),
              const SizedBox(width: 10),
              _buildKeypadButton('0'),
              const SizedBox(width: 10),
              _buildSpecialKeypadButton(
                icon: Icons.backspace_rounded,
                onTap: _onBackspace,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.3,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.surfaceHighlight),
            ),
          ),
          onPressed: () => _onKeypadTap(digit),
          child: Text(
            digit,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKeypadButton({String? label, IconData? icon, required VoidCallback onTap, required Color color}) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.3,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: color,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.surfaceHighlight),
            ),
          ),
          onPressed: onTap,
          child: label != null
              ? Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color))
              : Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
