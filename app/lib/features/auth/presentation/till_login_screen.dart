import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../staff/data/staff_sync_service.dart';
import '../data/till_auth_service.dart';
import '../domain/till_auth_state.dart';

class TillLoginScreen extends ConsumerStatefulWidget {
  const TillLoginScreen({super.key});

  @override
  ConsumerState<TillLoginScreen> createState() => _TillLoginScreenState();
}

class _TillLoginScreenState extends ConsumerState<TillLoginScreen> {
  List<StaffEntry> _staffList = [];
  StaffEntry? _selectedStaff;
  String _pin = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final db = ref.read(tillDatabaseProvider);
    final staff = await db.getAllStaff();
    if (mounted) {
      setState(() {
        _staffList = staff;
        if (staff.isNotEmpty && _selectedStaff == null) {
          _selectedStaff = staff.first;
        }
      });
    }

    // Attempt background sync if online
    try {
      final syncService = ref.read(staffSyncServiceProvider);
      await syncService.syncStaffBundle();
      final updatedStaff = await db.getAllStaff();
      if (mounted) {
        setState(() {
          _staffList = updatedStaff;
          if (_selectedStaff != null) {
            final match = updatedStaff.where((s) => s.id == _selectedStaff!.id);
            if (match.isNotEmpty) {
              _selectedStaff = match.first;
            } else if (updatedStaff.isNotEmpty) {
              _selectedStaff = updatedStaff.first;
            }
          } else if (updatedStaff.isNotEmpty) {
            _selectedStaff = updatedStaff.first;
          }
        });
      }
    } catch (_) {
      // Offline: keep existing local staff
    }
  }

  void _onDigitPressed(String digit) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += digit;
      _errorMessage = null;
    });
  }

  void _onBackspacePressed() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _onConfirmPressed() async {
    if (_selectedStaff == null || _pin.length < 4 || _pin.length > 6) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(tillSessionProvider.notifier)
          .login(staff: _selectedStaff!, pin: _pin);
      if (mounted) {
        context.go(AppRoutes.tillHome);
      }
    } on TillAuthInvalidPinException {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.loginInvalidPin;
          _pin = '';
        });
      }
    } on TillAuthNotAllowedException {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.loginStaffNotAllowed;
          _pin = '';
        });
      }
    } on TillAuthLockoutException catch (e) {
      if (mounted) {
        final local = e.lockedUntil.toLocal();
        final hh = local.hour.toString().padLeft(2, '0');
        final mm = local.minute.toString().padLeft(2, '0');
        final timeStr = '$hh:$mm';
        setState(() {
          _errorMessage = l10n.loginLockedUntil(timeStr);
          _pin = '';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.enrollmentNetworkError;
          _pin = '';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getInitials(String name) {
    final clean = name.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
    final parts = clean
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '??';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('login-sync-button'),
            icon: const Icon(Icons.sync_rounded),
            onPressed: _loadStaff,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (ref.watch(tillSessionProvider)?.isOffline == true)
              Container(
                key: const Key('login-offline-session-banner'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: AppDimensions.paddingMedium,
                ),
                color: AppColors.surfaceHighlight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.primaryAmber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.loginOfflineSession,
                      style: const TextStyle(
                        color: AppColors.primaryAmber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _staffList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_off_rounded,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),
                          Text(
                            l10n.loginNoStaff,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),
                          ElevatedButton.icon(
                            key: const Key('login-retry-sync-button'),
                            onPressed: _loadStaff,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(l10n.commonRetry),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        // Left column: Staff tiles
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: AppColors.surfaceHighlight,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(
                                    AppDimensions.paddingMedium,
                                  ),
                                  child: Text(
                                    l10n.loginSelectStaff,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: AppColors.textMuted),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.paddingMedium,
                                    ),
                                    itemCount: _staffList.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final staff = _staffList[index];
                                      final isSelected =
                                          _selectedStaff?.id == staff.id;
                                      return _StaffTile(
                                        key: Key('staff-tile-${staff.id}'),
                                        name: staff.displayName,
                                        initials: _getInitials(
                                          staff.displayName,
                                        ),
                                        isSelected: isSelected,
                                        onTap: () {
                                          setState(() {
                                            _selectedStaff = staff;
                                            _pin = '';
                                            _errorMessage = null;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right column: Keypad and PIN Entry
                        Expanded(
                          flex: 6,
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingLarge,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 380,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      _selectedStaff?.displayName ??
                                          l10n.loginSelectStaff,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.loginEnterPin,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textMuted,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.paddingMedium,
                                    ),

                                    if (_errorMessage != null) ...[
                                      Container(
                                        key: const Key('login-error-banner'),
                                        padding: const EdgeInsets.all(
                                          AppDimensions.paddingMedium,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.alertRedBg,
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusMedium,
                                          ),
                                          border: Border.all(
                                            color: AppColors.alertRed,
                                          ),
                                        ),
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: AppColors.alertRed,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppDimensions.paddingMedium,
                                      ),
                                    ],

                                    // PIN Dots: show only typed dots
                                    Container(
                                      key: const Key('pin-dots-container'),
                                      height: 48,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(_pin.length, (
                                          index,
                                        ) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primaryAmber,
                                              shape: BoxShape.circle,
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.paddingMedium,
                                    ),

                                    // Keypad
                                    _Keypad(
                                      onDigit: _onDigitPressed,
                                      onBackspace: _onBackspacePressed,
                                      onConfirm: _onConfirmPressed,
                                      isConfirmEnabled:
                                          _pin.length >= 4 && _pin.length <= 6,
                                      isLoading: _isLoading,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({
    super.key,
    required this.name,
    required this.initials,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final String initials;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.preferredTouchTarget,
      ),
      child: Material(
        color: isSelected ? AppColors.surfaceHighlight : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryAmber
                    : AppColors.surfaceHighlight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isSelected
                      ? AppColors.primaryAmber
                      : AppColors.surfaceElevated,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.backgroundDeep
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryAmber,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onConfirm,
    required this.isConfirmEnabled,
    required this.isLoading,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onConfirm;
  final bool isConfirmEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget buildDigitButton(String digit) {
      return SizedBox(
        width: AppDimensions.massiveTouchTarget,
        height: AppDimensions.preferredTouchTarget,
        child: OutlinedButton(
          key: Key('keypad-$digit'),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surfaceCard,
            side: const BorderSide(color: AppColors.surfaceHighlight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => onDigit(digit),
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildDigitButton('1'),
            buildDigitButton('2'),
            buildDigitButton('3'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildDigitButton('4'),
            buildDigitButton('5'),
            buildDigitButton('6'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildDigitButton('7'),
            buildDigitButton('8'),
            buildDigitButton('9'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Backspace button
            SizedBox(
              width: AppDimensions.massiveTouchTarget,
              height: AppDimensions.preferredTouchTarget,
              child: OutlinedButton(
                key: const Key('keypad-backspace'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surfaceCard,
                  side: const BorderSide(color: AppColors.surfaceHighlight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: onBackspace,
                child: const Icon(
                  Icons.backspace_outlined,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            buildDigitButton('0'),
            // Explicit confirm button
            SizedBox(
              width: AppDimensions.massiveTouchTarget,
              height: AppDimensions.preferredTouchTarget,
              child: ElevatedButton(
                key: const Key('keypad-confirm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConfirmEnabled
                      ? AppColors.primaryAmber
                      : AppColors.surfaceHighlight,
                  foregroundColor: isConfirmEnabled
                      ? AppColors.backgroundDeep
                      : AppColors.textDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: (isConfirmEnabled && !isLoading) ? onConfirm : null,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.backgroundDeep,
                        ),
                      )
                    : Text(
                        l10n.commonConfirm,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
