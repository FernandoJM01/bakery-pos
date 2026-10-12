import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../catalog/domain/product.dart';
import 'cart_notifier.dart';

class HeldTicket {
  final String id;
  final String label;
  final DateTime createdAt;
  final String cashierName;
  final List<CartItem> items;
  final int totalCents;

  const HeldTicket({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.cashierName,
    required this.items,
    required this.totalCents,
  });
}

class HeldTicketsNotifier extends StateNotifier<List<HeldTicket>> {
  static const _uuid = Uuid();

  HeldTicketsNotifier() : super([]);

  String parkCart({
    required String label,
    required String cashierName,
    required List<CartItem> items,
    required int totalCents,
  }) {
    if (items.isEmpty) return '';

    final id = _uuid.v4();
    final newTicket = HeldTicket(
      id: id,
      label: label.trim().isEmpty ? 'Ticket #${state.length + 1}' : label.trim(),
      createdAt: DateTime.now(),
      cashierName: cashierName,
      items: List.from(items),
      totalCents: totalCents,
    );

    state = [newTicket, ...state];
    return id;
  }

  HeldTicket? resumeTicket(String id) {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return null;

    final ticket = state[index];
    state = state.where((t) => t.id != id).toList();
    return ticket;
  }

  void deleteTicket(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final heldTicketsNotifierProvider = StateNotifierProvider<HeldTicketsNotifier, List<HeldTicket>>((ref) {
  return HeldTicketsNotifier();
});
