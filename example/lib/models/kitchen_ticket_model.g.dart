// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KitchenTicketModel _$KitchenTicketModelFromJson(Map<String, dynamic> json) =>
    KitchenTicketModel(
      products: (json['products'] as List<dynamic>)
          .map((e) =>
              KitchenTicketProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      order: (json['order'] as num).toInt(),
      date: json['date'] as String,
    );

Map<String, dynamic> _$KitchenTicketModelToJson(KitchenTicketModel instance) =>
    <String, dynamic>{
      'products': instance.products.map((e) => e.toJson()).toList(),
      'order': instance.order,
      'date': instance.date,
    };
