// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part 'kitchen_ticket_product_modifiers_model.g.dart';

@JsonSerializable(explicitToJson: true)
class KitchenTicketProductModifiersModel {
  @override
  @JsonKey(name: "name")
  final String name;

  @override
  @JsonKey(name: "quantity")
  final int quantity;

  const KitchenTicketProductModifiersModel(
      {required this.name, required this.quantity});

  factory KitchenTicketProductModifiersModel.fromJson(
          Map<String, dynamic> json) =>
      _$KitchenTicketProductModifiersModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$KitchenTicketProductModifiersModelToJson(this);

  static Future<KitchenTicketProductModifiersModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      KitchenTicketProductModifiersModel.fromJson(json);
}
