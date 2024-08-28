// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineTicketModel _$OfflineTicketModelFromJson(Map<String, dynamic> json) =>
    OfflineTicketModel(
      branchInfo:
          BranchInfoModel.fromJson(json['branch'] as Map<String, dynamic>),
      order: (json['order'] as num).toInt(),
      products: (json['products'] as List<dynamic>)
          .map((e) => TicketProductsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      isOffline: json['is_offline'] as bool?,
      date: json['date'] as String,
    );

Map<String, dynamic> _$OfflineTicketModelToJson(OfflineTicketModel instance) =>
    <String, dynamic>{
      'branch': instance.branchInfo.toJson(),
      'products': instance.products.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'date': instance.date,
      'order': instance.order,
      'is_offline': instance.isOffline,
    };
