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

  const BranchInfoModel({required this.address, required this.name});

  factory BranchInfoModel.fromJson(Map<String, dynamic> json) =>
      _$BranchInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchInfoModelToJson(this);

  static Future<BranchInfoModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      BranchInfoModel.fromJson(json);
}
