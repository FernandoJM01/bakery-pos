import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/till_auth_service.dart';
import '../data/held_ticket_repository.dart';
import '../domain/ticket.dart';

String _hhmm(DateTime at) {
  final t = at.toLocal();
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// **Guardar**: keeps the ticket on this till with an optional name and
/// clears the screen (M3 brief 4.4).
Future<void> holdCurrentTicket(BuildContext context, WidgetRef ref) async {
  final ticket = ref.read(ticketProvider);
  final staffId = ref.read(tillSessionProvider)?.staff.id;
  if (ticket.isEmpty || staffId == null) return;
  final text = await showDialog<String>(
    context: context,
    builder: (_) => const _HoldDialog(),
  );
  if (text == null) return;
  await ref
      .read(heldTicketRepositoryProvider)
      .hold(
        ticket,
        name: text,
        staffId: staffId,
        now: ref.read(saleClockProvider)(),
      );
  ref.read(ticketProvider.notifier).clear();
  ref.invalidate(heldTicketsProvider);
}

/// Asks for an optional name; closes with it ('' for none), or null.
class _HoldDialog extends StatefulWidget {
  const _HoldDialog();

  @override
  State<_HoldDialog> createState() => _HoldDialogState();
}

class _HoldDialogState extends State<_HoldDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.saleHoldTitle),
      content: SizedBox(
        width: 400,
        child: TextField(
          key: const Key('hold-name'),
          controller: _name,
          autofocus: true,
          maxLength: 60,
          decoration: InputDecoration(
            labelText: l10n.saleHoldName,
            hintText: l10n.saleHoldNameHint,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('hold-confirm'),
          onPressed: () => Navigator.of(context).pop(_name.text),
          child: Text(l10n.saleHold),
        ),
      ],
    );
  }
}

/// **En espera (n)**: the held tickets of this till, newest first.
class HeldTicketsDialog extends ConsumerWidget {
  const HeldTicketsDialog({super.key});

  Future<void> _resume(BuildContext context, WidgetRef ref, String id) async {
    final ticket = await ref.read(heldTicketRepositoryProvider).resume(id);
    ref.invalidate(heldTicketsProvider);
    if (ticket != null) ref.read(ticketProvider.notifier).restore(ticket);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _discard(WidgetRef ref, String id) async {
    final staffId = ref.read(tillSessionProvider)?.staff.id;
    if (staffId == null) return;
    await ref
        .read(heldTicketRepositoryProvider)
        .discard(id, staffId: staffId, now: ref.read(saleClockProvider)());
    ref.invalidate(heldTicketsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final held = ref.watch(heldTicketsProvider);
    final busy = !ref.watch(ticketProvider).isEmpty;

    return AlertDialog(
      title: Text(l10n.saleHeldTitle),
      content: SizedBox(
        width: 520,
        child: held.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Text(l10n.saleHeldEmpty),
          data: (items) => items.isEmpty
              ? Text(l10n.saleHeldEmpty, key: const Key('held-empty'))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (busy)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall,
                        ),
                        child: Text(
                          l10n.saleHeldBusy,
                          key: const Key('held-busy'),
                          style: const TextStyle(
                            color: AppColors.warningOrange,
                          ),
                        ),
                      ),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final h in items)
                            ListTile(
                              key: Key('held-${h.id}'),
                              title: Text(h.name ?? l10n.saleHeldUnnamed),
                              subtitle: Text(
                                l10n.saleHeldSubtitle(
                                  _hhmm(h.heldAt),
                                  h.lineCount,
                                  formatCents(h.totalCents),
                                ),
                              ),
                              trailing: Wrap(
                                spacing: AppDimensions.paddingSmall,
                                children: [
                                  TextButton(
                                    key: Key('held-discard-${h.id}'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.alertRed,
                                    ),
                                    onPressed: () => _discard(ref, h.id),
                                    child: Text(l10n.saleHeldDiscard),
                                  ),
                                  FilledButton(
                                    key: Key('held-resume-${h.id}'),
                                    onPressed: busy
                                        ? null
                                        : () => _resume(context, ref, h.id),
                                    child: Text(l10n.saleHeldResume),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
