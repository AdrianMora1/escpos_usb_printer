// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchInfoModel _$BranchInfoModelFromJson(Map<String, dynamic> json) =>
    BranchInfoModel(
      address: json['address'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String,
      postalCode: (json['postal_code'] as num).toInt(),
    );

Map<String, dynamic> _$BranchInfoModelToJson(BranchInfoModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'postal_code': instance.postalCode,
      'phone': instance.phone,
    };
