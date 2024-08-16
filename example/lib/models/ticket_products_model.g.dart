// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_products_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketProductsModel _$TicketProductsModelFromJson(Map<String, dynamic> json) =>
    TicketProductsModel(
      price: (json['price'] as num).toDouble(),
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      modifier: (json['modifiers'] as List<dynamic>?)
          ?.map((e) =>
              TicketProductModifierModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TicketProductsModelToJson(
        TicketProductsModel instance) =>
    <String, dynamic>{
      'product_name': instance.productName,
      'modifiers': instance.modifier?.map((e) => e.toJson()).toList(),
      'quantity': instance.quantity,
      'price': instance.price,
    };
