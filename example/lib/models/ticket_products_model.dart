// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

// ignore: depend_on_referenced_packages
import 'ticket_product_modifier_model.dart';

part 'ticket_products_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketProductsModel {
  @override
  @JsonKey(name: "product_name")
  final String productName;

  @override
  @JsonKey(name: "modifiers")
  final List<TicketProductModifierModel>? modifier;

  @override
  @JsonKey(name: "quantity")
  final int quantity;

  @override
  @JsonKey(name: "price")
  final double price;

  const TicketProductsModel(
      {required this.price,
      required this.productName,
      required this.quantity,
      this.modifier});

  factory TicketProductsModel.fromJson(Map<String, dynamic> json) =>
      _$TicketProductsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketProductsModelToJson(this);

  static Future<TicketProductsModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      TicketProductsModel.fromJson(json);
}
