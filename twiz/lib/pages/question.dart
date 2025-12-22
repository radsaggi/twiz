import 'dart:math';

import 'package:animated_switcher_transitions/animated_switcher_transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../display.dart';
import '../global_state.dart';
import '../widgets/scoreboard_mini.dart';
import '../widgets/team_options.dart';

enum QuestionDisplayState {
  EMPTY,
  SHOW_CLUE1,
  SHOW_CLUE2,
}

class QuestionState extends ChangeNotifier {
  var _displayState = QuestionDisplayState.EMPTY;

  void doRevealClue1() {
    if (_displayState != QuestionDisplayState.SHOW_CLUE1) {
      _displayState = QuestionDisplayState.SHOW_CLUE1;
      notifyListeners();
    }
  }

  void doRevealClue2() {
    if (_displayState != QuestionDisplayState.SHOW_CLUE2) {
      _displayState = QuestionDisplayState.SHOW_CLUE2;
      notifyListeners();
    }
  }

  QuestionDisplayState getDisplayState() {
    return _displayState;
  }
}

class QuestionDisplayWidget extends StatelessWidget with TeamOptionsPopopWidgetProvider {
  static const route = "/question";

  const QuestionDisplayWidget();

  @override
  Widget build(BuildContext context) {
    final questionData =
        ModalRoute.of(context)!.settings.arguments as QuestionData?;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionState()),
        Provider.value(value: questionData ?? QuestionData.sample()),
      ],
      builder: DisplayCharacterstics.wrapped(childBuilder: _buildSubtree),
    );
  }

  Widget _buildSubtree(BuildContext context, _child) {
    var questionState = context.watch<QuestionState>();
    var questionData = context.watch<QuestionData>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final scoreboardState = context.watch<GlobalScoreboard>();
    return Scaffold(
      appBar: AppBar(
        title: Text(questionData.title,
            textScaler: displayCharacterstics.compundedTextScaler(scale: 1.1)),
        titleTextStyle: textTheme.displaySmall!.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
        toolbarHeight: displayCharacterstics.appBarHeight,
        elevation: 4,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back),
          color: colorScheme.secondary,
          iconSize: displayCharacterstics.iconSize * 1.5,
          padding: displayCharacterstics.fullPadding / 2.5,
        ),
        leadingWidth: displayCharacterstics.paddingRaw * 3,
        actions: [
          IconButton.filledTonal(
            onPressed: () => showDialog<String>(
                context: context,
                builder: (context) => provideUsing(
                    context, scoreboardState, displayCharacterstics),
            ),
            icon: Icon(Icons.settings),
            iconSize: displayCharacterstics.iconSize,
            padding: displayCharacterstics.fullPadding / 2,
          ),
          displayCharacterstics.fullSpacer,
          IconButton.filledTonal(
            onPressed: () {
              questionState.doRevealClue1();
            },
            icon: Icon(Icons.visibility_outlined),
            iconSize: displayCharacterstics.iconSize,
            padding: displayCharacterstics.fullPadding / 2,
          ),
          displayCharacterstics.fullSpacer,
          IconButton.filledTonal(
            onPressed: () {
              questionState.doRevealClue2();
            },
            icon: Icon(Icons.visibility),
            iconSize: displayCharacterstics.iconSize,
            padding: displayCharacterstics.fullPadding / 2,
          ),
          displayCharacterstics.halfSpacer,
          ScoreBoardMiniWidget(),
          displayCharacterstics.halfSpacer,
        ],
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(flex: 6, child: QuestionTitleWidget()),
            Expanded(flex: 17, child: ClueGridWidget()),
            Spacer(flex: 1),
          ]),
    );
  }
}

class QuestionTitleWidget extends StatelessWidget {
  const QuestionTitleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var questionData = context.watch<QuestionData>();
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.lerp(Alignment.centerLeft, Alignment.topLeft, 0.5),
      padding: displayCharacterstics.fullPadding,
      child: Text(questionData.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style:
              textTheme.displayMedium!.copyWith(color: colorScheme.secondary),
          textScaler: displayCharacterstics.textScaler),
    );
  }
}

class ClueGridWidget extends StatelessWidget {
  const ClueGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final displayCharacterstics = context.read<DisplayCharacterstics>();
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: GridView.count(
          crossAxisCount: 3,
          physics: NeverScrollableScrollPhysics(),
          padding: displayCharacterstics.fullPadding / 2,
          childAspectRatio:
              (6.0 / 3.0) * (constraints.maxWidth / constraints.maxHeight),
          children: List.generate(
              18, (idx) => _buildClueGridWidget(context, idx),
              growable: false),
        ),
      );
    });
  }

  Widget _buildClueGridWidget(BuildContext context, int index) {
    var questionData = context.watch<QuestionData>();
    if (index < 3) {
      return _ClueScoreDisplayWidget(columnIndex: index);
    } else {
      var clueIdx = index - 3;
      clueIdx = 5 * (clueIdx % 3) + (clueIdx ~/ 3);
      return Provider.value(
          value: questionData.clues[clueIdx],
          child: ClueDisplayWidget(index: clueIdx));
    }
  }
}

class _ClueScoreDisplayWidget extends StatelessWidget {
  const _ClueScoreDisplayWidget({super.key, required this.columnIndex});

  final int columnIndex;

