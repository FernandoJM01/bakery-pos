import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../pos/presentation/cart_notifier.dart';
import '../domain/promotion_rule.dart';
import 'promotions_notifier.dart';

class PromotionsDialog extends ConsumerWidget {
  const PromotionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promoState = ref.watch(promotionsNotifierProvider);
    final promoNotifier = ref.read(promotionsNotifierProvider.notifier);
    final cart = ref.watch(cartNotifierProvider);

    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceHighlight),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 620),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.local_offer_rounded, color: AppColors.primaryAmber, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Combos y Descuentos',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.close,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.surfaceHighlight),
            const SizedBox(height: 16),

            if (promoState.activePromotion != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successGreenBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Descuento aplicado: ${promoState.activePromotion!.name} (-\$${(promoState.discountCents / 100).toStringAsFixed(2)})',
                        style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => promoNotifier.removePromotion(),
                      child: const Text('Quitar', style: TextStyle(color: AppColors.alertRed, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: ListView.separated(
                itemCount: promoNotifier.availablePromotions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final promo = promoNotifier.availablePromotions[idx];
                  final isSelected = promoState.activePromotion?.id == promo.id;

                  // Validación rápida si cumple requisitos
                  bool canApply = true;
                  if (promo.type == PromotionType.comboBundle) {
                    canApply = promo.requiredProductIds.every((id) => cart.items.containsKey(id));
                  }

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceElevated : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryAmber : AppColors.surfaceHighlight,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAmber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            promo.type == PromotionType.comboBundle ? Icons.breakfast_dining_rounded : Icons.percent_rounded,
                            color: AppColors.primaryAmber,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                promo.description,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                              if (promo.type == PromotionType.comboBundle && !canApply) ...[
                                const SizedBox(height: 4),
                                const Text(
                                  'Agrega 1 Café Flat White y 1 Croissant para activar',
                                  style: TextStyle(color: AppColors.alertRed, fontSize: 11, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canApply ? AppColors.primaryAmber : AppColors.surfaceElevated,
                            foregroundColor: canApply ? Colors.black : AppColors.textDisabled,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          onPressed: canApply
                              ? () {
                                  promoNotifier.applyPromotion(promo, cart);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.successGreen,
                                      content: Text('✓ ${promo.name} aplicado a la orden'),
                                    ),
                                  );
                                }
                              : null,
                          child: Text(
                            isSelected ? 'Aplicado' : 'Aplicar',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
