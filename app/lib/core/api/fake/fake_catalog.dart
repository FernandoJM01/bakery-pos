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
    'shift.opened',
    'cash.movement',
    'shift.closed',
    'stock.produced',
    'stock.wasted',
    'stock.counted',
    'order.prepaid',
    'oven.received',
    'oven.status',
    'oven.picked_up',
  };

  /// Oven service rows, as tests seed them.
  bool ovenEnabled = false;
  final List<Map<String, dynamic>> ovenRules = [];
  final List<Map<String, dynamic>> ovenTickets = [];

  /// Report answers, as tests seed them.
  Map<String, dynamic> dashboard = {};
  final Map<String, List<Map<String, dynamic>>> salesReport = {};

  Map<String, dynamic> _salesTotals(List<Map<String, dynamic>> rows) {
    int sum(String k) => rows.fold(0, (a, r) => a + ((r[k] as int?) ?? 0));
    return {
      'key': 'total',
      'label': 'Total',
      'saleCount': sum('saleCount'),
      'quantity': null,
      'grossCents': sum('grossCents'),
      'discountCents': sum('discountCents'),
      'netCents': sum('netCents'),
      'cashCents': sum('cashCents'),
      'prepaidCents': sum('prepaidCents'),
      'refundCents': sum('refundCents'),
      'baseCents': null,
      'taxCents': null,
    };
  }

  /// `Customer` and `CustomerOrder` rows, as tests seed them.
  final List<Map<String, dynamic>> customers = [];
  final List<Map<String, dynamic>> customerOrders = [];

  /// `OrderTicket` rows, as tests seed them.
  final List<Map<String, dynamic>> orderTickets = [];

  /// Back office stock rows, as tests seed them.
  final List<Map<String, dynamic>> stockLevels = [];
  final List<Map<String, dynamic>> stockEvents = [];
  final List<Map<String, dynamic>> waste = [];
  final List<Map<String, dynamic>> transfers = [];
  Map<String, dynamic> stockCheck = {
    'checkedAt': null,
    'rowsChecked': 0,
    'mismatches': 0,
  };

  /// `BranchLot` rows, as tests seed them.
  final List<Map<String, dynamic>> lots = [];

  /// `ShiftDetail` rows, as tests seed them.
  final List<Map<String, dynamic>> shifts = [];

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

  Map<String, dynamic> _ruleView(Map<String, dynamic> p) {
    final c = categories.firstWhere(
      (c) => c['id'] == p['categoryId'],
      orElse: () => {'name': ''},
    );
    return {
      'productId': p['id'],
      'categoryId': p['categoryId'],
      'categoryName': c['name'],
      'productName': p['name'],
      'isActive': p['isActive'] ?? true,
      'dayOldDiscountAfterDays': p['dayOldDiscountAfterDays'],
      'dayOldDiscountBp': p['dayOldDiscountBp'],
      'dayOldWasteAfterDays': p['dayOldWasteAfterDays'],
    };
  }

  Map<String, dynamic> _costView(Map<String, dynamic> v) {
    final p = products.firstWhere((p) => p['id'] == v['productId']);
    return {
      'variantId': v['id'],
      'productName': p['name'],
      'variantName': v['name'],
      'categoryName': _ruleView(p)['categoryName'],
      'priceCents': v['priceCents'],
      'costCents': v['costCents'],
    };
  }

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
      case ('GET', ['day-old-rules']):
        return _ok({
          'items': [for (final p in products) _ruleView(p)],
        });
      case ('PUT', ['day-old-rules']):
        final b = body as Map;
        final ids = (b['productIds'] as List).cast<String>();
        final rule = {
          for (final k in [
            'dayOldDiscountAfterDays',
            'dayOldDiscountBp',
            'dayOldWasteAfterDays',
          ])
            k: b[k],
        };
        final error = _dayOldError(rule);
        if (error != null) return error;
        final touched = [
          for (final p in products)
            if (ids.contains(p['id'])) p,
        ];
        if (touched.length != ids.length) {
          return _err(404, 'NOT_FOUND', 'Product not found');
        }
        for (final p in touched) {
          _touch(p..addAll(rule));
        }
        return _ok({
          'items': [for (final p in touched) _ruleView(p)],
        });
      case ('GET', ['costs']):
        return _ok({
          'items': [
            for (final v in variants)
              if (v['isActive'] != false) _costView(v),
          ],
        });
      case ('PUT', ['costs', final id]):
        final v = _find(variants, id);
        if (v == null) return _err(404, 'NOT_FOUND', 'Variant not found');
        v['costCents'] = (body as Map)['costCents'];
        return _ok(_costView(v));
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

      case ('GET', ['oven', 'board']):
        return _ok({
          'generatedAt': DateTime.now().toUtc().toIso8601String(),
          'today': DateTime.now().toIso8601String().substring(0, 10),
          'enabled': ovenEnabled,
          'rules': ovenRules,
          'tickets': ovenTickets,
        });
      case ('GET', ['oven', 'fees']):
        return _ok({
          'items': ovenRules,
          'branches': [
            for (final (i, id) in branchIds.indexed)
              {
                'branchId': id,
                'name': 'Sucursal ${i + 1}',
                'enabled': ovenEnabled,
              },
          ],
        });
      case ('POST', ['oven', 'fees']):
        final r = {
          'id': _id('0f'),
          'isActive': true,
          'sortOrder': 0,
          'variantId': _id('0e'),
          'productName': 'Servicio de horno',
          'ivaBp': 1600,
          'iepsRateId': null,
          'iepsBp': 0,
          ...Map<String, dynamic>.from(body as Map),
        };
        r['variantName'] = r['name'];
        ovenRules.add(r);
        return _ok(r, 201);
      case ('PATCH', ['oven', 'fees', final id]):
        final r = ovenRules.firstWhere((x) => x['id'] == id);
        r.addAll(Map<String, dynamic>.from(body as Map));
        return _ok(r);
      case ('PUT', ['oven', 'branches', final id]):
        ovenEnabled = (body as Map)['enabled'] as bool;
        return _ok({'branchId': id, 'enabled': ovenEnabled});
      case ('GET', ['reports', 'dashboard']):
        return _ok(dashboard);
      case ('GET', ['reports', 'sales']):
        final group = query['groupBy']?.toString() ?? 'day';
        return _ok({
          'from': query['from'],
          'to': query['to'],
          'groupBy': group,
          'items': salesReport[group] ?? <Object>[],
          'totals': _salesTotals(salesReport[group] ?? const []),
        });
      case ('GET', ['customers']):
        final q = (query['q']?.toString() ?? '').toLowerCase();
        return _ok({
          'items': [
            for (final c in customers)
              if (q.isEmpty ||
                  (c['name'] as String).toLowerCase().contains(q) ||
                  ((c['phone'] as String?) ?? '').contains(q))
                c,
          ],
        });
      case ('POST', ['customers']):
        final c = {
          'id': _id('c0'),
          'name': (body as Map)['name'],
          'phone': body['phone'],
          'rfc': null,
          'notes': null,
          'isActive': true,
          'balanceCents': 0,
        };
        customers.add(c);
        return _ok(c, 201);
      case ('GET', ['customers', final id]):
        final c = customers.where((x) => x['id'] == id).firstOrNull;
        if (c == null) return _err(404, 'NOT_FOUND', 'Customer not found');
        return _ok({
          ...c,
          'orders': [
            for (final o in customerOrders)
              if (o['customerId'] == id) o,
          ],
          'entries': <Object>[],
        });
      case ('POST', ['orders']):
        final b = Map<String, dynamic>.from(body as Map);
        final c = customers.firstWhere((x) => x['id'] == b['customerId']);
        final o = {
          'id': _id('0d'),
          'customerName': c['name'],
          'endDate': null,
          'status': 'ACTIVE',
          'pausedFrom': null,
          'pausedUntil': null,
          'note': null,
          'skips': <Object>[],
          ...b,
          'lines': [
            for (final l in (b['lines'] as List).cast<Map>())
              <String, dynamic>{
                ...Map<String, dynamic>.from(l),
                'productName': _find(
                  products,
                  _find(variants, l['variantId'] as String)!['productId']
                      as String,
                )!['name'],
                'variantName': 'Pieza',
              },
          ],
        };
        customerOrders.add(o);
        return _ok(o, 201);
      case ('POST', ['orders', final id, final action]):
        final o = customerOrders.firstWhere((x) => x['id'] == id);
        switch (action) {
          case 'pause':
            o['status'] = 'PAUSED';
            o['pausedFrom'] = (body as Map)['from'];
          case 'resume':
            o['status'] = 'ACTIVE';
            o['pausedFrom'] = null;
          case 'end':
            o['status'] = 'ENDED';
          case 'skips':
            (o['skips'] as List).add((body as Map)['date']);
        }
        return _ok(o);
      case ('GET', ['orders', 'tickets']):
        return _ok({
          'generatedAt': DateTime.now().toUtc().toIso8601String(),
          'today': DateTime.now().toIso8601String().substring(0, 10),
          'items': orderTickets,
        });
      case ('GET', ['stock', 'levels']):
        return _ok({'items': stockLevels});
      case ('GET', ['stock', 'checks', 'latest']):
        return _ok(stockCheck);
      case ('GET', ['stock', 'events']):
        return _ok({'items': stockEvents, 'nextCursor': null});
      case ('GET', ['stock', 'waste']):
        return _ok({
          'items': waste,
          'nextCursor': null,
          'totalCostCents': waste.fold<int>(
            0,
            (a, w) =>
                a + (w['quantity'] as int) * ((w['costCents'] as int?) ?? 0),
          ),
        });
      case ('GET', ['stock', 'transfers']):
        return _ok({'items': transfers, 'nextCursor': null});
      case ('POST', ['stock', 'transfers', final id, 'receive']):
        final t = transfers.firstWhere((x) => x['id'] == id);
        final given = ((body as Map)['lines'] as List).cast<Map>();
        var flagged = false;
        for (final (i, l) in (t['lines'] as List).cast<Map>().indexed) {
          l['quantityReceived'] = given[i]['quantityReceived'];
          if (l['quantityReceived'] != l['quantitySent']) flagged = true;
        }
        t
          ..['status'] = 'RECEIVED'
          ..['receivedAt'] = DateTime.now().toUtc().toIso8601String()
          ..['receivedByStaffId'] = t['sentByStaffId']
          ..['flagged'] = flagged;
        return _ok(t);
      case ('GET', ['stock', 'lots']):
        return _ok({
          'generatedAt': DateTime.now().toUtc().toIso8601String(),
          'lots': lots,
          'shortages': <Object>[],
        });
      case ('GET', ['shifts']):
        final flagged = query['flagged']?.toString() == 'true';
        return _ok({
          'items': [
            for (final s in shifts)
              if (!flagged || s['flagged'] == true) s,
          ],
          'nextCursor': null,
        });
      case ('GET', ['shifts', final id]):
        final shift = shifts.where((s) => s['id'] == id).firstOrNull;
        if (shift == null) return _err(404, 'NOT_FOUND', 'Shift not found');
        return _ok(shift);
      case ('POST', ['shifts', final id, 'notes']):
        final shift = shifts.where((s) => s['id'] == id).firstOrNull;
        if (shift == null) return _err(404, 'NOT_FOUND', 'Shift not found');
        (shift['notes'] as List).add({
          'staffId': shift['openedByStaffId'],
          'note': (body as Map)['note'],
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
        return _ok(shift);

      case ('GET', ['sales']):
        return _ok(_listSales(query));
      case ('GET', ['sales', 'lookup']):
        final folio = query['folio']?.toString();
        final sale = sales.where((x) => x['folio'] == folio).firstOrNull;
        if (sale == null) return _err(404, 'NOT_FOUND', 'Sale not found');
        return _ok(saleView(sale));
      case ('GET', ['sales', final saleId]):
        final sale = sales.where((x) => x['id'] == saleId).firstOrNull;
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

  /// Sales newest first, filtered like the server: `from` inclusive, `to`
  /// exclusive, exact folio and branch; `cursor` is the offset as text.
  Map<String, dynamic> _listSales(Map<String, dynamic> query) {
    final from = DateTime.tryParse(query['from']?.toString() ?? '');
    final to = DateTime.tryParse(query['to']?.toString() ?? '');
    final branch = query['branchId']?.toString();
    final folio = query['folio']?.toString();
    final limit = int.tryParse(query['limit']?.toString() ?? '') ?? 50;
    final offset = int.tryParse(query['cursor']?.toString() ?? '') ?? 0;
    final matches =
        [
          for (final s in sales.map(saleView))
            if ((branch == null || s['branchId'] == branch) &&
                (folio == null || s['folio'] == folio) &&
                (from == null ||
                    !DateTime.parse(s['occurredAt'] as String)
                        .isBefore(from)) &&
                (to == null ||
                    DateTime.parse(s['occurredAt'] as String).isBefore(to)))
              s,
        ]..sort(
          (a, b) =>
              (b['occurredAt'] as String).compareTo(a['occurredAt'] as String),
        );
    final page = matches.skip(offset).take(limit).toList();
    final next = offset + page.length;
    return {
      'items': [
        for (final s in page)
          {...s}
            ..remove('folioNumber')
            ..remove('shiftId')
            ..remove('receivedAt')
            ..remove('lines')
            ..remove('discounts')
            ..remove('taxes')
            ..remove('payments')
            ..remove('voidedLines')
            ..remove('refunds'),
      ],
      'nextCursor': next < matches.length ? next.toString() : null,
    };
  }

  /// A stored `sale.completed` payload as the contract's `Sale`.
  Map<String, dynamic> saleView(Map<String, dynamic> p) {
    final lines = [
      for (final l in (p['lines'] as List).cast<Map>())
        {
          ...Map<String, dynamic>.from(l)..remove('discount'),
          'dayOld': l['dayOld'] ?? false,
          'fullPriceCents': l['fullPriceCents'] ?? l['unitPriceCents'],
          'refundedQuantity': l['refundedQuantity'] ?? 0,
          'refundedCents': l['refundedCents'] ?? 0,
        },
    ];
    return {
      'id': p['id'],
      'folio': p['folio'],
      'folioNumber': p['folioNumber'],
      'branchId': p['branchId'] ?? deviceBranchId,
      'deviceId': p['deviceId'] ?? 'fake-other-till',
      'cashierStaffId': p['cashierStaffId'],
      'cashierName': p['cashierName'] ?? 'Ana (Cajera)',
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
      'discounts': p['discounts'] ?? <Object>[],
      'taxes': p['taxes'] ?? <Object>[],
      'payments': p['payments'],
      'voidedLines': p['voidedLines'] ?? <Object>[],
      'refunds': p['refunds'] ?? <Object>[],
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
