class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String action;
  final String details;
  final String category; // 'AUTH', 'POS', 'PRODUCCION', 'RH', 'CAJA'

  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.action,
    required this.details,
    this.category = 'POS',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'user_id': userId,
    'user_name': userName,
    'action': action,
    'details': details,
    'category': category,
  };

  factory AuditLogEntry.fromMap(Map<String, dynamic> map) {
    return AuditLogEntry(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      action: map['action'] as String,
      details: map['details'] as String,
      category: (map['category'] ?? 'POS') as String,
    );
  }
}
