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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    approverStaffId,
    requesterStaffId,
    action,
    reference,
    createdAt,
    syncedAt,
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
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
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
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
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
  final DateTime? syncedAt;
  const OfflineApprovalEntry({
    required this.id,
    required this.approverStaffId,
    required this.requesterStaffId,
    required this.action,
    this.reference,
    required this.createdAt,
    this.syncedAt,
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
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
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
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
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
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
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
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  OfflineApprovalEntry copyWith({
    String? id,
    String? approverStaffId,
    String? requesterStaffId,
    String? action,
    Value<String?> reference = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => OfflineApprovalEntry(
    id: id ?? this.id,
    approverStaffId: approverStaffId ?? this.approverStaffId,
    requesterStaffId: requesterStaffId ?? this.requesterStaffId,
    action: action ?? this.action,
    reference: reference.present ? reference.value : this.reference,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
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
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
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
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
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
    syncedAt,
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
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class OfflineApprovalEntriesCompanion
    extends UpdateCompanion<OfflineApprovalEntry> {
  final Value<String> id;
  final Value<String> approverStaffId;
  final Value<String> requesterStaffId;
  final Value<String> action;
  final Value<String?> reference;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const OfflineApprovalEntriesCompanion({
    this.id = const Value.absent(),
    this.approverStaffId = const Value.absent(),
    this.requesterStaffId = const Value.absent(),
    this.action = const Value.absent(),
    this.reference = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineApprovalEntriesCompanion.insert({
    required String id,
    required String approverStaffId,
    required String requesterStaffId,
    required String action,
    this.reference = const Value.absent(),
    required DateTime createdAt,
    this.syncedAt = const Value.absent(),
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
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (approverStaffId != null) 'approver_staff_id': approverStaffId,
      if (requesterStaffId != null) 'requester_staff_id': requesterStaffId,
      if (action != null) 'action': action,
      if (reference != null) 'reference': reference,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
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
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return OfflineApprovalEntriesCompanion(
      id: id ?? this.id,
      approverStaffId: approverStaffId ?? this.approverStaffId,
      requesterStaffId: requesterStaffId ?? this.requesterStaffId,
      action: action ?? this.action,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
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
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
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
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogTaxRatesTable extends CatalogTaxRates
    with TableInfo<$CatalogTaxRatesTable, CatalogTaxRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogTaxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateBpMeta = const VerificationMeta('rateBp');
  @override
  late final GeneratedColumn<int> rateBp = GeneratedColumn<int>(
    'rate_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, name, rateBp, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_tax_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogTaxRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rate_bp')) {
      context.handle(
        _rateBpMeta,
        rateBp.isAcceptableOrUnknown(data['rate_bp']!, _rateBpMeta),
      );
    } else if (isInserting) {
      context.missing(_rateBpMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogTaxRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogTaxRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rateBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_bp'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CatalogTaxRatesTable createAlias(String alias) {
    return $CatalogTaxRatesTable(attachedDatabase, alias);
  }
}

class CatalogTaxRate extends DataClass implements Insertable<CatalogTaxRate> {
  final String id;
  final String kind;
  final String name;
  final int rateBp;
  final bool isActive;
  const CatalogTaxRate({
    required this.id,
    required this.kind,
    required this.name,
    required this.rateBp,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    map['rate_bp'] = Variable<int>(rateBp);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CatalogTaxRatesCompanion toCompanion(bool nullToAbsent) {
    return CatalogTaxRatesCompanion(
      id: Value(id),
      kind: Value(kind),
      name: Value(name),
      rateBp: Value(rateBp),
      isActive: Value(isActive),
    );
  }

  factory CatalogTaxRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogTaxRate(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      rateBp: serializer.fromJson<int>(json['rateBp']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'rateBp': serializer.toJson<int>(rateBp),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CatalogTaxRate copyWith({
    String? id,
    String? kind,
    String? name,
    int? rateBp,
    bool? isActive,
  }) => CatalogTaxRate(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    rateBp: rateBp ?? this.rateBp,
    isActive: isActive ?? this.isActive,
  );
  CatalogTaxRate copyWithCompanion(CatalogTaxRatesCompanion data) {
    return CatalogTaxRate(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      rateBp: data.rateBp.present ? data.rateBp.value : this.rateBp,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogTaxRate(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('rateBp: $rateBp, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, name, rateBp, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogTaxRate &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.rateBp == this.rateBp &&
          other.isActive == this.isActive);
}

class CatalogTaxRatesCompanion extends UpdateCompanion<CatalogTaxRate> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> name;
  final Value<int> rateBp;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CatalogTaxRatesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.rateBp = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogTaxRatesCompanion.insert({
    required String id,
    required String kind,
    required String name,
    required int rateBp,
    required bool isActive,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       name = Value(name),
       rateBp = Value(rateBp),
       isActive = Value(isActive);
  static Insertable<CatalogTaxRate> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<int>? rateBp,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (rateBp != null) 'rate_bp': rateBp,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogTaxRatesCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? name,
    Value<int>? rateBp,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CatalogTaxRatesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      rateBp: rateBp ?? this.rateBp,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rateBp.present) {
      map['rate_bp'] = Variable<int>(rateBp.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogTaxRatesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('rateBp: $rateBp, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogCategoriesTable extends CatalogCategories
    with TableInfo<$CatalogCategoriesTable, CatalogCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder, color, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CatalogCategoriesTable createAlias(String alias) {
    return $CatalogCategoriesTable(attachedDatabase, alias);
  }
}

class CatalogCategory extends DataClass implements Insertable<CatalogCategory> {
  final String id;
  final String name;
  final int sortOrder;
  final String? color;
  final bool isActive;
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.color,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CatalogCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CatalogCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      isActive: Value(isActive),
    );
  }

  factory CatalogCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      color: serializer.fromJson<String?>(json['color']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'color': serializer.toJson<String?>(color),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CatalogCategory copyWith({
    String? id,
    String? name,
    int? sortOrder,
    Value<String?> color = const Value.absent(),
    bool? isActive,
  }) => CatalogCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    color: color.present ? color.value : this.color,
    isActive: isActive ?? this.isActive,
  );
  CatalogCategory copyWithCompanion(CatalogCategoriesCompanion data) {
    return CatalogCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      color: data.color.present ? data.color.value : this.color,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder, color, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.color == this.color &&
          other.isActive == this.isActive);
}

class CatalogCategoriesCompanion extends UpdateCompanion<CatalogCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<String?> color;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CatalogCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.color = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogCategoriesCompanion.insert({
    required String id,
    required String name,
    required int sortOrder,
    this.color = const Value.absent(),
    required bool isActive,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sortOrder = Value(sortOrder),
       isActive = Value(isActive);
  static Insertable<CatalogCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<String>? color,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (color != null) 'color': color,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<String?>? color,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CatalogCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogProductsTable extends CatalogProducts
    with TableInfo<$CatalogProductsTable, CatalogProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoIdMeta = const VerificationMeta(
    'photoId',
  );
  @override
  late final GeneratedColumn<String> photoId = GeneratedColumn<String>(
    'photo_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ivaRateIdMeta = const VerificationMeta(
    'ivaRateId',
  );
  @override
  late final GeneratedColumn<String> ivaRateId = GeneratedColumn<String>(
    'iva_rate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iepsRateIdMeta = const VerificationMeta(
    'iepsRateId',
  );
  @override
  late final GeneratedColumn<String> iepsRateId = GeneratedColumn<String>(
    'ieps_rate_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayOldDiscountAfterDaysMeta =
      const VerificationMeta('dayOldDiscountAfterDays');
  @override
  late final GeneratedColumn<int> dayOldDiscountAfterDays =
      GeneratedColumn<int>(
        'day_old_discount_after_days',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dayOldDiscountBpMeta = const VerificationMeta(
    'dayOldDiscountBp',
  );
  @override
  late final GeneratedColumn<int> dayOldDiscountBp = GeneratedColumn<int>(
    'day_old_discount_bp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayOldWasteAfterDaysMeta =
      const VerificationMeta('dayOldWasteAfterDays');
  @override
  late final GeneratedColumn<int> dayOldWasteAfterDays = GeneratedColumn<int>(
    'day_old_waste_after_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    unit,
    photoId,
    ivaRateId,
    iepsRateId,
    dayOldDiscountAfterDays,
    dayOldDiscountBp,
    dayOldWasteAfterDays,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogProduct> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('photo_id')) {
      context.handle(
        _photoIdMeta,
        photoId.isAcceptableOrUnknown(data['photo_id']!, _photoIdMeta),
      );
    }
    if (data.containsKey('iva_rate_id')) {
      context.handle(
        _ivaRateIdMeta,
        ivaRateId.isAcceptableOrUnknown(data['iva_rate_id']!, _ivaRateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ivaRateIdMeta);
    }
    if (data.containsKey('ieps_rate_id')) {
      context.handle(
        _iepsRateIdMeta,
        iepsRateId.isAcceptableOrUnknown(
          data['ieps_rate_id']!,
          _iepsRateIdMeta,
        ),
      );
    }
    if (data.containsKey('day_old_discount_after_days')) {
      context.handle(
        _dayOldDiscountAfterDaysMeta,
        dayOldDiscountAfterDays.isAcceptableOrUnknown(
          data['day_old_discount_after_days']!,
          _dayOldDiscountAfterDaysMeta,
        ),
      );
    }
    if (data.containsKey('day_old_discount_bp')) {
      context.handle(
        _dayOldDiscountBpMeta,
        dayOldDiscountBp.isAcceptableOrUnknown(
          data['day_old_discount_bp']!,
          _dayOldDiscountBpMeta,
        ),
      );
    }
    if (data.containsKey('day_old_waste_after_days')) {
      context.handle(
        _dayOldWasteAfterDaysMeta,
        dayOldWasteAfterDays.isAcceptableOrUnknown(
          data['day_old_waste_after_days']!,
          _dayOldWasteAfterDaysMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogProduct(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      photoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_id'],
      ),
      ivaRateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iva_rate_id'],
      )!,
      iepsRateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ieps_rate_id'],
      ),
      dayOldDiscountAfterDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_old_discount_after_days'],
      ),
      dayOldDiscountBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_old_discount_bp'],
      ),
      dayOldWasteAfterDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_old_waste_after_days'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CatalogProductsTable createAlias(String alias) {
    return $CatalogProductsTable(attachedDatabase, alias);
  }
}

class CatalogProduct extends DataClass implements Insertable<CatalogProduct> {
  final String id;
  final String categoryId;
  final String name;
  final String unit;
  final String? photoId;
  final String ivaRateId;
  final String? iepsRateId;
  final int? dayOldDiscountAfterDays;
  final int? dayOldDiscountBp;
  final int? dayOldWasteAfterDays;
  final int sortOrder;
  final bool isActive;
  const CatalogProduct({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.unit,
    this.photoId,
    required this.ivaRateId,
    this.iepsRateId,
    this.dayOldDiscountAfterDays,
    this.dayOldDiscountBp,
    this.dayOldWasteAfterDays,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || photoId != null) {
      map['photo_id'] = Variable<String>(photoId);
    }
    map['iva_rate_id'] = Variable<String>(ivaRateId);
    if (!nullToAbsent || iepsRateId != null) {
      map['ieps_rate_id'] = Variable<String>(iepsRateId);
    }
    if (!nullToAbsent || dayOldDiscountAfterDays != null) {
      map['day_old_discount_after_days'] = Variable<int>(
        dayOldDiscountAfterDays,
      );
    }
    if (!nullToAbsent || dayOldDiscountBp != null) {
      map['day_old_discount_bp'] = Variable<int>(dayOldDiscountBp);
    }
    if (!nullToAbsent || dayOldWasteAfterDays != null) {
      map['day_old_waste_after_days'] = Variable<int>(dayOldWasteAfterDays);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CatalogProductsCompanion toCompanion(bool nullToAbsent) {
    return CatalogProductsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      unit: Value(unit),
      photoId: photoId == null && nullToAbsent
          ? const Value.absent()
          : Value(photoId),
      ivaRateId: Value(ivaRateId),
      iepsRateId: iepsRateId == null && nullToAbsent
          ? const Value.absent()
          : Value(iepsRateId),
      dayOldDiscountAfterDays: dayOldDiscountAfterDays == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOldDiscountAfterDays),
      dayOldDiscountBp: dayOldDiscountBp == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOldDiscountBp),
      dayOldWasteAfterDays: dayOldWasteAfterDays == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOldWasteAfterDays),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory CatalogProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogProduct(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      photoId: serializer.fromJson<String?>(json['photoId']),
      ivaRateId: serializer.fromJson<String>(json['ivaRateId']),
      iepsRateId: serializer.fromJson<String?>(json['iepsRateId']),
      dayOldDiscountAfterDays: serializer.fromJson<int?>(
        json['dayOldDiscountAfterDays'],
      ),
      dayOldDiscountBp: serializer.fromJson<int?>(json['dayOldDiscountBp']),
      dayOldWasteAfterDays: serializer.fromJson<int?>(
        json['dayOldWasteAfterDays'],
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'photoId': serializer.toJson<String?>(photoId),
      'ivaRateId': serializer.toJson<String>(ivaRateId),
      'iepsRateId': serializer.toJson<String?>(iepsRateId),
      'dayOldDiscountAfterDays': serializer.toJson<int?>(
        dayOldDiscountAfterDays,
      ),
      'dayOldDiscountBp': serializer.toJson<int?>(dayOldDiscountBp),
      'dayOldWasteAfterDays': serializer.toJson<int?>(dayOldWasteAfterDays),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CatalogProduct copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? unit,
    Value<String?> photoId = const Value.absent(),
    String? ivaRateId,
    Value<String?> iepsRateId = const Value.absent(),
    Value<int?> dayOldDiscountAfterDays = const Value.absent(),
    Value<int?> dayOldDiscountBp = const Value.absent(),
    Value<int?> dayOldWasteAfterDays = const Value.absent(),
    int? sortOrder,
    bool? isActive,
  }) => CatalogProduct(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    photoId: photoId.present ? photoId.value : this.photoId,
    ivaRateId: ivaRateId ?? this.ivaRateId,
    iepsRateId: iepsRateId.present ? iepsRateId.value : this.iepsRateId,
    dayOldDiscountAfterDays: dayOldDiscountAfterDays.present
        ? dayOldDiscountAfterDays.value
        : this.dayOldDiscountAfterDays,
    dayOldDiscountBp: dayOldDiscountBp.present
        ? dayOldDiscountBp.value
        : this.dayOldDiscountBp,
    dayOldWasteAfterDays: dayOldWasteAfterDays.present
        ? dayOldWasteAfterDays.value
        : this.dayOldWasteAfterDays,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  CatalogProduct copyWithCompanion(CatalogProductsCompanion data) {
    return CatalogProduct(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      photoId: data.photoId.present ? data.photoId.value : this.photoId,
      ivaRateId: data.ivaRateId.present ? data.ivaRateId.value : this.ivaRateId,
      iepsRateId: data.iepsRateId.present
          ? data.iepsRateId.value
          : this.iepsRateId,
      dayOldDiscountAfterDays: data.dayOldDiscountAfterDays.present
          ? data.dayOldDiscountAfterDays.value
          : this.dayOldDiscountAfterDays,
      dayOldDiscountBp: data.dayOldDiscountBp.present
          ? data.dayOldDiscountBp.value
          : this.dayOldDiscountBp,
      dayOldWasteAfterDays: data.dayOldWasteAfterDays.present
          ? data.dayOldWasteAfterDays.value
          : this.dayOldWasteAfterDays,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogProduct(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('photoId: $photoId, ')
          ..write('ivaRateId: $ivaRateId, ')
          ..write('iepsRateId: $iepsRateId, ')
          ..write('dayOldDiscountAfterDays: $dayOldDiscountAfterDays, ')
          ..write('dayOldDiscountBp: $dayOldDiscountBp, ')
          ..write('dayOldWasteAfterDays: $dayOldWasteAfterDays, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    name,
    unit,
    photoId,
    ivaRateId,
    iepsRateId,
    dayOldDiscountAfterDays,
    dayOldDiscountBp,
    dayOldWasteAfterDays,
    sortOrder,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogProduct &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.photoId == this.photoId &&
          other.ivaRateId == this.ivaRateId &&
          other.iepsRateId == this.iepsRateId &&
          other.dayOldDiscountAfterDays == this.dayOldDiscountAfterDays &&
          other.dayOldDiscountBp == this.dayOldDiscountBp &&
          other.dayOldWasteAfterDays == this.dayOldWasteAfterDays &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class CatalogProductsCompanion extends UpdateCompanion<CatalogProduct> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<String> unit;
  final Value<String?> photoId;
  final Value<String> ivaRateId;
  final Value<String?> iepsRateId;
  final Value<int?> dayOldDiscountAfterDays;
  final Value<int?> dayOldDiscountBp;
  final Value<int?> dayOldWasteAfterDays;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CatalogProductsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.photoId = const Value.absent(),
    this.ivaRateId = const Value.absent(),
    this.iepsRateId = const Value.absent(),
    this.dayOldDiscountAfterDays = const Value.absent(),
    this.dayOldDiscountBp = const Value.absent(),
    this.dayOldWasteAfterDays = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogProductsCompanion.insert({
    required String id,
    required String categoryId,
    required String name,
    required String unit,
    this.photoId = const Value.absent(),
    required String ivaRateId,
    this.iepsRateId = const Value.absent(),
    this.dayOldDiscountAfterDays = const Value.absent(),
    this.dayOldDiscountBp = const Value.absent(),
    this.dayOldWasteAfterDays = const Value.absent(),
    required int sortOrder,
    required bool isActive,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       name = Value(name),
       unit = Value(unit),
       ivaRateId = Value(ivaRateId),
       sortOrder = Value(sortOrder),
       isActive = Value(isActive);
  static Insertable<CatalogProduct> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<String>? photoId,
    Expression<String>? ivaRateId,
    Expression<String>? iepsRateId,
    Expression<int>? dayOldDiscountAfterDays,
    Expression<int>? dayOldDiscountBp,
    Expression<int>? dayOldWasteAfterDays,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (photoId != null) 'photo_id': photoId,
      if (ivaRateId != null) 'iva_rate_id': ivaRateId,
      if (iepsRateId != null) 'ieps_rate_id': iepsRateId,
      if (dayOldDiscountAfterDays != null)
        'day_old_discount_after_days': dayOldDiscountAfterDays,
      if (dayOldDiscountBp != null) 'day_old_discount_bp': dayOldDiscountBp,
      if (dayOldWasteAfterDays != null)
        'day_old_waste_after_days': dayOldWasteAfterDays,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String>? name,
    Value<String>? unit,
    Value<String?>? photoId,
    Value<String>? ivaRateId,
    Value<String?>? iepsRateId,
    Value<int?>? dayOldDiscountAfterDays,
    Value<int?>? dayOldDiscountBp,
    Value<int?>? dayOldWasteAfterDays,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CatalogProductsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      photoId: photoId ?? this.photoId,
      ivaRateId: ivaRateId ?? this.ivaRateId,
      iepsRateId: iepsRateId ?? this.iepsRateId,
      dayOldDiscountAfterDays:
          dayOldDiscountAfterDays ?? this.dayOldDiscountAfterDays,
      dayOldDiscountBp: dayOldDiscountBp ?? this.dayOldDiscountBp,
      dayOldWasteAfterDays: dayOldWasteAfterDays ?? this.dayOldWasteAfterDays,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (photoId.present) {
      map['photo_id'] = Variable<String>(photoId.value);
    }
    if (ivaRateId.present) {
      map['iva_rate_id'] = Variable<String>(ivaRateId.value);
    }
    if (iepsRateId.present) {
      map['ieps_rate_id'] = Variable<String>(iepsRateId.value);
    }
    if (dayOldDiscountAfterDays.present) {
      map['day_old_discount_after_days'] = Variable<int>(
        dayOldDiscountAfterDays.value,
      );
    }
    if (dayOldDiscountBp.present) {
      map['day_old_discount_bp'] = Variable<int>(dayOldDiscountBp.value);
    }
    if (dayOldWasteAfterDays.present) {
      map['day_old_waste_after_days'] = Variable<int>(
        dayOldWasteAfterDays.value,
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogProductsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('photoId: $photoId, ')
          ..write('ivaRateId: $ivaRateId, ')
          ..write('iepsRateId: $iepsRateId, ')
          ..write('dayOldDiscountAfterDays: $dayOldDiscountAfterDays, ')
          ..write('dayOldDiscountBp: $dayOldDiscountBp, ')
          ..write('dayOldWasteAfterDays: $dayOldWasteAfterDays, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogVariantsTable extends CatalogVariants
    with TableInfo<$CatalogVariantsTable, CatalogVariant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogVariantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceCentsMeta = const VerificationMeta(
    'priceCents',
  );
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
    'price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    name,
    sku,
    barcode,
    priceCents,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_variants';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogVariant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('price_cents')) {
      context.handle(
        _priceCentsMeta,
        priceCents.isAcceptableOrUnknown(data['price_cents']!, _priceCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_priceCentsMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogVariant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogVariant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      priceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_cents'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CatalogVariantsTable createAlias(String alias) {
    return $CatalogVariantsTable(attachedDatabase, alias);
  }
}

class CatalogVariant extends DataClass implements Insertable<CatalogVariant> {
  final String id;
  final String productId;
  final String name;
  final String? sku;
  final String? barcode;
  final int priceCents;
  final int sortOrder;
  final bool isActive;
  const CatalogVariant({
    required this.id,
    required this.productId,
    required this.name,
    this.sku,
    this.barcode,
    required this.priceCents,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['price_cents'] = Variable<int>(priceCents);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CatalogVariantsCompanion toCompanion(bool nullToAbsent) {
    return CatalogVariantsCompanion(
      id: Value(id),
      productId: Value(productId),
      name: Value(name),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      priceCents: Value(priceCents),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory CatalogVariant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogVariant(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String?>(json['sku']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      priceCents: serializer.fromJson<int>(json['priceCents']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String?>(sku),
      'barcode': serializer.toJson<String?>(barcode),
      'priceCents': serializer.toJson<int>(priceCents),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CatalogVariant copyWith({
    String? id,
    String? productId,
    String? name,
    Value<String?> sku = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    int? priceCents,
    int? sortOrder,
    bool? isActive,
  }) => CatalogVariant(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    name: name ?? this.name,
    sku: sku.present ? sku.value : this.sku,
    barcode: barcode.present ? barcode.value : this.barcode,
    priceCents: priceCents ?? this.priceCents,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  CatalogVariant copyWithCompanion(CatalogVariantsCompanion data) {
    return CatalogVariant(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      priceCents: data.priceCents.present
          ? data.priceCents.value
          : this.priceCents,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogVariant(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('priceCents: $priceCents, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    name,
    sku,
    barcode,
    priceCents,
    sortOrder,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogVariant &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.priceCents == this.priceCents &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class CatalogVariantsCompanion extends UpdateCompanion<CatalogVariant> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> name;
  final Value<String?> sku;
  final Value<String?> barcode;
  final Value<int> priceCents;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CatalogVariantsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogVariantsCompanion.insert({
    required String id,
    required String productId,
    required String name,
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    required int priceCents,
    required int sortOrder,
    required bool isActive,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       name = Value(name),
       priceCents = Value(priceCents),
       sortOrder = Value(sortOrder),
       isActive = Value(isActive);
  static Insertable<CatalogVariant> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<int>? priceCents,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (priceCents != null) 'price_cents': priceCents,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogVariantsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? name,
    Value<String?>? sku,
    Value<String?>? barcode,
    Value<int>? priceCents,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CatalogVariantsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      priceCents: priceCents ?? this.priceCents,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogVariantsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('priceCents: $priceCents, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogBranchPricesTable extends CatalogBranchPrices
    with TableInfo<$CatalogBranchPricesTable, CatalogBranchPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogBranchPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceCentsMeta = const VerificationMeta(
    'priceCents',
  );
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
    'price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [variantId, priceCents];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_branch_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogBranchPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('price_cents')) {
      context.handle(
        _priceCentsMeta,
        priceCents.isAcceptableOrUnknown(data['price_cents']!, _priceCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_priceCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {variantId};
  @override
  CatalogBranchPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogBranchPrice(
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      )!,
      priceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_cents'],
      )!,
    );
  }

  @override
  $CatalogBranchPricesTable createAlias(String alias) {
    return $CatalogBranchPricesTable(attachedDatabase, alias);
  }
}

class CatalogBranchPrice extends DataClass
    implements Insertable<CatalogBranchPrice> {
  final String variantId;
  final int priceCents;
  const CatalogBranchPrice({required this.variantId, required this.priceCents});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['variant_id'] = Variable<String>(variantId);
    map['price_cents'] = Variable<int>(priceCents);
    return map;
  }

  CatalogBranchPricesCompanion toCompanion(bool nullToAbsent) {
    return CatalogBranchPricesCompanion(
      variantId: Value(variantId),
      priceCents: Value(priceCents),
    );
  }

  factory CatalogBranchPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogBranchPrice(
      variantId: serializer.fromJson<String>(json['variantId']),
      priceCents: serializer.fromJson<int>(json['priceCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'variantId': serializer.toJson<String>(variantId),
      'priceCents': serializer.toJson<int>(priceCents),
    };
  }

  CatalogBranchPrice copyWith({String? variantId, int? priceCents}) =>
      CatalogBranchPrice(
        variantId: variantId ?? this.variantId,
        priceCents: priceCents ?? this.priceCents,
      );
  CatalogBranchPrice copyWithCompanion(CatalogBranchPricesCompanion data) {
    return CatalogBranchPrice(
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      priceCents: data.priceCents.present
          ? data.priceCents.value
          : this.priceCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogBranchPrice(')
          ..write('variantId: $variantId, ')
          ..write('priceCents: $priceCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(variantId, priceCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogBranchPrice &&
          other.variantId == this.variantId &&
          other.priceCents == this.priceCents);
}

class CatalogBranchPricesCompanion extends UpdateCompanion<CatalogBranchPrice> {
  final Value<String> variantId;
  final Value<int> priceCents;
  final Value<int> rowid;
  const CatalogBranchPricesCompanion({
    this.variantId = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogBranchPricesCompanion.insert({
    required String variantId,
    required int priceCents,
    this.rowid = const Value.absent(),
  }) : variantId = Value(variantId),
       priceCents = Value(priceCents);
  static Insertable<CatalogBranchPrice> custom({
    Expression<String>? variantId,
    Expression<int>? priceCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (variantId != null) 'variant_id': variantId,
      if (priceCents != null) 'price_cents': priceCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogBranchPricesCompanion copyWith({
    Value<String>? variantId,
    Value<int>? priceCents,
    Value<int>? rowid,
  }) {
    return CatalogBranchPricesCompanion(
      variantId: variantId ?? this.variantId,
      priceCents: priceCents ?? this.priceCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogBranchPricesCompanion(')
          ..write('variantId: $variantId, ')
          ..write('priceCents: $priceCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateEntriesTable extends SyncStateEntries
    with TableInfo<$SyncStateEntriesTable, SyncStateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intValueMeta = const VerificationMeta(
    'intValue',
  );
  @override
  late final GeneratedColumn<int> intValue = GeneratedColumn<int>(
    'int_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, intValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateEntry> instance, {
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
    if (data.containsKey('int_value')) {
      context.handle(
        _intValueMeta,
        intValue.isAcceptableOrUnknown(data['int_value']!, _intValueMeta),
      );
    } else if (isInserting) {
      context.missing(_intValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncStateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      intValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}int_value'],
      )!,
    );
  }

  @override
  $SyncStateEntriesTable createAlias(String alias) {
    return $SyncStateEntriesTable(attachedDatabase, alias);
  }
}

class SyncStateEntry extends DataClass implements Insertable<SyncStateEntry> {
  final String key;
  final int intValue;
  const SyncStateEntry({required this.key, required this.intValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['int_value'] = Variable<int>(intValue);
    return map;
  }

  SyncStateEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncStateEntriesCompanion(
      key: Value(key),
      intValue: Value(intValue),
    );
  }

  factory SyncStateEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateEntry(
      key: serializer.fromJson<String>(json['key']),
      intValue: serializer.fromJson<int>(json['intValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'intValue': serializer.toJson<int>(intValue),
    };
  }

  SyncStateEntry copyWith({String? key, int? intValue}) =>
      SyncStateEntry(key: key ?? this.key, intValue: intValue ?? this.intValue);
  SyncStateEntry copyWithCompanion(SyncStateEntriesCompanion data) {
    return SyncStateEntry(
      key: data.key.present ? data.key.value : this.key,
      intValue: data.intValue.present ? data.intValue.value : this.intValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateEntry(')
          ..write('key: $key, ')
          ..write('intValue: $intValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, intValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateEntry &&
          other.key == this.key &&
          other.intValue == this.intValue);
}

class SyncStateEntriesCompanion extends UpdateCompanion<SyncStateEntry> {
  final Value<String> key;
  final Value<int> intValue;
  final Value<int> rowid;
  const SyncStateEntriesCompanion({
    this.key = const Value.absent(),
    this.intValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateEntriesCompanion.insert({
    required String key,
    required int intValue,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       intValue = Value(intValue);
  static Insertable<SyncStateEntry> custom({
    Expression<String>? key,
    Expression<int>? intValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (intValue != null) 'int_value': intValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateEntriesCompanion copyWith({
    Value<String>? key,
    Value<int>? intValue,
    Value<int>? rowid,
  }) {
    return SyncStateEntriesCompanion(
      key: key ?? this.key,
      intValue: intValue ?? this.intValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (intValue.present) {
      map['int_value'] = Variable<int>(intValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateEntriesCompanion(')
          ..write('key: $key, ')
          ..write('intValue: $intValue, ')
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
  late final $CatalogTaxRatesTable catalogTaxRates = $CatalogTaxRatesTable(
    this,
  );
  late final $CatalogCategoriesTable catalogCategories =
      $CatalogCategoriesTable(this);
  late final $CatalogProductsTable catalogProducts = $CatalogProductsTable(
    this,
  );
  late final $CatalogVariantsTable catalogVariants = $CatalogVariantsTable(
    this,
  );
  late final $CatalogBranchPricesTable catalogBranchPrices =
      $CatalogBranchPricesTable(this);
  late final $SyncStateEntriesTable syncStateEntries = $SyncStateEntriesTable(
    this,
  );
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
    catalogTaxRates,
    catalogCategories,
    catalogProducts,
    catalogVariants,
    catalogBranchPrices,
    syncStateEntries,
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
      Value<DateTime?> syncedAt,
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
      Value<DateTime?> syncedAt,
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

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
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

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
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

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
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
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflineApprovalEntriesCompanion(
                id: id,
                approverStaffId: approverStaffId,
                requesterStaffId: requesterStaffId,
                action: action,
                reference: reference,
                createdAt: createdAt,
                syncedAt: syncedAt,
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
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflineApprovalEntriesCompanion.insert(
                id: id,
                approverStaffId: approverStaffId,
                requesterStaffId: requesterStaffId,
                action: action,
                reference: reference,
                createdAt: createdAt,
                syncedAt: syncedAt,
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
typedef $$CatalogTaxRatesTableCreateCompanionBuilder =
    CatalogTaxRatesCompanion Function({
      required String id,
      required String kind,
      required String name,
      required int rateBp,
      required bool isActive,
      Value<int> rowid,
    });
typedef $$CatalogTaxRatesTableUpdateCompanionBuilder =
    CatalogTaxRatesCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> name,
      Value<int> rateBp,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$CatalogTaxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogTaxRatesTable> {
  $$CatalogTaxRatesTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateBp => $composableBuilder(
    column: $table.rateBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogTaxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogTaxRatesTable> {
  $$CatalogTaxRatesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateBp => $composableBuilder(
    column: $table.rateBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogTaxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogTaxRatesTable> {
  $$CatalogTaxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get rateBp =>
      $composableBuilder(column: $table.rateBp, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CatalogTaxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogTaxRatesTable,
          CatalogTaxRate,
          $$CatalogTaxRatesTableFilterComposer,
          $$CatalogTaxRatesTableOrderingComposer,
          $$CatalogTaxRatesTableAnnotationComposer,
          $$CatalogTaxRatesTableCreateCompanionBuilder,
          $$CatalogTaxRatesTableUpdateCompanionBuilder,
          (
            CatalogTaxRate,
            BaseReferences<
              _$AppDatabase,
              $CatalogTaxRatesTable,
              CatalogTaxRate
            >,
          ),
          CatalogTaxRate,
          PrefetchHooks Function()
        > {
  $$CatalogTaxRatesTableTableManager(
    _$AppDatabase db,
    $CatalogTaxRatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogTaxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogTaxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogTaxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rateBp = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogTaxRatesCompanion(
                id: id,
                kind: kind,
                name: name,
                rateBp: rateBp,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String name,
                required int rateBp,
                required bool isActive,
                Value<int> rowid = const Value.absent(),
              }) => CatalogTaxRatesCompanion.insert(
                id: id,
                kind: kind,
                name: name,
                rateBp: rateBp,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogTaxRatesTable, CatalogTaxRate>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogTaxRatesTable,
                    CatalogTaxRate
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogTaxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogTaxRatesTable,
      CatalogTaxRate,
      $$CatalogTaxRatesTableFilterComposer,
      $$CatalogTaxRatesTableOrderingComposer,
      $$CatalogTaxRatesTableAnnotationComposer,
      $$CatalogTaxRatesTableCreateCompanionBuilder,
      $$CatalogTaxRatesTableUpdateCompanionBuilder,
      (
        CatalogTaxRate,
        BaseReferences<_$AppDatabase, $CatalogTaxRatesTable, CatalogTaxRate>,
      ),
      CatalogTaxRate,
      PrefetchHooks Function()
    >;
typedef $$CatalogCategoriesTableCreateCompanionBuilder =
    CatalogCategoriesCompanion Function({
      required String id,
      required String name,
      required int sortOrder,
      Value<String?> color,
      required bool isActive,
      Value<int> rowid,
    });
typedef $$CatalogCategoriesTableUpdateCompanionBuilder =
    CatalogCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> sortOrder,
      Value<String?> color,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$CatalogCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogCategoriesTable> {
  $$CatalogCategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogCategoriesTable> {
  $$CatalogCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogCategoriesTable> {
  $$CatalogCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CatalogCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogCategoriesTable,
          CatalogCategory,
          $$CatalogCategoriesTableFilterComposer,
          $$CatalogCategoriesTableOrderingComposer,
          $$CatalogCategoriesTableAnnotationComposer,
          $$CatalogCategoriesTableCreateCompanionBuilder,
          $$CatalogCategoriesTableUpdateCompanionBuilder,
          (
            CatalogCategory,
            BaseReferences<
              _$AppDatabase,
              $CatalogCategoriesTable,
              CatalogCategory
            >,
          ),
          CatalogCategory,
          PrefetchHooks Function()
        > {
  $$CatalogCategoriesTableTableManager(
    _$AppDatabase db,
    $CatalogCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogCategoriesCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                color: color,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int sortOrder,
                Value<String?> color = const Value.absent(),
                required bool isActive,
                Value<int> rowid = const Value.absent(),
              }) => CatalogCategoriesCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                color: color,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogCategoriesTable, CatalogCategory>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogCategoriesTable,
                    CatalogCategory
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogCategoriesTable,
      CatalogCategory,
      $$CatalogCategoriesTableFilterComposer,
      $$CatalogCategoriesTableOrderingComposer,
      $$CatalogCategoriesTableAnnotationComposer,
      $$CatalogCategoriesTableCreateCompanionBuilder,
      $$CatalogCategoriesTableUpdateCompanionBuilder,
      (
        CatalogCategory,
        BaseReferences<_$AppDatabase, $CatalogCategoriesTable, CatalogCategory>,
      ),
      CatalogCategory,
      PrefetchHooks Function()
    >;
typedef $$CatalogProductsTableCreateCompanionBuilder =
    CatalogProductsCompanion Function({
      required String id,
      required String categoryId,
      required String name,
      required String unit,
      Value<String?> photoId,
      required String ivaRateId,
      Value<String?> iepsRateId,
      Value<int?> dayOldDiscountAfterDays,
      Value<int?> dayOldDiscountBp,
      Value<int?> dayOldWasteAfterDays,
      required int sortOrder,
      required bool isActive,
      Value<int> rowid,
    });
typedef $$CatalogProductsTableUpdateCompanionBuilder =
    CatalogProductsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String> name,
      Value<String> unit,
      Value<String?> photoId,
      Value<String> ivaRateId,
      Value<String?> iepsRateId,
      Value<int?> dayOldDiscountAfterDays,
      Value<int?> dayOldDiscountBp,
      Value<int?> dayOldWasteAfterDays,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$CatalogProductsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogProductsTable> {
  $$CatalogProductsTableFilterComposer({
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

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoId => $composableBuilder(
    column: $table.photoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ivaRateId => $composableBuilder(
    column: $table.ivaRateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iepsRateId => $composableBuilder(
    column: $table.iepsRateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOldDiscountAfterDays => $composableBuilder(
    column: $table.dayOldDiscountAfterDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOldDiscountBp => $composableBuilder(
    column: $table.dayOldDiscountBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOldWasteAfterDays => $composableBuilder(
    column: $table.dayOldWasteAfterDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogProductsTable> {
  $$CatalogProductsTableOrderingComposer({
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

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoId => $composableBuilder(
    column: $table.photoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ivaRateId => $composableBuilder(
    column: $table.ivaRateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iepsRateId => $composableBuilder(
    column: $table.iepsRateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOldDiscountAfterDays => $composableBuilder(
    column: $table.dayOldDiscountAfterDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOldDiscountBp => $composableBuilder(
    column: $table.dayOldDiscountBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOldWasteAfterDays => $composableBuilder(
    column: $table.dayOldWasteAfterDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogProductsTable> {
  $$CatalogProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get photoId =>
      $composableBuilder(column: $table.photoId, builder: (column) => column);

  GeneratedColumn<String> get ivaRateId =>
      $composableBuilder(column: $table.ivaRateId, builder: (column) => column);

  GeneratedColumn<String> get iepsRateId => $composableBuilder(
    column: $table.iepsRateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOldDiscountAfterDays => $composableBuilder(
    column: $table.dayOldDiscountAfterDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOldDiscountBp => $composableBuilder(
    column: $table.dayOldDiscountBp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOldWasteAfterDays => $composableBuilder(
    column: $table.dayOldWasteAfterDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CatalogProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogProductsTable,
          CatalogProduct,
          $$CatalogProductsTableFilterComposer,
          $$CatalogProductsTableOrderingComposer,
          $$CatalogProductsTableAnnotationComposer,
          $$CatalogProductsTableCreateCompanionBuilder,
          $$CatalogProductsTableUpdateCompanionBuilder,
          (
            CatalogProduct,
            BaseReferences<
              _$AppDatabase,
              $CatalogProductsTable,
              CatalogProduct
            >,
          ),
          CatalogProduct,
          PrefetchHooks Function()
        > {
  $$CatalogProductsTableTableManager(
    _$AppDatabase db,
    $CatalogProductsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> photoId = const Value.absent(),
                Value<String> ivaRateId = const Value.absent(),
                Value<String?> iepsRateId = const Value.absent(),
                Value<int?> dayOldDiscountAfterDays = const Value.absent(),
                Value<int?> dayOldDiscountBp = const Value.absent(),
                Value<int?> dayOldWasteAfterDays = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogProductsCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                unit: unit,
                photoId: photoId,
                ivaRateId: ivaRateId,
                iepsRateId: iepsRateId,
                dayOldDiscountAfterDays: dayOldDiscountAfterDays,
                dayOldDiscountBp: dayOldDiscountBp,
                dayOldWasteAfterDays: dayOldWasteAfterDays,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required String name,
                required String unit,
                Value<String?> photoId = const Value.absent(),
                required String ivaRateId,
                Value<String?> iepsRateId = const Value.absent(),
                Value<int?> dayOldDiscountAfterDays = const Value.absent(),
                Value<int?> dayOldDiscountBp = const Value.absent(),
                Value<int?> dayOldWasteAfterDays = const Value.absent(),
                required int sortOrder,
                required bool isActive,
                Value<int> rowid = const Value.absent(),
              }) => CatalogProductsCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                unit: unit,
                photoId: photoId,
                ivaRateId: ivaRateId,
                iepsRateId: iepsRateId,
                dayOldDiscountAfterDays: dayOldDiscountAfterDays,
                dayOldDiscountBp: dayOldDiscountBp,
                dayOldWasteAfterDays: dayOldWasteAfterDays,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogProductsTable, CatalogProduct>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogProductsTable,
                    CatalogProduct
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogProductsTable,
      CatalogProduct,
      $$CatalogProductsTableFilterComposer,
      $$CatalogProductsTableOrderingComposer,
      $$CatalogProductsTableAnnotationComposer,
      $$CatalogProductsTableCreateCompanionBuilder,
      $$CatalogProductsTableUpdateCompanionBuilder,
      (
        CatalogProduct,
        BaseReferences<_$AppDatabase, $CatalogProductsTable, CatalogProduct>,
      ),
      CatalogProduct,
      PrefetchHooks Function()
    >;
typedef $$CatalogVariantsTableCreateCompanionBuilder =
    CatalogVariantsCompanion Function({
      required String id,
      required String productId,
      required String name,
      Value<String?> sku,
      Value<String?> barcode,
      required int priceCents,
      required int sortOrder,
      required bool isActive,
      Value<int> rowid,
    });
typedef $$CatalogVariantsTableUpdateCompanionBuilder =
    CatalogVariantsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> name,
      Value<String?> sku,
      Value<String?> barcode,
      Value<int> priceCents,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$CatalogVariantsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogVariantsTable> {
  $$CatalogVariantsTableFilterComposer({
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

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogVariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogVariantsTable> {
  $$CatalogVariantsTableOrderingComposer({
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

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogVariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogVariantsTable> {
  $$CatalogVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CatalogVariantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogVariantsTable,
          CatalogVariant,
          $$CatalogVariantsTableFilterComposer,
          $$CatalogVariantsTableOrderingComposer,
          $$CatalogVariantsTableAnnotationComposer,
          $$CatalogVariantsTableCreateCompanionBuilder,
          $$CatalogVariantsTableUpdateCompanionBuilder,
          (
            CatalogVariant,
            BaseReferences<
              _$AppDatabase,
              $CatalogVariantsTable,
              CatalogVariant
            >,
          ),
          CatalogVariant,
          PrefetchHooks Function()
        > {
  $$CatalogVariantsTableTableManager(
    _$AppDatabase db,
    $CatalogVariantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogVariantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogVariantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<int> priceCents = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogVariantsCompanion(
                id: id,
                productId: productId,
                name: name,
                sku: sku,
                barcode: barcode,
                priceCents: priceCents,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String name,
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required int priceCents,
                required int sortOrder,
                required bool isActive,
                Value<int> rowid = const Value.absent(),
              }) => CatalogVariantsCompanion.insert(
                id: id,
                productId: productId,
                name: name,
                sku: sku,
                barcode: barcode,
                priceCents: priceCents,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogVariantsTable, CatalogVariant>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogVariantsTable,
                    CatalogVariant
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogVariantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogVariantsTable,
      CatalogVariant,
      $$CatalogVariantsTableFilterComposer,
      $$CatalogVariantsTableOrderingComposer,
      $$CatalogVariantsTableAnnotationComposer,
      $$CatalogVariantsTableCreateCompanionBuilder,
      $$CatalogVariantsTableUpdateCompanionBuilder,
      (
        CatalogVariant,
        BaseReferences<_$AppDatabase, $CatalogVariantsTable, CatalogVariant>,
      ),
      CatalogVariant,
      PrefetchHooks Function()
    >;
typedef $$CatalogBranchPricesTableCreateCompanionBuilder =
    CatalogBranchPricesCompanion Function({
      required String variantId,
      required int priceCents,
      Value<int> rowid,
    });
typedef $$CatalogBranchPricesTableUpdateCompanionBuilder =
    CatalogBranchPricesCompanion Function({
      Value<String> variantId,
      Value<int> priceCents,
      Value<int> rowid,
    });

class $$CatalogBranchPricesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogBranchPricesTable> {
  $$CatalogBranchPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogBranchPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogBranchPricesTable> {
  $$CatalogBranchPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogBranchPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogBranchPricesTable> {
  $$CatalogBranchPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => column,
  );
}

class $$CatalogBranchPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogBranchPricesTable,
          CatalogBranchPrice,
          $$CatalogBranchPricesTableFilterComposer,
          $$CatalogBranchPricesTableOrderingComposer,
          $$CatalogBranchPricesTableAnnotationComposer,
          $$CatalogBranchPricesTableCreateCompanionBuilder,
          $$CatalogBranchPricesTableUpdateCompanionBuilder,
          (
            CatalogBranchPrice,
            BaseReferences<
              _$AppDatabase,
              $CatalogBranchPricesTable,
              CatalogBranchPrice
            >,
          ),
          CatalogBranchPrice,
          PrefetchHooks Function()
        > {
  $$CatalogBranchPricesTableTableManager(
    _$AppDatabase db,
    $CatalogBranchPricesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogBranchPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogBranchPricesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CatalogBranchPricesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> variantId = const Value.absent(),
                Value<int> priceCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogBranchPricesCompanion(
                variantId: variantId,
                priceCents: priceCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String variantId,
                required int priceCents,
                Value<int> rowid = const Value.absent(),
              }) => CatalogBranchPricesCompanion.insert(
                variantId: variantId,
                priceCents: priceCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogBranchPricesTable, CatalogBranchPrice>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogBranchPricesTable,
                    CatalogBranchPrice
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogBranchPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogBranchPricesTable,
      CatalogBranchPrice,
      $$CatalogBranchPricesTableFilterComposer,
      $$CatalogBranchPricesTableOrderingComposer,
      $$CatalogBranchPricesTableAnnotationComposer,
      $$CatalogBranchPricesTableCreateCompanionBuilder,
      $$CatalogBranchPricesTableUpdateCompanionBuilder,
      (
        CatalogBranchPrice,
        BaseReferences<
          _$AppDatabase,
          $CatalogBranchPricesTable,
          CatalogBranchPrice
        >,
      ),
      CatalogBranchPrice,
      PrefetchHooks Function()
    >;
typedef $$SyncStateEntriesTableCreateCompanionBuilder =
    SyncStateEntriesCompanion Function({
      required String key,
      required int intValue,
      Value<int> rowid,
    });
typedef $$SyncStateEntriesTableUpdateCompanionBuilder =
    SyncStateEntriesCompanion Function({
      Value<String> key,
      Value<int> intValue,
      Value<int> rowid,
    });

class $$SyncStateEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateEntriesTable> {
  $$SyncStateEntriesTableFilterComposer({
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

  ColumnFilters<int> get intValue => $composableBuilder(
    column: $table.intValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateEntriesTable> {
  $$SyncStateEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get intValue => $composableBuilder(
    column: $table.intValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateEntriesTable> {
  $$SyncStateEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get intValue =>
      $composableBuilder(column: $table.intValue, builder: (column) => column);
}

class $$SyncStateEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateEntriesTable,
          SyncStateEntry,
          $$SyncStateEntriesTableFilterComposer,
          $$SyncStateEntriesTableOrderingComposer,
          $$SyncStateEntriesTableAnnotationComposer,
          $$SyncStateEntriesTableCreateCompanionBuilder,
          $$SyncStateEntriesTableUpdateCompanionBuilder,
          (
            SyncStateEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncStateEntriesTable,
              SyncStateEntry
            >,
          ),
          SyncStateEntry,
          PrefetchHooks Function()
        > {
  $$SyncStateEntriesTableTableManager(
    _$AppDatabase db,
    $SyncStateEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> intValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateEntriesCompanion(
                key: key,
                intValue: intValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required int intValue,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateEntriesCompanion.insert(
                key: key,
                intValue: intValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStateEntriesTable, SyncStateEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncStateEntriesTable,
                    SyncStateEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateEntriesTable,
      SyncStateEntry,
      $$SyncStateEntriesTableFilterComposer,
      $$SyncStateEntriesTableOrderingComposer,
      $$SyncStateEntriesTableAnnotationComposer,
      $$SyncStateEntriesTableCreateCompanionBuilder,
      $$SyncStateEntriesTableUpdateCompanionBuilder,
      (
        SyncStateEntry,
        BaseReferences<_$AppDatabase, $SyncStateEntriesTable, SyncStateEntry>,
      ),
      SyncStateEntry,
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
  $$CatalogTaxRatesTableTableManager get catalogTaxRates =>
      $$CatalogTaxRatesTableTableManager(_db, _db.catalogTaxRates);
  $$CatalogCategoriesTableTableManager get catalogCategories =>
      $$CatalogCategoriesTableTableManager(_db, _db.catalogCategories);
  $$CatalogProductsTableTableManager get catalogProducts =>
      $$CatalogProductsTableTableManager(_db, _db.catalogProducts);
  $$CatalogVariantsTableTableManager get catalogVariants =>
      $$CatalogVariantsTableTableManager(_db, _db.catalogVariants);
  $$CatalogBranchPricesTableTableManager get catalogBranchPrices =>
      $$CatalogBranchPricesTableTableManager(_db, _db.catalogBranchPrices);
  $$SyncStateEntriesTableTableManager get syncStateEntries =>
      $$SyncStateEntriesTableTableManager(_db, _db.syncStateEntries);
}
