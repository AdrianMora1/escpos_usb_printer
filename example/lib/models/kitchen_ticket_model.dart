// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

import 'kitchen_ticket_product_model.dart';

// ignore: depend_on_referenced_packages

part 'kitchen_ticket_model.g.dart';

@JsonSerializable(explicitToJson: true)
class KitchenTicketModel {
  @override
  @JsonKey(name: "products")
  final List<KitchenTicketProductModel> products;

  @override
  @JsonKey(name: "order")
  final int order;

  @override
  @JsonKey(name: "date")
  final String date;

  const KitchenTicketModel({
    required this.products,
    required this.order,
    required this.date,
  });

  factory KitchenTicketModel.fromJson(Map<String, dynamic> json) =>
      _$KitchenTicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$KitchenTicketModelToJson(this);

  static Future<KitchenTicketModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      KitchenTicketModel.fromJson(json);
}
