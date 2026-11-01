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

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorStaffIdMeta = const VerificationMeta(
    'actorStaffId',
  );
  @override
  late final GeneratedColumn<String> actorStaffId = GeneratedColumn<String>(
    'actor_staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    occurredAt,
    actorStaffId,
    payload,
    attempts,
    status,
    lastErrorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('actor_staff_id')) {
      context.handle(
        _actorStaffIdMeta,
        actorStaffId.isAcceptableOrUnknown(
          data['actor_staff_id']!,
          _actorStaffIdMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      actorStaffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_staff_id'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final String id;
  final String type;
  final DateTime occurredAt;
  final String? actorStaffId;

  /// JSON object; never holds a PIN.
  final String payload;
  final int attempts;

  /// `PENDING` or `QUARANTINED`; delivered records are deleted.
  final String status;
  final String? lastErrorCode;
  const OutboxEntry({
    required this.id,
    required this.type,
    required this.occurredAt,
    this.actorStaffId,
    required this.payload,
    required this.attempts,
    required this.status,
    this.lastErrorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || actorStaffId != null) {
      map['actor_staff_id'] = Variable<String>(actorStaffId);
    }
    map['payload'] = Variable<String>(payload);
    map['attempts'] = Variable<int>(attempts);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      type: Value(type),
      occurredAt: Value(occurredAt),
      actorStaffId: actorStaffId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorStaffId),
      payload: Value(payload),
      attempts: Value(attempts),
      status: Value(status),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      actorStaffId: serializer.fromJson<String?>(json['actorStaffId']),
      payload: serializer.fromJson<String>(json['payload']),
      attempts: serializer.fromJson<int>(json['attempts']),
      status: serializer.fromJson<String>(json['status']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'actorStaffId': serializer.toJson<String?>(actorStaffId),
      'payload': serializer.toJson<String>(payload),
      'attempts': serializer.toJson<int>(attempts),
      'status': serializer.toJson<String>(status),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
    };
  }

  OutboxEntry copyWith({
    String? id,
    String? type,
    DateTime? occurredAt,
    Value<String?> actorStaffId = const Value.absent(),
    String? payload,
    int? attempts,
    String? status,
    Value<String?> lastErrorCode = const Value.absent(),
  }) => OutboxEntry(
    id: id ?? this.id,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    actorStaffId: actorStaffId.present ? actorStaffId.value : this.actorStaffId,
    payload: payload ?? this.payload,
    attempts: attempts ?? this.attempts,
    status: status ?? this.status,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
  );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      actorStaffId: data.actorStaffId.present
          ? data.actorStaffId.value
          : this.actorStaffId,
      payload: data.payload.present ? data.payload.value : this.payload,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      status: data.status.present ? data.status.value : this.status,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('actorStaffId: $actorStaffId, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('status: $status, ')
          ..write('lastErrorCode: $lastErrorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    occurredAt,
    actorStaffId,
    payload,
    attempts,
    status,
    lastErrorCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.actorStaffId == this.actorStaffId &&
          other.payload == this.payload &&
          other.attempts == this.attempts &&
          other.status == this.status &&
          other.lastErrorCode == this.lastErrorCode);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String?> actorStaffId;
  final Value<String> payload;
  final Value<int> attempts;
  final Value<String> status;
  final Value<String?> lastErrorCode;
  final Value<int> rowid;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.actorStaffId = const Value.absent(),
    this.payload = const Value.absent(),
    this.attempts = const Value.absent(),
    this.status = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    required String id,
    required String type,
    required DateTime occurredAt,
    this.actorStaffId = const Value.absent(),
    required String payload,
    this.attempts = const Value.absent(),
    this.status = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       occurredAt = Value(occurredAt),
       payload = Value(payload);
  static Insertable<OutboxEntry> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? actorStaffId,
    Expression<String>? payload,
    Expression<int>? attempts,
    Expression<String>? status,
    Expression<String>? lastErrorCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (actorStaffId != null) 'actor_staff_id': actorStaffId,
      if (payload != null) 'payload': payload,
      if (attempts != null) 'attempts': attempts,
      if (status != null) 'status': status,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String?>? actorStaffId,
    Value<String>? payload,
    Value<int>? attempts,
    Value<String>? status,
    Value<String?>? lastErrorCode,
    Value<int>? rowid,
  }) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      actorStaffId: actorStaffId ?? this.actorStaffId,
      payload: payload ?? this.payload,
      attempts: attempts ?? this.attempts,
      status: status ?? this.status,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (actorStaffId.present) {
      map['actor_staff_id'] = Variable<String>(actorStaffId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('actorStaffId: $actorStaffId, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('status: $status, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSalesTable extends LocalSales
    with TableInfo<$LocalSalesTable, LocalSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folioMeta = const VerificationMeta('folio');
  @override
  late final GeneratedColumn<String> folio = GeneratedColumn<String>(
    'folio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _folioNumberMeta = const VerificationMeta(
    'folioNumber',
  );
  @override
  late final GeneratedColumn<int> folioNumber = GeneratedColumn<int>(
    'folio_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _cashierStaffIdMeta = const VerificationMeta(
    'cashierStaffId',
  );
  @override
  late final GeneratedColumn<String> cashierStaffId = GeneratedColumn<String>(
    'cashier_staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashierNameMeta = const VerificationMeta(
    'cashierName',
  );
  @override
  late final GeneratedColumn<String> cashierName = GeneratedColumn<String>(
    'cashier_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossCentsMeta = const VerificationMeta(
    'grossCents',
  );
  @override
  late final GeneratedColumn<int> grossCents = GeneratedColumn<int>(
    'gross_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountCentsMeta = const VerificationMeta(
    'discountCents',
  );
  @override
  late final GeneratedColumn<int> discountCents = GeneratedColumn<int>(
    'discount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenderedCentsMeta = const VerificationMeta(
    'tenderedCents',
  );
  @override
  late final GeneratedColumn<int> tenderedCents = GeneratedColumn<int>(
    'tendered_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeCentsMeta = const VerificationMeta(
    'changeCents',
  );
  @override
  late final GeneratedColumn<int> changeCents = GeneratedColumn<int>(
    'change_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('COMPLETED'),
  );
  static const VerificationMeta _refundedCentsMeta = const VerificationMeta(
    'refundedCents',
  );
  @override
  late final GeneratedColumn<int> refundedCents = GeneratedColumn<int>(
    'refunded_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _voidedLinesJsonMeta = const VerificationMeta(
    'voidedLinesJson',
  );
  @override
  late final GeneratedColumn<String> voidedLinesJson = GeneratedColumn<String>(
    'voided_lines_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folio,
    folioNumber,
    cashierStaffId,
    cashierName,
    occurredAt,
    grossCents,
    discountCents,
    totalCents,
    tenderedCents,
    changeCents,
    status,
    refundedCents,
    voidedLinesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('folio')) {
      context.handle(
        _folioMeta,
        folio.isAcceptableOrUnknown(data['folio']!, _folioMeta),
      );
    } else if (isInserting) {
      context.missing(_folioMeta);
    }
    if (data.containsKey('folio_number')) {
      context.handle(
        _folioNumberMeta,
        folioNumber.isAcceptableOrUnknown(
          data['folio_number']!,
          _folioNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_folioNumberMeta);
    }
    if (data.containsKey('cashier_staff_id')) {
      context.handle(
        _cashierStaffIdMeta,
        cashierStaffId.isAcceptableOrUnknown(
          data['cashier_staff_id']!,
          _cashierStaffIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashierStaffIdMeta);
    }
    if (data.containsKey('cashier_name')) {
      context.handle(
        _cashierNameMeta,
        cashierName.isAcceptableOrUnknown(
          data['cashier_name']!,
          _cashierNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashierNameMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('gross_cents')) {
      context.handle(
        _grossCentsMeta,
        grossCents.isAcceptableOrUnknown(data['gross_cents']!, _grossCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_grossCentsMeta);
    }
    if (data.containsKey('discount_cents')) {
      context.handle(
        _discountCentsMeta,
        discountCents.isAcceptableOrUnknown(
          data['discount_cents']!,
          _discountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountCentsMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('tendered_cents')) {
      context.handle(
        _tenderedCentsMeta,
        tenderedCents.isAcceptableOrUnknown(
          data['tendered_cents']!,
          _tenderedCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tenderedCentsMeta);
    }
    if (data.containsKey('change_cents')) {
      context.handle(
        _changeCentsMeta,
        changeCents.isAcceptableOrUnknown(
          data['change_cents']!,
          _changeCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changeCentsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('refunded_cents')) {
      context.handle(
        _refundedCentsMeta,
        refundedCents.isAcceptableOrUnknown(
          data['refunded_cents']!,
          _refundedCentsMeta,
        ),
      );
    }
    if (data.containsKey('voided_lines_json')) {
      context.handle(
        _voidedLinesJsonMeta,
        voidedLinesJson.isAcceptableOrUnknown(
          data['voided_lines_json']!,
          _voidedLinesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      folio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folio'],
      )!,
      folioNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folio_number'],
      )!,
      cashierStaffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_staff_id'],
      )!,
      cashierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_name'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      grossCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_cents'],
      )!,
      discountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_cents'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      tenderedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tendered_cents'],
      )!,
      changeCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_cents'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      refundedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refunded_cents'],
      )!,
      voidedLinesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voided_lines_json'],
      )!,
    );
  }

  @override
  $LocalSalesTable createAlias(String alias) {
    return $LocalSalesTable(attachedDatabase, alias);
  }
}

class LocalSale extends DataClass implements Insertable<LocalSale> {
  final String id;
  final String folio;
  final int folioNumber;
  final String cashierStaffId;
  final String cashierName;
  final DateTime occurredAt;
  final int grossCents;
  final int discountCents;
  final int totalCents;

  /// The one cash payment: what the customer gave and the change.
  final int tenderedCents;
  final int changeCents;

  /// `COMPLETED`, `PARTIALLY_REFUNDED`, `REFUNDED` or `VOIDED`.
  final String status;
  final int refundedCents;

  /// Lines removed before payment, as the outbox payload's `voidedLines`.
  final String voidedLinesJson;
  const LocalSale({
    required this.id,
    required this.folio,
    required this.folioNumber,
    required this.cashierStaffId,
    required this.cashierName,
    required this.occurredAt,
    required this.grossCents,
    required this.discountCents,
    required this.totalCents,
    required this.tenderedCents,
    required this.changeCents,
    required this.status,
    required this.refundedCents,
    required this.voidedLinesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['folio'] = Variable<String>(folio);
    map['folio_number'] = Variable<int>(folioNumber);
    map['cashier_staff_id'] = Variable<String>(cashierStaffId);
    map['cashier_name'] = Variable<String>(cashierName);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['gross_cents'] = Variable<int>(grossCents);
    map['discount_cents'] = Variable<int>(discountCents);
    map['total_cents'] = Variable<int>(totalCents);
    map['tendered_cents'] = Variable<int>(tenderedCents);
    map['change_cents'] = Variable<int>(changeCents);
    map['status'] = Variable<String>(status);
    map['refunded_cents'] = Variable<int>(refundedCents);
    map['voided_lines_json'] = Variable<String>(voidedLinesJson);
    return map;
  }

  LocalSalesCompanion toCompanion(bool nullToAbsent) {
    return LocalSalesCompanion(
      id: Value(id),
      folio: Value(folio),
      folioNumber: Value(folioNumber),
      cashierStaffId: Value(cashierStaffId),
      cashierName: Value(cashierName),
      occurredAt: Value(occurredAt),
      grossCents: Value(grossCents),
      discountCents: Value(discountCents),
      totalCents: Value(totalCents),
      tenderedCents: Value(tenderedCents),
      changeCents: Value(changeCents),
      status: Value(status),
      refundedCents: Value(refundedCents),
      voidedLinesJson: Value(voidedLinesJson),
    );
  }

  factory LocalSale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSale(
      id: serializer.fromJson<String>(json['id']),
      folio: serializer.fromJson<String>(json['folio']),
      folioNumber: serializer.fromJson<int>(json['folioNumber']),
      cashierStaffId: serializer.fromJson<String>(json['cashierStaffId']),
      cashierName: serializer.fromJson<String>(json['cashierName']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      grossCents: serializer.fromJson<int>(json['grossCents']),
      discountCents: serializer.fromJson<int>(json['discountCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      tenderedCents: serializer.fromJson<int>(json['tenderedCents']),
      changeCents: serializer.fromJson<int>(json['changeCents']),
      status: serializer.fromJson<String>(json['status']),
      refundedCents: serializer.fromJson<int>(json['refundedCents']),
      voidedLinesJson: serializer.fromJson<String>(json['voidedLinesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'folio': serializer.toJson<String>(folio),
      'folioNumber': serializer.toJson<int>(folioNumber),
      'cashierStaffId': serializer.toJson<String>(cashierStaffId),
      'cashierName': serializer.toJson<String>(cashierName),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'grossCents': serializer.toJson<int>(grossCents),
      'discountCents': serializer.toJson<int>(discountCents),
      'totalCents': serializer.toJson<int>(totalCents),
      'tenderedCents': serializer.toJson<int>(tenderedCents),
      'changeCents': serializer.toJson<int>(changeCents),
      'status': serializer.toJson<String>(status),
      'refundedCents': serializer.toJson<int>(refundedCents),
      'voidedLinesJson': serializer.toJson<String>(voidedLinesJson),
    };
  }

  LocalSale copyWith({
    String? id,
    String? folio,
    int? folioNumber,
    String? cashierStaffId,
    String? cashierName,
    DateTime? occurredAt,
    int? grossCents,
    int? discountCents,
    int? totalCents,
    int? tenderedCents,
    int? changeCents,
    String? status,
    int? refundedCents,
    String? voidedLinesJson,
  }) => LocalSale(
    id: id ?? this.id,
    folio: folio ?? this.folio,
    folioNumber: folioNumber ?? this.folioNumber,
    cashierStaffId: cashierStaffId ?? this.cashierStaffId,
    cashierName: cashierName ?? this.cashierName,
    occurredAt: occurredAt ?? this.occurredAt,
    grossCents: grossCents ?? this.grossCents,
    discountCents: discountCents ?? this.discountCents,
    totalCents: totalCents ?? this.totalCents,
    tenderedCents: tenderedCents ?? this.tenderedCents,
    changeCents: changeCents ?? this.changeCents,
    status: status ?? this.status,
    refundedCents: refundedCents ?? this.refundedCents,
    voidedLinesJson: voidedLinesJson ?? this.voidedLinesJson,
  );
  LocalSale copyWithCompanion(LocalSalesCompanion data) {
    return LocalSale(
      id: data.id.present ? data.id.value : this.id,
      folio: data.folio.present ? data.folio.value : this.folio,
      folioNumber: data.folioNumber.present
          ? data.folioNumber.value
          : this.folioNumber,
      cashierStaffId: data.cashierStaffId.present
          ? data.cashierStaffId.value
          : this.cashierStaffId,
      cashierName: data.cashierName.present
          ? data.cashierName.value
          : this.cashierName,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      grossCents: data.grossCents.present
          ? data.grossCents.value
          : this.grossCents,
      discountCents: data.discountCents.present
          ? data.discountCents.value
          : this.discountCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      tenderedCents: data.tenderedCents.present
          ? data.tenderedCents.value
          : this.tenderedCents,
      changeCents: data.changeCents.present
          ? data.changeCents.value
          : this.changeCents,
      status: data.status.present ? data.status.value : this.status,
      refundedCents: data.refundedCents.present
          ? data.refundedCents.value
          : this.refundedCents,
      voidedLinesJson: data.voidedLinesJson.present
          ? data.voidedLinesJson.value
          : this.voidedLinesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSale(')
          ..write('id: $id, ')
          ..write('folio: $folio, ')
          ..write('folioNumber: $folioNumber, ')
          ..write('cashierStaffId: $cashierStaffId, ')
          ..write('cashierName: $cashierName, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('grossCents: $grossCents, ')
          ..write('discountCents: $discountCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('tenderedCents: $tenderedCents, ')
          ..write('changeCents: $changeCents, ')
          ..write('status: $status, ')
          ..write('refundedCents: $refundedCents, ')
          ..write('voidedLinesJson: $voidedLinesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    folio,
    folioNumber,
    cashierStaffId,
    cashierName,
    occurredAt,
    grossCents,
    discountCents,
    totalCents,
    tenderedCents,
    changeCents,
    status,
    refundedCents,
    voidedLinesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSale &&
          other.id == this.id &&
          other.folio == this.folio &&
          other.folioNumber == this.folioNumber &&
          other.cashierStaffId == this.cashierStaffId &&
          other.cashierName == this.cashierName &&
          other.occurredAt == this.occurredAt &&
          other.grossCents == this.grossCents &&
          other.discountCents == this.discountCents &&
          other.totalCents == this.totalCents &&
          other.tenderedCents == this.tenderedCents &&
          other.changeCents == this.changeCents &&
          other.status == this.status &&
          other.refundedCents == this.refundedCents &&
          other.voidedLinesJson == this.voidedLinesJson);
}

class LocalSalesCompanion extends UpdateCompanion<LocalSale> {
  final Value<String> id;
  final Value<String> folio;
  final Value<int> folioNumber;
  final Value<String> cashierStaffId;
  final Value<String> cashierName;
  final Value<DateTime> occurredAt;
  final Value<int> grossCents;
  final Value<int> discountCents;
  final Value<int> totalCents;
  final Value<int> tenderedCents;
  final Value<int> changeCents;
  final Value<String> status;
  final Value<int> refundedCents;
  final Value<String> voidedLinesJson;
  final Value<int> rowid;
  const LocalSalesCompanion({
    this.id = const Value.absent(),
    this.folio = const Value.absent(),
    this.folioNumber = const Value.absent(),
    this.cashierStaffId = const Value.absent(),
    this.cashierName = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.grossCents = const Value.absent(),
    this.discountCents = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.tenderedCents = const Value.absent(),
    this.changeCents = const Value.absent(),
    this.status = const Value.absent(),
    this.refundedCents = const Value.absent(),
    this.voidedLinesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSalesCompanion.insert({
    required String id,
    required String folio,
    required int folioNumber,
    required String cashierStaffId,
    required String cashierName,
    required DateTime occurredAt,
    required int grossCents,
    required int discountCents,
    required int totalCents,
    required int tenderedCents,
    required int changeCents,
    this.status = const Value.absent(),
    this.refundedCents = const Value.absent(),
    this.voidedLinesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       folio = Value(folio),
       folioNumber = Value(folioNumber),
       cashierStaffId = Value(cashierStaffId),
       cashierName = Value(cashierName),
       occurredAt = Value(occurredAt),
       grossCents = Value(grossCents),
       discountCents = Value(discountCents),
       totalCents = Value(totalCents),
       tenderedCents = Value(tenderedCents),
       changeCents = Value(changeCents);
  static Insertable<LocalSale> custom({
    Expression<String>? id,
    Expression<String>? folio,
    Expression<int>? folioNumber,
    Expression<String>? cashierStaffId,
    Expression<String>? cashierName,
    Expression<DateTime>? occurredAt,
    Expression<int>? grossCents,
    Expression<int>? discountCents,
    Expression<int>? totalCents,
    Expression<int>? tenderedCents,
    Expression<int>? changeCents,
    Expression<String>? status,
    Expression<int>? refundedCents,
    Expression<String>? voidedLinesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folio != null) 'folio': folio,
      if (folioNumber != null) 'folio_number': folioNumber,
      if (cashierStaffId != null) 'cashier_staff_id': cashierStaffId,
      if (cashierName != null) 'cashier_name': cashierName,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (grossCents != null) 'gross_cents': grossCents,
      if (discountCents != null) 'discount_cents': discountCents,
      if (totalCents != null) 'total_cents': totalCents,
      if (tenderedCents != null) 'tendered_cents': tenderedCents,
      if (changeCents != null) 'change_cents': changeCents,
      if (status != null) 'status': status,
      if (refundedCents != null) 'refunded_cents': refundedCents,
      if (voidedLinesJson != null) 'voided_lines_json': voidedLinesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSalesCompanion copyWith({
    Value<String>? id,
    Value<String>? folio,
    Value<int>? folioNumber,
    Value<String>? cashierStaffId,
    Value<String>? cashierName,
    Value<DateTime>? occurredAt,
    Value<int>? grossCents,
    Value<int>? discountCents,
    Value<int>? totalCents,
    Value<int>? tenderedCents,
    Value<int>? changeCents,
    Value<String>? status,
    Value<int>? refundedCents,
    Value<String>? voidedLinesJson,
    Value<int>? rowid,
  }) {
    return LocalSalesCompanion(
      id: id ?? this.id,
      folio: folio ?? this.folio,
      folioNumber: folioNumber ?? this.folioNumber,
      cashierStaffId: cashierStaffId ?? this.cashierStaffId,
      cashierName: cashierName ?? this.cashierName,
      occurredAt: occurredAt ?? this.occurredAt,
      grossCents: grossCents ?? this.grossCents,
      discountCents: discountCents ?? this.discountCents,
      totalCents: totalCents ?? this.totalCents,
      tenderedCents: tenderedCents ?? this.tenderedCents,
      changeCents: changeCents ?? this.changeCents,
      status: status ?? this.status,
      refundedCents: refundedCents ?? this.refundedCents,
      voidedLinesJson: voidedLinesJson ?? this.voidedLinesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (folio.present) {
      map['folio'] = Variable<String>(folio.value);
    }
    if (folioNumber.present) {
      map['folio_number'] = Variable<int>(folioNumber.value);
    }
    if (cashierStaffId.present) {
      map['cashier_staff_id'] = Variable<String>(cashierStaffId.value);
    }
    if (cashierName.present) {
      map['cashier_name'] = Variable<String>(cashierName.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (grossCents.present) {
      map['gross_cents'] = Variable<int>(grossCents.value);
    }
    if (discountCents.present) {
      map['discount_cents'] = Variable<int>(discountCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (tenderedCents.present) {
      map['tendered_cents'] = Variable<int>(tenderedCents.value);
    }
    if (changeCents.present) {
      map['change_cents'] = Variable<int>(changeCents.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (refundedCents.present) {
      map['refunded_cents'] = Variable<int>(refundedCents.value);
    }
    if (voidedLinesJson.present) {
      map['voided_lines_json'] = Variable<String>(voidedLinesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSalesCompanion(')
          ..write('id: $id, ')
          ..write('folio: $folio, ')
          ..write('folioNumber: $folioNumber, ')
          ..write('cashierStaffId: $cashierStaffId, ')
          ..write('cashierName: $cashierName, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('grossCents: $grossCents, ')
          ..write('discountCents: $discountCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('tenderedCents: $tenderedCents, ')
          ..write('changeCents: $changeCents, ')
          ..write('status: $status, ')
          ..write('refundedCents: $refundedCents, ')
          ..write('voidedLinesJson: $voidedLinesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSaleLinesTable extends LocalSaleLines
    with TableInfo<$LocalSaleLinesTable, LocalSaleLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSaleLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineNoMeta = const VerificationMeta('lineNo');
  @override
  late final GeneratedColumn<int> lineNo = GeneratedColumn<int>(
    'line_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantNameMeta = const VerificationMeta(
    'variantName',
  );
  @override
  late final GeneratedColumn<String> variantName = GeneratedColumn<String>(
    'variant_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossCentsMeta = const VerificationMeta(
    'grossCents',
  );
  @override
  late final GeneratedColumn<int> grossCents = GeneratedColumn<int>(
    'gross_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineDiscountCentsMeta = const VerificationMeta(
    'lineDiscountCents',
  );
  @override
  late final GeneratedColumn<int> lineDiscountCents = GeneratedColumn<int>(
    'line_discount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderDiscountCentsMeta =
      const VerificationMeta('orderDiscountCents');
  @override
  late final GeneratedColumn<int> orderDiscountCents = GeneratedColumn<int>(
    'order_discount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netCentsMeta = const VerificationMeta(
    'netCents',
  );
  @override
  late final GeneratedColumn<int> netCents = GeneratedColumn<int>(
    'net_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _ivaBpMeta = const VerificationMeta('ivaBp');
  @override
  late final GeneratedColumn<int> ivaBp = GeneratedColumn<int>(
    'iva_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _iepsBpMeta = const VerificationMeta('iepsBp');
  @override
  late final GeneratedColumn<int> iepsBp = GeneratedColumn<int>(
    'ieps_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseCentsMeta = const VerificationMeta(
    'baseCents',
  );
  @override
  late final GeneratedColumn<int> baseCents = GeneratedColumn<int>(
    'base_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iepsCentsMeta = const VerificationMeta(
    'iepsCents',
  );
  @override
  late final GeneratedColumn<int> iepsCents = GeneratedColumn<int>(
    'ieps_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ivaCentsMeta = const VerificationMeta(
    'ivaCents',
  );
  @override
  late final GeneratedColumn<int> ivaCents = GeneratedColumn<int>(
    'iva_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refundedQuantityMeta = const VerificationMeta(
    'refundedQuantity',
  );
  @override
  late final GeneratedColumn<int> refundedQuantity = GeneratedColumn<int>(
    'refunded_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _refundedCentsMeta = const VerificationMeta(
    'refundedCents',
  );
  @override
  late final GeneratedColumn<int> refundedCents = GeneratedColumn<int>(
    'refunded_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    saleId,
    lineNo,
    variantId,
    productName,
    variantName,
    quantity,
    unitPriceCents,
    grossCents,
    lineDiscountCents,
    orderDiscountCents,
    netCents,
    ivaRateId,
    ivaBp,
    iepsRateId,
    iepsBp,
    baseCents,
    iepsCents,
    ivaCents,
    refundedQuantity,
    refundedCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sale_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSaleLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('line_no')) {
      context.handle(
        _lineNoMeta,
        lineNo.isAcceptableOrUnknown(data['line_no']!, _lineNoMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNoMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('variant_name')) {
      context.handle(
        _variantNameMeta,
        variantName.isAcceptableOrUnknown(
          data['variant_name']!,
          _variantNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variantNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('gross_cents')) {
      context.handle(
        _grossCentsMeta,
        grossCents.isAcceptableOrUnknown(data['gross_cents']!, _grossCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_grossCentsMeta);
    }
    if (data.containsKey('line_discount_cents')) {
      context.handle(
        _lineDiscountCentsMeta,
        lineDiscountCents.isAcceptableOrUnknown(
          data['line_discount_cents']!,
          _lineDiscountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineDiscountCentsMeta);
    }
    if (data.containsKey('order_discount_cents')) {
      context.handle(
        _orderDiscountCentsMeta,
        orderDiscountCents.isAcceptableOrUnknown(
          data['order_discount_cents']!,
          _orderDiscountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderDiscountCentsMeta);
    }
    if (data.containsKey('net_cents')) {
      context.handle(
        _netCentsMeta,
        netCents.isAcceptableOrUnknown(data['net_cents']!, _netCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_netCentsMeta);
    }
    if (data.containsKey('iva_rate_id')) {
      context.handle(
        _ivaRateIdMeta,
        ivaRateId.isAcceptableOrUnknown(data['iva_rate_id']!, _ivaRateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ivaRateIdMeta);
    }
    if (data.containsKey('iva_bp')) {
      context.handle(
        _ivaBpMeta,
        ivaBp.isAcceptableOrUnknown(data['iva_bp']!, _ivaBpMeta),
      );
    } else if (isInserting) {
      context.missing(_ivaBpMeta);
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
    if (data.containsKey('ieps_bp')) {
      context.handle(
        _iepsBpMeta,
        iepsBp.isAcceptableOrUnknown(data['ieps_bp']!, _iepsBpMeta),
      );
    } else if (isInserting) {
      context.missing(_iepsBpMeta);
    }
    if (data.containsKey('base_cents')) {
      context.handle(
        _baseCentsMeta,
        baseCents.isAcceptableOrUnknown(data['base_cents']!, _baseCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_baseCentsMeta);
    }
    if (data.containsKey('ieps_cents')) {
      context.handle(
        _iepsCentsMeta,
        iepsCents.isAcceptableOrUnknown(data['ieps_cents']!, _iepsCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_iepsCentsMeta);
    }
    if (data.containsKey('iva_cents')) {
      context.handle(
        _ivaCentsMeta,
        ivaCents.isAcceptableOrUnknown(data['iva_cents']!, _ivaCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_ivaCentsMeta);
    }
    if (data.containsKey('refunded_quantity')) {
      context.handle(
        _refundedQuantityMeta,
        refundedQuantity.isAcceptableOrUnknown(
          data['refunded_quantity']!,
          _refundedQuantityMeta,
        ),
      );
    }
    if (data.containsKey('refunded_cents')) {
      context.handle(
        _refundedCentsMeta,
        refundedCents.isAcceptableOrUnknown(
          data['refunded_cents']!,
          _refundedCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saleId, lineNo};
  @override
  LocalSaleLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSaleLine(
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      lineNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_no'],
      )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      variantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      grossCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_cents'],
      )!,
      lineDiscountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_discount_cents'],
      )!,
      orderDiscountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_discount_cents'],
      )!,
      netCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_cents'],
      )!,
      ivaRateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iva_rate_id'],
      )!,
      ivaBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iva_bp'],
      )!,
      iepsRateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ieps_rate_id'],
      ),
      iepsBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ieps_bp'],
      )!,
      baseCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_cents'],
      )!,
      iepsCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ieps_cents'],
      )!,
      ivaCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iva_cents'],
      )!,
      refundedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refunded_quantity'],
      )!,
      refundedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refunded_cents'],
      )!,
    );
  }

  @override
  $LocalSaleLinesTable createAlias(String alias) {
    return $LocalSaleLinesTable(attachedDatabase, alias);
  }
}

class LocalSaleLine extends DataClass implements Insertable<LocalSaleLine> {
  final String saleId;
  final int lineNo;
  final String variantId;
  final String productName;
  final String variantName;
  final int quantity;
  final int unitPriceCents;
  final int grossCents;
  final int lineDiscountCents;
  final int orderDiscountCents;
  final int netCents;
  final String ivaRateId;
  final int ivaBp;
  final String? iepsRateId;
  final int iepsBp;
  final int baseCents;
  final int iepsCents;
  final int ivaCents;
  final int refundedQuantity;
  final int refundedCents;
  const LocalSaleLine({
    required this.saleId,
    required this.lineNo,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.unitPriceCents,
    required this.grossCents,
    required this.lineDiscountCents,
    required this.orderDiscountCents,
    required this.netCents,
    required this.ivaRateId,
    required this.ivaBp,
    this.iepsRateId,
    required this.iepsBp,
    required this.baseCents,
    required this.iepsCents,
    required this.ivaCents,
    required this.refundedQuantity,
    required this.refundedCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sale_id'] = Variable<String>(saleId);
    map['line_no'] = Variable<int>(lineNo);
    map['variant_id'] = Variable<String>(variantId);
    map['product_name'] = Variable<String>(productName);
    map['variant_name'] = Variable<String>(variantName);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    map['gross_cents'] = Variable<int>(grossCents);
    map['line_discount_cents'] = Variable<int>(lineDiscountCents);
    map['order_discount_cents'] = Variable<int>(orderDiscountCents);
    map['net_cents'] = Variable<int>(netCents);
    map['iva_rate_id'] = Variable<String>(ivaRateId);
    map['iva_bp'] = Variable<int>(ivaBp);
    if (!nullToAbsent || iepsRateId != null) {
      map['ieps_rate_id'] = Variable<String>(iepsRateId);
    }
    map['ieps_bp'] = Variable<int>(iepsBp);
    map['base_cents'] = Variable<int>(baseCents);
    map['ieps_cents'] = Variable<int>(iepsCents);
    map['iva_cents'] = Variable<int>(ivaCents);
    map['refunded_quantity'] = Variable<int>(refundedQuantity);
    map['refunded_cents'] = Variable<int>(refundedCents);
    return map;
  }

  LocalSaleLinesCompanion toCompanion(bool nullToAbsent) {
    return LocalSaleLinesCompanion(
      saleId: Value(saleId),
      lineNo: Value(lineNo),
      variantId: Value(variantId),
      productName: Value(productName),
      variantName: Value(variantName),
      quantity: Value(quantity),
      unitPriceCents: Value(unitPriceCents),
      grossCents: Value(grossCents),
      lineDiscountCents: Value(lineDiscountCents),
      orderDiscountCents: Value(orderDiscountCents),
      netCents: Value(netCents),
      ivaRateId: Value(ivaRateId),
      ivaBp: Value(ivaBp),
      iepsRateId: iepsRateId == null && nullToAbsent
          ? const Value.absent()
          : Value(iepsRateId),
      iepsBp: Value(iepsBp),
      baseCents: Value(baseCents),
      iepsCents: Value(iepsCents),
      ivaCents: Value(ivaCents),
      refundedQuantity: Value(refundedQuantity),
      refundedCents: Value(refundedCents),
    );
  }

  factory LocalSaleLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSaleLine(
      saleId: serializer.fromJson<String>(json['saleId']),
      lineNo: serializer.fromJson<int>(json['lineNo']),
      variantId: serializer.fromJson<String>(json['variantId']),
      productName: serializer.fromJson<String>(json['productName']),
      variantName: serializer.fromJson<String>(json['variantName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      grossCents: serializer.fromJson<int>(json['grossCents']),
      lineDiscountCents: serializer.fromJson<int>(json['lineDiscountCents']),
      orderDiscountCents: serializer.fromJson<int>(json['orderDiscountCents']),
      netCents: serializer.fromJson<int>(json['netCents']),
      ivaRateId: serializer.fromJson<String>(json['ivaRateId']),
      ivaBp: serializer.fromJson<int>(json['ivaBp']),
      iepsRateId: serializer.fromJson<String?>(json['iepsRateId']),
      iepsBp: serializer.fromJson<int>(json['iepsBp']),
      baseCents: serializer.fromJson<int>(json['baseCents']),
      iepsCents: serializer.fromJson<int>(json['iepsCents']),
      ivaCents: serializer.fromJson<int>(json['ivaCents']),
      refundedQuantity: serializer.fromJson<int>(json['refundedQuantity']),
      refundedCents: serializer.fromJson<int>(json['refundedCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saleId': serializer.toJson<String>(saleId),
      'lineNo': serializer.toJson<int>(lineNo),
      'variantId': serializer.toJson<String>(variantId),
      'productName': serializer.toJson<String>(productName),
      'variantName': serializer.toJson<String>(variantName),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'grossCents': serializer.toJson<int>(grossCents),
      'lineDiscountCents': serializer.toJson<int>(lineDiscountCents),
      'orderDiscountCents': serializer.toJson<int>(orderDiscountCents),
      'netCents': serializer.toJson<int>(netCents),
      'ivaRateId': serializer.toJson<String>(ivaRateId),
      'ivaBp': serializer.toJson<int>(ivaBp),
      'iepsRateId': serializer.toJson<String?>(iepsRateId),
      'iepsBp': serializer.toJson<int>(iepsBp),
      'baseCents': serializer.toJson<int>(baseCents),
      'iepsCents': serializer.toJson<int>(iepsCents),
      'ivaCents': serializer.toJson<int>(ivaCents),
      'refundedQuantity': serializer.toJson<int>(refundedQuantity),
      'refundedCents': serializer.toJson<int>(refundedCents),
    };
  }

  LocalSaleLine copyWith({
    String? saleId,
    int? lineNo,
    String? variantId,
    String? productName,
    String? variantName,
    int? quantity,
    int? unitPriceCents,
    int? grossCents,
    int? lineDiscountCents,
    int? orderDiscountCents,
    int? netCents,
    String? ivaRateId,
    int? ivaBp,
    Value<String?> iepsRateId = const Value.absent(),
    int? iepsBp,
    int? baseCents,
    int? iepsCents,
    int? ivaCents,
    int? refundedQuantity,
    int? refundedCents,
  }) => LocalSaleLine(
    saleId: saleId ?? this.saleId,
    lineNo: lineNo ?? this.lineNo,
    variantId: variantId ?? this.variantId,
    productName: productName ?? this.productName,
    variantName: variantName ?? this.variantName,
    quantity: quantity ?? this.quantity,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    grossCents: grossCents ?? this.grossCents,
    lineDiscountCents: lineDiscountCents ?? this.lineDiscountCents,
    orderDiscountCents: orderDiscountCents ?? this.orderDiscountCents,
    netCents: netCents ?? this.netCents,
    ivaRateId: ivaRateId ?? this.ivaRateId,
    ivaBp: ivaBp ?? this.ivaBp,
    iepsRateId: iepsRateId.present ? iepsRateId.value : this.iepsRateId,
    iepsBp: iepsBp ?? this.iepsBp,
    baseCents: baseCents ?? this.baseCents,
    iepsCents: iepsCents ?? this.iepsCents,
    ivaCents: ivaCents ?? this.ivaCents,
    refundedQuantity: refundedQuantity ?? this.refundedQuantity,
    refundedCents: refundedCents ?? this.refundedCents,
  );
  LocalSaleLine copyWithCompanion(LocalSaleLinesCompanion data) {
    return LocalSaleLine(
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      lineNo: data.lineNo.present ? data.lineNo.value : this.lineNo,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      variantName: data.variantName.present
          ? data.variantName.value
          : this.variantName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      grossCents: data.grossCents.present
          ? data.grossCents.value
          : this.grossCents,
      lineDiscountCents: data.lineDiscountCents.present
          ? data.lineDiscountCents.value
          : this.lineDiscountCents,
      orderDiscountCents: data.orderDiscountCents.present
          ? data.orderDiscountCents.value
          : this.orderDiscountCents,
      netCents: data.netCents.present ? data.netCents.value : this.netCents,
      ivaRateId: data.ivaRateId.present ? data.ivaRateId.value : this.ivaRateId,
      ivaBp: data.ivaBp.present ? data.ivaBp.value : this.ivaBp,
      iepsRateId: data.iepsRateId.present
          ? data.iepsRateId.value
          : this.iepsRateId,
      iepsBp: data.iepsBp.present ? data.iepsBp.value : this.iepsBp,
      baseCents: data.baseCents.present ? data.baseCents.value : this.baseCents,
      iepsCents: data.iepsCents.present ? data.iepsCents.value : this.iepsCents,
      ivaCents: data.ivaCents.present ? data.ivaCents.value : this.ivaCents,
      refundedQuantity: data.refundedQuantity.present
          ? data.refundedQuantity.value
          : this.refundedQuantity,
      refundedCents: data.refundedCents.present
          ? data.refundedCents.value
          : this.refundedCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSaleLine(')
          ..write('saleId: $saleId, ')
          ..write('lineNo: $lineNo, ')
          ..write('variantId: $variantId, ')
          ..write('productName: $productName, ')
          ..write('variantName: $variantName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('grossCents: $grossCents, ')
          ..write('lineDiscountCents: $lineDiscountCents, ')
          ..write('orderDiscountCents: $orderDiscountCents, ')
          ..write('netCents: $netCents, ')
          ..write('ivaRateId: $ivaRateId, ')
          ..write('ivaBp: $ivaBp, ')
          ..write('iepsRateId: $iepsRateId, ')
          ..write('iepsBp: $iepsBp, ')
          ..write('baseCents: $baseCents, ')
          ..write('iepsCents: $iepsCents, ')
          ..write('ivaCents: $ivaCents, ')
          ..write('refundedQuantity: $refundedQuantity, ')
          ..write('refundedCents: $refundedCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    saleId,
    lineNo,
    variantId,
    productName,
    variantName,
    quantity,
    unitPriceCents,
    grossCents,
    lineDiscountCents,
    orderDiscountCents,
    netCents,
    ivaRateId,
    ivaBp,
    iepsRateId,
    iepsBp,
    baseCents,
    iepsCents,
    ivaCents,
    refundedQuantity,
    refundedCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSaleLine &&
          other.saleId == this.saleId &&
          other.lineNo == this.lineNo &&
          other.variantId == this.variantId &&
          other.productName == this.productName &&
          other.variantName == this.variantName &&
          other.quantity == this.quantity &&
          other.unitPriceCents == this.unitPriceCents &&
          other.grossCents == this.grossCents &&
          other.lineDiscountCents == this.lineDiscountCents &&
          other.orderDiscountCents == this.orderDiscountCents &&
          other.netCents == this.netCents &&
          other.ivaRateId == this.ivaRateId &&
          other.ivaBp == this.ivaBp &&
          other.iepsRateId == this.iepsRateId &&
          other.iepsBp == this.iepsBp &&
          other.baseCents == this.baseCents &&
          other.iepsCents == this.iepsCents &&
          other.ivaCents == this.ivaCents &&
          other.refundedQuantity == this.refundedQuantity &&
          other.refundedCents == this.refundedCents);
}

class LocalSaleLinesCompanion extends UpdateCompanion<LocalSaleLine> {
  final Value<String> saleId;
  final Value<int> lineNo;
  final Value<String> variantId;
  final Value<String> productName;
  final Value<String> variantName;
  final Value<int> quantity;
  final Value<int> unitPriceCents;
  final Value<int> grossCents;
  final Value<int> lineDiscountCents;
  final Value<int> orderDiscountCents;
  final Value<int> netCents;
  final Value<String> ivaRateId;
  final Value<int> ivaBp;
  final Value<String?> iepsRateId;
  final Value<int> iepsBp;
  final Value<int> baseCents;
  final Value<int> iepsCents;
  final Value<int> ivaCents;
  final Value<int> refundedQuantity;
  final Value<int> refundedCents;
  final Value<int> rowid;
  const LocalSaleLinesCompanion({
    this.saleId = const Value.absent(),
    this.lineNo = const Value.absent(),
    this.variantId = const Value.absent(),
    this.productName = const Value.absent(),
    this.variantName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.grossCents = const Value.absent(),
    this.lineDiscountCents = const Value.absent(),
    this.orderDiscountCents = const Value.absent(),
    this.netCents = const Value.absent(),
    this.ivaRateId = const Value.absent(),
    this.ivaBp = const Value.absent(),
    this.iepsRateId = const Value.absent(),
    this.iepsBp = const Value.absent(),
    this.baseCents = const Value.absent(),
    this.iepsCents = const Value.absent(),
    this.ivaCents = const Value.absent(),
    this.refundedQuantity = const Value.absent(),
    this.refundedCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSaleLinesCompanion.insert({
    required String saleId,
    required int lineNo,
    required String variantId,
    required String productName,
    required String variantName,
    required int quantity,
    required int unitPriceCents,
    required int grossCents,
    required int lineDiscountCents,
    required int orderDiscountCents,
    required int netCents,
    required String ivaRateId,
    required int ivaBp,
    this.iepsRateId = const Value.absent(),
    required int iepsBp,
    required int baseCents,
    required int iepsCents,
    required int ivaCents,
    this.refundedQuantity = const Value.absent(),
    this.refundedCents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : saleId = Value(saleId),
       lineNo = Value(lineNo),
       variantId = Value(variantId),
       productName = Value(productName),
       variantName = Value(variantName),
       quantity = Value(quantity),
       unitPriceCents = Value(unitPriceCents),
       grossCents = Value(grossCents),
       lineDiscountCents = Value(lineDiscountCents),
       orderDiscountCents = Value(orderDiscountCents),
       netCents = Value(netCents),
       ivaRateId = Value(ivaRateId),
       ivaBp = Value(ivaBp),
       iepsBp = Value(iepsBp),
       baseCents = Value(baseCents),
       iepsCents = Value(iepsCents),
       ivaCents = Value(ivaCents);
  static Insertable<LocalSaleLine> custom({
    Expression<String>? saleId,
    Expression<int>? lineNo,
    Expression<String>? variantId,
    Expression<String>? productName,
    Expression<String>? variantName,
    Expression<int>? quantity,
    Expression<int>? unitPriceCents,
    Expression<int>? grossCents,
    Expression<int>? lineDiscountCents,
    Expression<int>? orderDiscountCents,
    Expression<int>? netCents,
    Expression<String>? ivaRateId,
    Expression<int>? ivaBp,
    Expression<String>? iepsRateId,
    Expression<int>? iepsBp,
    Expression<int>? baseCents,
    Expression<int>? iepsCents,
    Expression<int>? ivaCents,
    Expression<int>? refundedQuantity,
    Expression<int>? refundedCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saleId != null) 'sale_id': saleId,
      if (lineNo != null) 'line_no': lineNo,
      if (variantId != null) 'variant_id': variantId,
      if (productName != null) 'product_name': productName,
      if (variantName != null) 'variant_name': variantName,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (grossCents != null) 'gross_cents': grossCents,
      if (lineDiscountCents != null) 'line_discount_cents': lineDiscountCents,
      if (orderDiscountCents != null)
        'order_discount_cents': orderDiscountCents,
      if (netCents != null) 'net_cents': netCents,
      if (ivaRateId != null) 'iva_rate_id': ivaRateId,
      if (ivaBp != null) 'iva_bp': ivaBp,
      if (iepsRateId != null) 'ieps_rate_id': iepsRateId,
      if (iepsBp != null) 'ieps_bp': iepsBp,
      if (baseCents != null) 'base_cents': baseCents,
      if (iepsCents != null) 'ieps_cents': iepsCents,
      if (ivaCents != null) 'iva_cents': ivaCents,
      if (refundedQuantity != null) 'refunded_quantity': refundedQuantity,
      if (refundedCents != null) 'refunded_cents': refundedCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSaleLinesCompanion copyWith({
    Value<String>? saleId,
    Value<int>? lineNo,
    Value<String>? variantId,
    Value<String>? productName,
    Value<String>? variantName,
    Value<int>? quantity,
    Value<int>? unitPriceCents,
    Value<int>? grossCents,
    Value<int>? lineDiscountCents,
    Value<int>? orderDiscountCents,
    Value<int>? netCents,
    Value<String>? ivaRateId,
    Value<int>? ivaBp,
    Value<String?>? iepsRateId,
    Value<int>? iepsBp,
    Value<int>? baseCents,
    Value<int>? iepsCents,
    Value<int>? ivaCents,
    Value<int>? refundedQuantity,
    Value<int>? refundedCents,
    Value<int>? rowid,
  }) {
    return LocalSaleLinesCompanion(
      saleId: saleId ?? this.saleId,
      lineNo: lineNo ?? this.lineNo,
      variantId: variantId ?? this.variantId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      quantity: quantity ?? this.quantity,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      grossCents: grossCents ?? this.grossCents,
      lineDiscountCents: lineDiscountCents ?? this.lineDiscountCents,
      orderDiscountCents: orderDiscountCents ?? this.orderDiscountCents,
      netCents: netCents ?? this.netCents,
      ivaRateId: ivaRateId ?? this.ivaRateId,
      ivaBp: ivaBp ?? this.ivaBp,
      iepsRateId: iepsRateId ?? this.iepsRateId,
      iepsBp: iepsBp ?? this.iepsBp,
      baseCents: baseCents ?? this.baseCents,
      iepsCents: iepsCents ?? this.iepsCents,
      ivaCents: ivaCents ?? this.ivaCents,
      refundedQuantity: refundedQuantity ?? this.refundedQuantity,
      refundedCents: refundedCents ?? this.refundedCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (lineNo.present) {
      map['line_no'] = Variable<int>(lineNo.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (variantName.present) {
      map['variant_name'] = Variable<String>(variantName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (grossCents.present) {
      map['gross_cents'] = Variable<int>(grossCents.value);
    }
    if (lineDiscountCents.present) {
      map['line_discount_cents'] = Variable<int>(lineDiscountCents.value);
    }
    if (orderDiscountCents.present) {
      map['order_discount_cents'] = Variable<int>(orderDiscountCents.value);
    }
    if (netCents.present) {
      map['net_cents'] = Variable<int>(netCents.value);
    }
    if (ivaRateId.present) {
      map['iva_rate_id'] = Variable<String>(ivaRateId.value);
    }
    if (ivaBp.present) {
      map['iva_bp'] = Variable<int>(ivaBp.value);
    }
    if (iepsRateId.present) {
      map['ieps_rate_id'] = Variable<String>(iepsRateId.value);
    }
    if (iepsBp.present) {
      map['ieps_bp'] = Variable<int>(iepsBp.value);
    }
    if (baseCents.present) {
      map['base_cents'] = Variable<int>(baseCents.value);
    }
    if (iepsCents.present) {
      map['ieps_cents'] = Variable<int>(iepsCents.value);
    }
    if (ivaCents.present) {
      map['iva_cents'] = Variable<int>(ivaCents.value);
    }
    if (refundedQuantity.present) {
      map['refunded_quantity'] = Variable<int>(refundedQuantity.value);
    }
    if (refundedCents.present) {
      map['refunded_cents'] = Variable<int>(refundedCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSaleLinesCompanion(')
          ..write('saleId: $saleId, ')
          ..write('lineNo: $lineNo, ')
          ..write('variantId: $variantId, ')
          ..write('productName: $productName, ')
          ..write('variantName: $variantName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('grossCents: $grossCents, ')
          ..write('lineDiscountCents: $lineDiscountCents, ')
          ..write('orderDiscountCents: $orderDiscountCents, ')
          ..write('netCents: $netCents, ')
          ..write('ivaRateId: $ivaRateId, ')
          ..write('ivaBp: $ivaBp, ')
          ..write('iepsRateId: $iepsRateId, ')
          ..write('iepsBp: $iepsBp, ')
          ..write('baseCents: $baseCents, ')
          ..write('iepsCents: $iepsCents, ')
          ..write('ivaCents: $ivaCents, ')
          ..write('refundedQuantity: $refundedQuantity, ')
          ..write('refundedCents: $refundedCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSaleDiscountsTable extends LocalSaleDiscounts
    with TableInfo<$LocalSaleDiscountsTable, LocalSaleDiscount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSaleDiscountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineNoMeta = const VerificationMeta('lineNo');
  @override
  late final GeneratedColumn<int> lineNo = GeneratedColumn<int>(
    'line_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _centsMeta = const VerificationMeta('cents');
  @override
  late final GeneratedColumn<int> cents = GeneratedColumn<int>(
    'cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approverStaffIdMeta = const VerificationMeta(
    'approverStaffId',
  );
  @override
  late final GeneratedColumn<String> approverStaffId = GeneratedColumn<String>(
    'approver_staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    lineNo,
    kind,
    value,
    cents,
    reason,
    note,
    approverStaffId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sale_discounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSaleDiscount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('line_no')) {
      context.handle(
        _lineNoMeta,
        lineNo.isAcceptableOrUnknown(data['line_no']!, _lineNoMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('cents')) {
      context.handle(
        _centsMeta,
        cents.isAcceptableOrUnknown(data['cents']!, _centsMeta),
      );
    } else if (isInserting) {
      context.missing(_centsMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('approver_staff_id')) {
      context.handle(
        _approverStaffIdMeta,
        approverStaffId.isAcceptableOrUnknown(
          data['approver_staff_id']!,
          _approverStaffIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSaleDiscount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSaleDiscount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      lineNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_no'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      cents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cents'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      approverStaffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approver_staff_id'],
      ),
    );
  }

  @override
  $LocalSaleDiscountsTable createAlias(String alias) {
    return $LocalSaleDiscountsTable(attachedDatabase, alias);
  }
}

class LocalSaleDiscount extends DataClass
    implements Insertable<LocalSaleDiscount> {
  final String id;
  final String saleId;

  /// Null for the ticket discount.
  final int? lineNo;
  final String kind;
  final int value;
  final int cents;
  final String reason;
  final String? note;
  final String? approverStaffId;
  const LocalSaleDiscount({
    required this.id,
    required this.saleId,
    this.lineNo,
    required this.kind,
    required this.value,
    required this.cents,
    required this.reason,
    this.note,
    this.approverStaffId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    if (!nullToAbsent || lineNo != null) {
      map['line_no'] = Variable<int>(lineNo);
    }
    map['kind'] = Variable<String>(kind);
    map['value'] = Variable<int>(value);
    map['cents'] = Variable<int>(cents);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || approverStaffId != null) {
      map['approver_staff_id'] = Variable<String>(approverStaffId);
    }
    return map;
  }

  LocalSaleDiscountsCompanion toCompanion(bool nullToAbsent) {
    return LocalSaleDiscountsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      lineNo: lineNo == null && nullToAbsent
          ? const Value.absent()
          : Value(lineNo),
      kind: Value(kind),
      value: Value(value),
      cents: Value(cents),
      reason: Value(reason),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      approverStaffId: approverStaffId == null && nullToAbsent
          ? const Value.absent()
          : Value(approverStaffId),
    );
  }

  factory LocalSaleDiscount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSaleDiscount(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      lineNo: serializer.fromJson<int?>(json['lineNo']),
      kind: serializer.fromJson<String>(json['kind']),
      value: serializer.fromJson<int>(json['value']),
      cents: serializer.fromJson<int>(json['cents']),
      reason: serializer.fromJson<String>(json['reason']),
      note: serializer.fromJson<String?>(json['note']),
      approverStaffId: serializer.fromJson<String?>(json['approverStaffId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'lineNo': serializer.toJson<int?>(lineNo),
      'kind': serializer.toJson<String>(kind),
      'value': serializer.toJson<int>(value),
      'cents': serializer.toJson<int>(cents),
      'reason': serializer.toJson<String>(reason),
      'note': serializer.toJson<String?>(note),
      'approverStaffId': serializer.toJson<String?>(approverStaffId),
    };
  }

  LocalSaleDiscount copyWith({
    String? id,
    String? saleId,
    Value<int?> lineNo = const Value.absent(),
    String? kind,
    int? value,
    int? cents,
    String? reason,
    Value<String?> note = const Value.absent(),
    Value<String?> approverStaffId = const Value.absent(),
  }) => LocalSaleDiscount(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    lineNo: lineNo.present ? lineNo.value : this.lineNo,
    kind: kind ?? this.kind,
    value: value ?? this.value,
    cents: cents ?? this.cents,
    reason: reason ?? this.reason,
    note: note.present ? note.value : this.note,
    approverStaffId: approverStaffId.present
        ? approverStaffId.value
        : this.approverStaffId,
  );
  LocalSaleDiscount copyWithCompanion(LocalSaleDiscountsCompanion data) {
    return LocalSaleDiscount(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      lineNo: data.lineNo.present ? data.lineNo.value : this.lineNo,
      kind: data.kind.present ? data.kind.value : this.kind,
      value: data.value.present ? data.value.value : this.value,
      cents: data.cents.present ? data.cents.value : this.cents,
      reason: data.reason.present ? data.reason.value : this.reason,
      note: data.note.present ? data.note.value : this.note,
      approverStaffId: data.approverStaffId.present
          ? data.approverStaffId.value
          : this.approverStaffId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSaleDiscount(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('lineNo: $lineNo, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('cents: $cents, ')
          ..write('reason: $reason, ')
          ..write('note: $note, ')
          ..write('approverStaffId: $approverStaffId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    lineNo,
    kind,
    value,
    cents,
    reason,
    note,
    approverStaffId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSaleDiscount &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.lineNo == this.lineNo &&
          other.kind == this.kind &&
          other.value == this.value &&
          other.cents == this.cents &&
          other.reason == this.reason &&
          other.note == this.note &&
          other.approverStaffId == this.approverStaffId);
}

class LocalSaleDiscountsCompanion extends UpdateCompanion<LocalSaleDiscount> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<int?> lineNo;
  final Value<String> kind;
  final Value<int> value;
  final Value<int> cents;
  final Value<String> reason;
  final Value<String?> note;
  final Value<String?> approverStaffId;
  final Value<int> rowid;
  const LocalSaleDiscountsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.lineNo = const Value.absent(),
    this.kind = const Value.absent(),
    this.value = const Value.absent(),
    this.cents = const Value.absent(),
    this.reason = const Value.absent(),
    this.note = const Value.absent(),
    this.approverStaffId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSaleDiscountsCompanion.insert({
    required String id,
    required String saleId,
    this.lineNo = const Value.absent(),
    required String kind,
    required int value,
    required int cents,
    required String reason,
    this.note = const Value.absent(),
    this.approverStaffId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       kind = Value(kind),
       value = Value(value),
       cents = Value(cents),
       reason = Value(reason);
  static Insertable<LocalSaleDiscount> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<int>? lineNo,
    Expression<String>? kind,
    Expression<int>? value,
    Expression<int>? cents,
    Expression<String>? reason,
    Expression<String>? note,
    Expression<String>? approverStaffId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (lineNo != null) 'line_no': lineNo,
      if (kind != null) 'kind': kind,
      if (value != null) 'value': value,
      if (cents != null) 'cents': cents,
      if (reason != null) 'reason': reason,
      if (note != null) 'note': note,
      if (approverStaffId != null) 'approver_staff_id': approverStaffId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSaleDiscountsCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<int?>? lineNo,
    Value<String>? kind,
    Value<int>? value,
    Value<int>? cents,
    Value<String>? reason,
    Value<String?>? note,
    Value<String?>? approverStaffId,
    Value<int>? rowid,
  }) {
    return LocalSaleDiscountsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      lineNo: lineNo ?? this.lineNo,
      kind: kind ?? this.kind,
      value: value ?? this.value,
      cents: cents ?? this.cents,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      approverStaffId: approverStaffId ?? this.approverStaffId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (lineNo.present) {
      map['line_no'] = Variable<int>(lineNo.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (cents.present) {
      map['cents'] = Variable<int>(cents.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (approverStaffId.present) {
      map['approver_staff_id'] = Variable<String>(approverStaffId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSaleDiscountsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('lineNo: $lineNo, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('cents: $cents, ')
          ..write('reason: $reason, ')
          ..write('note: $note, ')
          ..write('approverStaffId: $approverStaffId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalHeldTicketsTable extends LocalHeldTickets
    with TableInfo<$LocalHeldTicketsTable, LocalHeldTicket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHeldTicketsTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heldAtMeta = const VerificationMeta('heldAt');
  @override
  late final GeneratedColumn<DateTime> heldAt = GeneratedColumn<DateTime>(
    'held_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heldByStaffIdMeta = const VerificationMeta(
    'heldByStaffId',
  );
  @override
  late final GeneratedColumn<String> heldByStaffId = GeneratedColumn<String>(
    'held_by_staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineCountMeta = const VerificationMeta(
    'lineCount',
  );
  @override
  late final GeneratedColumn<int> lineCount = GeneratedColumn<int>(
    'line_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketJsonMeta = const VerificationMeta(
    'ticketJson',
  );
  @override
  late final GeneratedColumn<String> ticketJson = GeneratedColumn<String>(
    'ticket_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    heldAt,
    heldByStaffId,
    lineCount,
    totalCents,
    ticketJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_held_tickets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalHeldTicket> instance, {
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
    }
    if (data.containsKey('held_at')) {
      context.handle(
        _heldAtMeta,
        heldAt.isAcceptableOrUnknown(data['held_at']!, _heldAtMeta),
      );
    } else if (isInserting) {
      context.missing(_heldAtMeta);
    }
    if (data.containsKey('held_by_staff_id')) {
      context.handle(
        _heldByStaffIdMeta,
        heldByStaffId.isAcceptableOrUnknown(
          data['held_by_staff_id']!,
          _heldByStaffIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_heldByStaffIdMeta);
    }
    if (data.containsKey('line_count')) {
      context.handle(
        _lineCountMeta,
        lineCount.isAcceptableOrUnknown(data['line_count']!, _lineCountMeta),
      );
    } else if (isInserting) {
      context.missing(_lineCountMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('ticket_json')) {
      context.handle(
        _ticketJsonMeta,
        ticketJson.isAcceptableOrUnknown(data['ticket_json']!, _ticketJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_ticketJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHeldTicket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHeldTicket(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      heldAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}held_at'],
      )!,
      heldByStaffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}held_by_staff_id'],
      )!,
      lineCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_count'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      ticketJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_json'],
      )!,
    );
  }

  @override
  $LocalHeldTicketsTable createAlias(String alias) {
    return $LocalHeldTicketsTable(attachedDatabase, alias);
  }
}

class LocalHeldTicket extends DataClass implements Insertable<LocalHeldTicket> {
  final String id;
  final String? name;
  final DateTime heldAt;
  final String heldByStaffId;
  final int lineCount;
  final int totalCents;

  /// The whole ticket (lines with their prices, discounts, voided units).
  final String ticketJson;
  const LocalHeldTicket({
    required this.id,
    this.name,
    required this.heldAt,
    required this.heldByStaffId,
    required this.lineCount,
    required this.totalCents,
    required this.ticketJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['held_at'] = Variable<DateTime>(heldAt);
    map['held_by_staff_id'] = Variable<String>(heldByStaffId);
    map['line_count'] = Variable<int>(lineCount);
    map['total_cents'] = Variable<int>(totalCents);
    map['ticket_json'] = Variable<String>(ticketJson);
    return map;
  }

  LocalHeldTicketsCompanion toCompanion(bool nullToAbsent) {
    return LocalHeldTicketsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      heldAt: Value(heldAt),
      heldByStaffId: Value(heldByStaffId),
      lineCount: Value(lineCount),
      totalCents: Value(totalCents),
      ticketJson: Value(ticketJson),
    );
  }

  factory LocalHeldTicket.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHeldTicket(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      heldAt: serializer.fromJson<DateTime>(json['heldAt']),
      heldByStaffId: serializer.fromJson<String>(json['heldByStaffId']),
      lineCount: serializer.fromJson<int>(json['lineCount']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      ticketJson: serializer.fromJson<String>(json['ticketJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'heldAt': serializer.toJson<DateTime>(heldAt),
      'heldByStaffId': serializer.toJson<String>(heldByStaffId),
      'lineCount': serializer.toJson<int>(lineCount),
      'totalCents': serializer.toJson<int>(totalCents),
      'ticketJson': serializer.toJson<String>(ticketJson),
    };
  }

  LocalHeldTicket copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    DateTime? heldAt,
    String? heldByStaffId,
    int? lineCount,
    int? totalCents,
    String? ticketJson,
  }) => LocalHeldTicket(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    heldAt: heldAt ?? this.heldAt,
    heldByStaffId: heldByStaffId ?? this.heldByStaffId,
    lineCount: lineCount ?? this.lineCount,
    totalCents: totalCents ?? this.totalCents,
    ticketJson: ticketJson ?? this.ticketJson,
  );
  LocalHeldTicket copyWithCompanion(LocalHeldTicketsCompanion data) {
    return LocalHeldTicket(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      heldAt: data.heldAt.present ? data.heldAt.value : this.heldAt,
      heldByStaffId: data.heldByStaffId.present
          ? data.heldByStaffId.value
          : this.heldByStaffId,
      lineCount: data.lineCount.present ? data.lineCount.value : this.lineCount,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      ticketJson: data.ticketJson.present
          ? data.ticketJson.value
          : this.ticketJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHeldTicket(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('heldAt: $heldAt, ')
          ..write('heldByStaffId: $heldByStaffId, ')
          ..write('lineCount: $lineCount, ')
          ..write('totalCents: $totalCents, ')
          ..write('ticketJson: $ticketJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    heldAt,
    heldByStaffId,
    lineCount,
    totalCents,
    ticketJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHeldTicket &&
          other.id == this.id &&
          other.name == this.name &&
          other.heldAt == this.heldAt &&
          other.heldByStaffId == this.heldByStaffId &&
          other.lineCount == this.lineCount &&
          other.totalCents == this.totalCents &&
          other.ticketJson == this.ticketJson);
}

class LocalHeldTicketsCompanion extends UpdateCompanion<LocalHeldTicket> {
  final Value<String> id;
  final Value<String?> name;
  final Value<DateTime> heldAt;
  final Value<String> heldByStaffId;
  final Value<int> lineCount;
  final Value<int> totalCents;
  final Value<String> ticketJson;
  final Value<int> rowid;
  const LocalHeldTicketsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.heldAt = const Value.absent(),
    this.heldByStaffId = const Value.absent(),
    this.lineCount = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.ticketJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalHeldTicketsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    required DateTime heldAt,
    required String heldByStaffId,
    required int lineCount,
    required int totalCents,
    required String ticketJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       heldAt = Value(heldAt),
       heldByStaffId = Value(heldByStaffId),
       lineCount = Value(lineCount),
       totalCents = Value(totalCents),
       ticketJson = Value(ticketJson);
  static Insertable<LocalHeldTicket> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? heldAt,
    Expression<String>? heldByStaffId,
    Expression<int>? lineCount,
    Expression<int>? totalCents,
    Expression<String>? ticketJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (heldAt != null) 'held_at': heldAt,
      if (heldByStaffId != null) 'held_by_staff_id': heldByStaffId,
      if (lineCount != null) 'line_count': lineCount,
      if (totalCents != null) 'total_cents': totalCents,
      if (ticketJson != null) 'ticket_json': ticketJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalHeldTicketsCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<DateTime>? heldAt,
    Value<String>? heldByStaffId,
    Value<int>? lineCount,
    Value<int>? totalCents,
    Value<String>? ticketJson,
    Value<int>? rowid,
  }) {
    return LocalHeldTicketsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      heldAt: heldAt ?? this.heldAt,
      heldByStaffId: heldByStaffId ?? this.heldByStaffId,
      lineCount: lineCount ?? this.lineCount,
      totalCents: totalCents ?? this.totalCents,
      ticketJson: ticketJson ?? this.ticketJson,
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
    if (heldAt.present) {
      map['held_at'] = Variable<DateTime>(heldAt.value);
    }
    if (heldByStaffId.present) {
      map['held_by_staff_id'] = Variable<String>(heldByStaffId.value);
    }
    if (lineCount.present) {
      map['line_count'] = Variable<int>(lineCount.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (ticketJson.present) {
      map['ticket_json'] = Variable<String>(ticketJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHeldTicketsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('heldAt: $heldAt, ')
          ..write('heldByStaffId: $heldByStaffId, ')
          ..write('lineCount: $lineCount, ')
          ..write('totalCents: $totalCents, ')
          ..write('ticketJson: $ticketJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRefundsTable extends LocalRefunds
    with TableInfo<$LocalRefundsTable, LocalRefund> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRefundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folioMeta = const VerificationMeta('folio');
  @override
  late final GeneratedColumn<String> folio = GeneratedColumn<String>(
    'folio',
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
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  static const VerificationMeta _approverStaffIdMeta = const VerificationMeta(
    'approverStaffId',
  );
  @override
  late final GeneratedColumn<String> approverStaffId = GeneratedColumn<String>(
    'approver_staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linesJsonMeta = const VerificationMeta(
    'linesJson',
  );
  @override
  late final GeneratedColumn<String> linesJson = GeneratedColumn<String>(
    'lines_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    folio,
    kind,
    reason,
    note,
    staffId,
    approverStaffId,
    occurredAt,
    totalCents,
    linesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_refunds';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRefund> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('folio')) {
      context.handle(
        _folioMeta,
        folio.isAcceptableOrUnknown(data['folio']!, _folioMeta),
      );
    } else if (isInserting) {
      context.missing(_folioMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('approver_staff_id')) {
      context.handle(
        _approverStaffIdMeta,
        approverStaffId.isAcceptableOrUnknown(
          data['approver_staff_id']!,
          _approverStaffIdMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('lines_json')) {
      context.handle(
        _linesJsonMeta,
        linesJson.isAcceptableOrUnknown(data['lines_json']!, _linesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_linesJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRefund map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRefund(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      folio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folio'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      approverStaffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approver_staff_id'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      linesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lines_json'],
      )!,
    );
  }

  @override
  $LocalRefundsTable createAlias(String alias) {
    return $LocalRefundsTable(attachedDatabase, alias);
  }
}

class LocalRefund extends DataClass implements Insertable<LocalRefund> {
  final String id;
  final String saleId;
  final String folio;

  /// `REFUND` or `VOID`.
  final String kind;
  final String reason;
  final String? note;
  final String staffId;
  final String? approverStaffId;
  final DateTime occurredAt;
  final int totalCents;

  /// The refund lines, as the outbox payload's `lines`.
  final String linesJson;
  const LocalRefund({
    required this.id,
    required this.saleId,
    required this.folio,
    required this.kind,
    required this.reason,
    this.note,
    required this.staffId,
    this.approverStaffId,
    required this.occurredAt,
    required this.totalCents,
    required this.linesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['folio'] = Variable<String>(folio);
    map['kind'] = Variable<String>(kind);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['staff_id'] = Variable<String>(staffId);
    if (!nullToAbsent || approverStaffId != null) {
      map['approver_staff_id'] = Variable<String>(approverStaffId);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['total_cents'] = Variable<int>(totalCents);
    map['lines_json'] = Variable<String>(linesJson);
    return map;
  }

  LocalRefundsCompanion toCompanion(bool nullToAbsent) {
    return LocalRefundsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      folio: Value(folio),
      kind: Value(kind),
      reason: Value(reason),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      staffId: Value(staffId),
      approverStaffId: approverStaffId == null && nullToAbsent
          ? const Value.absent()
          : Value(approverStaffId),
      occurredAt: Value(occurredAt),
      totalCents: Value(totalCents),
      linesJson: Value(linesJson),
    );
  }

  factory LocalRefund.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRefund(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      folio: serializer.fromJson<String>(json['folio']),
      kind: serializer.fromJson<String>(json['kind']),
      reason: serializer.fromJson<String>(json['reason']),
      note: serializer.fromJson<String?>(json['note']),
      staffId: serializer.fromJson<String>(json['staffId']),
      approverStaffId: serializer.fromJson<String?>(json['approverStaffId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      linesJson: serializer.fromJson<String>(json['linesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'folio': serializer.toJson<String>(folio),
      'kind': serializer.toJson<String>(kind),
      'reason': serializer.toJson<String>(reason),
      'note': serializer.toJson<String?>(note),
      'staffId': serializer.toJson<String>(staffId),
      'approverStaffId': serializer.toJson<String?>(approverStaffId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'totalCents': serializer.toJson<int>(totalCents),
      'linesJson': serializer.toJson<String>(linesJson),
    };
  }

  LocalRefund copyWith({
    String? id,
    String? saleId,
    String? folio,
    String? kind,
    String? reason,
    Value<String?> note = const Value.absent(),
    String? staffId,
    Value<String?> approverStaffId = const Value.absent(),
    DateTime? occurredAt,
    int? totalCents,
    String? linesJson,
  }) => LocalRefund(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    folio: folio ?? this.folio,
    kind: kind ?? this.kind,
    reason: reason ?? this.reason,
    note: note.present ? note.value : this.note,
    staffId: staffId ?? this.staffId,
    approverStaffId: approverStaffId.present
        ? approverStaffId.value
        : this.approverStaffId,
    occurredAt: occurredAt ?? this.occurredAt,
    totalCents: totalCents ?? this.totalCents,
    linesJson: linesJson ?? this.linesJson,
  );
  LocalRefund copyWithCompanion(LocalRefundsCompanion data) {
    return LocalRefund(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      folio: data.folio.present ? data.folio.value : this.folio,
      kind: data.kind.present ? data.kind.value : this.kind,
      reason: data.reason.present ? data.reason.value : this.reason,
      note: data.note.present ? data.note.value : this.note,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      approverStaffId: data.approverStaffId.present
          ? data.approverStaffId.value
          : this.approverStaffId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      linesJson: data.linesJson.present ? data.linesJson.value : this.linesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRefund(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('folio: $folio, ')
          ..write('kind: $kind, ')
          ..write('reason: $reason, ')
          ..write('note: $note, ')
          ..write('staffId: $staffId, ')
          ..write('approverStaffId: $approverStaffId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('totalCents: $totalCents, ')
          ..write('linesJson: $linesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    folio,
    kind,
    reason,
    note,
    staffId,
    approverStaffId,
    occurredAt,
    totalCents,
    linesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRefund &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.folio == this.folio &&
          other.kind == this.kind &&
          other.reason == this.reason &&
          other.note == this.note &&
          other.staffId == this.staffId &&
          other.approverStaffId == this.approverStaffId &&
          other.occurredAt == this.occurredAt &&
          other.totalCents == this.totalCents &&
          other.linesJson == this.linesJson);
}

class LocalRefundsCompanion extends UpdateCompanion<LocalRefund> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> folio;
  final Value<String> kind;
  final Value<String> reason;
  final Value<String?> note;
  final Value<String> staffId;
  final Value<String?> approverStaffId;
  final Value<DateTime> occurredAt;
  final Value<int> totalCents;
  final Value<String> linesJson;
  final Value<int> rowid;
  const LocalRefundsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.folio = const Value.absent(),
    this.kind = const Value.absent(),
    this.reason = const Value.absent(),
    this.note = const Value.absent(),
    this.staffId = const Value.absent(),
    this.approverStaffId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.linesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRefundsCompanion.insert({
    required String id,
    required String saleId,
    required String folio,
    required String kind,
    required String reason,
    this.note = const Value.absent(),
    required String staffId,
    this.approverStaffId = const Value.absent(),
    required DateTime occurredAt,
    required int totalCents,
    required String linesJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       folio = Value(folio),
       kind = Value(kind),
       reason = Value(reason),
       staffId = Value(staffId),
       occurredAt = Value(occurredAt),
       totalCents = Value(totalCents),
       linesJson = Value(linesJson);
  static Insertable<LocalRefund> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? folio,
    Expression<String>? kind,
    Expression<String>? reason,
    Expression<String>? note,
    Expression<String>? staffId,
    Expression<String>? approverStaffId,
    Expression<DateTime>? occurredAt,
    Expression<int>? totalCents,
    Expression<String>? linesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (folio != null) 'folio': folio,
      if (kind != null) 'kind': kind,
      if (reason != null) 'reason': reason,
      if (note != null) 'note': note,
      if (staffId != null) 'staff_id': staffId,
      if (approverStaffId != null) 'approver_staff_id': approverStaffId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (totalCents != null) 'total_cents': totalCents,
      if (linesJson != null) 'lines_json': linesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRefundsCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? folio,
    Value<String>? kind,
    Value<String>? reason,
    Value<String?>? note,
    Value<String>? staffId,
    Value<String?>? approverStaffId,
    Value<DateTime>? occurredAt,
    Value<int>? totalCents,
    Value<String>? linesJson,
    Value<int>? rowid,
  }) {
    return LocalRefundsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      folio: folio ?? this.folio,
      kind: kind ?? this.kind,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      staffId: staffId ?? this.staffId,
      approverStaffId: approverStaffId ?? this.approverStaffId,
      occurredAt: occurredAt ?? this.occurredAt,
      totalCents: totalCents ?? this.totalCents,
      linesJson: linesJson ?? this.linesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (folio.present) {
      map['folio'] = Variable<String>(folio.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (approverStaffId.present) {
      map['approver_staff_id'] = Variable<String>(approverStaffId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (linesJson.present) {
      map['lines_json'] = Variable<String>(linesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRefundsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('folio: $folio, ')
          ..write('kind: $kind, ')
          ..write('reason: $reason, ')
          ..write('note: $note, ')
          ..write('staffId: $staffId, ')
          ..write('approverStaffId: $approverStaffId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('totalCents: $totalCents, ')
          ..write('linesJson: $linesJson, ')
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
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $LocalSalesTable localSales = $LocalSalesTable(this);
  late final $LocalSaleLinesTable localSaleLines = $LocalSaleLinesTable(this);
  late final $LocalSaleDiscountsTable localSaleDiscounts =
      $LocalSaleDiscountsTable(this);
  late final $LocalHeldTicketsTable localHeldTickets = $LocalHeldTicketsTable(
    this,
  );
  late final $LocalRefundsTable localRefunds = $LocalRefundsTable(this);
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
    outboxEntries,
    localSales,
    localSaleLines,
    localSaleDiscounts,
    localHeldTickets,
    localRefunds,
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
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      required String id,
      required String type,
      required DateTime occurredAt,
      Value<String?> actorStaffId,
      required String payload,
      Value<int> attempts,
      Value<String> status,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String?> actorStaffId,
      Value<String> payload,
      Value<int> attempts,
      Value<String> status,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorStaffId => $composableBuilder(
    column: $table.actorStaffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorStaffId => $composableBuilder(
    column: $table.actorStaffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorStaffId => $composableBuilder(
    column: $table.actorStaffId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntry,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> actorStaffId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEntriesCompanion(
                id: id,
                type: type,
                occurredAt: occurredAt,
                actorStaffId: actorStaffId,
                payload: payload,
                attempts: attempts,
                status: status,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required DateTime occurredAt,
                Value<String?> actorStaffId = const Value.absent(),
                required String payload,
                Value<int> attempts = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                id: id,
                type: type,
                occurredAt: occurredAt,
                actorStaffId: actorStaffId,
                payload: payload,
                attempts: attempts,
                status: status,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxEntriesTable, OutboxEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OutboxEntriesTable,
                    OutboxEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntry,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntry,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
      ),
      OutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$LocalSalesTableCreateCompanionBuilder = LocalSalesCompanion Function({
  required String id,
  required String folio,
  required int folioNumber,
  required String cashierStaffId,
  required String cashierName,
  required DateTime occurredAt,
  required int grossCents,
  required int discountCents,
  required int totalCents,
  required int tenderedCents,
  required int changeCents,
  Value<String> status,
  Value<int> refundedCents,
  Value<String> voidedLinesJson,
  Value<int> rowid,
});
typedef $$LocalSalesTableUpdateCompanionBuilder = LocalSalesCompanion Function({
  Value<String> id,
  Value<String> folio,
  Value<int> folioNumber,
  Value<String> cashierStaffId,
  Value<String> cashierName,
  Value<DateTime> occurredAt,
  Value<int> grossCents,
  Value<int> discountCents,
  Value<int> totalCents,
  Value<int> tenderedCents,
  Value<int> changeCents,
  Value<String> status,
  Value<int> refundedCents,
  Value<String> voidedLinesJson,
  Value<int> rowid,
});

class $$LocalSalesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSalesTable> {
  $$LocalSalesTableFilterComposer({
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

  ColumnFilters<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get folioNumber => $composableBuilder(
    column: $table.folioNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierStaffId => $composableBuilder(
    column: $table.cashierStaffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierName => $composableBuilder(
    column: $table.cashierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountCents => $composableBuilder(
    column: $table.discountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tenderedCents => $composableBuilder(
    column: $table.tenderedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changeCents => $composableBuilder(
    column: $table.changeCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refundedCents => $composableBuilder(
    column: $table.refundedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidedLinesJson => $composableBuilder(
    column: $table.voidedLinesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSalesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSalesTable> {
  $$LocalSalesTableOrderingComposer({
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

  ColumnOrderings<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get folioNumber => $composableBuilder(
    column: $table.folioNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierStaffId => $composableBuilder(
    column: $table.cashierStaffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierName => $composableBuilder(
    column: $table.cashierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountCents => $composableBuilder(
    column: $table.discountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tenderedCents => $composableBuilder(
    column: $table.tenderedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changeCents => $composableBuilder(
    column: $table.changeCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refundedCents => $composableBuilder(
    column: $table.refundedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidedLinesJson => $composableBuilder(
    column: $table.voidedLinesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSalesTable> {
  $$LocalSalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get folio =>
      $composableBuilder(column: $table.folio, builder: (column) => column);

  GeneratedColumn<int> get folioNumber => $composableBuilder(
    column: $table.folioNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cashierStaffId => $composableBuilder(
    column: $table.cashierStaffId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cashierName => $composableBuilder(
    column: $table.cashierName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountCents => $composableBuilder(
    column: $table.discountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tenderedCents => $composableBuilder(
    column: $table.tenderedCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get changeCents => $composableBuilder(
    column: $table.changeCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get refundedCents => $composableBuilder(
    column: $table.refundedCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voidedLinesJson => $composableBuilder(
    column: $table.voidedLinesJson,
    builder: (column) => column,
  );
}

class $$LocalSalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSalesTable,
          LocalSale,
          $$LocalSalesTableFilterComposer,
          $$LocalSalesTableOrderingComposer,
          $$LocalSalesTableAnnotationComposer,
          $$LocalSalesTableCreateCompanionBuilder,
          $$LocalSalesTableUpdateCompanionBuilder,
          (
            LocalSale,
            BaseReferences<_$AppDatabase, $LocalSalesTable, LocalSale>,
          ),
          LocalSale,
          PrefetchHooks Function()
        > {
  $$LocalSalesTableTableManager(_$AppDatabase db, $LocalSalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> folio = const Value.absent(),
                Value<int> folioNumber = const Value.absent(),
                Value<String> cashierStaffId = const Value.absent(),
                Value<String> cashierName = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> grossCents = const Value.absent(),
                Value<int> discountCents = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<int> tenderedCents = const Value.absent(),
                Value<int> changeCents = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> refundedCents = const Value.absent(),
                Value<String> voidedLinesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSalesCompanion(
                id: id,
                folio: folio,
                folioNumber: folioNumber,
                cashierStaffId: cashierStaffId,
                cashierName: cashierName,
                occurredAt: occurredAt,
                grossCents: grossCents,
                discountCents: discountCents,
                totalCents: totalCents,
                tenderedCents: tenderedCents,
                changeCents: changeCents,
                status: status,
                refundedCents: refundedCents,
                voidedLinesJson: voidedLinesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String folio,
                required int folioNumber,
                required String cashierStaffId,
                required String cashierName,
                required DateTime occurredAt,
                required int grossCents,
                required int discountCents,
                required int totalCents,
                required int tenderedCents,
                required int changeCents,
                Value<String> status = const Value.absent(),
                Value<int> refundedCents = const Value.absent(),
                Value<String> voidedLinesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSalesCompanion.insert(
                id: id,
                folio: folio,
                folioNumber: folioNumber,
                cashierStaffId: cashierStaffId,
                cashierName: cashierName,
                occurredAt: occurredAt,
                grossCents: grossCents,
                discountCents: discountCents,
                totalCents: totalCents,
                tenderedCents: tenderedCents,
                changeCents: changeCents,
                status: status,
                refundedCents: refundedCents,
                voidedLinesJson: voidedLinesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSalesTable, LocalSale>(table),
                  BaseReferences<_$AppDatabase, $LocalSalesTable, LocalSale>(
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

typedef $$LocalSalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSalesTable,
      LocalSale,
      $$LocalSalesTableFilterComposer,
      $$LocalSalesTableOrderingComposer,
      $$LocalSalesTableAnnotationComposer,
      $$LocalSalesTableCreateCompanionBuilder,
      $$LocalSalesTableUpdateCompanionBuilder,
      (LocalSale, BaseReferences<_$AppDatabase, $LocalSalesTable, LocalSale>),
      LocalSale,
      PrefetchHooks Function()
    >;
typedef $$LocalSaleLinesTableCreateCompanionBuilder =
    LocalSaleLinesCompanion Function({
      required String saleId,
      required int lineNo,
      required String variantId,
      required String productName,
      required String variantName,
      required int quantity,
      required int unitPriceCents,
      required int grossCents,
      required int lineDiscountCents,
      required int orderDiscountCents,
      required int netCents,
      required String ivaRateId,
      required int ivaBp,
      Value<String?> iepsRateId,
      required int iepsBp,
      required int baseCents,
      required int iepsCents,
      required int ivaCents,
      Value<int> refundedQuantity,
      Value<int> refundedCents,
      Value<int> rowid,
    });
typedef $$LocalSaleLinesTableUpdateCompanionBuilder =
    LocalSaleLinesCompanion Function({
      Value<String> saleId,
      Value<int> lineNo,
      Value<String> variantId,
      Value<String> productName,
      Value<String> variantName,
      Value<int> quantity,
      Value<int> unitPriceCents,
      Value<int> grossCents,
      Value<int> lineDiscountCents,
      Value<int> orderDiscountCents,
      Value<int> netCents,
      Value<String> ivaRateId,
      Value<int> ivaBp,
      Value<String?> iepsRateId,
      Value<int> iepsBp,
      Value<int> baseCents,
      Value<int> iepsCents,
      Value<int> ivaCents,
      Value<int> refundedQuantity,
      Value<int> refundedCents,
      Value<int> rowid,
    });

class $$LocalSaleLinesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSaleLinesTable> {
  $$LocalSaleLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantName => $composableBuilder(
    column: $table.variantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineDiscountCents => $composableBuilder(
    column: $table.lineDiscountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderDiscountCents => $composableBuilder(
    column: $table.orderDiscountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netCents => $composableBuilder(
    column: $table.netCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ivaRateId => $composableBuilder(
    column: $table.ivaRateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ivaBp => $composableBuilder(
    column: $table.ivaBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iepsRateId => $composableBuilder(
    column: $table.iepsRateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iepsBp => $composableBuilder(
    column: $table.iepsBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseCents => $composableBuilder(
    column: $table.baseCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iepsCents => $composableBuilder(
    column: $table.iepsCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ivaCents => $composableBuilder(
    column: $table.ivaCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refundedQuantity => $composableBuilder(
    column: $table.refundedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refundedCents => $composableBuilder(
    column: $table.refundedCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSaleLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSaleLinesTable> {
  $$LocalSaleLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantName => $composableBuilder(
    column: $table.variantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineDiscountCents => $composableBuilder(
    column: $table.lineDiscountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderDiscountCents => $composableBuilder(
    column: $table.orderDiscountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netCents => $composableBuilder(
    column: $table.netCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ivaRateId => $composableBuilder(
    column: $table.ivaRateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ivaBp => $composableBuilder(
    column: $table.ivaBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iepsRateId => $composableBuilder(
    column: $table.iepsRateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iepsBp => $composableBuilder(
    column: $table.iepsBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseCents => $composableBuilder(
    column: $table.baseCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iepsCents => $composableBuilder(
    column: $table.iepsCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ivaCents => $composableBuilder(
    column: $table.ivaCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refundedQuantity => $composableBuilder(
    column: $table.refundedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refundedCents => $composableBuilder(
    column: $table.refundedCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSaleLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSaleLinesTable> {
  $$LocalSaleLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<int> get lineNo =>
      $composableBuilder(column: $table.lineNo, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variantName => $composableBuilder(
    column: $table.variantName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineDiscountCents => $composableBuilder(
    column: $table.lineDiscountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderDiscountCents => $composableBuilder(
    column: $table.orderDiscountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get netCents =>
      $composableBuilder(column: $table.netCents, builder: (column) => column);

  GeneratedColumn<String> get ivaRateId =>
      $composableBuilder(column: $table.ivaRateId, builder: (column) => column);

  GeneratedColumn<int> get ivaBp =>
      $composableBuilder(column: $table.ivaBp, builder: (column) => column);

  GeneratedColumn<String> get iepsRateId => $composableBuilder(
    column: $table.iepsRateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iepsBp =>
      $composableBuilder(column: $table.iepsBp, builder: (column) => column);

  GeneratedColumn<int> get baseCents =>
      $composableBuilder(column: $table.baseCents, builder: (column) => column);

  GeneratedColumn<int> get iepsCents =>
      $composableBuilder(column: $table.iepsCents, builder: (column) => column);

  GeneratedColumn<int> get ivaCents =>
      $composableBuilder(column: $table.ivaCents, builder: (column) => column);

  GeneratedColumn<int> get refundedQuantity => $composableBuilder(
    column: $table.refundedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refundedCents => $composableBuilder(
    column: $table.refundedCents,
    builder: (column) => column,
  );
}

class $$LocalSaleLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSaleLinesTable,
          LocalSaleLine,
          $$LocalSaleLinesTableFilterComposer,
          $$LocalSaleLinesTableOrderingComposer,
          $$LocalSaleLinesTableAnnotationComposer,
          $$LocalSaleLinesTableCreateCompanionBuilder,
          $$LocalSaleLinesTableUpdateCompanionBuilder,
          (
            LocalSaleLine,
            BaseReferences<_$AppDatabase, $LocalSaleLinesTable, LocalSaleLine>,
          ),
          LocalSaleLine,
          PrefetchHooks Function()
        > {
  $$LocalSaleLinesTableTableManager(
    _$AppDatabase db,
    $LocalSaleLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSaleLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSaleLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSaleLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saleId = const Value.absent(),
                Value<int> lineNo = const Value.absent(),
                Value<String> variantId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> variantName = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> grossCents = const Value.absent(),
                Value<int> lineDiscountCents = const Value.absent(),
                Value<int> orderDiscountCents = const Value.absent(),
                Value<int> netCents = const Value.absent(),
                Value<String> ivaRateId = const Value.absent(),
                Value<int> ivaBp = const Value.absent(),
                Value<String?> iepsRateId = const Value.absent(),
                Value<int> iepsBp = const Value.absent(),
                Value<int> baseCents = const Value.absent(),
                Value<int> iepsCents = const Value.absent(),
                Value<int> ivaCents = const Value.absent(),
                Value<int> refundedQuantity = const Value.absent(),
                Value<int> refundedCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSaleLinesCompanion(
                saleId: saleId,
                lineNo: lineNo,
                variantId: variantId,
                productName: productName,
                variantName: variantName,
                quantity: quantity,
                unitPriceCents: unitPriceCents,
                grossCents: grossCents,
                lineDiscountCents: lineDiscountCents,
                orderDiscountCents: orderDiscountCents,
                netCents: netCents,
                ivaRateId: ivaRateId,
                ivaBp: ivaBp,
                iepsRateId: iepsRateId,
                iepsBp: iepsBp,
                baseCents: baseCents,
                iepsCents: iepsCents,
                ivaCents: ivaCents,
                refundedQuantity: refundedQuantity,
                refundedCents: refundedCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saleId,
                required int lineNo,
                required String variantId,
                required String productName,
                required String variantName,
                required int quantity,
                required int unitPriceCents,
                required int grossCents,
                required int lineDiscountCents,
                required int orderDiscountCents,
                required int netCents,
                required String ivaRateId,
                required int ivaBp,
                Value<String?> iepsRateId = const Value.absent(),
                required int iepsBp,
                required int baseCents,
                required int iepsCents,
                required int ivaCents,
                Value<int> refundedQuantity = const Value.absent(),
                Value<int> refundedCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSaleLinesCompanion.insert(
                saleId: saleId,
                lineNo: lineNo,
                variantId: variantId,
                productName: productName,
                variantName: variantName,
                quantity: quantity,
                unitPriceCents: unitPriceCents,
                grossCents: grossCents,
                lineDiscountCents: lineDiscountCents,
                orderDiscountCents: orderDiscountCents,
                netCents: netCents,
                ivaRateId: ivaRateId,
                ivaBp: ivaBp,
                iepsRateId: iepsRateId,
                iepsBp: iepsBp,
                baseCents: baseCents,
                iepsCents: iepsCents,
                ivaCents: ivaCents,
                refundedQuantity: refundedQuantity,
                refundedCents: refundedCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSaleLinesTable, LocalSaleLine>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalSaleLinesTable,
                    LocalSaleLine
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSaleLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSaleLinesTable,
      LocalSaleLine,
      $$LocalSaleLinesTableFilterComposer,
      $$LocalSaleLinesTableOrderingComposer,
      $$LocalSaleLinesTableAnnotationComposer,
      $$LocalSaleLinesTableCreateCompanionBuilder,
      $$LocalSaleLinesTableUpdateCompanionBuilder,
      (
        LocalSaleLine,
        BaseReferences<_$AppDatabase, $LocalSaleLinesTable, LocalSaleLine>,
      ),
      LocalSaleLine,
      PrefetchHooks Function()
    >;
typedef $$LocalSaleDiscountsTableCreateCompanionBuilder =
    LocalSaleDiscountsCompanion Function({
      required String id,
      required String saleId,
      Value<int?> lineNo,
      required String kind,
      required int value,
      required int cents,
      required String reason,
      Value<String?> note,
      Value<String?> approverStaffId,
      Value<int> rowid,
    });
typedef $$LocalSaleDiscountsTableUpdateCompanionBuilder =
    LocalSaleDiscountsCompanion Function({
      Value<String> id,
      Value<String> saleId,
      Value<int?> lineNo,
      Value<String> kind,
      Value<int> value,
      Value<int> cents,
      Value<String> reason,
      Value<String?> note,
      Value<String?> approverStaffId,
      Value<int> rowid,
    });

class $$LocalSaleDiscountsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSaleDiscountsTable> {
  $$LocalSaleDiscountsTableFilterComposer({
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

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cents => $composableBuilder(
    column: $table.cents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approverStaffId => $composableBuilder(
    column: $table.approverStaffId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSaleDiscountsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSaleDiscountsTable> {
  $$LocalSaleDiscountsTableOrderingComposer({
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

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cents => $composableBuilder(
    column: $table.cents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approverStaffId => $composableBuilder(
    column: $table.approverStaffId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSaleDiscountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSaleDiscountsTable> {
  $$LocalSaleDiscountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<int> get lineNo =>
      $composableBuilder(column: $table.lineNo, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get cents =>
      $composableBuilder(column: $table.cents, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get approverStaffId => $composableBuilder(
    column: $table.approverStaffId,
    builder: (column) => column,
  );
}

class $$LocalSaleDiscountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSaleDiscountsTable,
          LocalSaleDiscount,
          $$LocalSaleDiscountsTableFilterComposer,
          $$LocalSaleDiscountsTableOrderingComposer,
          $$LocalSaleDiscountsTableAnnotationComposer,
          $$LocalSaleDiscountsTableCreateCompanionBuilder,
          $$LocalSaleDiscountsTableUpdateCompanionBuilder,
          (
            LocalSaleDiscount,
            BaseReferences<
              _$AppDatabase,
              $LocalSaleDiscountsTable,
              LocalSaleDiscount
            >,
          ),
          LocalSaleDiscount,
          PrefetchHooks Function()
        > {
  $$LocalSaleDiscountsTableTableManager(
    _$AppDatabase db,
    $LocalSaleDiscountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSaleDiscountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSaleDiscountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSaleDiscountsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<int?> lineNo = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> cents = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> approverStaffId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSaleDiscountsCompanion(
                id: id,
                saleId: saleId,
                lineNo: lineNo,
                kind: kind,
                value: value,
                cents: cents,
                reason: reason,
                note: note,
                approverStaffId: approverStaffId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                Value<int?> lineNo = const Value.absent(),
                required String kind,
                required int value,
                required int cents,
                required String reason,
                Value<String?> note = const Value.absent(),
                Value<String?> approverStaffId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSaleDiscountsCompanion.insert(
                id: id,
                saleId: saleId,
                lineNo: lineNo,
                kind: kind,
                value: value,
                cents: cents,
                reason: reason,
                note: note,
                approverStaffId: approverStaffId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSaleDiscountsTable, LocalSaleDiscount>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalSaleDiscountsTable,
                    LocalSaleDiscount
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSaleDiscountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSaleDiscountsTable,
      LocalSaleDiscount,
      $$LocalSaleDiscountsTableFilterComposer,
      $$LocalSaleDiscountsTableOrderingComposer,
      $$LocalSaleDiscountsTableAnnotationComposer,
      $$LocalSaleDiscountsTableCreateCompanionBuilder,
      $$LocalSaleDiscountsTableUpdateCompanionBuilder,
      (
        LocalSaleDiscount,
        BaseReferences<
          _$AppDatabase,
          $LocalSaleDiscountsTable,
          LocalSaleDiscount
        >,
      ),
      LocalSaleDiscount,
      PrefetchHooks Function()
    >;
typedef $$LocalHeldTicketsTableCreateCompanionBuilder =
    LocalHeldTicketsCompanion Function({
      required String id,
      Value<String?> name,
      required DateTime heldAt,
      required String heldByStaffId,
      required int lineCount,
      required int totalCents,
      required String ticketJson,
      Value<int> rowid,
    });
typedef $$LocalHeldTicketsTableUpdateCompanionBuilder =
    LocalHeldTicketsCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<DateTime> heldAt,
      Value<String> heldByStaffId,
      Value<int> lineCount,
      Value<int> totalCents,
      Value<String> ticketJson,
      Value<int> rowid,
    });

class $$LocalHeldTicketsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalHeldTicketsTable> {
  $$LocalHeldTicketsTableFilterComposer({
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

  ColumnFilters<DateTime> get heldAt => $composableBuilder(
    column: $table.heldAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heldByStaffId => $composableBuilder(
    column: $table.heldByStaffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineCount => $composableBuilder(
    column: $table.lineCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticketJson => $composableBuilder(
    column: $table.ticketJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalHeldTicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalHeldTicketsTable> {
  $$LocalHeldTicketsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get heldAt => $composableBuilder(
    column: $table.heldAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heldByStaffId => $composableBuilder(
    column: $table.heldByStaffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineCount => $composableBuilder(
    column: $table.lineCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticketJson => $composableBuilder(
    column: $table.ticketJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalHeldTicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalHeldTicketsTable> {
  $$LocalHeldTicketsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get heldAt =>
      $composableBuilder(column: $table.heldAt, builder: (column) => column);

  GeneratedColumn<String> get heldByStaffId => $composableBuilder(
    column: $table.heldByStaffId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineCount =>
      $composableBuilder(column: $table.lineCount, builder: (column) => column);

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ticketJson => $composableBuilder(
    column: $table.ticketJson,
    builder: (column) => column,
  );
}

class $$LocalHeldTicketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalHeldTicketsTable,
          LocalHeldTicket,
          $$LocalHeldTicketsTableFilterComposer,
          $$LocalHeldTicketsTableOrderingComposer,
          $$LocalHeldTicketsTableAnnotationComposer,
          $$LocalHeldTicketsTableCreateCompanionBuilder,
          $$LocalHeldTicketsTableUpdateCompanionBuilder,
          (
            LocalHeldTicket,
            BaseReferences<
              _$AppDatabase,
              $LocalHeldTicketsTable,
              LocalHeldTicket
            >,
          ),
          LocalHeldTicket,
          PrefetchHooks Function()
        > {
  $$LocalHeldTicketsTableTableManager(
    _$AppDatabase db,
    $LocalHeldTicketsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalHeldTicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalHeldTicketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalHeldTicketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<DateTime> heldAt = const Value.absent(),
                Value<String> heldByStaffId = const Value.absent(),
                Value<int> lineCount = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<String> ticketJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalHeldTicketsCompanion(
                id: id,
                name: name,
                heldAt: heldAt,
                heldByStaffId: heldByStaffId,
                lineCount: lineCount,
                totalCents: totalCents,
                ticketJson: ticketJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                required DateTime heldAt,
                required String heldByStaffId,
                required int lineCount,
                required int totalCents,
                required String ticketJson,
                Value<int> rowid = const Value.absent(),
              }) => LocalHeldTicketsCompanion.insert(
                id: id,
                name: name,
                heldAt: heldAt,
                heldByStaffId: heldByStaffId,
                lineCount: lineCount,
                totalCents: totalCents,
                ticketJson: ticketJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalHeldTicketsTable, LocalHeldTicket>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalHeldTicketsTable,
                    LocalHeldTicket
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalHeldTicketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalHeldTicketsTable,
      LocalHeldTicket,
      $$LocalHeldTicketsTableFilterComposer,
      $$LocalHeldTicketsTableOrderingComposer,
      $$LocalHeldTicketsTableAnnotationComposer,
      $$LocalHeldTicketsTableCreateCompanionBuilder,
      $$LocalHeldTicketsTableUpdateCompanionBuilder,
      (
        LocalHeldTicket,
        BaseReferences<_$AppDatabase, $LocalHeldTicketsTable, LocalHeldTicket>,
      ),
      LocalHeldTicket,
      PrefetchHooks Function()
    >;
typedef $$LocalRefundsTableCreateCompanionBuilder =
    LocalRefundsCompanion Function({
      required String id,
      required String saleId,
      required String folio,
      required String kind,
      required String reason,
      Value<String?> note,
      required String staffId,
      Value<String?> approverStaffId,
      required DateTime occurredAt,
      required int totalCents,
      required String linesJson,
      Value<int> rowid,
    });
typedef $$LocalRefundsTableUpdateCompanionBuilder =
    LocalRefundsCompanion Function({
      Value<String> id,
      Value<String> saleId,
      Value<String> folio,
      Value<String> kind,
      Value<String> reason,
      Value<String?> note,
      Value<String> staffId,
      Value<String?> approverStaffId,
      Value<DateTime> occurredAt,
      Value<int> totalCents,
      Value<String> linesJson,
      Value<int> rowid,
    });

class $$LocalRefundsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRefundsTable> {
  $$LocalRefundsTableFilterComposer({
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

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approverStaffId => $composableBuilder(
    column: $table.approverStaffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linesJson => $composableBuilder(
    column: $table.linesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRefundsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRefundsTable> {
  $$LocalRefundsTableOrderingComposer({
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

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approverStaffId => $composableBuilder(
    column: $table.approverStaffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linesJson => $composableBuilder(
    column: $table.linesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRefundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRefundsTable> {
  $$LocalRefundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get folio =>
      $composableBuilder(column: $table.folio, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get approverStaffId => $composableBuilder(
    column: $table.approverStaffId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linesJson =>
      $composableBuilder(column: $table.linesJson, builder: (column) => column);
}

class $$LocalRefundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRefundsTable,
          LocalRefund,
          $$LocalRefundsTableFilterComposer,
          $$LocalRefundsTableOrderingComposer,
          $$LocalRefundsTableAnnotationComposer,
          $$LocalRefundsTableCreateCompanionBuilder,
          $$LocalRefundsTableUpdateCompanionBuilder,
          (
            LocalRefund,
            BaseReferences<_$AppDatabase, $LocalRefundsTable, LocalRefund>,
          ),
          LocalRefund,
          PrefetchHooks Function()
        > {
  $$LocalRefundsTableTableManager(_$AppDatabase db, $LocalRefundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRefundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRefundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRefundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> folio = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> staffId = const Value.absent(),
                Value<String?> approverStaffId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<String> linesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRefundsCompanion(
                id: id,
                saleId: saleId,
                folio: folio,
                kind: kind,
                reason: reason,
                note: note,
                staffId: staffId,
                approverStaffId: approverStaffId,
                occurredAt: occurredAt,
                totalCents: totalCents,
                linesJson: linesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                required String folio,
                required String kind,
                required String reason,
                Value<String?> note = const Value.absent(),
                required String staffId,
                Value<String?> approverStaffId = const Value.absent(),
                required DateTime occurredAt,
                required int totalCents,
                required String linesJson,
                Value<int> rowid = const Value.absent(),
              }) => LocalRefundsCompanion.insert(
                id: id,
                saleId: saleId,
                folio: folio,
                kind: kind,
                reason: reason,
                note: note,
                staffId: staffId,
                approverStaffId: approverStaffId,
                occurredAt: occurredAt,
                totalCents: totalCents,
                linesJson: linesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalRefundsTable, LocalRefund>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalRefundsTable,
                    LocalRefund
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRefundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRefundsTable,
      LocalRefund,
      $$LocalRefundsTableFilterComposer,
      $$LocalRefundsTableOrderingComposer,
      $$LocalRefundsTableAnnotationComposer,
      $$LocalRefundsTableCreateCompanionBuilder,
      $$LocalRefundsTableUpdateCompanionBuilder,
      (
        LocalRefund,
        BaseReferences<_$AppDatabase, $LocalRefundsTable, LocalRefund>,
      ),
      LocalRefund,
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
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$LocalSalesTableTableManager get localSales =>
      $$LocalSalesTableTableManager(_db, _db.localSales);
  $$LocalSaleLinesTableTableManager get localSaleLines =>
      $$LocalSaleLinesTableTableManager(_db, _db.localSaleLines);
  $$LocalSaleDiscountsTableTableManager get localSaleDiscounts =>
      $$LocalSaleDiscountsTableTableManager(_db, _db.localSaleDiscounts);
  $$LocalHeldTicketsTableTableManager get localHeldTickets =>
      $$LocalHeldTicketsTableTableManager(_db, _db.localHeldTickets);
  $$LocalRefundsTableTableManager get localRefunds =>
      $$LocalRefundsTableTableManager(_db, _db.localRefunds);
}