  @override
  Widget build(BuildContext context) {
    var questionState = context.watch<QuestionState>();
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final score_text = switch (questionState.getDisplayState()) {
      QuestionDisplayState.EMPTY => "---",
      QuestionDisplayState.SHOW_CLUE1 => "${CLUE1_SCORES[columnIndex]} points",
      QuestionDisplayState.SHOW_CLUE2 => "${CLUE2_SCORES[columnIndex]} points",
    };

    final theme = Theme.of(context);
    return Container(
      margin: displayCharacterstics.fullPadding / 2,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        color: CLUE_COLORS[this.columnIndex].primary,
      ),
      alignment: Alignment.center,
      child: Text(
        score_text,
        style: theme.textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
        textScaler: displayCharacterstics.textScaler,
      ),
    );
  }
}

class ClueDisplayWidget extends StatefulWidget {
  const ClueDisplayWidget({super.key, required this.index});

  final int index;

  @override
  State<ClueDisplayWidget> createState() => _ClueDisplayWidgetState();
}

class _ClueDisplayWidgetState extends State<ClueDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    return Container(
      margin: displayCharacterstics.fullPadding / 2,
      child: LayoutBuilder(builder: (context, constraints) {
        final maxButtonSize = min(constraints.maxHeight, constraints.maxWidth);
        return Stack(
          alignment: Alignment.centerLeft,
          fit: StackFit.expand,
          children: [
            Positioned(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: ClueTextWidget(
                  index: widget.index, iconPadding: maxButtonSize),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: ClueAnswerButtonWidget(
                  index: widget.index,
                  maxButtonSize: maxButtonSize,
                  maxSize: constraints.biggest),
            ),
          ],
        );
      }),
    );
  }
}

class ClueAnswerButtonWidget extends StatefulWidget {
  const ClueAnswerButtonWidget(
      {super.key,
      required this.index,
      required this.maxButtonSize,
      required this.maxSize});

  final int index;
  final double maxButtonSize;
  final Size maxSize;

  @override
  State<ClueAnswerButtonWidget> createState() => _ClueAnswerButtonWidgetState();
}

class _ClueAnswerButtonWidgetState extends State<ClueAnswerButtonWidget> {
  var answer_shown = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      transitionBuilder: AnimatedSwitcherTransitions.slideRight,
      layoutBuilder: AnimatedSwitcherLayouts.inOut,
      child: answer_shown
          ? _buildAnswerOverlay(context)
          : _buildAnswerButton(context),
    );
  }

  Widget _buildAnswerButton(BuildContext context) {
    final clueData = context.watch<ClueData>();
    final theme = Theme.of(context);
    final colorScheme = CLUE_COLORS[this.widget.index ~/ 5];
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    return Container(
      width: this.widget.maxButtonSize,
      height: this.widget.maxButtonSize,
      child: FilledButton(
        onPressed: () => setState(() {
          answer_shown = true;
        }),
        child: Text(
          clueData.prompt,
          style: theme.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer),
          textScaler: displayCharacterstics.textScaler,
        ),
        style: FilledButton.styleFrom(
            textStyle: theme.textTheme.headlineMedium
                ?.copyWith(color: theme.colorScheme.onInverseSurface),
            backgroundColor: colorScheme.inversePrimary,
            elevation: 2,
            shape: const CircleBorder(),
            padding: displayCharacterstics.fullPadding / 4),
      ),
    );
  }

  Widget _buildAnswerOverlay(BuildContext context) {
    final clueData = context.watch<ClueData>();
    final theme = Theme.of(context);
    final colorScheme = CLUE_COLORS[this.widget.index ~/ 5];
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: displayCharacterstics.paddingRaw,
          vertical: displayCharacterstics.paddingRaw / 2),
      width: this.widget.maxSize.width,
      height: this.widget.maxSize.height,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        color: colorScheme.primary,
        shadows: kElevationToShadow[4],
      ),
      child: Text(clueData.answer,
          maxLines: 1,
          style: theme.textTheme.displayMedium
              ?.copyWith(color: colorScheme.onPrimary),
          textScaler: displayCharacterstics.textScaler,
          overflow: TextOverflow.ellipsis),
    );
  }
}

class ClueTextWidget extends StatelessWidget {
  final int index;
  final double iconPadding;

  const ClueTextWidget(
      {super.key, required this.index, required this.iconPadding});

  @override
  Widget build(BuildContext context) {
    final clueData = context.watch<ClueData>();
    var question_state = context.watch<QuestionState>();
    final clue_text = switch (question_state.getDisplayState()) {
      QuestionDisplayState.EMPTY => "",
      QuestionDisplayState.SHOW_CLUE1 => clueData.hint1,
      QuestionDisplayState.SHOW_CLUE2 => clueData.hint2,
    };

    final theme = Theme.of(context);
    final colorScheme = CLUE_COLORS[index ~/ 5];
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    return ClipPath(
      clipper: ShapeBorderClipper(shape: StadiumBorder()),
      child: Container(
        padding: EdgeInsets.only(
            left: iconPadding + displayCharacterstics.paddingRaw / 2,
            right: displayCharacterstics.paddingRaw / 2),
        alignment: Alignment.centerLeft,
        color: colorScheme.primaryContainer,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 800),
          transitionBuilder: AnimatedSwitcherTransitions.slideBottom,
          child: Text(clue_text,
              maxLines: 3,
              key: ValueKey((index, question_state.getDisplayState())),
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: colorScheme.onPrimaryContainer),
              textScaler: displayCharacterstics.compundedTextScaler(scale: 0.9),
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
