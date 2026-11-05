// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';

part 'transfer_line.g.dart';

@JsonSerializable()
class TransferLine {
  const TransferLine({
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.producedOn,
    required this.quantitySent,
    this.quantityReceived,
  });

  factory TransferLine.fromJson(Map<String, Object?> json) =>
      _$TransferLineFromJson(json);

  final String variantId;
  final String productName;
  final String variantName;
  final LocalDate producedOn;
  final int quantitySent;
  final int? quantityReceived;

  Map<String, Object?> toJson() => _$TransferLineToJson(this);
}
