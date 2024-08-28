// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

import 'branch_info_model.dart';
// ignore: depend_on_referenced_packages
import 'ticket_products_model.dart';

part 'offline_ticket_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OfflineTicketModel {
  @override
  @JsonKey(name: "branch")
  final BranchInfoModel branchInfo;

  @override
  @JsonKey(name: "products")
  final List<TicketProductsModel> products;

  @override
  @JsonKey(name: "total")
  final double total;

  @override
  @JsonKey(name: "date")
  final String date;

  @override
  @JsonKey(name: "order")
  final int order;

  @override
  @JsonKey(name: "is_offline")
  final bool? isOffline;

  const OfflineTicketModel(
      {required this.branchInfo,
      required this.order,
      required this.products,
      required this.total,
      this.isOffline,
      required this.date});

  factory OfflineTicketModel.fromJson(Map<String, dynamic> json) =>
      _$OfflineTicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfflineTicketModelToJson(this);

  static Future<OfflineTicketModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      OfflineTicketModel.fromJson(json);
}
