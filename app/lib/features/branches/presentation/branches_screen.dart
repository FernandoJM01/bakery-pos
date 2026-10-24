import 'package:bakery_pos/core/theme/app_colors.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/features/branches/data/branches_service.dart';
import 'package:bakery_pos/features/branches/presentation/branch_form_dialog.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final branchesState = ref.watch(branchesServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.branchesTitle),
        actions: [
          IconButton(
            key: const Key('refresh-branches-button'),
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(branchesServiceProvider.notifier).refresh(),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
            child: ElevatedButton.icon(
              key: const Key('create-branch-button'),
              icon: const Icon(Icons.add),
              label: Text(l10n.branchesNew),
              onPressed: () async {
                final created = await showDialog<bool>(
                  context: context,
                  builder: (_) => const BranchCreateDialog(),
                );
                if (created == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.branchesCreateSuccess)),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: branchesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.branchesErrorLoading,
                style: const TextStyle(color: AppColors.alertRed),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              ElevatedButton(
                onPressed: () =>
                    ref.read(branchesServiceProvider.notifier).refresh(),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (branches) {
          if (branches.isEmpty) {
            return Center(
              child: Text(
                l10n.branchesEmpty,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  key: const Key('branches-table'),
                  columnSpacing: 24.0,
                  horizontalMargin: 16.0,
                  columns: [
                    DataColumn(label: Text(l10n.branchesCode)),
                    DataColumn(label: Text(l10n.branchesName)),
                    DataColumn(label: Text(l10n.branchesAddress)),
                    DataColumn(label: Text(l10n.branchesTimezone)),
                    DataColumn(label: Text(l10n.branchesStatus)),
                    const DataColumn(label: SizedBox.shrink()),
                  ],
                  rows: [
                    for (final branch in branches)
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              branch.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(branch.name)),
                          DataCell(Text(branch.address ?? '')),
                          DataCell(Text(branch.timezone)),
                          DataCell(
                            Chip(
                              label: Text(
                                branch.isActive
                                    ? l10n.branchesActive
                                    : l10n.branchesInactive,
                              ),
                              backgroundColor: branch.isActive
                                  ? AppColors.successGreenBg
                                  : AppColors.surfaceHighlight,
                            ),
                          ),
                          DataCell(
                            IconButton(
                              key: Key('edit-branch-${branch.code}'),
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                final updated = await showDialog<bool>(
                                  context: context,
                                  builder: (_) =>
                                      BranchEditDialog(branch: branch),
                                );
                                if (updated == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.branchesUpdateSuccess),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
