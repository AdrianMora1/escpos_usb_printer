// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

import 'branch_info_model.dart';
import 'session_info_model.dart';
import 'ticket_payment_method_model.dart';
// ignore: depend_on_referenced_packages
import 'ticket_products_model.dart';

part 'ticket_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketModel {
  @override
  @JsonKey(name: "branch")
  final BranchInfoModel branchInfo;

  @override
  @JsonKey(name: "session")
  final SessionInfoModel session;

  @override
  @JsonKey(name: "products")
  final List<TicketProductsModel> products;

  @override
  @JsonKey(name: "subtotal")
  final double subTotal;

  @override
  @JsonKey(name: "tax")
  final double tax;

  @override
  @JsonKey(name: "discount")
  final double discount;

  @override
  @JsonKey(name: "total")
  final double total;

  @override
  @JsonKey(name: "payment_methods")
  final List<TicketPaymentMethodModel> paymentMethods;

  @override
  @JsonKey(name: "total_in_words")
  final String totalInWords;

  @override
  @JsonKey(name: "url_invoice")
  final String urlInvoice;

  @override
  @JsonKey(name: "order")
  final int orderId;

  @override
  @JsonKey(name: "rfc")
  final String rfc;

  @override
  @JsonKey(name: "date")
  final String date;

  @override
  @JsonKey(name: "is_offline")
  final bool? isOffline;

  const TicketModel(
      {required this.branchInfo,
      required this.orderId,
      required this.products,
      required this.total,
      this.isOffline,
      required this.session,
      required this.discount,
      required this.subTotal,
      required this.tax,
      required this.urlInvoice,
      required this.paymentMethods,
      required this.totalInWords,
      required this.date,
      required this.rfc});

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketModelToJson(this);

  static Future<TicketModel> fromJsonModel(Map<String, dynamic> json) async =>
      TicketModel.fromJson(json);
}
