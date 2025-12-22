import 'dart:convert';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'global_state.g.dart';

const ScoreboardLength = 5;

const CLUE1_SCORES = [20, 30, 40];
const CLUE2_SCORES = [10, 15, 20];
final CLUE_COLORS = [
  Color(0xFF4C9BBA),
  Color(0xFF007256),
  Color(0xFFA70043),
].map(_deriveColorScheme).toList(growable: false);

ColorScheme _deriveColorScheme(Color color) {
  return ColorScheme.fromSeed(
      seedColor: color, dynamicSchemeVariant: DynamicSchemeVariant.vibrant);
}

class GlobalScoreboard extends ChangeNotifier {
  final _colors = List.generate(
      ScoreboardLength, (idx) => _deriveColorScheme(_defaultColors[idx]));
  final _names = List.generate(
      ScoreboardLength, (idx) => "This is a long team name ${idx + 1}");
  var _scores = List.filled(ScoreboardLength, /* value = */ 0);

  static const List<Color> _defaultColors = [
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.green,
    // Colors.yellow,
    Color(0xFFF0B03F),
  ];

  void updateScore(int index, int newScore) {
    this._scores[index] = newScore;
    notifyListeners();
  }

  int getScore(int index) {
    return this._scores[index];
  }

  ColorScheme getColorScheme(int index) {
    return this._colors[index];
  }

  String getTeamName(int index) {
    return this._names[index];
  }

  void updateColor(Color newColor, int index) {
    this._colors[index] = _deriveColorScheme(newColor);
    notifyListeners();
  }

  void updateName(String name, int index) {
    this._names[index] = name;
    notifyListeners();
  }
}

class GlobalData extends ChangeNotifier {
  CategoriesData categories = CategoriesData.sample();

  Future<void> uploadJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["json"],
    );
    if (result == null) {
      return;
    }
    
    final fileContents = utf8.decode(await result.files.first.bytes!);
    final jsonData = await json.decode(fileContents);
    categories = CategoriesData.fromJson(jsonData);
    notifyListeners();
  }
}

enum CategoryStatus {
  HIDDEN,
  REVEALED,
  EXHAUSTED,
}

final List<MaterialColor> _CATEGORY_COLORS = [
  Colors.blue,
  Colors.cyan,
  Colors.lime,
  Colors.orange,
  Colors.purple,
];

@immutable
class CategoriesData {
  CategoriesData._private(this.categories);

  CategoriesData.sample({int count = 10, int? seed})
      : categories = List.generate(count, (idx) {
          final random = Random(seed);
          final idx = random.nextInt(5);
          final suffix = (random.nextInt(512).toRadixString(16))
              .toUpperCase()
              .padLeft(4, "0");
          final categoryName = "${SampleCategories[idx]}-${suffix}";
          final question = QuestionData.sample(
              title: "Question Title ${idx}",
              description: "More details about \"${categoryName}\". "
                  "${QuestionData.SampleDescription}");
          return (categoryName, question);
        });

  factory CategoriesData.fromJson(Map<String, dynamic> json) =>
      CategoriesData._private(json.entries
          .map((entry) => (entry.key, QuestionData.fromJson(entry.value)))
          .toList());

  static const SampleCategories = [
    "Science",
    "Art",
    "Pop Culture",
    "This is a very long category",
    "Business"
  ];

  final List<(String, QuestionData)> categories;

  int getCount() {
    return categories.length;
  }

  int getMaxRowCount() {
    return (getCount() + 1) ~/ 2;
  }

  String getCategoryName(int index, {hidden = false}) {
    final config = this.categories[index];
    if (hidden) {
      return "Category ${index + 1}";
    } else {
      return config.$1;
    }
  }

  QuestionData getCategoryQuestion(int index) {
    return this.categories[index].$2;
  }

  Color getColorForStatus(int index, CategoryStatus status) {
    final materialColor = _CATEGORY_COLORS[index % getMaxRowCount()];
    return switch (status) {
      CategoryStatus.HIDDEN => materialColor[200]!,
      CategoryStatus.REVEALED => materialColor[400]!,
      CategoryStatus.EXHAUSTED => Colors.grey[400]!,
    };
  }
}

@immutable
@JsonSerializable(explicitToJson: true)
class QuestionData {
  const QuestionData(this.title, this.description, this.clues);

  QuestionData.sample({String? title, String? description})
      : title = title ?? "Question Title here",
        description = description ?? SampleDescription,
        clues = List.generate(15, ClueData.sample);

  static const SampleDescription =
      "Question description goes here. Lorem ipsum dolor sit amet, consectetur"
      " adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore"
      " magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"
      " ullamco laboris nisi ut aliquip ex ea commodo consequat.";

  final String title;
  final String description;

  final List<ClueData> clues;

  factory QuestionData.fromJson(Map<String, dynamic> json) =>
      _$QuestionDataFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionDataToJson(this);
}

@immutable
@JsonSerializable()
class ClueData {
  const ClueData(this.prompt, this.hint1, this.hint2, this.answer);

  const ClueData.sample(idx)
      : prompt = "10${idx}",
        hint1 = "Clue ${idx} Hint 1: ${SampleHint}",
        hint2 = "Clue ${idx} Hint 2: ${SampleHint}",
        answer = "This is the answer ${idx}";

  static const SampleHint =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

  final String prompt;
  final String hint1;
  final String hint2;
  final String answer;

  factory ClueData.fromJson(Map<String, dynamic> json) =>
      _$ClueDataFromJson(json);

  Map<String, dynamic> toJson() => _$ClueDataToJson(this);
}
