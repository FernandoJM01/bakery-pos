import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client_provider.dart';
import 'generated/models/photo.dart';
import 'generated/models/product.dart';
import 'generated/models/variant.dart';

/// The two catalog calls the generated client cannot make:
///
/// * PATCH with `null`: the client drops nulls (`include_if_null: false`), but
///   `null` is how the contract clears `iepsRateId`, `photoId`,
///   `description`, the day-old fields, `sku` and `barcode`. These send the
///   map as given, nulls included.
/// * Photo upload from bytes: the generated `uploadPhoto` needs a `dart:io`
///   `File`, which the browser back office does not have.
class CatalogWrites {
  CatalogWrites(this._dio);

  final Dio _dio;

  Future<Product> patchProduct(String id, Map<String, Object?> changes) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/products/$id',
      data: changes,
    );
    return Product.fromJson(res.data!);
  }

  Future<Variant> patchVariant(String id, Map<String, Object?> changes) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/variants/$id',
      data: changes,
    );
    return Variant.fromJson(res.data!);
  }

  Future<Photo> uploadPhoto(Uint8List bytes, String filename) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/photos',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    );
    return Photo.fromJson(res.data!);
  }
}

final catalogWritesProvider = Provider<CatalogWrites>(
  (ref) => CatalogWrites(ref.watch(dioProvider)),
);

/// Photos are public and served by id, so screens load them by URL.
String photoUrl(String baseUrl, String photoId) {
  final base = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  return '$base/v1/photos/$photoId';
}
