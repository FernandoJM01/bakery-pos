enum BakeBatchStatus {
  fermenting('En Fermentación'),
  baking('En Horno'),
  cooling('Enfriamiento'),
  readyInShowcase('En Vitrina (Listo)');

  final String label;
  const BakeBatchStatus(this.label);
}

class BakeBatch {
  final String id;
  final String batchNumber;
  final String productName;
  final String productSku;
  final String ovenName;
  final int targetUnits;
  final int completedUnits;
  final int wasteUnits;
  final String? wasteReason;
  final BakeBatchStatus status;
  final int tempCelsius;
  final int minutesRemaining;
  final String scheduledShift;

  const BakeBatch({
    required this.id,
    required this.batchNumber,
    required this.productName,
    required this.productSku,
    required this.ovenName,
    required this.targetUnits,
    this.completedUnits = 0,
    this.wasteUnits = 0,
    this.wasteReason,
    this.status = BakeBatchStatus.fermenting,
    required this.tempCelsius,
    required this.minutesRemaining,
    required this.scheduledShift,
  });

  BakeBatch copyWith({
    String? id,
    String? batchNumber,
    String? productName,
    String? productSku,
    String? ovenName,
    int? targetUnits,
    int? completedUnits,
    int? wasteUnits,
    String? wasteReason,
    BakeBatchStatus? status,
    int? tempCelsius,
    int? minutesRemaining,
    String? scheduledShift,
  }) {
    return BakeBatch(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      ovenName: ovenName ?? this.ovenName,
      targetUnits: targetUnits ?? this.targetUnits,
      completedUnits: completedUnits ?? this.completedUnits,
      wasteUnits: wasteUnits ?? this.wasteUnits,
      wasteReason: wasteReason ?? this.wasteReason,
      status: status ?? this.status,
      tempCelsius: tempCelsius ?? this.tempCelsius,
      minutesRemaining: minutesRemaining ?? this.minutesRemaining,
      scheduledShift: scheduledShift ?? this.scheduledShift,
    );
  }
}
