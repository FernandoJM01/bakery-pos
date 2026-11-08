import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/generated/models/get_v1_oven_fees_response.dart';
import 'package:bakery_pos/core/api/generated/models/oven_fee_rule.dart';
import 'package:bakery_pos/core/api/generated/models/oven_fee_rule_create.dart';
import 'package:bakery_pos/core/api/generated/models/oven_fee_rule_update.dart';
import 'package:bakery_pos/core/api/generated/models/tax_kind.dart';
import 'package:bakery_pos/core/api/generated/models/tax_rate.dart';
import 'package:bakery_pos/core/api/generated/models/v1_oven_branches_branch_id_request_body.dart';
import 'package:bakery_pos/core/money/money.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/auth/data/backoffice_auth_service.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/features/catalog/data/catalog_admin_service.dart';
import 'package:bakery_pos/features/oven/domain/oven_fee.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ovenFeesProvider = FutureProvider.autoDispose<GetV1OvenFeesResponse>(
  (ref) => ref.read(restClientProvider).oven.listOvenFees(),
);

/// Back office Horno (M8.5): which branches take dishes, and what each dish
/// type costs. The fee is a base plus a price per kilo.
class OvenSettingsScreen extends ConsumerWidget {
  const OvenSettingsScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    OvenFeeRule? rule,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _FeeDialog(rule: rule),
    );
    if (saved != true) return;
    ref.invalidate(ovenFeesProvider);
    messenger.showSnackBar(SnackBar(content: Text(l10n.ovenFeeSaved)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fees = ref.watch(ovenFeesProvider);
    final canBranches =
        ref
            .watch(backofficeAuthServiceProvider)
            .currentSession
            ?.permissions
            .contains('branches.manage') ==
        true;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ovenSettingsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('oven-fee-add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.ovenFeeAdd),
        onPressed: () => _edit(context, ref, null),
      ),
      body: fees.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: AdminErrorBanner(message: commonAdminError(l10n, e)),
        ),
        data: (data) => ListView(
          key: const Key('oven-settings'),
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          children: [
            Text(l10n.ovenSettingsIntro),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(l10n.ovenBranches, style: theme.textTheme.titleMedium),
            Card(
              child: Column(
                children: [
                  for (final b in data.branches)
                    SwitchListTile(
                      key: Key('oven-branch-${b.branchId}'),
                      title: Text(b.name),
                      value: b.enabled,
                      onChanged: !canBranches
                          ? null
                          : (v) async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await ref
                                    .read(restClientProvider)
                                    .oven
                                    .setOvenBranch(
                                      branchId: b.branchId,
                                      body: V1OvenBranchesBranchIdRequestBody(
                                        enabled: v,
                                      ),
                                    );
                                ref.invalidate(ovenFeesProvider);
                              } on Object catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(commonAdminError(l10n, e)),
                                  ),
                                );
                              }
                            },
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(l10n.ovenFees, style: theme.textTheme.titleMedium),
            if (data.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Text(
                  l10n.ovenFeesEmpty,
                  key: const Key('oven-fees-empty'),
                ),
              ),
            Card(
              child: Column(
                children: [
                  for (final r in data.items)
                    ListTile(
                      key: Key('oven-fee-${r.id}'),
                      title: Text(r.name),
                      subtitle: Text(
                        l10n.ovenFeeRuleText(
                          formatCents(r.baseCents),
                          formatCents(r.perKgCents),
                          formatCents(ovenFee(r.baseCents, r.perKgCents, 1000)),
                        ),
                      ),
                      trailing: r.isActive
                          ? const Icon(Icons.edit_outlined)
                          : AdminStatusChip(
                              label: l10n.ovenFeeOff,
                              color: AppColors.textMuted,
                            ),
                      onTap: () => _edit(context, ref, r),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _FeeDialog extends ConsumerStatefulWidget {
  const _FeeDialog({required this.rule});

  final OvenFeeRule? rule;

  @override
  ConsumerState<_FeeDialog> createState() => _FeeDialogState();
}

class _FeeDialogState extends ConsumerState<_FeeDialog> {
  late final _name = TextEditingController(text: widget.rule?.name ?? '');
  late final _base = TextEditingController(
    text: widget.rule == null ? '' : centsToInput(widget.rule!.baseCents),
  );
  late final _perKg = TextEditingController(
    text: widget.rule == null ? '' : centsToInput(widget.rule!.perKgCents),
  );
  late String? _ivaId = widget.rule?.ivaRateId;
  late bool _active = widget.rule?.isActive ?? true;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _base.dispose();
    _perKg.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final base = parseCents(_base.text.trim());
    final perKg = parseCents(_perKg.text.trim());
    final name = _name.text.trim();
    if (name.isEmpty || base == null || perKg == null || _ivaId == null) {
      setState(() => _error = l10n.ovenFeeIncomplete);
      return;
    }
    setState(() => _busy = true);
    final api = ref.read(restClientProvider).oven;
    try {
      final rule = widget.rule;
      if (rule == null) {
        await api.createOvenFee(
          body: OvenFeeRuleCreate(
            name: name,
            baseCents: base,
            perKgCents: perKg,
            ivaRateId: _ivaId!,
          ),
        );
      } else {
        await api.updateOvenFee(
          ruleId: rule.id,
          body: OvenFeeRuleUpdate(
            name: name,
            baseCents: base,
            perKgCents: perKg,
            isActive: _active,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      setState(() {
        _busy = false;
        _error = commonAdminError(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rates = [
      for (final t in ref.watch(taxRatesProvider).value ?? const <TaxRate>[])
        if (t.kind == TaxKind.iva && (t.isActive || t.id == _ivaId)) t,
    ];
    final base = parseCents(_base.text.trim());
    final perKg = parseCents(_perKg.text.trim());
    return AlertDialog(
      title: Text(widget.rule == null ? l10n.ovenFeeAdd : l10n.ovenFeeEdit),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('oven-fee-name'),
              controller: _name,
              decoration: InputDecoration(labelText: l10n.ovenFeeName),
            ),
            TextField(
              key: const Key('oven-fee-base'),
              controller: _base,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.ovenFeeBase),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              key: const Key('oven-fee-perkg'),
              controller: _perKg,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.ovenFeePerKg),
              onChanged: (_) => setState(() {}),
            ),
            if (widget.rule == null)
              DropdownButtonFormField<String>(
                key: const Key('oven-fee-iva'),
                initialValue: _ivaId,
                decoration: InputDecoration(labelText: l10n.ovenFeeIva),
                items: [
                  for (final t in rates)
                    DropdownMenuItem(
                      value: t.id,
                      child: Text(
                        l10n.ovenFeeIvaOption(
                          t.name,
                          formatPercentBp(t.rateBp),
                        ),
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _ivaId = v),
              )
            else
              SwitchListTile(
                key: const Key('oven-fee-active'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.ovenFeeActive),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            if (base != null && perKg != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
                child: Text(
                  l10n.ovenFeeExample(
                    formatCents(ovenFee(base, perKg, 1000)),
                    formatCents(ovenFee(base, perKg, 3000)),
                  ),
                  key: const Key('oven-fee-example'),
                ),
              ),
            if (_error != null)
              Text(
                _error!,
                key: const Key('oven-fee-error'),
                style: const TextStyle(color: AppColors.alertRed),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('oven-fee-save'),
          onPressed: _busy ? null : _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
