// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

import 'kitchen_ticket_product_modifiers_model.dart';

// ignore: depend_on_referenced_packages

part 'kitchen_ticket_product_model.g.dart';

@JsonSerializable(explicitToJson: true)
class KitchenTicketProductModel {
  @override
  @JsonKey(name: "product_name")
  final String productName;

  @override
  @JsonKey(name: "modifiers")
  final List<KitchenTicketProductModifiersModel>? modifiers;

  @override
  @JsonKey(name: "quantity")
  final int quantity;

  const KitchenTicketProductModel({
    required this.productName,
    this.modifiers,
    required this.quantity,
  });

  factory KitchenTicketProductModel.fromJson(Map<String, dynamic> json) =>
      _$KitchenTicketProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$KitchenTicketProductModelToJson(this);

  static Future<KitchenTicketProductModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      KitchenTicketProductModel.fromJson(json);
}
