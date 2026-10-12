import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/promotion_rule.dart';
import '../../pos/presentation/cart_notifier.dart';

class AppliedPromotionState {
  final PromotionRule? activePromotion;
  final int discountCents;

  const AppliedPromotionState({
    this.activePromotion,
    this.discountCents = 0,
  });
}

class PromotionsNotifier extends StateNotifier<AppliedPromotionState> {
  final List<PromotionRule> availablePromotions = List.from(PromotionRule.defaultPromotions);

  PromotionsNotifier() : super(const AppliedPromotionState());

  void applyPromotion(PromotionRule promo, CartState cart) {
    if (cart.isEmpty) {
      state = const AppliedPromotionState();
      return;
    }

    int calculatedDiscount = 0;

    switch (promo.type) {
      case PromotionType.comboBundle:
        // Verifica si todos los productos del combo están en el carrito
        final hasAll = promo.requiredProductIds.every((id) => cart.items.containsKey(id));
        if (hasAll) {
          calculatedDiscount = promo.discountValue;
        }
        break;
      case PromotionType.percentageDiscount:
        calculatedDiscount = ((cart.subtotalCents * promo.discountValue) / 100).round();
        break;
      case PromotionType.fixedAmountDiscount:
        calculatedDiscount = promo.discountValue.clamp(0, cart.subtotalCents);
        break;
    }

    state = AppliedPromotionState(
      activePromotion: promo,
      discountCents: calculatedDiscount,
    );
  }

  void removePromotion() {
    state = const AppliedPromotionState();
  }

  void addCustomPromotion(PromotionRule newPromo) {
    availablePromotions.add(newPromo);
  }
}

final promotionsNotifierProvider = StateNotifierProvider<PromotionsNotifier, AppliedPromotionState>((ref) {
  return PromotionsNotifier();
});
