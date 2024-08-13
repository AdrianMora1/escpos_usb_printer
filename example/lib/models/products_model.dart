// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part 'products_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductsModel {
  @override
  @JsonKey(name: "product_name")
  final String productName;

  @override
  @JsonKey(name: "quantity")
  final int quantity;

  @override
  @JsonKey(name: "price")
  final double price;

  const ProductsModel(
      {required this.price, required this.productName, required this.quantity});

  factory ProductsModel.fromJson(Map<String, dynamic> json) =>
      _$ProductsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsModelToJson(this);

  static Future<ProductsModel> fromJsonModel(Map<String, dynamic> json) async =>
      ProductsModel.fromJson(json);
}
