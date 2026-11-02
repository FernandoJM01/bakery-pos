// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'shift_note.g.dart';

@JsonSerializable()
class ShiftNote {
  const ShiftNote({
    required this.staffId,
    required this.note,
    required this.createdAt,
  });

  factory ShiftNote.fromJson(Map<String, Object?> json) =>
      _$ShiftNoteFromJson(json);

  final String staffId;
  final String note;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$ShiftNoteToJson(this);
}
