// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'basis_points.dart';
import 'cents.dart';

part 'order_ticket_line.g.dart';

@JsonSerializable()
class OrderTicketLine {
  const OrderTicketLine({
    required this.lineNo,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.unitPriceCents,
    required this.ivaRateId,
    required this.ivaBp,
    required this.iepsRateId,
    required this.iepsBp,
  });

  factory OrderTicketLine.fromJson(Map<String, Object?> json) =>
      _$OrderTicketLineFromJson(json);

  final int lineNo;
  final String variantId;
  final String productName;
  final String variantName;
  final int quantity;
  final Cents unitPriceCents;
  final String ivaRateId;
  final BasisPoints ivaBp;
  final String? iepsRateId;
  final BasisPoints iepsBp;

  Map<String, Object?> toJson() => _$OrderTicketLineToJson(this);
}
