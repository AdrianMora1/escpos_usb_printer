// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionInfoModel _$SessionInfoModelFromJson(Map<String, dynamic> json) =>
    SessionInfoModel(
      line: json['line'] as String,
      lineId: (json['line_id'] as num).toInt(),
      sessionId: (json['session_id'] as num).toInt(),
      user: json['user'] as String,
    );

Map<String, dynamic> _$SessionInfoModelToJson(SessionInfoModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'line': instance.line,
      'line_id': instance.lineId,
      'session_id': instance.sessionId,
    };
