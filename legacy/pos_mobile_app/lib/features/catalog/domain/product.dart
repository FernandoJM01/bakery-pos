class ProductVariant {
  final String id;
  final String name; // ej. "Vainilla Tradicional", "Chocolate Belga"
  final int priceDeltaCents; // Diferencial de precio en centavos (ej. 0 o +50)
  final String? skuSuffix; // ej. "-VAN", "-CHOC"

  const ProductVariant({
    required this.id,
    required this.name,
    this.priceDeltaCents = 0,
    this.skuSuffix,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price_delta_cents': priceDeltaCents,
    'sku_suffix': skuSuffix,
  };

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] as String,
      name: map['name'] as String,
      priceDeltaCents: (map['price_delta_cents'] ?? 0) as int,
      skuSuffix: map['sku_suffix'] as String?,
    );
  }
}

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
  final List<ProductVariant> variants;

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
    this.variants = const [],
  });

  bool get hasVariants => variants.isNotEmpty;

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
    'PAST-CONC': 'assets/products/concha_dulce.jpg',
    'PAST-CROI': 'assets/products/butter_croissant.jpg',
    'PAST-CHOC': 'assets/products/pain_au_chocolat.jpg',
    'PAST-OREJ': 'assets/products/butter_croissant.jpg',
    'CAKE-TART': 'assets/products/berry_tart.jpg',
    'BEV-COFF': 'assets/products/flat_white_coffee.jpg',
    'BEV-OLLA': 'assets/products/flat_white_coffee.jpg',
    'BREAD-BOLI': 'assets/products/artisan_baguette.jpg',
    'BREAD-FOCA': 'assets/products/sourdough_loaf.jpg',
  };

  static const Map<String, List<ProductVariant>> defaultSkuVariants = {
    'PAST-CONC': [
      ProductVariant(id: 'var-concha-van', name: 'Vainilla Tradicional', priceDeltaCents: 0, skuSuffix: '-VAN'),
      ProductVariant(id: 'var-concha-choc', name: 'Chocolate Belga', priceDeltaCents: 0, skuSuffix: '-CHOC'),
      ProductVariant(id: 'var-concha-fres', name: 'Fresa Silvestre', priceDeltaCents: 0, skuSuffix: '-FRES'),
      ProductVariant(id: 'var-concha-nuez', name: 'Nuez y Canela', priceDeltaCents: 25, skuSuffix: '-NUEZ'),
    ],
    'BEV-COFF': [
      ProductVariant(id: 'var-milk-reg', name: 'Leche Entera', priceDeltaCents: 0),
      ProductVariant(id: 'var-milk-oat', name: 'Leche de Avena', priceDeltaCents: 50),
      ProductVariant(id: 'var-milk-alm', name: 'Leche de Almendra', priceDeltaCents: 50),
      ProductVariant(id: 'var-milk-des', name: 'Leche Deslactosada', priceDeltaCents: 0),
    ],
    'BEV-OLLA': [
      ProductVariant(id: 'var-olla-reg', name: 'Piloncillo y Canela Clásico', priceDeltaCents: 0),
      ProductVariant(id: 'var-olla-cit', name: 'Toque de Naranja y Clavo', priceDeltaCents: 25),
    ],
  };

  factory Product.fromMap(Map<String, dynamic> map) {
    final sku = map['sku'] as String;
    final explicitImage = map['image_asset'] as String?;
    final variantsList = defaultSkuVariants[sku] ?? const [];
    return Product(
      id: map['id'] as String,
      sku: sku,
      barcode: map['barcode'] as String?,
      name: map['name'] as String,
      category: map['category'] as String,
      unit: (map['unit'] ?? 'PIECE') as String,
      priceCents: map['price_cents'] as int,
      imageAsset: explicitImage ?? _skuToImageAsset[sku] ?? 'assets/products/sourdough_loaf.jpg',
      isActive: (map['is_active'] as int) == 1,
      variants: variantsList,
    );
  }
}
