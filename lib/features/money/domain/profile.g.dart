// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  goalUsd: (json['goalUsd'] as num?)?.toDouble() ?? 5000,
  uahPerUsd: (json['uahPerUsd'] as num?)?.toDouble() ?? 41.5,
  uahPerEur: (json['uahPerEur'] as num?)?.toDouble() ?? 45.5,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'goalUsd': instance.goalUsd,
  'uahPerUsd': instance.uahPerUsd,
  'uahPerEur': instance.uahPerEur,
};
