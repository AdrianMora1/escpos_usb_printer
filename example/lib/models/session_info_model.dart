// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part 'session_info_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SessionInfoModel {
  @override
  @JsonKey(name: "user")
  final String user;

  @override
  @JsonKey(name: "line")
  final String line;

  @override
  @JsonKey(name: "line_id")
  final int lineId;

  @override
  @JsonKey(name: "session_id")
  final int sessionId;

  const SessionInfoModel({
    required this.line,
    required this.lineId,
    required this.sessionId,
    required this.user,
  });

  factory SessionInfoModel.fromJson(Map<String, dynamic> json) =>
      _$SessionInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionInfoModelToJson(this);

  static Future<SessionInfoModel> fromJsonModel(
          Map<String, dynamic> json) async =>
      SessionInfoModel.fromJson(json);
}
