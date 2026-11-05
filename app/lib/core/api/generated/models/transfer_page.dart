// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'transfer.dart';

part 'transfer_page.g.dart';

@JsonSerializable()
class TransferPage {
  const TransferPage({required this.items, required this.nextCursor});

  factory TransferPage.fromJson(Map<String, Object?> json) =>
      _$TransferPageFromJson(json);

  final List<Transfer> items;
  final String? nextCursor;

  Map<String, Object?> toJson() => _$TransferPageToJson(this);
}
