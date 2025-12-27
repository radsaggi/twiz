import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'global_state.dart';
import 'pages/categories.dart';
import 'pages/question.dart';
import 'pages/team_options.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalScoreboard()),
        ChangeNotifierProvider(create: (_) => GlobalData()),
      ],
      child: MaterialApp(
        title: 'Buzz Flutter',
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
          ),
          useMaterial3: true,
        ),
        routes: {
          CategoriesDisplayWidget.route: (context) =>
              const CategoriesDisplayWidget(),
          QuestionDisplayWidget.route: (context) =>
              const QuestionDisplayWidget(),
          TeamOptionsPage.route: (context) => const TeamOptionsPage(),
        },
        initialRoute: CategoriesDisplayWidget.route,
      ),
    );
  }
}
