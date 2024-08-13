// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KitchenTicketProductModel _$KitchenTicketProductModelFromJson(
        Map<String, dynamic> json) =>
    KitchenTicketProductModel(
      productName: json['product_name'] as String,
      modifiers: (json['modifiers'] as List<dynamic>?)
          ?.map((e) => KitchenTicketProductModifiersModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$KitchenTicketProductModelToJson(
        KitchenTicketProductModel instance) =>
    <String, dynamic>{
      'product_name': instance.productName,
      'modifiers': instance.modifiers?.map((e) => e.toJson()).toList(),
      'quantity': instance.quantity,
    };
