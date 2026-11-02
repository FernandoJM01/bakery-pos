// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'v1_shifts_shift_id_notes_request_body.g.dart';

@JsonSerializable()
class V1ShiftsShiftIdNotesRequestBody {
  const V1ShiftsShiftIdNotesRequestBody({required this.note});

  factory V1ShiftsShiftIdNotesRequestBody.fromJson(Map<String, Object?> json) =>
      _$V1ShiftsShiftIdNotesRequestBodyFromJson(json);

  final String note;

  Map<String, Object?> toJson() =>
      _$V1ShiftsShiftIdNotesRequestBodyToJson(this);
}
