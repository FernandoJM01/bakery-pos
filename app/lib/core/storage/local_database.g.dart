// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $StaffEntriesTable extends StaffEntries
    with TableInfo<$StaffEntriesTable, StaffEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offlinePinVerifierMeta =
      const VerificationMeta('offlinePinVerifier');
  @override
  late final GeneratedColumn<String> offlinePinVerifier =
      GeneratedColumn<String>(
        'offline_pin_verifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _pinUpdatedAtMeta = const VerificationMeta(
    'pinUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pinUpdatedAt = GeneratedColumn<DateTime>(
    'pin_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    role,
    offlinePinVerifier,
    pinUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('offline_pin_verifier')) {
      context.handle(
        _offlinePinVerifierMeta,
        offlinePinVerifier.isAcceptableOrUnknown(
          data['offline_pin_verifier']!,
          _offlinePinVerifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_offlinePinVerifierMeta);
    }
    if (data.containsKey('pin_updated_at')) {
      context.handle(
        _pinUpdatedAtMeta,
        pinUpdatedAt.isAcceptableOrUnknown(
          data['pin_updated_at']!,
          _pinUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pinUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      offlinePinVerifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offline_pin_verifier'],
      )!,
      pinUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pin_updated_at'],
      )!,
    );
  }

  @override
  $StaffEntriesTable createAlias(String alias) {
    return $StaffEntriesTable(attachedDatabase, alias);
  }
}

class StaffEntry extends DataClass implements Insertable<StaffEntry> {
  final String id;
  final String displayName;
  final String role;
  final String offlinePinVerifier;
  final DateTime pinUpdatedAt;
  const StaffEntry({
    required this.id,
    required this.displayName,
    required this.role,
    required this.offlinePinVerifier,
    required this.pinUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['role'] = Variable<String>(role);
    map['offline_pin_verifier'] = Variable<String>(offlinePinVerifier);
    map['pin_updated_at'] = Variable<DateTime>(pinUpdatedAt);
    return map;
  }

  StaffEntriesCompanion toCompanion(bool nullToAbsent) {
    return StaffEntriesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      role: Value(role),
      offlinePinVerifier: Value(offlinePinVerifier),
      pinUpdatedAt: Value(pinUpdatedAt),
    );
  }

