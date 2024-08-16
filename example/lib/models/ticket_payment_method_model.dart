// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part 'ticket_payment_method_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketPaymentMethodModel {
  @override
  @JsonKey(name: "payment")
  final String payment;

  @override
  @JsonKey(name: "amount")
  final double amount;

  const TicketPaymentMethodModel({
    required this.amount,
    required this.payment,
  });

  factory TicketPaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$TicketPaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketPaymentMethodModelToJson(this);

  static Future<TicketPaymentMethodModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      TicketPaymentMethodModel.fromJson(json);
}
