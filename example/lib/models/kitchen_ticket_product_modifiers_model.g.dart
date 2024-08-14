// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket_product_modifiers_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KitchenTicketProductModifiersModel _$KitchenTicketProductModifiersModelFromJson(
        Map<String, dynamic> json) =>
    KitchenTicketProductModifiersModel(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$KitchenTicketProductModifiersModelToJson(
        KitchenTicketProductModifiersModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
    };
