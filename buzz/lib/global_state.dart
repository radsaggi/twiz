import 'dart:convert';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'global_state.g.dart';

// Maximum number of teams allowed
const int MAX_TEAMS = 8;
const int DEFAULT_TEAMS = 4;

final List<Color> _DEFAULT_TEAM_COLORS = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.pink,
];

ColorScheme deriveColorScheme(Color color) {
  return ColorScheme.fromSeed(
    seedColor: color,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    secondary: color,
  );
}

class GlobalScoreboard extends ChangeNotifier {
  int _teamCount = DEFAULT_TEAMS;
  List<int> _scores = [];
  List<String> _names = [];
  List<Color> _seedColors = [];
  List<ColorScheme> _colors = [];

  GlobalScoreboard() {
    _initializeTeams();
  }

  void _initializeTeams() {
    _scores = List.generate(_teamCount, (_) => 0);
    _names = List.generate(_teamCount, (idx) => "Team ${idx + 1}");
    _seedColors = List.generate(
      _teamCount,
      (idx) => _DEFAULT_TEAM_COLORS[idx % _DEFAULT_TEAM_COLORS.length],
    );
    _colors = _seedColors.map(deriveColorScheme).toList();
  }

  int get teamCount => _teamCount;

  void addTeam() {
    if (_teamCount < MAX_TEAMS) {
      _teamCount++;
      _scores.add(0);
      _names.add("Team $_teamCount");
      final newColor =
          _DEFAULT_TEAM_COLORS[(_teamCount - 1) % _DEFAULT_TEAM_COLORS.length];
      _seedColors.add(newColor);
      _colors.add(deriveColorScheme(newColor));
      notifyListeners();
    }
  }

  void removeTeam() {
    if (_teamCount > 1) {
      _teamCount--;
      _scores.removeLast();
      _names.removeLast();
      _seedColors.removeLast();
      _colors.removeLast();
      notifyListeners();
    }
  }

  void updateScore(int index, int newScore) {
    if (index >= 0 && index < _teamCount) {
      _scores[index] = newScore;
      notifyListeners();
    }
  }

  int getScore(int index) => _scores[index];
  String getTeamName(int index) => _names[index];
  Color getTeamColor(int index) => _seedColors[index];
  ColorScheme getColorScheme(int index) => _colors[index];

  void updateColor(Color newColor, int index) {
    if (index >= 0 && index < _teamCount) {
      _seedColors[index] = newColor;
      _colors[index] = deriveColorScheme(newColor);
      notifyListeners();
    }
  }

  void updateName(String name, int index) {
    if (index >= 0 && index < _teamCount) {
      _names[index] = name;
      notifyListeners();
    }
  }

  void resetScores() {
    for (int i = 0; i < _scores.length; i++) {
      _scores[i] = 0;
    }
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

  // Method to advance question index for a category
  void advanceCategory(int categoryIndex) {
    if (categoryIndex >= 0 && categoryIndex < categories.items.length) {
      final item = categories.items[categoryIndex];
      if (item.currentQuestionIndex < item.questions.length) {
        item.currentQuestionIndex++;
        notifyListeners();
      }
    }
  }
}

enum CategoryStatus { REVEALED, EXHAUSTED }

@immutable
class CategoriesData {
  CategoriesData._private(this.items);

  CategoriesData.sample() : items = _createSampleData();

  static List<CategoryItem> _createSampleData() {
    return [
      CategoryItem("History", List.generate(4, (i) => QuestionData.sample(i))),
      CategoryItem("Science", List.generate(4, (i) => QuestionData.sample(i))),
      CategoryItem("Arts", List.generate(4, (i) => QuestionData.sample(i))),
      CategoryItem(
        "Geography",
        List.generate(4, (i) => QuestionData.sample(i)),
      ),
    ];
  }

  factory CategoriesData.fromJson(Map<String, dynamic> json) {
    final items = json.entries.map((entry) {
      final questionList = (entry.value as List)
          .map((q) => QuestionData.fromJson(q as Map<String, dynamic>))
          .toList();
      return CategoryItem(entry.key, questionList);
    }).toList();
    return CategoriesData._private(items);
  }

  final List<CategoryItem> items;

  int getCount() {
    return items.length;
  }
}

class CategoryItem {
  final String name;
  final List<QuestionData> questions;
  int currentQuestionIndex = 0;

  CategoryItem(this.name, this.questions);

  CategoryStatus get status => currentQuestionIndex >= questions.length
      ? CategoryStatus.EXHAUSTED
      : CategoryStatus.REVEALED;

  String getProgress() {
    return "${min(currentQuestionIndex + 1, questions.length)}/${questions.length}";
  }

  QuestionData? getCurrentQuestion() {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }
}

@immutable
@JsonSerializable(explicitToJson: true)
class QuestionData {
  const QuestionData(this.answer, this.clues);

  QuestionData.sample(int idx)
    : answer = "Answer $idx",
      clues = [
        "Clue 1 for Q$idx",
        "Clue 2 for Q$idx",
        "Clue 3 for Q$idx",
        "Clue 4 for Q$idx",
        "Clue 5 for Q$idx",
      ];

  final String answer;
  final List<String> clues;

  factory QuestionData.fromJson(Map<String, dynamic> json) =>
      _$QuestionDataFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionDataToJson(this);
}
