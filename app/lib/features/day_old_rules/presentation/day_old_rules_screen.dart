import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/catalog_writes.dart';
import 'package:bakery_pos/core/api/generated/models/day_old_rule.dart';
import 'package:bakery_pos/core/money/money.dart';
import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/backoffice/common/admin_ui.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dayOldRulesProvider = FutureProvider.autoDispose<List<DayOldRule>>((
  ref,
) async {
  final res = await ref.read(restClientProvider).catalog.listDayOldRules();
  return res.items;
});

/// One line for a rule, as the list and the dialog preview show it.
String dayOldRuleLabel(AppLocalizations l10n, int? after, int? bp, int? waste) {
  if (after != null && bp != null) {
    final percent = formatPercentBp(bp);
    return waste == null
        ? l10n.dayOldRuleText(percent, after)
        : l10n.dayOldRuleWithWaste(percent, after, waste);
  }
  return waste == null ? l10n.dayOldNoRule : l10n.dayOldWasteOnly(waste);
}

/// Back office: day-old rules for every product at once (decided 4 Nov 2026).
/// Pick products, or a whole category, and set when bread goes down in price
/// and when it goes to waste. Tills get the rule with the catalog.
class DayOldRulesScreen extends ConsumerStatefulWidget {
  const DayOldRulesScreen({super.key});

  @override
  ConsumerState<DayOldRulesScreen> createState() => _DayOldRulesScreenState();
}

class _DayOldRulesScreenState extends ConsumerState<DayOldRulesScreen> {
  final _selected = <String>{};

  Future<void> _apply(List<DayOldRule> rules) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final first = rules.firstWhere((r) => _selected.contains(r.productId));
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _RuleDialog(productIds: _selected.toList(), initial: first),
    );
    if (saved != true || !mounted) return;
    setState(_selected.clear);
    ref.invalidate(dayOldRulesProvider);
    messenger.showSnackBar(SnackBar(content: Text(l10n.dayOldSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final rules = ref.watch(dayOldRulesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dayOldTitle)),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: AdminErrorBanner(message: commonAdminError(l10n, e)),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: Text(l10n.dayOldEmpty, key: const Key('dayold-empty')),
            );
          }
          final byCategory = <String, List<DayOldRule>>{};
          for (final r in rows) {
            (byCategory[r.categoryName] ??= []).add(r);
          }
          return ListView(
            key: const Key('dayold-list'),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            children: [
              Text(l10n.dayOldIntro),
              const SizedBox(height: AppDimensions.paddingMedium),
              for (final MapEntry(key: category, value: items)
                  in byCategory.entries) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(category, style: theme.textTheme.titleMedium),
                    ),
                    TextButton(
                      key: Key('dayold-category-$category'),
                      onPressed: () => setState(() {
                        final ids = items.map((r) => r.productId);
                        if (ids.every(_selected.contains)) {
                          _selected.removeAll(ids);
                        } else {
                          _selected.addAll(ids);
                        }
                      }),
                      child: Text(l10n.dayOldSelectCategory),
                    ),
                  ],
                ),
                Card(
                  child: Column(
                    children: [
                      for (final r in items)
                        CheckboxListTile(
                          key: Key('dayold-${r.productId}'),
                          value: _selected.contains(r.productId),
                          onChanged: (v) => setState(() {
                            if (v == true) {
                              _selected.add(r.productId);
                            } else {
                              _selected.remove(r.productId);
                            }
                          }),
                          title: Text(r.productName),
                          subtitle: Text(
                            dayOldRuleLabel(
                              l10n,
                              r.dayOldDiscountAfterDays,
                              r.dayOldDiscountBp,
                              r.dayOldWasteAfterDays,
                            ),
                            key: Key('dayold-rule-${r.productId}'),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: _selected.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(l10n.dayOldSelected(_selected.length)),
                    ),
                    FilledButton(
                      key: const Key('dayold-apply'),
                      onPressed: () => _apply(rules.value ?? const []),
                      child: Text(l10n.dayOldApply),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RuleDialog extends ConsumerStatefulWidget {
  const _RuleDialog({required this.productIds, required this.initial});

  final List<String> productIds;
  final DayOldRule initial;

  @override
  ConsumerState<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends ConsumerState<_RuleDialog> {
  late final _after = TextEditingController(
    text: widget.initial.dayOldDiscountAfterDays?.toString() ?? '1',
  );
  late final _percent = TextEditingController(
    text: widget.initial.dayOldDiscountBp == null
        ? '30'
        : (widget.initial.dayOldDiscountBp! / 100).toStringAsFixed(0),
  );
  late final _waste = TextEditingController(
    text: widget.initial.dayOldWasteAfterDays?.toString() ?? '',
  );
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _after.dispose();
    _percent.dispose();
    _waste.dispose();
    super.dispose();
  }

  int? get _afterDays => int.tryParse(_after.text);
  int? get _bp {
    final p = int.tryParse(_percent.text);
    return p == null ? null : p * 100;
  }

  int? get _wasteDays => int.tryParse(_waste.text);

  bool get _valid {
    final after = _afterDays;
    final bp = _bp;
    final waste = _wasteDays;
    if (after == null || after < 1 || after > 60) return false;
    if (bp == null || bp < 100 || bp > 10000) return false;
    if (_waste.text.trim().isNotEmpty) {
      if (waste == null || waste <= after || waste > 60) return false;
    }
    return true;
  }

  Future<void> _save({required bool remove}) async {
    final l10n = AppLocalizations.of(context)!;
    if (!remove && !_valid) {
      setState(() => _error = l10n.dayOldInvalid);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(catalogWritesProvider)
          .setDayOldRules(
            productIds: widget.productIds,
            afterDays: remove ? null : _afterDays,
            discountBp: remove ? null : _bp,
            wasteAfterDays: remove ? null : _wasteDays,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = commonAdminError(l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return AlertDialog(
      title: Text(l10n.dayOldEditTitle(widget.productIds.length)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('dayold-after'),
              controller: _after,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: InputDecoration(labelText: l10n.dayOldAfterDays),
              onChanged: (_) => setState(() => _error = null),
            ),
            TextField(
              key: const Key('dayold-percent'),
              controller: _percent,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: InputDecoration(labelText: l10n.dayOldPercent),
              onChanged: (_) => setState(() => _error = null),
            ),
            TextField(
              key: const Key('dayold-waste'),
              controller: _waste,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: InputDecoration(labelText: l10n.dayOldWasteDays),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            if (_valid)
              Text(
                dayOldRuleLabel(l10n, _afterDays, _bp, _wasteDays),
                key: const Key('dayold-preview'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            if (_error != null)
              Text(
                _error!,
                key: const Key('dayold-error'),
                style: const TextStyle(color: AppColors.alertRed),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('dayold-remove'),
          onPressed: _busy ? null : () => _save(remove: true),
          child: Text(l10n.dayOldRemove),
        ),
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('dayold-save'),
          onPressed: _busy ? null : () => _save(remove: false),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
