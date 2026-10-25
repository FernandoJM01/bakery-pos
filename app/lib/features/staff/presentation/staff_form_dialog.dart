import 'package:bakery_pos/core/api/generated/models/role.dart';
import 'package:bakery_pos/core/api/generated/models/staff.dart';
import 'package:bakery_pos/core/api/generated/models/staff_create.dart';
import 'package:bakery_pos/core/api/generated/models/staff_update.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/features/staff/data/staff_admin_service.dart';
import 'package:bakery_pos/features/staff/presentation/staff_labels.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Spanish text for staff errors; the contract gives every 409 the code
/// CONFLICT, so the server message tells the two staff conflicts apart.
String staffErrorText(AppLocalizations l10n, Object error) {
  if (apiErrorCode(error) == 'CONFLICT') {
    final message = (apiErrorMessage(error) ?? '').toLowerCase();
    if (message.contains('owner')) return l10n.staffLastOwner;
    if (message.contains('email')) return l10n.staffEmailConflict;
  }
  return commonAdminError(l10n, error);
}

/// Creates a staff member, or edits one when [staff] is given.
class StaffFormDialog extends ConsumerStatefulWidget {
  const StaffFormDialog({super.key, this.staff});

  final Staff? staff;

  @override
  ConsumerState<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends ConsumerState<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _fullName = TextEditingController(text: widget.staff?.fullName);
  late final _displayName = TextEditingController(
    text: widget.staff?.displayName,
  );
  late final _email = TextEditingController(text: widget.staff?.email);
  final _password = TextEditingController();
  final _pin = TextEditingController();
  final _pinConfirm = TextEditingController();
  late Role _role = widget.staff?.role ?? Role.cashier;
  late final Set<String> _branchIds = {...?widget.staff?.branchIds};
  bool _saving = false;
  String? _error;
  bool _branchError = false;

  bool get _isEdit => widget.staff != null;
  bool get _usesBackOffice =>
      _role == Role.owner || _role == Role.branchManager;

