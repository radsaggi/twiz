import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../display.dart';
import '../global_state.dart';
import '../widgets/scoreboard_mini.dart';
import 'team_options.dart';

class QuestionState extends ChangeNotifier {
  int _currentClueIndex = 0;
  bool _isAnswerRevealed = false;

  int get currentClueIndex => _currentClueIndex;
  bool get isAnswerRevealed => _isAnswerRevealed;

  void revealNextClue() {
    if (_currentClueIndex < 5) {
      _currentClueIndex++;
      notifyListeners();
    }
  }

  void revealAnswer() {
    if (!_isAnswerRevealed) {
      _isAnswerRevealed = true;
      notifyListeners();
    }
  }
}

class QuestionDisplayWidget extends StatelessWidget {
  static const route = "/question";

  const QuestionDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as (String, QuestionData)?;
    final title = args?.$1 ?? "Question";
    final questionData = args?.$2 ?? QuestionData.sample(1);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionState()),
        Provider.value(value: questionData),
      ],
      builder: (context, _) {
         return DisplayCharacterstics.wrapped(
            childBuilder: (context, child) => _buildSubtree(context, title)
         )(context, null);
      }
    );
  }

  Widget _buildSubtree(BuildContext context, String title) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final questionState = context.watch<QuestionState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            textScaler: displayCharacterstics.compundedTextScaler(scale: 1.1)),
        titleTextStyle: theme.textTheme.displaySmall!.copyWith(
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
            onPressed: () =>
                Navigator.pushNamed(context, TeamOptionsPage.route),
            icon: Icon(Icons.settings),
            iconSize: displayCharacterstics.iconSize,
            padding: displayCharacterstics.fullPadding / 2,
          ),
          displayCharacterstics.fullSpacer,
          IconButton.filledTonal(
            onPressed: questionState.currentClueIndex < 5
                ? () => questionState.revealNextClue()
                : null,
            icon: Icon(Icons.visibility_outlined),
            iconSize: displayCharacterstics.iconSize,
            padding: displayCharacterstics.fullPadding / 2,
            tooltip: "Reveal Next Clue",
          ),
          displayCharacterstics.fullSpacer,
          IconButton.filledTonal(
            onPressed: !questionState.isAnswerRevealed
                ? () => questionState.revealAnswer()
                : null,
            icon: Icon(Icons.visibility),
            iconSize: displayCharacterstics.iconSize,
            padding: displayCharacterstics.fullPadding / 2,
            tooltip: "Reveal Answer",
          ),
          displayCharacterstics.halfSpacer,
          ScoreBoardMiniWidget(),
          displayCharacterstics.halfSpacer,
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: _AnswerDisplay(),
              ),
              Expanded(
                flex: 8,
                child: _CluesDisplay(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questionState = context.watch<QuestionState>();
    final questionData = context.watch<QuestionData>();
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: displayCharacterstics.fullPadding,
      decoration: BoxDecoration(
        color: questionState.isAnswerRevealed
            ? colorScheme.tertiaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.tertiary,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: !questionState.isAnswerRevealed
              ? () => questionState.revealAnswer()
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                questionState.isAnswerRevealed
                    ? questionData.answer
                    : "TAP TO REVEAL ANSWER",
                key: ValueKey(questionState.isAnswerRevealed),
                style: theme.textTheme.displayMedium!.copyWith(
                  color: questionState.isAnswerRevealed
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onSurfaceVariant.withAlpha(100),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                textScaler: displayCharacterstics.textScaler,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CluesDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        displayCharacterstics.paddingRaw,
        0,
        displayCharacterstics.paddingRaw,
        displayCharacterstics.paddingRaw,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) => Expanded(child: _ClueBox(index: index))),
      ),
    );
  }
}

class _ClueBox extends StatelessWidget {
  final int index;

  const _ClueBox({required this.index});

  @override
  Widget build(BuildContext context) {
    final questionState = context.watch<QuestionState>();
    final questionData = context.watch<QuestionData>();
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final isRevealed = index < questionState.currentClueIndex;
    final clueText = isRevealed ? questionData.clues[index] : "";

    return Container(
      margin: EdgeInsets.symmetric(vertical: displayCharacterstics.paddingRaw / 2),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isRevealed ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isRevealed 
            ? null 
            : Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
        child: isRevealed 
            ? Padding(
                padding: displayCharacterstics.fullPadding,
                child: Text(
                  clueText,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                  textAlign: TextAlign.center,
                  textScaler: displayCharacterstics.textScaler,
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}

