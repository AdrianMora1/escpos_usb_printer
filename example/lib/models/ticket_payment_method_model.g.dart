// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketPaymentMethodModel _$TicketPaymentMethodModelFromJson(
        Map<String, dynamic> json) =>
    TicketPaymentMethodModel(
      amount: (json['amount'] as num).toDouble(),
      payment: json['payment'] as String,
    );

Map<String, dynamic> _$TicketPaymentMethodModelToJson(
        TicketPaymentMethodModel instance) =>
    <String, dynamic>{
      'payment': instance.payment,
      'amount': instance.amount,
    };
