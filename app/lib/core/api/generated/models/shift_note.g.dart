// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftNote _$ShiftNoteFromJson(Map<String, dynamic> json) => ShiftNote(
  staffId: json['staffId'] as String,
  note: json['note'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ShiftNoteToJson(ShiftNote instance) => <String, dynamic>{
  'staffId': instance.staffId,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
};
