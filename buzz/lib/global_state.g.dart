// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionData _$QuestionDataFromJson(Map<String, dynamic> json) => QuestionData(
  json['answer'] as String,
  (json['clues'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$QuestionDataToJson(QuestionData instance) =>
    <String, dynamic>{'answer': instance.answer, 'clues': instance.clues};
