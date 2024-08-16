// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part 'branch_info_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BranchInfoModel {
  @override
  @JsonKey(name: "name")
  final String name;

  @override
  @JsonKey(name: "address")
  final String address;

  @override
  @JsonKey(name: "city")
  final String city;

  @override
  @JsonKey(name: "postal_code")
  final int postalCode;

  @override
  @JsonKey(name: "phone")
  final String phone;

  const BranchInfoModel(
      {required this.address,
      required this.name,
      required this.city,
      required this.phone,
      required this.postalCode});

  factory BranchInfoModel.fromJson(Map<String, dynamic> json) =>
      _$BranchInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchInfoModelToJson(this);

  static Future<BranchInfoModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      BranchInfoModel.fromJson(json);
}
