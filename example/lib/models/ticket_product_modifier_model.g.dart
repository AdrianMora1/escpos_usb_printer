// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_product_modifier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketProductModifierModel _$TicketProductModifierModelFromJson(
        Map<String, dynamic> json) =>
    TicketProductModifierModel(
      price: (json['price'] as num).toInt(),
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$TicketProductModifierModelToJson(
        TicketProductModifierModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'quantity': instance.quantity,
    };
