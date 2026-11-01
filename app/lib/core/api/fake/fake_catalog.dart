/// In-memory catalog and sync server for the fake API (M2). It follows the
/// contract closely enough for screens and the till's sync code to be tested
/// without a server: change numbers, branch prices with removal, conflicts on
/// SKU or barcode, the outbox push with duplicates and quarantine.
library;

import 'dart:convert';

/// A fake response: an HTTP status and its JSON body.
typedef FakeReply = ({int status, Object? body});

FakeReply _ok(Object? body, [int status = 200]) => (status: status, body: body);
FakeReply _err(
  int status,
  String code,
  String message, [
  Map<String, Object?>? details,
]) => (
  status: status,
  body: {'code': code, 'message': message, 'details': ?details},
);

class FakeCatalog {
  FakeCatalog({required this.branchIds, this.deviceId = 'fake-device'}) {
    for (final (kind, name, bp) in [
      ('IVA', 'IVA 0%', 0),
      ('IVA', 'IVA 16%', 1600),
      ('IEPS', 'IEPS 8%', 800),
    ]) {
      taxRates.add(
        _touch({
          'id': _id('7a'),
          'kind': kind,
          'name': name,
          'rateBp': bp,
          'isActive': true,
        }),
      );
    }
  }

  final List<String> branchIds;

  /// The till that pushes records, for quarantine entries.
  final String deviceId;

  /// Device branch used by the sync routes (the fake has one till).
  String get deviceBranchId => branchIds.first;

  final taxRates = <Map<String, dynamic>>[];
  final categories = <Map<String, dynamic>>[];
  final products = <Map<String, dynamic>>[];
  final variants = <Map<String, dynamic>>[];

  /// Keyed by `variantId|branchId`; a removed one keeps `deletedAt`.
  final branchPrices = <String, Map<String, dynamic>>{};
  final photoIds = <String>[];

  /// Record id → `APPLIED` or the quarantine entry.
  final inbox = <String, Object>{};
  final quarantine = <Map<String, dynamic>>[];

  /// `sale.completed` payloads the fake server applied, with their id.
  final sales = <Map<String, dynamic>>[];

  static const _knownTypes = {
    'audit.offline_event',
    'sale.completed',
    'sale.refunded',
  };

  int _seq = 0;
  int _ids = 0;

  String _id(String prefix) {
    _ids++;
    return '0192e2b0-$prefix${_ids.toRadixString(16).padLeft(2, '0')}-7000-8000-'
        '${_ids.toRadixString(16).padLeft(12, '0')}';
  }

