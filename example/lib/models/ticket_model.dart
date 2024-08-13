// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';
import 'package:escpos_usb_printer_example/models/products_model.dart';

import 'branch_info_model.dart';

part 'ticket_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketModel {
  @override
  @JsonKey(name: "branch")
  final BranchInfoModel branchInfoModel;

  @override
  @JsonKey(name: "products")
  final List<ProductsModel> productsModel;

  @override
  @JsonKey(name: "total")
  final double total;

  @override
  @JsonKey(name: "order")
  final int order;

  @override
  @JsonKey(name: "is_offline")
  final bool isOffline;

  const TicketModel(
      {required this.branchInfoModel,
      required this.order,
      required this.productsModel,
      required this.total,
      required this.isOffline});

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketModelToJson(this);

  static Future<TicketModel> fromJsonModel(Map<String, dynamic> json) async =>
      TicketModel.fromJson(json);
}
