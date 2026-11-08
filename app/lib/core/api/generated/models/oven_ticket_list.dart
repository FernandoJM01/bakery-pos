// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'oven_branch_state.dart';
import 'oven_ticket.dart';

part 'oven_ticket_list.g.dart';

@JsonSerializable()
class OvenTicketList {
  const OvenTicketList({required this.branches, required this.items});

  factory OvenTicketList.fromJson(Map<String, Object?> json) =>
      _$OvenTicketListFromJson(json);

  final List<OvenBranchState> branches;
  final List<OvenTicket> items;

  Map<String, Object?> toJson() => _$OvenTicketListToJson(this);
}
