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

class $StaffLockoutEntriesTable extends StaffLockoutEntries
    with TableInfo<$StaffLockoutEntriesTable, StaffLockoutEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffLockoutEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _failedAttemptsMeta = const VerificationMeta(
    'failedAttempts',
  );
  @override
  late final GeneratedColumn<int> failedAttempts = GeneratedColumn<int>(
    'failed_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lockedUntilMeta = const VerificationMeta(
    'lockedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
    'locked_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [staffId, failedAttempts, lockedUntil];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_lockout_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffLockoutEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('failed_attempts')) {
      context.handle(
        _failedAttemptsMeta,
        failedAttempts.isAcceptableOrUnknown(
          data['failed_attempts']!,
          _failedAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('locked_until')) {
      context.handle(
        _lockedUntilMeta,
        lockedUntil.isAcceptableOrUnknown(
          data['locked_until']!,
          _lockedUntilMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {staffId};
  @override
  StaffLockoutEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffLockoutEntry(
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      failedAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_attempts'],
      )!,
      lockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_until'],
      ),
    );
  }

  @override
  $StaffLockoutEntriesTable createAlias(String alias) {
    return $StaffLockoutEntriesTable(attachedDatabase, alias);
  }
}

class StaffLockoutEntry extends DataClass
    implements Insertable<StaffLockoutEntry> {
  final String staffId;
  final int failedAttempts;
  final DateTime? lockedUntil;
  const StaffLockoutEntry({
    required this.staffId,
    required this.failedAttempts,
    this.lockedUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['staff_id'] = Variable<String>(staffId);
    map['failed_attempts'] = Variable<int>(failedAttempts);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    return map;
  }

  StaffLockoutEntriesCompanion toCompanion(bool nullToAbsent) {
    return StaffLockoutEntriesCompanion(
      staffId: Value(staffId),
      failedAttempts: Value(failedAttempts),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
    );
  }

  factory StaffLockoutEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffLockoutEntry(
      staffId: serializer.fromJson<String>(json['staffId']),
      failedAttempts: serializer.fromJson<int>(json['failedAttempts']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'staffId': serializer.toJson<String>(staffId),
      'failedAttempts': serializer.toJson<int>(failedAttempts),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
    };
  }

  StaffLockoutEntry copyWith({
    String? staffId,
    int? failedAttempts,
    Value<DateTime?> lockedUntil = const Value.absent(),
  }) => StaffLockoutEntry(
    staffId: staffId ?? this.staffId,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
  );
  StaffLockoutEntry copyWithCompanion(StaffLockoutEntriesCompanion data) {
    return StaffLockoutEntry(
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      failedAttempts: data.failedAttempts.present
          ? data.failedAttempts.value
          : this.failedAttempts,
      lockedUntil: data.lockedUntil.present
          ? data.lockedUntil.value
          : this.lockedUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffLockoutEntry(')
          ..write('staffId: $staffId, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntil: $lockedUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(staffId, failedAttempts, lockedUntil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffLockoutEntry &&
          other.staffId == this.staffId &&
          other.failedAttempts == this.failedAttempts &&
          other.lockedUntil == this.lockedUntil);
}

class StaffLockoutEntriesCompanion extends UpdateCompanion<StaffLockoutEntry> {
  final Value<String> staffId;
  final Value<int> failedAttempts;
  final Value<DateTime?> lockedUntil;
  final Value<int> rowid;
  const StaffLockoutEntriesCompanion({
    this.staffId = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffLockoutEntriesCompanion.insert({
    required String staffId,
    this.failedAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : staffId = Value(staffId);
  static Insertable<StaffLockoutEntry> custom({
    Expression<String>? staffId,
    Expression<int>? failedAttempts,
    Expression<DateTime>? lockedUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (staffId != null) 'staff_id': staffId,
      if (failedAttempts != null) 'failed_attempts': failedAttempts,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffLockoutEntriesCompanion copyWith({
    Value<String>? staffId,
    Value<int>? failedAttempts,
    Value<DateTime?>? lockedUntil,
    Value<int>? rowid,
  }) {
    return StaffLockoutEntriesCompanion(
      staffId: staffId ?? this.staffId,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (failedAttempts.present) {
      map['failed_attempts'] = Variable<int>(failedAttempts.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffLockoutEntriesCompanion(')
          ..write('staffId: $staffId, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineApprovalEntriesTable extends OfflineApprovalEntries
    with TableInfo<$OfflineApprovalEntriesTable, OfflineApprovalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineApprovalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _approverStaffIdMeta = const VerificationMeta(
    'approverStaffId',
  );
  @override
  late final GeneratedColumn<String> approverStaffId = GeneratedColumn<String>(
    'approver_staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requesterStaffIdMeta = const VerificationMeta(
    'requesterStaffId',
  );
  @override
  late final GeneratedColumn<String> requesterStaffId = GeneratedColumn<String>(
    'requester_staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    approverStaffId,
    requesterStaffId,
    action,
    reference,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_approval_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineApprovalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('approver_staff_id')) {
      context.handle(
        _approverStaffIdMeta,
        approverStaffId.isAcceptableOrUnknown(
          data['approver_staff_id']!,
          _approverStaffIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_approverStaffIdMeta);
    }
    if (data.containsKey('requester_staff_id')) {
      context.handle(
        _requesterStaffIdMeta,
        requesterStaffId.isAcceptableOrUnknown(
          data['requester_staff_id']!,
          _requesterStaffIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requesterStaffIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineApprovalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineApprovalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      approverStaffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approver_staff_id'],
      )!,
      requesterStaffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requester_staff_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OfflineApprovalEntriesTable createAlias(String alias) {
    return $OfflineApprovalEntriesTable(attachedDatabase, alias);
  }
}

class OfflineApprovalEntry extends DataClass
    implements Insertable<OfflineApprovalEntry> {
  final String id;
  final String approverStaffId;
  final String requesterStaffId;
  final String action;
  final String? reference;
  final DateTime createdAt;
  const OfflineApprovalEntry({
    required this.id,
    required this.approverStaffId,
    required this.requesterStaffId,
    required this.action,
    this.reference,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['approver_staff_id'] = Variable<String>(approverStaffId);
    map['requester_staff_id'] = Variable<String>(requesterStaffId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OfflineApprovalEntriesCompanion toCompanion(bool nullToAbsent) {
    return OfflineApprovalEntriesCompanion(
      id: Value(id),
      approverStaffId: Value(approverStaffId),
      requesterStaffId: Value(requesterStaffId),
      action: Value(action),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      createdAt: Value(createdAt),
    );
  }

  factory OfflineApprovalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineApprovalEntry(
      id: serializer.fromJson<String>(json['id']),
      approverStaffId: serializer.fromJson<String>(json['approverStaffId']),
      requesterStaffId: serializer.fromJson<String>(json['requesterStaffId']),
      action: serializer.fromJson<String>(json['action']),
      reference: serializer.fromJson<String?>(json['reference']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'approverStaffId': serializer.toJson<String>(approverStaffId),
      'requesterStaffId': serializer.toJson<String>(requesterStaffId),
      'action': serializer.toJson<String>(action),
      'reference': serializer.toJson<String?>(reference),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OfflineApprovalEntry copyWith({
    String? id,
    String? approverStaffId,
    String? requesterStaffId,
    String? action,
    Value<String?> reference = const Value.absent(),
    DateTime? createdAt,
  }) => OfflineApprovalEntry(
    id: id ?? this.id,
    approverStaffId: approverStaffId ?? this.approverStaffId,
    requesterStaffId: requesterStaffId ?? this.requesterStaffId,
    action: action ?? this.action,
    reference: reference.present ? reference.value : this.reference,
    createdAt: createdAt ?? this.createdAt,
  );
  OfflineApprovalEntry copyWithCompanion(OfflineApprovalEntriesCompanion data) {
    return OfflineApprovalEntry(
      id: data.id.present ? data.id.value : this.id,
      approverStaffId: data.approverStaffId.present
          ? data.approverStaffId.value
          : this.approverStaffId,
      requesterStaffId: data.requesterStaffId.present
          ? data.requesterStaffId.value
          : this.requesterStaffId,
      action: data.action.present ? data.action.value : this.action,
      reference: data.reference.present ? data.reference.value : this.reference,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineApprovalEntry(')
          ..write('id: $id, ')
          ..write('approverStaffId: $approverStaffId, ')
          ..write('requesterStaffId: $requesterStaffId, ')
          ..write('action: $action, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    approverStaffId,
    requesterStaffId,
    action,
    reference,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineApprovalEntry &&
          other.id == this.id &&
          other.approverStaffId == this.approverStaffId &&
          other.requesterStaffId == this.requesterStaffId &&
          other.action == this.action &&
          other.reference == this.reference &&
          other.createdAt == this.createdAt);
}

class OfflineApprovalEntriesCompanion
    extends UpdateCompanion<OfflineApprovalEntry> {
  final Value<String> id;
  final Value<String> approverStaffId;
  final Value<String> requesterStaffId;
  final Value<String> action;
  final Value<String?> reference;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OfflineApprovalEntriesCompanion({
    this.id = const Value.absent(),
    this.approverStaffId = const Value.absent(),
    this.requesterStaffId = const Value.absent(),
    this.action = const Value.absent(),
    this.reference = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineApprovalEntriesCompanion.insert({
    required String id,
    required String approverStaffId,
    required String requesterStaffId,
    required String action,
    this.reference = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       approverStaffId = Value(approverStaffId),
       requesterStaffId = Value(requesterStaffId),
       action = Value(action),
       createdAt = Value(createdAt);
  static Insertable<OfflineApprovalEntry> custom({
    Expression<String>? id,
    Expression<String>? approverStaffId,
    Expression<String>? requesterStaffId,
    Expression<String>? action,
    Expression<String>? reference,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (approverStaffId != null) 'approver_staff_id': approverStaffId,
      if (requesterStaffId != null) 'requester_staff_id': requesterStaffId,
      if (action != null) 'action': action,
      if (reference != null) 'reference': reference,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineApprovalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? approverStaffId,
    Value<String>? requesterStaffId,
    Value<String>? action,
    Value<String?>? reference,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OfflineApprovalEntriesCompanion(
      id: id ?? this.id,
      approverStaffId: approverStaffId ?? this.approverStaffId,
      requesterStaffId: requesterStaffId ?? this.requesterStaffId,
      action: action ?? this.action,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (approverStaffId.present) {
      map['approver_staff_id'] = Variable<String>(approverStaffId.value);
    }
    if (requesterStaffId.present) {
      map['requester_staff_id'] = Variable<String>(requesterStaffId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineApprovalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('approverStaffId: $approverStaffId, ')
          ..write('requesterStaffId: $requesterStaffId, ')
          ..write('action: $action, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt, ')
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
  late final $StaffLockoutEntriesTable staffLockoutEntries =
      $StaffLockoutEntriesTable(this);
  late final $OfflineApprovalEntriesTable offlineApprovalEntries =
      $OfflineApprovalEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    staffEntries,
    rolePermissions,
    sessionStateEntries,
    staffLockoutEntries,
    offlineApprovalEntries,
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
typedef $$StaffLockoutEntriesTableCreateCompanionBuilder =
    StaffLockoutEntriesCompanion Function({
      required String staffId,
      Value<int> failedAttempts,
      Value<DateTime?> lockedUntil,
      Value<int> rowid,
    });
typedef $$StaffLockoutEntriesTableUpdateCompanionBuilder =
    StaffLockoutEntriesCompanion Function({
      Value<String> staffId,
      Value<int> failedAttempts,
      Value<DateTime?> lockedUntil,
      Value<int> rowid,
    });

class $$StaffLockoutEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $StaffLockoutEntriesTable> {
  $$StaffLockoutEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaffLockoutEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffLockoutEntriesTable> {
  $$StaffLockoutEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaffLockoutEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffLockoutEntriesTable> {
  $$StaffLockoutEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => column,
  );
}

class $$StaffLockoutEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaffLockoutEntriesTable,
          StaffLockoutEntry,
          $$StaffLockoutEntriesTableFilterComposer,
          $$StaffLockoutEntriesTableOrderingComposer,
          $$StaffLockoutEntriesTableAnnotationComposer,
          $$StaffLockoutEntriesTableCreateCompanionBuilder,
          $$StaffLockoutEntriesTableUpdateCompanionBuilder,
          (
            StaffLockoutEntry,
            BaseReferences<
              _$AppDatabase,
              $StaffLockoutEntriesTable,
              StaffLockoutEntry
            >,
          ),
          StaffLockoutEntry,
          PrefetchHooks Function()
        > {
  $$StaffLockoutEntriesTableTableManager(
    _$AppDatabase db,
    $StaffLockoutEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffLockoutEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffLockoutEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StaffLockoutEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> staffId = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffLockoutEntriesCompanion(
                staffId: staffId,
                failedAttempts: failedAttempts,
                lockedUntil: lockedUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String staffId,
                Value<int> failedAttempts = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffLockoutEntriesCompanion.insert(
                staffId: staffId,
                failedAttempts: failedAttempts,
                lockedUntil: lockedUntil,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StaffLockoutEntriesTable, StaffLockoutEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $StaffLockoutEntriesTable,
                    StaffLockoutEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StaffLockoutEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaffLockoutEntriesTable,
      StaffLockoutEntry,
      $$StaffLockoutEntriesTableFilterComposer,
      $$StaffLockoutEntriesTableOrderingComposer,
      $$StaffLockoutEntriesTableAnnotationComposer,
      $$StaffLockoutEntriesTableCreateCompanionBuilder,
      $$StaffLockoutEntriesTableUpdateCompanionBuilder,
      (
        StaffLockoutEntry,
        BaseReferences<
          _$AppDatabase,
          $StaffLockoutEntriesTable,
          StaffLockoutEntry
        >,
      ),
      StaffLockoutEntry,
      PrefetchHooks Function()
    >;
typedef $$OfflineApprovalEntriesTableCreateCompanionBuilder =
    OfflineApprovalEntriesCompanion Function({
      required String id,
      required String approverStaffId,
      required String requesterStaffId,
      required String action,
      Value<String?> reference,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OfflineApprovalEntriesTableUpdateCompanionBuilder =
    OfflineApprovalEntriesCompanion Function({
      Value<String> id,
      Value<String> approverStaffId,
      Value<String> requesterStaffId,
      Value<String> action,
      Value<String?> reference,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$OfflineApprovalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineApprovalEntriesTable> {
  $$OfflineApprovalEntriesTableFilterComposer({
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

  ColumnFilters<String> get approverStaffId => $composableBuilder(
    column: $table.approverStaffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requesterStaffId => $composableBuilder(
    column: $table.requesterStaffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineApprovalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineApprovalEntriesTable> {
  $$OfflineApprovalEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get approverStaffId => $composableBuilder(
    column: $table.approverStaffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requesterStaffId => $composableBuilder(
    column: $table.requesterStaffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineApprovalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineApprovalEntriesTable> {
  $$OfflineApprovalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get approverStaffId => $composableBuilder(
    column: $table.approverStaffId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requesterStaffId => $composableBuilder(
    column: $table.requesterStaffId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OfflineApprovalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfflineApprovalEntriesTable,
          OfflineApprovalEntry,
          $$OfflineApprovalEntriesTableFilterComposer,
          $$OfflineApprovalEntriesTableOrderingComposer,
          $$OfflineApprovalEntriesTableAnnotationComposer,
          $$OfflineApprovalEntriesTableCreateCompanionBuilder,
          $$OfflineApprovalEntriesTableUpdateCompanionBuilder,
          (
            OfflineApprovalEntry,
            BaseReferences<
              _$AppDatabase,
              $OfflineApprovalEntriesTable,
              OfflineApprovalEntry
            >,
          ),
          OfflineApprovalEntry,
          PrefetchHooks Function()
        > {
  $$OfflineApprovalEntriesTableTableManager(
    _$AppDatabase db,
    $OfflineApprovalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineApprovalEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OfflineApprovalEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OfflineApprovalEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> approverStaffId = const Value.absent(),
                Value<String> requesterStaffId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflineApprovalEntriesCompanion(
                id: id,
                approverStaffId: approverStaffId,
                requesterStaffId: requesterStaffId,
                action: action,
                reference: reference,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String approverStaffId,
                required String requesterStaffId,
                required String action,
                Value<String?> reference = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OfflineApprovalEntriesCompanion.insert(
                id: id,
                approverStaffId: approverStaffId,
                requesterStaffId: requesterStaffId,
                action: action,
                reference: reference,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $OfflineApprovalEntriesTable,
                    OfflineApprovalEntry
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OfflineApprovalEntriesTable,
                    OfflineApprovalEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineApprovalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfflineApprovalEntriesTable,
      OfflineApprovalEntry,
      $$OfflineApprovalEntriesTableFilterComposer,
      $$OfflineApprovalEntriesTableOrderingComposer,
      $$OfflineApprovalEntriesTableAnnotationComposer,
      $$OfflineApprovalEntriesTableCreateCompanionBuilder,
      $$OfflineApprovalEntriesTableUpdateCompanionBuilder,
      (
        OfflineApprovalEntry,
        BaseReferences<
          _$AppDatabase,
          $OfflineApprovalEntriesTable,
          OfflineApprovalEntry
        >,
      ),
      OfflineApprovalEntry,
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
  $$StaffLockoutEntriesTableTableManager get staffLockoutEntries =>
      $$StaffLockoutEntriesTableTableManager(_db, _db.staffLockoutEntries);
  $$OfflineApprovalEntriesTableTableManager get offlineApprovalEntries =>
      $$OfflineApprovalEntriesTableTableManager(
        _db,
        _db.offlineApprovalEntries,
      );
}
