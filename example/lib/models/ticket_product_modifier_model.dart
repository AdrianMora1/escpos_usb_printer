// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part 'ticket_product_modifier_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketProductModifierModel {
  @override
  @JsonKey(name: "name")
  final String name;

  @override
  @JsonKey(name: "price")
  final int price;

  @override
  @JsonKey(name: "quantity")
  final int quantity;

  const TicketProductModifierModel(
      {required this.price, required this.name, required this.quantity});

  factory TicketProductModifierModel.fromJson(Map<String, dynamic> json) =>
      _$TicketProductModifierModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketProductModifierModelToJson(this);

  static Future<TicketProductModifierModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      TicketProductModifierModel.fromJson(json);
}
