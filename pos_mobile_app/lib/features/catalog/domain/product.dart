class Product {
  final String id;
  final String sku;
  final String? barcode;
  final String name;
  final String category;
  final String unit;
  final int priceCents;
  final String? imageAsset;
  final bool isActive;

  const Product({
    required this.id,
    required this.sku,
    this.barcode,
    required this.name,
    required this.category,
    this.unit = 'PIECE',
    required this.priceCents,
    this.imageAsset,
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

  static const Map<String, String> _skuToImageAsset = {
    'BREAD-SOUR': 'assets/products/sourdough_loaf.jpg',
    'BREAD-BAGU': 'assets/products/artisan_baguette.jpg',
    'PAST-CROI': 'assets/products/butter_croissant.jpg',
    'PAST-CHOC': 'assets/products/pain_au_chocolat.jpg',
    'PAST-CINN': 'assets/products/pain_au_chocolat.jpg',
    'CAKE-ECLR': 'assets/products/berry_tart.jpg',
    'CAKE-TART': 'assets/products/berry_tart.jpg',
    'BEV-COFF': 'assets/products/flat_white_coffee.jpg',
  };

  factory Product.fromMap(Map<String, dynamic> map) {
    final sku = map['sku'] as String;
    final explicitImage = map['image_asset'] as String?;
    return Product(
      id: map['id'] as String,
      sku: sku,
      barcode: map['barcode'] as String?,
      name: map['name'] as String,
      category: map['category'] as String,
      unit: (map['unit'] ?? 'PIECE') as String,
      priceCents: map['price_cents'] as int,
      imageAsset: explicitImage ?? _skuToImageAsset[sku],
      isActive: (map['is_active'] as int) == 1,
    );
  }
}