  Map<String, dynamic> _touch(Map<String, dynamic> row) {
    row['changeSeq'] = ++_seq;
    row['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    return row;
  }

  static Map<String, dynamic> _public(Map<String, dynamic> row) => Map.of(row)
    ..remove('changeSeq')
    ..remove('deletedAt');

  Map<String, dynamic>? _find(List<Map<String, dynamic>> list, String id) {
    for (final r in list) {
      if (r['id'] == id) return r;
    }
    return null;
  }

  Map<String, dynamic> _variantView(Map<String, dynamic> v) => {
    ..._public(v),
    'branchPrices': [
      for (final bp in branchPrices.values)
        if (bp['variantId'] == v['id'] && bp['deletedAt'] == null) _public(bp),
    ],
  };

  Map<String, dynamic> _productView(Map<String, dynamic> p) => {
    ..._public(p),
    'variants': [
      for (final v in variants)
        if (v['productId'] == p['id']) _variantView(v),
    ],
  };

  /// SKU or barcode already used by another variant, as a 409.
  FakeReply? _uniqueClash(Map<String, dynamic> body, {String? exceptId}) {
    for (final field in ['sku', 'barcode']) {
      final value = body[field];
      if (value == null) continue;
      if (variants.any((v) => v[field] == value && v['id'] != exceptId)) {
        return _err(409, 'CONFLICT', '$field already in use', {'field': field});
      }
    }
    return null;
  }

  FakeReply? _dayOldError(Map<String, dynamic> p) {
    final days = p['dayOldDiscountAfterDays'];
    final bp = p['dayOldDiscountBp'];
    final waste = p['dayOldWasteAfterDays'];
    if ((days == null) != (bp == null)) {
      return _err(
        400,
        'VALIDATION_FAILED',
        'Day-old discount days and percentage go together',
      );
    }
    if (days is int && waste is int && waste <= days) {
      return _err(
        400,
        'VALIDATION_FAILED',
        'Waste days must be greater than discount days',
      );
    }
    return null;
  }

  FakeReply? _taxKindError(Map<String, dynamic> p) {
    final iva = _find(taxRates, p['ivaRateId'] as String? ?? '');
    if (iva == null || iva['kind'] != 'IVA') {
      return _err(400, 'VALIDATION_FAILED', 'ivaRateId must be an IVA rate');
    }
    final iepsId = p['iepsRateId'] as String?;
    if (iepsId != null && _find(taxRates, iepsId)?['kind'] != 'IEPS') {
      return _err(400, 'VALIDATION_FAILED', 'iepsRateId must be an IEPS rate');
    }
    return null;
  }

  Map<String, dynamic> _newVariant(String productId, Map<String, dynamic> b) =>
      _touch({
        'id': _id('7c'),
        'productId': productId,
        'name': b['name'],
        'sku': b['sku'],
        'barcode': b['barcode'],
        'priceCents': b['priceCents'],
        'sortOrder': b['sortOrder'] ?? 0,
        'isActive': true,
      });

  static const _productFields = [
    'categoryId',
    'name',
    'description',
    'unit',
    'photoId',
    'ivaRateId',
    'iepsRateId',
    'dayOldDiscountAfterDays',
    'dayOldDiscountBp',
    'dayOldWasteAfterDays',
    'sortOrder',
    'isActive',
  ];

  /// Handles a catalog or sync request, or returns null when it is not one.
  FakeReply? handle(
    String method,
    String path,
    Map<String, dynamic> query,
    Object? data,
  ) {
    // A round trip through JSON, as on the wire: generated models put
    // nested objects (such as VariantCreate) in their toJson maps.
    final body = data is Map
        ? jsonDecode(jsonEncode(data)) as Map<String, dynamic>
        : <String, dynamic>{};
    final seg = path.split('?').first.split('/v1/').last.split('/');
    final includeInactive = query['includeInactive']?.toString() == 'true';
    bool visible(Map<String, dynamic> r) =>
        includeInactive || r['isActive'] == true;

    switch ((method, seg)) {
      case ('GET', ['tax-rates']):
        return _ok([for (final t in taxRates) _public(t)]);
      case ('POST', ['tax-rates']):
        final t = _touch({
          'id': _id('7a'),
          'kind': body['kind'],
          'name': body['name'],
          'rateBp': body['rateBp'],
          'isActive': true,
        });
        taxRates.add(t);
        return _ok(_public(t), 201);
      case ('PATCH', ['tax-rates', final id]):
        final t = _find(taxRates, id);
        if (t == null) return _err(404, 'NOT_FOUND', 'Tax rate not found');
        final inUse = products.any(
          (p) => p['ivaRateId'] == id || p['iepsRateId'] == id,
        );
        if (body['isActive'] == false && inUse) {
          return _err(409, 'CONFLICT', 'Tax rate is in use');
        }
        for (final k in ['name', 'isActive']) {
          if (body.containsKey(k)) t[k] = body[k];
        }
        return _ok(_public(_touch(t)));

      case ('GET', ['categories']):
        final list = categories.where(visible).toList()
          ..sort(
            (a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int),
          );
        return _ok([for (final c in list) _public(c)]);
      case ('POST', ['categories']):
        if (categories.any(
          (c) => c['isActive'] == true && c['name'] == body['name'],
        )) {
          return _err(409, 'CONFLICT', 'Category name in use', {
            'field': 'name',
          });
        }
        final c = _touch({
          'id': _id('7b'),
          'name': body['name'],
          'color': body['color'],
          'sortOrder': body['sortOrder'] ?? categories.length,
          'isActive': true,
        });
        categories.add(c);
        return _ok(_public(c), 201);
      case ('PATCH', ['categories', final id]):
        final c = _find(categories, id);
        if (c == null) return _err(404, 'NOT_FOUND', 'Category not found');
        for (final k in ['name', 'color', 'sortOrder', 'isActive']) {
          if (body.containsKey(k)) c[k] = body[k];
        }
        return _ok(_public(_touch(c)));

      case ('GET', ['products']):
        final q = (query['q']?.toString() ?? '').toLowerCase();
        final cat = query['categoryId']?.toString();
        bool matches(Map<String, dynamic> p) {
          if (q.isEmpty) return true;
          if ((p['name'] as String).toLowerCase().contains(q)) return true;
          return variants.any(
            (v) =>
                v['productId'] == p['id'] &&
                [
                  v['name'],
                  v['sku'],
                  v['barcode'],
                ].any((s) => s is String && s.toLowerCase().contains(q)),
          );
        }

        final list = [
          for (final p in products)
            if (visible(p) &&
                (cat == null || p['categoryId'] == cat) &&
                matches(p))
              _productView(p),
        ];
        final start = int.tryParse(query['cursor']?.toString() ?? '') ?? 0;
        final limit = int.tryParse(query['limit']?.toString() ?? '') ?? 50;
        final end = (start + limit).clamp(0, list.length);
        return _ok({
          'items': list.sublist(start.clamp(0, list.length), end),
          'nextCursor': end < list.length ? '$end' : null,
        });
      case ('POST', ['products']):
        final error = _taxKindError(body) ?? _dayOldError(body);
        if (error != null) return error;
        final vs = [
          for (final v in body['variants'] as List? ?? const [])
            Map<String, dynamic>.from(v as Map),
        ];
        for (final v in vs) {
          final clash = _uniqueClash(v);
          if (clash != null) return clash;
        }
        final p = _touch({
          'id': _id('7d'),
          for (final k in _productFields) k: body[k],
          'sortOrder': body['sortOrder'] ?? 0,
          'isActive': true,
        });
        products.add(p);
        for (final v in vs) {
          variants.add(_newVariant(p['id'] as String, v));
        }
        return _ok(_productView(p), 201);
      case ('GET', ['products', final id]):
        final p = _find(products, id);
        if (p == null) return _err(404, 'NOT_FOUND', 'Product not found');
        return _ok(_productView(p));
      case ('PATCH', ['products', final id]):
        final p = _find(products, id);
        if (p == null) return _err(404, 'NOT_FOUND', 'Product not found');
        final next = {
          ...p,
          for (final k in _productFields)
            if (body.containsKey(k)) k: body[k],
        };
        final error = _taxKindError(next) ?? _dayOldError(next);
        if (error != null) return error;
        p.addAll(next);
        return _ok(_productView(_touch(p)));
      case ('POST', ['products', final id, 'variants']):
        final p = _find(products, id);
        if (p == null) return _err(404, 'NOT_FOUND', 'Product not found');
        final clash = _uniqueClash(body);
        if (clash != null) return clash;
        final v = _newVariant(id, body);
        variants.add(v);
        return _ok(_variantView(v), 201);
      case ('PATCH', ['variants', final id]):
        final v = _find(variants, id);
        if (v == null) return _err(404, 'NOT_FOUND', 'Variant not found');
        final clash = _uniqueClash(body, exceptId: id);
        if (clash != null) return clash;
        if (body['isActive'] == false) {
          final others = variants.where(
            (o) =>
                o['productId'] == v['productId'] &&
                o['id'] != id &&
                o['isActive'] == true,
          );
          if (others.isEmpty) {
            return _err(409, 'CONFLICT', 'A product needs an active variant');
          }
        }
        for (final k in [
          'name',
          'sku',
          'barcode',
          'priceCents',
          'sortOrder',
          'isActive',
        ]) {
          if (body.containsKey(k)) v[k] = body[k];
        }
        return _ok(_variantView(_touch(v)));
      case ('PUT', ['variants', final id, 'branch-prices', final branchId]):
        if (_find(variants, id) == null || !branchIds.contains(branchId)) {
          return _err(404, 'NOT_FOUND', 'Variant or branch not found');
        }
        final bp = _touch({
          'variantId': id,
          'branchId': branchId,
          'priceCents': body['priceCents'],
          'deletedAt': null,
        });
        branchPrices['$id|$branchId'] = bp;
        return _ok(_public(bp));
      case ('DELETE', ['variants', final id, 'branch-prices', final branchId]):
        final bp = branchPrices['$id|$branchId'];
        if (bp == null || bp['deletedAt'] != null) {
          return _err(404, 'NOT_FOUND', 'Branch price not found');
        }
        bp['deletedAt'] = DateTime.now().toUtc().toIso8601String();
        _touch(bp);
        return _ok(null, 204);

      case ('POST', ['photos']):
        final id = _id('7e');
        photoIds.add(id);
        return _ok({'id': id, 'width': 800, 'height': 800, 'bytes': 1024}, 201);

      case ('GET', ['sales', 'lookup']):
        final folio = query['folio']?.toString();
        final sale = sales.where((x) => x['folio'] == folio).firstOrNull;
        if (sale == null) return _err(404, 'NOT_FOUND', 'Sale not found');
        return _ok(saleView(sale));

      case ('GET', ['sync', 'catalog']):
        return _ok(_pull(query));
      case ('POST', ['sync', 'push']):
        return _ok(_push(body));
      case ('GET', ['sync', 'quarantine']):
        final status = query['status']?.toString() ?? 'OPEN';
        return _ok({
          'items': [
            for (final q in quarantine.reversed)
              if (status == 'ALL' ||
                  (status == 'OPEN') == (q['resolvedAt'] == null))
                q,
          ],
          'nextCursor': null,
        });
      case ('POST', ['sync', 'quarantine', final id, 'resolve']):
        final q = quarantine.where((e) => e['recordId'] == id).firstOrNull;
        if (q == null) return _err(404, 'NOT_FOUND', 'Record not found');
        if (q['resolvedAt'] != null) {
          return _err(409, 'CONFLICT', 'Already resolved');
        }
        q['resolvedAt'] = DateTime.now().toUtc().toIso8601String();
        q['resolvedByStaffId'] = null;
        q['resolutionNote'] = body['note'];
        return _ok(q);
    }
    return null;
  }

  Map<String, dynamic> _pull(Map<String, dynamic> query) {
    final since = int.tryParse(query['since']?.toString() ?? '') ?? 0;
    final limit = int.tryParse(query['limit']?.toString() ?? '') ?? 500;
    final rows = <(int, String, Map<String, dynamic>)>[
      for (final t in taxRates) (t['changeSeq'] as int, 'taxRates', _public(t)),
      for (final c in categories)
        (c['changeSeq'] as int, 'categories', _public(c)),
      for (final p in products)
        (
          p['changeSeq'] as int,
          'products',
          _public(p)
            ..remove('description')
            ..remove('updatedAt'),
        ),
      for (final v in variants)
        (v['changeSeq'] as int, 'variants', _public(v)..remove('updatedAt')),
      for (final bp in branchPrices.values)
        if (bp['branchId'] == deviceBranchId)
          (
            bp['changeSeq'] as int,
            'branchPrices',
            {
              'variantId': bp['variantId'],
              'priceCents': bp['deletedAt'] == null ? bp['priceCents'] : null,
              'removed': bp['deletedAt'] != null,
            },
          ),
    ].where((r) => r.$1 > since).toList()..sort((a, b) => a.$1.compareTo(b.$1));
    final taken = rows.take(limit).toList();
    return {
      'nextSince': taken.isEmpty ? since : taken.last.$1,
      'hasMore': rows.length > limit,
      'serverTime': DateTime.now().toUtc().toIso8601String(),
      for (final list in [
        'taxRates',
        'categories',
        'products',
        'variants',
        'branchPrices',
      ])
        list: [
          for (final r in taken)
            if (r.$2 == list) r.$3,
        ],
    };
  }

  /// A stored `sale.completed` payload as the contract's `Sale`.
  Map<String, dynamic> saleView(Map<String, dynamic> p) {
    final lines = [
      for (final l in (p['lines'] as List).cast<Map>())
        {
          ...Map<String, dynamic>.from(l)..remove('discount'),
          'refundedQuantity': l['refundedQuantity'] ?? 0,
          'refundedCents': l['refundedCents'] ?? 0,
        },
    ];
    return {
      'id': p['id'],
      'folio': p['folio'],
      'folioNumber': p['folioNumber'],
      'branchId': deviceBranchId,
      'deviceId': p['deviceId'] ?? 'fake-other-till',
      'cashierStaffId': p['cashierStaffId'],
      'cashierName': 'Ana (Cajera)',
      'occurredAt': p['occurredAt'],
      'receivedAt': p['occurredAt'],
      'status': p['status'] ?? 'COMPLETED',
      'lineCount': lines.length,
      'grossCents': p['grossCents'],
      'discountCents': p['discountCents'],
      'totalCents': p['totalCents'],
      'refundedCents': p['refundedCents'] ?? 0,
      'shiftId': null,
      'lines': lines,
      'discounts': <Object>[],
      'taxes': <Object>[],
      'payments': p['payments'],
      'voidedLines': p['voidedLines'] ?? <Object>[],
      'refunds': <Object>[],
    };
  }

  /// Records with an unknown type, or a payload holding a PIN, are
  /// quarantined like the server would; everything else applies once.
  Map<String, dynamic> _push(Map<String, dynamic> body) {
    final results = <Map<String, dynamic>>[];
    for (final raw in body['records'] as List? ?? const []) {
      final r = Map<String, dynamic>.from(raw as Map);
      final id = r['id'] as String;
      final seen = inbox[id];
      if (seen == 'APPLIED') {
        results.add({'id': id, 'status': 'DUPLICATE'});
        continue;
      }
      if (seen is Map) {
        results.add({
          'id': id,
          'status': 'QUARANTINED',
          'errorCode': seen['errorCode'],
        });
        continue;
      }
      final payload = Map<String, dynamic>.from(r['payload'] as Map? ?? {});
      final code = !_knownTypes.contains(r['type'])
          ? 'SYNC_UNKNOWN_TYPE'
          : payload.containsKey('pin')
          ? 'SYNC_INVALID_PAYLOAD'
          : null;
      if (code == null) {
        inbox[id] = 'APPLIED';
        if (r['type'] == 'sale.completed') {
          sales.add({'id': id, 'occurredAt': r['occurredAt'], ...payload});
        }
        results.add({'id': id, 'status': 'APPLIED'});
        continue;
      }
      final entry = <String, dynamic>{
        'recordId': id,
        'deviceId': deviceId,
        'branchId': deviceBranchId,
        'type': r['type'],
        'occurredAt': r['occurredAt'],
        'receivedAt': DateTime.now().toUtc().toIso8601String(),
        'errorCode': code,
        'errorMessage': 'Rejected by the fake server',
        'payload': payload..remove('pin'),
        'resolvedAt': null,
        'resolvedByStaffId': null,
        'resolutionNote': null,
      };
      inbox[id] = entry;
      quarantine.add(entry);
      results.add({'id': id, 'status': 'QUARANTINED', 'errorCode': code});
    }
    return {
      'results': results,
      'serverTime': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
