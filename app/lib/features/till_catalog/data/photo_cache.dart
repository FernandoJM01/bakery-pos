import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/api/api_client_provider.dart';

/// Product photos, downloaded once by id and kept on disk (M2 brief 4.2).
/// Photos are public and not sensitive, so they sit outside the encrypted
/// database. A photo id never changes content, so a cached file never
/// goes stale.
abstract class PhotoCache {
  /// The photo's bytes, or null when it is not cached and cannot be fetched.
  Future<Uint8List?> get(String photoId);
}

class DiskPhotoCache implements PhotoCache {
  DiskPhotoCache(this._dio, this._dir);

  final Dio _dio;
  final Future<Directory> Function() _dir;
  final _inFlight = <String, Future<Uint8List?>>{};

  static final _validId = RegExp(r'^[0-9a-fA-F-]{36}$');

  @override
  Future<Uint8List?> get(String photoId) {
    if (!_validId.hasMatch(photoId)) return Future.value(null);
    return _inFlight.putIfAbsent(photoId, () async {
      try {
        return await _load(photoId);
      } finally {
        _inFlight.remove(photoId);
      }
    });
  }

  Future<Uint8List?> _load(String photoId) async {
    final dir = await _dir();
    final file = File(p.join(dir.path, '$photoId.webp'));
    if (file.existsSync()) return file.readAsBytes();
    try {
      final res = await _dio.get<List<int>>(
        '/v1/photos/$photoId',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(res.data ?? const []);
      if (bytes.isEmpty) return null;
      await dir.create(recursive: true);
      // Write then rename, so a crash never leaves half a photo behind.
      final part = File('${file.path}.part');
      await part.writeAsBytes(bytes, flush: true);
      await part.rename(file.path);
      return bytes;
    } on DioException {
      return null;
    }
  }
}

final photoCacheProvider = Provider<PhotoCache>(
  (ref) => DiskPhotoCache(ref.watch(dioProvider), () async {
    final base = await getApplicationSupportDirectory();
    return Directory(p.join(base.path, 'photos'));
  }),
);
