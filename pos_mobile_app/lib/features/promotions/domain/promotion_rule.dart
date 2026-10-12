enum PromotionType {
  comboBundle,
  percentageDiscount,
  fixedAmountDiscount,
}

class PromotionRule {
  final String id;
  final String name;
  final String description;
  final PromotionType type;
  final int discountValue; // En porcentaje (ej. 15 = 15%) o en centavos (ej. 200 = $2.00)
  final List<String> requiredProductIds; // Para combos (ej. café + croissant)
  final int? comboFixedPriceCents; // Precio especial del paquete en centavos
  final bool isActive;

  const PromotionRule({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.discountValue,
    this.requiredProductIds = const [],
    this.comboFixedPriceCents,
    this.isActive = true,
  });

  static const List<PromotionRule> defaultPromotions = [
    PromotionRule(
      id: 'promo-01',
      name: 'Combo Desayuno Artesanal',
      description: 'Café Flat White + Croissant de Mantequilla por solo \$7.00',
      type: PromotionType.comboBundle,
      discountValue: 125, // Ahorro de $1.25 sobre el precio regular ($8.25)
      requiredProductIds: [
        'c0000000-0000-0000-0000-000000000007', // Café Flat White ($5.00)
        'c0000000-0000-0000-0000-000000000003', // Croissant ($3.25)
      ],
      comboFixedPriceCents: 700,
    ),
    PromotionRule(
      id: 'promo-02',
      name: 'Descuento Empleado / Vecino (15%)',
      description: '15% de descuento en el total de la orden',
      type: PromotionType.percentageDiscount,
      discountValue: 15,
    ),
    PromotionRule(
      id: 'promo-03',
      name: 'Cupón Bienvenida (-\$2.00)',
      description: '\$2.00 de descuento directo en compras mayores a \$10',
      type: PromotionType.fixedAmountDiscount,
      discountValue: 200,
    ),
  ];
}
