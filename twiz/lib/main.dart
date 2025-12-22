import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twiz/global_state.dart';

import 'pages/question.dart';
import 'pages/categories2.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalScoreboard()),
        ChangeNotifierProvider(create: (_) => GlobalData()),
      ],
      child: MaterialApp(
        title: 'Twiz Flutter',
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
        ),
        routes: {
          CategoriesDisplayWidget2.route: (context) =>
              ProxyProvider<GlobalData, CategoriesData>(
                  update: (_, globalData, _prevCategoriesData) =>
                      globalData.categories,
                  child: CategoriesDisplayWidget2()),
          QuestionDisplayWidget.route: (context) => QuestionDisplayWidget(),
        },
        initialRoute: CategoriesDisplayWidget2.route,
      ),
    );
  }
}
