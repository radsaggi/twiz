// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionData _$QuestionDataFromJson(Map<String, dynamic> json) => QuestionData(
      json['title'] as String,
      json['description'] as String,
      (json['clues'] as List<dynamic>)
          .map((e) => ClueData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuestionDataToJson(QuestionData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'clues': instance.clues.map((e) => e.toJson()).toList(),
    };

ClueData _$ClueDataFromJson(Map<String, dynamic> json) => ClueData(
      json['prompt'] as String,
      json['hint1'] as String,
      json['hint2'] as String,
      json['answer'] as String,
    );

Map<String, dynamic> _$ClueDataToJson(ClueData instance) => <String, dynamic>{
      'prompt': instance.prompt,
      'hint1': instance.hint1,
      'hint2': instance.hint2,
      'answer': instance.answer,
    };
