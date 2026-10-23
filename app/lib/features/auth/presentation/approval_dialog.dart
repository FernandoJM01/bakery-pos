import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/approval_request.dart';
import '../../../core/api/generated/models/permission_key.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/till_auth_service.dart';
import '../domain/approval_models.dart';
import '../domain/offline_pin_verifier.dart';

/// Only these roles can approve (brief 5.4, A12), matching the server.
const approverRoles = {'OWNER', 'BRANCH_MANAGER'};

Future<ApprovalResult?> requestApproval(
  BuildContext context, {
  required String action,
  String? reference,
}) {
  return showDialog<ApprovalResult?>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        ManagerApprovalDialog(action: action, reference: reference),
  );
}

class ManagerApprovalDialog extends ConsumerStatefulWidget {
  const ManagerApprovalDialog({
    super.key,
    required this.action,
    this.reference,
  });

  final String action;
  final String? reference;

  @override
  ConsumerState<ManagerApprovalDialog> createState() =>
      _ManagerApprovalDialogState();
}

class _ManagerApprovalDialogState extends ConsumerState<ManagerApprovalDialog> {
  List<StaffEntry> _eligibleStaff = [];
  StaffEntry? _selectedApprover;
  String _pin = '';
  bool _isLoading = false;
  bool _isLoadingStaff = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApprovers();
  }

  Future<void> _loadApprovers() async {
    final db = ref.read(tillDatabaseProvider);
    final currentSession = ref.read(tillSessionProvider);
    final staffWithPerm = await db.getStaffWithPermission(widget.action);
    final eligible = staffWithPerm
        .where(
          (s) =>
              s.id != currentSession?.staff.id &&
              approverRoles.contains(s.role),
        )
        .toList();

    if (mounted) {
      setState(() {
        _eligibleStaff = eligible;
        if (eligible.isNotEmpty) {
          _selectedApprover = eligible.first;
        }
        _isLoadingStaff = false;
      });
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
    if (_selectedApprover == null || _pin.length < 4 || _pin.length > 6) return;

    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(tillDatabaseProvider);
    final session = ref.read(tillSessionProvider);
    final now = DateTime.now();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isOffline = session?.isOffline ?? false;

    if (isOffline) {
      await _executeOfflineApproval(db, l10n, now);
      return;
    }

    // Online approval flow
    final restClient = ref.read(restClientProvider);
    try {
      final response = await restClient.auth.createApproval(
        body: ApprovalRequest(
          approverStaffId: _selectedApprover!.id,
          pin: _pin,
          action: PermissionKey.fromJson(widget.action),
          reference: widget.reference,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(
          OnlineApprovalResult(
            approvalToken: response.approvalToken,
            expiresAt: response.expiresAt,
            approverStaffId: response.approverStaffId,
            action: widget.action,
          ),
        );
      }
    } on DioException catch (e) {
      if (_isUnreachable(e)) {
        await _executeOfflineApproval(db, l10n, now);
        return;
      }

      final data = e.response?.data;
      final code = data is Map ? data['code']?.toString() : null;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _pin = '';
          switch (code) {
            case 'AUTH_INVALID_PIN':
              _errorMessage = l10n.approvalInvalidPin;
              break;
            case 'AUTH_LOCKED':
              _errorMessage = l10n.approvalLocked;
              break;
            case 'PERMISSION_DENIED':
              _errorMessage = l10n.approvalPermissionDenied;
              break;
            default:
              _errorMessage = l10n.approvalDenied;
              break;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _pin = '';
          _errorMessage = l10n.approvalDenied;
        });
      }
    }
  }

  Future<void> _executeOfflineApproval(
    AppDatabase db,
    AppLocalizations l10n,
    DateTime now,
  ) async {
    final approver = _selectedApprover!;
    final requester = ref.read(tillSessionProvider)?.staff;
    if (requester == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Check active lockout
    final activeLockout = await db.getActiveLockout(approver.id, now);
    if (activeLockout != null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _pin = '';
          _errorMessage = l10n.approvalLocked;
        });
      }
      return;
    }

    final verifier = ref.read(offlinePinVerifierProvider);
    final isValid = await verifier.verify(_pin, approver.offlinePinVerifier);

    if (!isValid) {
      final lockedUntil = await db.recordFailedPinAttempt(approver.id, now);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _pin = '';
          if (lockedUntil != null) {
            _errorMessage = l10n.approvalLocked;
          } else {
            _errorMessage = l10n.approvalInvalidPin;
          }
        });
      }
      return;
    }

    // Offline success
    await db.resetLockout(approver.id);
    final id = const Uuid().v7();
    await db.recordOfflineApproval(
      id: id,
      approverStaffId: approver.id,
      requesterStaffId: requester.id,
      action: widget.action,
      reference: widget.reference,
      createdAt: now,
    );

    if (mounted) {
      Navigator.of(context).pop(
        OfflineApprovalResult(
          id: id,
          approverStaffId: approver.id,
          action: widget.action,
          reference: widget.reference,
          createdAt: now,
        ),
      );
    }
  }

  static const _unreachableTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };

  static bool _isUnreachable(DioException e) =>
      e.response == null &&
      (_unreachableTypes.contains(e.type) ||
          (e.type == DioExceptionType.unknown && e.error is SocketException));

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return '??';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      key: const Key('manager-approval-dialog'),
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.surfaceHighlight),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.primaryAmber,
                    size: 28,
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Text(
                      l10n.approvalTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('approval-cancel-button'),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: l10n.commonCancel,
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                l10n.approvalPinPrompt,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // Body
              if (_isLoadingStaff)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.paddingLarge),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_eligibleStaff.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_off_rounded,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        Text(
                          l10n.approvalNoApprovers,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        ElevatedButton(
                          key: const Key('approval-close-empty-button'),
                          onPressed: () => Navigator.of(context).pop(null),
                          child: Text(l10n.commonClose),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Approvers list
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.approvalSelectApprover,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Expanded(
                              child: ListView.separated(
                                itemCount: _eligibleStaff.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final staff = _eligibleStaff[index];
                                  final isSelected =
                                      _selectedApprover?.id == staff.id;
                                  return _ApproverTile(
                                    key: Key('approval-staff-${staff.id}'),
                                    displayName: staff.displayName,
                                    initials: _getInitials(staff.displayName),
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedApprover = staff;
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
                      const SizedBox(width: AppDimensions.paddingLarge),

                      // PIN entry and Keypad
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Error banner
                            if (_errorMessage != null) ...[
                              Container(
                                key: const Key('approval-error-message'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingMedium,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.alertRedBg,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSmall,
                                  ),
                                  border: Border.all(
                                    color: AppColors.alertRed.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.alertRed,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // PIN dots (hidden length)
                            SizedBox(
                              height: 28,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_pin.length, (index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryAmber,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Keypad
                            _DialogKeypad(
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
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApproverTile extends StatelessWidget {
  const _ApproverTile({
    super.key,
    required this.displayName,
    required this.initials,
    required this.isSelected,
    required this.onTap,
  });

  final String displayName;
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
              vertical: 8,
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
                  radius: 18,
                  backgroundColor: isSelected
                      ? AppColors.primaryAmber
                      : AppColors.surfaceElevated,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected
                          ? AppColors.backgroundDeep
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Text(
                    displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogKeypad extends StatelessWidget {
  const _DialogKeypad({
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

    Widget buildDigit(String digit) {
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
          onPressed: isLoading ? null : () => onDigit(digit),
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 22,
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
          children: [buildDigit('1'), buildDigit('2'), buildDigit('3')],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [buildDigit('4'), buildDigit('5'), buildDigit('6')],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [buildDigit('7'), buildDigit('8'), buildDigit('9')],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Backspace
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
                onPressed: isLoading ? null : onBackspace,
                child: const Icon(
                  Icons.backspace_outlined,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
            buildDigit('0'),
            // Confirm button
            SizedBox(
              width: AppDimensions.massiveTouchTarget,
              height: AppDimensions.preferredTouchTarget,
              child: ElevatedButton(
                key: const Key('keypad-confirm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: AppColors.backgroundDeep,
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.backgroundDeep,
                          ),
                        ),
                      )
                    : Text(
                        l10n.commonConfirm,
                        style: const TextStyle(
                          fontSize: 14,
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
