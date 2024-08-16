// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketModel _$TicketModelFromJson(Map<String, dynamic> json) => TicketModel(
      branchInfo:
          BranchInfoModel.fromJson(json['branch'] as Map<String, dynamic>),
      orderId: (json['order'] as num).toInt(),
      products: (json['products'] as List<dynamic>)
          .map((e) => TicketProductsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      isOffline: json['is_offline'] as bool?,
      session:
          SessionInfoModel.fromJson(json['session'] as Map<String, dynamic>),
      discount: (json['discount'] as num).toDouble(),
      subTotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      urlInvoice: json['url_invoice'] as String,
      paymentMethods: (json['payment_methods'] as List<dynamic>)
          .map((e) =>
              TicketPaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalInWords: json['total_in_words'] as String,
      date: json['date'] as String,
      rfc: json['rfc'] as String,
    );

Map<String, dynamic> _$TicketModelToJson(TicketModel instance) =>
    <String, dynamic>{
      'branch': instance.branchInfo.toJson(),
      'session': instance.session.toJson(),
      'products': instance.products.map((e) => e.toJson()).toList(),
      'subtotal': instance.subTotal,
      'tax': instance.tax,
      'discount': instance.discount,
      'total': instance.total,
      'payment_methods':
          instance.paymentMethods.map((e) => e.toJson()).toList(),
      'total_in_words': instance.totalInWords,
      'url_invoice': instance.urlInvoice,
      'order': instance.orderId,
      'rfc': instance.rfc,
      'date': instance.date,
      'is_offline': instance.isOffline,
    };