  @override
  void dispose() {
    for (final c in [
      _fullName,
      _displayName,
      _email,
      _password,
      _pin,
      _pinConfirm,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _needsPassword() =>
      _role == Role.owner && !(_isEdit && widget.staff!.hasPassword);

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final formOk = _formKey.currentState!.validate();
    setState(() => _branchError = _branchIds.isEmpty);
    if (!formOk || _branchIds.isEmpty) return;

    final email = _email.text.trim().toLowerCase();
    final password = _password.text;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final notifier = ref.read(staffAdminProvider.notifier);
      if (!_isEdit) {
        await notifier.create(
          StaffCreate(
            fullName: _fullName.text.trim(),
            displayName: _displayName.text.trim(),
            role: _role,
            email: _usesBackOffice && email.isNotEmpty ? email : null,
            password: _usesBackOffice && password.isNotEmpty ? password : null,
            branchIds: _branchIds.toList(),
            pin: _pin.text,
          ),
        );
      } else {
        final s = widget.staff!;
        String? changed(String value, String? old) =>
            value == (old ?? '') ? null : value;
        final branchesChanged =
            _branchIds.length != s.branchIds.length ||
            !_branchIds.containsAll(s.branchIds);
        final update = StaffUpdate(
          fullName: changed(_fullName.text.trim(), s.fullName),
          displayName: changed(_displayName.text.trim(), s.displayName),
          role: _role == s.role ? null : _role,
          email: _usesBackOffice && email.isNotEmpty
              ? changed(email, s.email)
              : null,
          password: _usesBackOffice && password.isNotEmpty ? password : null,
          branchIds: branchesChanged ? _branchIds.toList() : null,
        );
        if (update.toJson().isNotEmpty) {
          await notifier.updateStaff(s.id, update);
        }
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = staffErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branches = ref.watch(branchesServiceProvider).value ?? const [];

    return AlertDialog(
      title: Text(_isEdit ? l10n.staffEdit : l10n.staffNew),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, minWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) AdminErrorBanner(message: _error!),
                TextFormField(
                  key: const Key('staff-fullname-input'),
                  controller: _fullName,
                  decoration: InputDecoration(labelText: l10n.staffFullName),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    return t.isEmpty || t.length > 120
                        ? l10n.staffFullNameInvalid
                        : null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                TextFormField(
                  key: const Key('staff-displayname-input'),
                  controller: _displayName,
                  decoration: InputDecoration(
                    labelText: l10n.staffDisplayName,
                    helperText: l10n.staffDisplayNameHelp,
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    return t.isEmpty || t.length > 30
                        ? l10n.staffDisplayNameInvalid
                        : null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                DropdownButtonFormField<Role>(
                  key: const Key('staff-role-input'),
                  initialValue: _role,
                  decoration: InputDecoration(labelText: l10n.staffRole),
                  items: [
                    for (final r in Role.$valuesDefined)
                      DropdownMenuItem(
                        value: r,
                        child: Text(roleLabel(r, l10n)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? _role),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(l10n.staffBranches),
                const SizedBox(height: AppDimensions.paddingSmall),
                Wrap(
                  spacing: AppDimensions.paddingSmall,
                  children: [
                    for (final b in branches)
                      FilterChip(
                        key: Key('staff-branch-${b.code}'),
                        label: Text(b.name),
                        selected: _branchIds.contains(b.id),
                        onSelected: (on) => setState(() {
                          on ? _branchIds.add(b.id) : _branchIds.remove(b.id);
                        }),
                      ),
                  ],
                ),
                if (_branchError)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimensions.paddingSmall,
                    ),
                    child: Text(
                      l10n.staffBranchesRequired,
                      key: const Key('staff-branches-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (_usesBackOffice) ...[
                  const SizedBox(height: AppDimensions.paddingMedium),
                  TextFormField(
                    key: const Key('staff-email-input'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: _role == Role.owner
                          ? l10n.staffEmail
                          : l10n.staffEmailOptional,
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      final required =
                          _role == Role.owner || _password.text.isNotEmpty;
                      if (t.isEmpty) {
                        return required ? l10n.staffEmailRequired : null;
                      }
                      return emailPattern.hasMatch(t)
                          ? null
                          : l10n.staffEmailInvalid;
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  TextFormField(
                    key: const Key('staff-password-input'),
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _isEdit
                          ? l10n.staffNewPasswordOptional
                          : l10n.staffPassword,
                      helperText: l10n.staffPasswordHelp,
                    ),
                    validator: (v) {
                      final t = v ?? '';
                      if (t.isEmpty) {
                        return _needsPassword()
                            ? l10n.staffPasswordRequired
                            : null;
                      }
                      return t.length < 10 ? l10n.staffPasswordTooShort : null;
                    },
                  ),
                ],
                if (!_isEdit) ...[
                  const SizedBox(height: AppDimensions.paddingMedium),
                  _PinFields(pin: _pin, confirm: _pinConfirm),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('cancel-button'),
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('save-staff-button'),
          onPressed: _saving ? null : _save,
          child: Text(_saving ? l10n.branchesSaving : l10n.commonSave),
        ),
      ],
    );
  }
}

/// The PIN typed twice, so a typo never locks someone out.
class _PinFields extends StatelessWidget {
  const _PinFields({required this.pin, required this.confirm});

  final TextEditingController pin;
  final TextEditingController confirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            key: const Key('staff-pin-input'),
            controller: pin,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(labelText: l10n.staffPin),
            validator: (v) =>
                pinPattern.hasMatch(v ?? '') ? null : l10n.staffPinInvalid,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: TextFormField(
            key: const Key('staff-pin-confirm-input'),
            controller: confirm,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(labelText: l10n.staffPinConfirm),
            validator: (v) => v == pin.text ? null : l10n.staffPinMismatch,
          ),
        ),
      ],
    );
  }
}

class StaffPinDialog extends ConsumerStatefulWidget {
  const StaffPinDialog({super.key, required this.staff});

  final Staff staff;

  @override
  ConsumerState<StaffPinDialog> createState() => _StaffPinDialogState();
}

class _StaffPinDialogState extends ConsumerState<StaffPinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(staffAdminProvider.notifier)
          .setPin(widget.staff.id, _pin.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = staffErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.staffResetPinTitle(widget.staff.displayName)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) AdminErrorBanner(message: _error!),
              Text(l10n.staffResetPinMessage),
              const SizedBox(height: AppDimensions.paddingMedium),
              _PinFields(pin: _pin, confirm: _confirm),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('cancel-button'),
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          key: const Key('save-pin-button'),
          onPressed: _saving ? null : _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