  factory StaffEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffEntry(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      offlinePinVerifier: serializer.fromJson<String>(
        json['offlinePinVerifier'],
      ),
      pinUpdatedAt: serializer.fromJson<DateTime>(json['pinUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'role': serializer.toJson<String>(role),
      'offlinePinVerifier': serializer.toJson<String>(offlinePinVerifier),
      'pinUpdatedAt': serializer.toJson<DateTime>(pinUpdatedAt),
    };
  }

  StaffEntry copyWith({
    String? id,
    String? displayName,
    String? role,
    String? offlinePinVerifier,
    DateTime? pinUpdatedAt,
  }) => StaffEntry(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    role: role ?? this.role,
    offlinePinVerifier: offlinePinVerifier ?? this.offlinePinVerifier,
    pinUpdatedAt: pinUpdatedAt ?? this.pinUpdatedAt,
  );
  StaffEntry copyWithCompanion(StaffEntriesCompanion data) {
    return StaffEntry(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      offlinePinVerifier: data.offlinePinVerifier.present
          ? data.offlinePinVerifier.value
          : this.offlinePinVerifier,
      pinUpdatedAt: data.pinUpdatedAt.present
          ? data.pinUpdatedAt.value
          : this.pinUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffEntry(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('offlinePinVerifier: $offlinePinVerifier, ')
          ..write('pinUpdatedAt: $pinUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, displayName, role, offlinePinVerifier, pinUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffEntry &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.offlinePinVerifier == this.offlinePinVerifier &&
          other.pinUpdatedAt == this.pinUpdatedAt);
}

class StaffEntriesCompanion extends UpdateCompanion<StaffEntry> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> role;
  final Value<String> offlinePinVerifier;
  final Value<DateTime> pinUpdatedAt;
  final Value<int> rowid;
  const StaffEntriesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.offlinePinVerifier = const Value.absent(),
    this.pinUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffEntriesCompanion.insert({
    required String id,
    required String displayName,
    required String role,
    required String offlinePinVerifier,
    required DateTime pinUpdatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       role = Value(role),
       offlinePinVerifier = Value(offlinePinVerifier),
       pinUpdatedAt = Value(pinUpdatedAt);
  static Insertable<StaffEntry> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<String>? offlinePinVerifier,
    Expression<DateTime>? pinUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (offlinePinVerifier != null)
        'offline_pin_verifier': offlinePinVerifier,
      if (pinUpdatedAt != null) 'pin_updated_at': pinUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? role,
    Value<String>? offlinePinVerifier,
    Value<DateTime>? pinUpdatedAt,
    Value<int>? rowid,
  }) {
    return StaffEntriesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      offlinePinVerifier: offlinePinVerifier ?? this.offlinePinVerifier,
      pinUpdatedAt: pinUpdatedAt ?? this.pinUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (offlinePinVerifier.present) {
      map['offline_pin_verifier'] = Variable<String>(offlinePinVerifier.value);
    }
    if (pinUpdatedAt.present) {
      map['pin_updated_at'] = Variable<DateTime>(pinUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffEntriesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('offlinePinVerifier: $offlinePinVerifier, ')
          ..write('pinUpdatedAt: $pinUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RolePermissionsTable extends RolePermissions
    with TableInfo<$RolePermissionsTable, RolePermission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolePermissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionKeyMeta = const VerificationMeta(
    'permissionKey',
  );
  @override
  late final GeneratedColumn<String> permissionKey = GeneratedColumn<String>(
    'permission_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [role, permissionKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'role_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RolePermission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('permission_key')) {
      context.handle(
        _permissionKeyMeta,
        permissionKey.isAcceptableOrUnknown(
          data['permission_key']!,
          _permissionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {role, permissionKey};
  @override
  RolePermission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RolePermission(
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      permissionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_key'],
      )!,
    );
  }

  @override
  $RolePermissionsTable createAlias(String alias) {
    return $RolePermissionsTable(attachedDatabase, alias);
  }
}

class RolePermission extends DataClass implements Insertable<RolePermission> {
  final String role;
  final String permissionKey;
  const RolePermission({required this.role, required this.permissionKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['role'] = Variable<String>(role);
    map['permission_key'] = Variable<String>(permissionKey);
    return map;
  }

  RolePermissionsCompanion toCompanion(bool nullToAbsent) {
    return RolePermissionsCompanion(
      role: Value(role),
      permissionKey: Value(permissionKey),
    );
  }

  factory RolePermission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RolePermission(
      role: serializer.fromJson<String>(json['role']),
      permissionKey: serializer.fromJson<String>(json['permissionKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'role': serializer.toJson<String>(role),
      'permissionKey': serializer.toJson<String>(permissionKey),
    };
  }

  RolePermission copyWith({String? role, String? permissionKey}) =>
      RolePermission(
        role: role ?? this.role,
        permissionKey: permissionKey ?? this.permissionKey,
      );
  RolePermission copyWithCompanion(RolePermissionsCompanion data) {
    return RolePermission(
      role: data.role.present ? data.role.value : this.role,
      permissionKey: data.permissionKey.present
          ? data.permissionKey.value
          : this.permissionKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RolePermission(')
          ..write('role: $role, ')
          ..write('permissionKey: $permissionKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(role, permissionKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RolePermission &&
          other.role == this.role &&
          other.permissionKey == this.permissionKey);
}

class RolePermissionsCompanion extends UpdateCompanion<RolePermission> {
  final Value<String> role;
  final Value<String> permissionKey;
  final Value<int> rowid;
  const RolePermissionsCompanion({
    this.role = const Value.absent(),
    this.permissionKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RolePermissionsCompanion.insert({
    required String role,
    required String permissionKey,
    this.rowid = const Value.absent(),
  }) : role = Value(role),
       permissionKey = Value(permissionKey);
  static Insertable<RolePermission> custom({
    Expression<String>? role,
    Expression<String>? permissionKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (role != null) 'role': role,
      if (permissionKey != null) 'permission_key': permissionKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RolePermissionsCompanion copyWith({
    Value<String>? role,
    Value<String>? permissionKey,
    Value<int>? rowid,
  }) {
    return RolePermissionsCompanion(
      role: role ?? this.role,
      permissionKey: permissionKey ?? this.permissionKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (permissionKey.present) {
      map['permission_key'] = Variable<String>(permissionKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolePermissionsCompanion(')
          ..write('role: $role, ')
          ..write('permissionKey: $permissionKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionStateEntriesTable extends SessionStateEntries
    with TableInfo<$SessionStateEntriesTable, SessionStateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionStateEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_state_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionStateEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SessionStateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionStateEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SessionStateEntriesTable createAlias(String alias) {
    return $SessionStateEntriesTable(attachedDatabase, alias);
  }
}

class SessionStateEntry extends DataClass
    implements Insertable<SessionStateEntry> {
  final String key;
  final String value;
  const SessionStateEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SessionStateEntriesCompanion toCompanion(bool nullToAbsent) {
    return SessionStateEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SessionStateEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionStateEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SessionStateEntry copyWith({String? key, String? value}) =>
      SessionStateEntry(key: key ?? this.key, value: value ?? this.value);
  SessionStateEntry copyWithCompanion(SessionStateEntriesCompanion data) {
    return SessionStateEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionStateEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionStateEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SessionStateEntriesCompanion extends UpdateCompanion<SessionStateEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SessionStateEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionStateEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SessionStateEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionStateEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SessionStateEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionStateEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StaffEntriesTable staffEntries = $StaffEntriesTable(this);
  late final $RolePermissionsTable rolePermissions = $RolePermissionsTable(
    this,
  );
  late final $SessionStateEntriesTable sessionStateEntries =
      $SessionStateEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    staffEntries,
    rolePermissions,
    sessionStateEntries,
  ];
}

typedef $$StaffEntriesTableCreateCompanionBuilder =
    StaffEntriesCompanion Function({
      required String id,
      required String displayName,
      required String role,
      required String offlinePinVerifier,
      required DateTime pinUpdatedAt,
      Value<int> rowid,
    });
typedef $$StaffEntriesTableUpdateCompanionBuilder =
    StaffEntriesCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> role,
      Value<String> offlinePinVerifier,
      Value<DateTime> pinUpdatedAt,
      Value<int> rowid,
    });

class $$StaffEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $StaffEntriesTable> {
  $$StaffEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get offlinePinVerifier => $composableBuilder(
    column: $table.offlinePinVerifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pinUpdatedAt => $composableBuilder(
    column: $table.pinUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaffEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffEntriesTable> {
  $$StaffEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get offlinePinVerifier => $composableBuilder(
    column: $table.offlinePinVerifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pinUpdatedAt => $composableBuilder(
    column: $table.pinUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaffEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffEntriesTable> {
  $$StaffEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get offlinePinVerifier => $composableBuilder(
    column: $table.offlinePinVerifier,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pinUpdatedAt => $composableBuilder(
    column: $table.pinUpdatedAt,
    builder: (column) => column,
  );
}

class $$StaffEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaffEntriesTable,
          StaffEntry,
          $$StaffEntriesTableFilterComposer,
          $$StaffEntriesTableOrderingComposer,
          $$StaffEntriesTableAnnotationComposer,
          $$StaffEntriesTableCreateCompanionBuilder,
          $$StaffEntriesTableUpdateCompanionBuilder,
          (
            StaffEntry,
            BaseReferences<_$AppDatabase, $StaffEntriesTable, StaffEntry>,
          ),
          StaffEntry,
          PrefetchHooks Function()
        > {
  $$StaffEntriesTableTableManager(_$AppDatabase db, $StaffEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> offlinePinVerifier = const Value.absent(),
                Value<DateTime> pinUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffEntriesCompanion(
                id: id,
                displayName: displayName,
                role: role,
                offlinePinVerifier: offlinePinVerifier,
                pinUpdatedAt: pinUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String role,
                required String offlinePinVerifier,
                required DateTime pinUpdatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StaffEntriesCompanion.insert(
                id: id,
                displayName: displayName,
                role: role,
                offlinePinVerifier: offlinePinVerifier,
                pinUpdatedAt: pinUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StaffEntriesTable, StaffEntry>(table),
                  BaseReferences<_$AppDatabase, $StaffEntriesTable, StaffEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StaffEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaffEntriesTable,
      StaffEntry,
      $$StaffEntriesTableFilterComposer,
      $$StaffEntriesTableOrderingComposer,
      $$StaffEntriesTableAnnotationComposer,
      $$StaffEntriesTableCreateCompanionBuilder,
      $$StaffEntriesTableUpdateCompanionBuilder,
      (
        StaffEntry,
        BaseReferences<_$AppDatabase, $StaffEntriesTable, StaffEntry>,
      ),
      StaffEntry,
      PrefetchHooks Function()
    >;
typedef $$RolePermissionsTableCreateCompanionBuilder =
    RolePermissionsCompanion Function({
      required String role,
      required String permissionKey,
      Value<int> rowid,
    });
typedef $$RolePermissionsTableUpdateCompanionBuilder =
    RolePermissionsCompanion Function({
      Value<String> role,
      Value<String> permissionKey,
      Value<int> rowid,
    });

class $$RolePermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $RolePermissionsTable> {
  $$RolePermissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionKey => $composableBuilder(
    column: $table.permissionKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RolePermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RolePermissionsTable> {
  $$RolePermissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionKey => $composableBuilder(
    column: $table.permissionKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolePermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolePermissionsTable> {
  $$RolePermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get permissionKey => $composableBuilder(
    column: $table.permissionKey,
    builder: (column) => column,
  );
}

class $$RolePermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolePermissionsTable,
          RolePermission,
          $$RolePermissionsTableFilterComposer,
          $$RolePermissionsTableOrderingComposer,
          $$RolePermissionsTableAnnotationComposer,
          $$RolePermissionsTableCreateCompanionBuilder,
          $$RolePermissionsTableUpdateCompanionBuilder,
          (
            RolePermission,
            BaseReferences<
              _$AppDatabase,
              $RolePermissionsTable,
              RolePermission
            >,
          ),
          RolePermission,
          PrefetchHooks Function()
        > {
  $$RolePermissionsTableTableManager(
    _$AppDatabase db,
    $RolePermissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolePermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolePermissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolePermissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> role = const Value.absent(),
                Value<String> permissionKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RolePermissionsCompanion(
                role: role,
                permissionKey: permissionKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String role,
                required String permissionKey,
                Value<int> rowid = const Value.absent(),
              }) => RolePermissionsCompanion.insert(
                role: role,
                permissionKey: permissionKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RolePermissionsTable, RolePermission>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RolePermissionsTable,
                    RolePermission
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RolePermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolePermissionsTable,
      RolePermission,
      $$RolePermissionsTableFilterComposer,
      $$RolePermissionsTableOrderingComposer,
      $$RolePermissionsTableAnnotationComposer,
      $$RolePermissionsTableCreateCompanionBuilder,
      $$RolePermissionsTableUpdateCompanionBuilder,
      (
        RolePermission,
        BaseReferences<_$AppDatabase, $RolePermissionsTable, RolePermission>,
      ),
      RolePermission,
      PrefetchHooks Function()
    >;
typedef $$SessionStateEntriesTableCreateCompanionBuilder =
    SessionStateEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SessionStateEntriesTableUpdateCompanionBuilder =
    SessionStateEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SessionStateEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionStateEntriesTable> {
  $$SessionStateEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionStateEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionStateEntriesTable> {
  $$SessionStateEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionStateEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionStateEntriesTable> {
  $$SessionStateEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SessionStateEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionStateEntriesTable,
          SessionStateEntry,
          $$SessionStateEntriesTableFilterComposer,
          $$SessionStateEntriesTableOrderingComposer,
          $$SessionStateEntriesTableAnnotationComposer,
          $$SessionStateEntriesTableCreateCompanionBuilder,
          $$SessionStateEntriesTableUpdateCompanionBuilder,
          (
            SessionStateEntry,
            BaseReferences<
              _$AppDatabase,
              $SessionStateEntriesTable,
              SessionStateEntry
            >,
          ),
          SessionStateEntry,
          PrefetchHooks Function()
        > {
  $$SessionStateEntriesTableTableManager(
    _$AppDatabase db,
    $SessionStateEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionStateEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionStateEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SessionStateEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionStateEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SessionStateEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionStateEntriesTable, SessionStateEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SessionStateEntriesTable,
                    SessionStateEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionStateEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionStateEntriesTable,
      SessionStateEntry,
      $$SessionStateEntriesTableFilterComposer,
      $$SessionStateEntriesTableOrderingComposer,
      $$SessionStateEntriesTableAnnotationComposer,
      $$SessionStateEntriesTableCreateCompanionBuilder,
      $$SessionStateEntriesTableUpdateCompanionBuilder,
      (
        SessionStateEntry,
        BaseReferences<
          _$AppDatabase,
          $SessionStateEntriesTable,
          SessionStateEntry
        >,
      ),
      SessionStateEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StaffEntriesTableTableManager get staffEntries =>
      $$StaffEntriesTableTableManager(_db, _db.staffEntries);
  $$RolePermissionsTableTableManager get rolePermissions =>
      $$RolePermissionsTableTableManager(_db, _db.rolePermissions);
  $$SessionStateEntriesTableTableManager get sessionStateEntries =>
      $$SessionStateEntriesTableTableManager(_db, _db.sessionStateEntries);
}
