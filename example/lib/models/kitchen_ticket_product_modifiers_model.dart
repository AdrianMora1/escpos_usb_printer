// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part 'kitchen_ticket_product_modifiers_model.g.dart';

@JsonSerializable(explicitToJson: true)
class KitchenTicketProductModifiersModel {
  @override
  @JsonKey(name: "name")
  final String name;

  const KitchenTicketProductModifiersModel({
    required this.name,
  });

  factory KitchenTicketProductModifiersModel.fromJson(
          Map<String, dynamic> json) =>
      _$KitchenTicketProductModifiersModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$KitchenTicketProductModifiersModelToJson(this);

  static Future<KitchenTicketProductModifiersModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      KitchenTicketProductModifiersModel.fromJson(json);
}
