import 'package:bakery_pos/core/api/generated/models/branch.dart';
import 'package:bakery_pos/core/api/generated/models/branch_create.dart';
import 'package:bakery_pos/core/api/generated/models/branch_update.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/features/branches/domain/mexico_timezones.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BranchCreateDialog extends ConsumerStatefulWidget {
  const BranchCreateDialog({super.key});

  @override
  ConsumerState<BranchCreateDialog> createState() => _BranchCreateDialogState();
}

class _BranchCreateDialogState extends ConsumerState<BranchCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedTimezone = 'America/Mexico_City';

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;
    try {
      final code = _codeController.text.trim().toUpperCase();
      final name = _nameController.text.trim();
      final address = _addressController.text.trim();

      await ref
          .read(branchesServiceProvider.notifier)
          .createBranch(
            BranchCreate(
              code: code,
              name: name,
              address: address.isEmpty ? null : address,
              timezone: _selectedTimezone,
            ),
          );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on DioException catch (e) {
      if (mounted) {
        final data = e.response?.data;
        final code = data is Map ? data['code']?.toString() : null;
        setState(() {
          if (code == 'CONFLICT' || e.response?.statusCode == 409) {
            _errorMessage = l10n.branchesCodeConflict;
          } else if (code == 'VALIDATION_FAILED' ||
              e.response?.statusCode == 400) {
            _errorMessage = l10n.validationFailed;
          } else {
            _errorMessage = l10n.enrollmentNetworkError;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.enrollmentNetworkError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.branchesNew),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.alertRedBg,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                      border: Border.all(color: AppColors.alertRed),
                    ),
                    child: Text(
                      _errorMessage!,
                      key: const Key('branch-dialog-error'),
                      style: const TextStyle(color: AppColors.alertRed),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                ],
                TextFormField(
                  key: const Key('branch-code-input'),
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(labelText: l10n.branchesCode),
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^[A-Z0-9]{2,10}$').hasMatch(value.trim())) {
                      return l10n.branchesCodeInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                TextFormField(
                  key: const Key('branch-name-input'),
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.branchesName),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.branchesNameRequired;
                    }
                    if (value.trim().length > 120) {
                      return l10n.branchesNameInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                TextFormField(
                  key: const Key('branch-address-input'),
                  controller: _addressController,
                  decoration: InputDecoration(labelText: l10n.branchesAddress),
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                DropdownButtonFormField<String>(
                  key: const Key('branch-timezone-input'),
                  isExpanded: true,
                  initialValue: _selectedTimezone,
                  decoration: InputDecoration(labelText: l10n.branchesTimezone),
                  items: [
                    for (final tz in mexicoTimezones)
                      DropdownMenuItem(
                        value: tz,
                        child: Text(formatMexicoTimezone(tz, l10n)),
                      ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTimezone = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('cancel-button'),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('save-branch-button'),
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.commonSave),
        ),
      ],
    );
  }
}

class BranchEditDialog extends ConsumerStatefulWidget {
  const BranchEditDialog({super.key, required this.branch});

  final Branch branch;

  @override
  ConsumerState<BranchEditDialog> createState() => _BranchEditDialogState();
}

class _BranchEditDialogState extends ConsumerState<BranchEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late String _selectedTimezone;
  late bool _isActive;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch.name);
    _addressController = TextEditingController(
      text: widget.branch.address ?? '',
    );
    _selectedTimezone = widget.branch.timezone;
    _isActive = widget.branch.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;
    try {
      final name = _nameController.text.trim();
      final address = _addressController.text.trim();

      await ref
          .read(branchesServiceProvider.notifier)
          .updateBranch(
            widget.branch.id,
            BranchUpdate(
              name: name,
              address: address.isEmpty ? null : address,
              timezone: _selectedTimezone,
              isActive: _isActive,
            ),
          );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on DioException catch (e) {
      if (mounted) {
        final data = e.response?.data;
        final code = data is Map ? data['code']?.toString() : null;
        setState(() {
          if (code == 'CONFLICT' || e.response?.statusCode == 409) {
            _errorMessage = l10n.branchesCodeConflict;
          } else if (code == 'VALIDATION_FAILED' ||
              e.response?.statusCode == 400) {
            _errorMessage = l10n.validationFailed;
          } else {
            _errorMessage = l10n.enrollmentNetworkError;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.enrollmentNetworkError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.branchesEdit),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.alertRedBg,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                      border: Border.all(color: AppColors.alertRed),
                    ),
                    child: Text(
                      _errorMessage!,
                      key: const Key('branch-dialog-error'),
                      style: const TextStyle(color: AppColors.alertRed),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                ],
                TextFormField(
                  key: const Key('branch-code-readonly'),
                  initialValue: widget.branch.code,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: l10n.branchesCode,
                    helperText: l10n.branchesCodeImmutable,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                TextFormField(
                  key: const Key('branch-name-input'),
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.branchesName),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.branchesNameRequired;
                    }
                    if (value.trim().length > 120) {
                      return l10n.branchesNameInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                TextFormField(
                  key: const Key('branch-address-input'),
                  controller: _addressController,
                  decoration: InputDecoration(labelText: l10n.branchesAddress),
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                DropdownButtonFormField<String>(
                  key: const Key('branch-timezone-input'),
                  isExpanded: true,
                  initialValue: mexicoTimezones.contains(_selectedTimezone)
                      ? _selectedTimezone
                      : 'America/Mexico_City',
                  decoration: InputDecoration(labelText: l10n.branchesTimezone),
                  items: [
                    for (final tz in mexicoTimezones)
                      DropdownMenuItem(
                        value: tz,
                        child: Text(formatMexicoTimezone(tz, l10n)),
                      ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTimezone = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                SwitchListTile(
                  key: const Key('branch-active-switch'),
                  title: Text(l10n.branchesActive),
                  value: _isActive,
                  onChanged: (val) {
                    setState(() {
                      _isActive = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('cancel-button'),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('save-branch-button'),
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.commonSave),
        ),
      ],
    );
  }
}
