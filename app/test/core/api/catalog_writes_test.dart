import 'dart:convert';
import 'dart:typed_data';

import 'package:bakery_pos/core/api/catalog_writes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what would go on the wire and answers with a canned body.
class _Wire extends Interceptor {
  _Wire(this.reply);

  final Map<String, dynamic> reply;
  RequestOptions? last;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    last = options;
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: reply),
    );
  }
}

const _ts = '2026-11-01T12:00:00.000Z';
Map<String, dynamic> _product() => {
  'id': 'p1',
  'categoryId': 'c1',
  'name': 'Concha',
  'description': null,
  'unit': 'PIECE',
  'photoId': null,
  'ivaRateId': 't1',
  'iepsRateId': null,
  'dayOldDiscountAfterDays': null,
  'dayOldDiscountBp': null,
  'dayOldWasteAfterDays': null,
  'sortOrder': 0,
  'isActive': true,
  'updatedAt': _ts,
  'variants': <Object>[],
};

void main() {
  test(
    'a product PATCH keeps null on the wire so IEPS can be cleared',
    () async {
      final wire = _Wire(_product());
      final dio = Dio(BaseOptions(baseUrl: 'http://pos.local'))
        ..interceptors.add(wire);
      final product = await CatalogWrites(dio)
          .patchProduct('p1', {'iepsRateId': null, 'photoId': null});

      expect(wire.last!.method, 'PATCH');
      expect(wire.last!.path, '/v1/products/p1');
      final sent = jsonEncode(wire.last!.data);
      expect(sent, '{"iepsRateId":null,"photoId":null}');
      expect(product.iepsRateId, isNull);
    },
  );

  test('a variant PATCH clears sku and barcode with null', () async {
    final wire = _Wire({
      'id': 'v1',
      'productId': 'p1',
      'name': 'Normal',
      'sku': null,
      'barcode': null,
      'priceCents': 1200,
      'sortOrder': 0,
      'isActive': true,
      'updatedAt': _ts,
      'branchPrices': <Object>[],
    });
    final dio = Dio()..interceptors.add(wire);
    await CatalogWrites(dio).patchVariant('v1', {'sku': null, 'barcode': null});
    expect(jsonEncode(wire.last!.data), '{"sku":null,"barcode":null}');
  });

  test('photos upload from bytes as the file field', () async {
    final wire = _Wire({'id': 'ph1', 'width': 800, 'height': 600, 'bytes': 9});
    final dio = Dio()..interceptors.add(wire);
    final photo = await CatalogWrites(dio)
        .uploadPhoto(Uint8List.fromList([1, 2, 3]), 'concha.jpg');
    final form = wire.last!.data as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'concha.jpg');
    expect(photo.id, 'ph1');
  });

  test('photo URLs are built from the server address', () {
    expect(
      photoUrl('http://pos.local:3000', 'ab'),
      'http://pos.local:3000/v1/photos/ab',
    );
    expect(
      photoUrl('http://pos.local/', 'ab'),
      'http://pos.local/v1/photos/ab',
    );
  });
}
