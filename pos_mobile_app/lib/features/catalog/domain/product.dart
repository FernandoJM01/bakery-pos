class Product {
  final String id;
  final String sku;
  final String? barcode;
  final String name;
  final String category;
  final String unit;
  final int priceCents;
  final bool isActive;

  const Product({
    required this.id,
    required this.sku,
    this.barcode,
    required this.name,
    required this.category,
    this.unit = 'PIECE',
    required this.priceCents,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'sku': sku,
    'barcode': barcode,
    'name': name,
    'category': category,
    'unit': unit,
    'price_cents': priceCents,
    'is_active': isActive ? 1 : 0,
    'synced_at': DateTime.now().millisecondsSinceEpoch,
  };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'] as String,
    sku: map['sku'] as String,
    barcode: map['barcode'] as String?,
    name: map['name'] as String,
    category: map['category'] as String,
    unit: (map['unit'] ?? 'PIECE') as String,
    priceCents: map['price_cents'] as int,
    isActive: (map['is_active'] as int) == 1,
  );
}
