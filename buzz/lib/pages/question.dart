import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../display.dart';
import '../global_state.dart';
import '../widgets/scoreboard_mini.dart';
import 'team_options.dart';

class QuestionState extends ChangeNotifier {
  int _currentClueIndex = 1; // Start with 1 clue revealed
  bool _isAnswerRevealed = false;

  int get currentClueIndex => _currentClueIndex;
  bool get isAnswerRevealed => _isAnswerRevealed;

  // Scoring logic: 60 base - 10 per revealed clue.
  // 1 clue revealed = 50 pts.
  int get potentialPoints => max(0, 60 - (10 * _currentClueIndex));

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
    final args =
        ModalRoute.of(context)!.settings.arguments as (String, QuestionData)?;
    final title = args?.$1 ?? "Question";
    final questionData = args?.$2 ?? QuestionData.sample(1);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionState()),
        Provider.value(value: questionData),
      ],
      builder: (context, _) {
        return DisplayCharacterstics.wrapped(
          childBuilder: (context, child) => _buildSubtree(context, title),
        )(context, null);
      },
    );
  }

  Widget _buildSubtree(BuildContext context, String title) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.secondaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          textScaler: displayCharacterstics.compundedTextScaler(scale: 1.1),
        ),
        titleTextStyle: theme.textTheme.displaySmall!.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w900,
        ),
        toolbarHeight: displayCharacterstics.appBarHeight,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back),
          color: colorScheme.onSecondaryContainer,
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
          ScoreBoardMiniWidget(),
          displayCharacterstics.halfSpacer,
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: displayCharacterstics.fullPadding * 2,
          child: _BodyContent(),
        ),
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    // Fixed width for the left timeline column
    final leftColumnWidth = 120.0 * displayCharacterstics.aspectRatioScale;

    return ListView(
      children: [
        // Header Row: Points (Left) and Answer (Right)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: leftColumnWidth, child: _PointsHeader()),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: displayCharacterstics.paddingRaw,
                  ),
                  child: Center(child: _AnswerSection()),
                ),
              ),
            ],
          ),
        ),
        // Clues List with Timeline
        _CluesTimelineList(leftColumnWidth: leftColumnWidth),
      ],
    );
  }
}

class _PointsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questionState = context.watch<QuestionState>();
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100 * displayCharacterstics.aspectRatioScale,
          height: 100 * displayCharacterstics.aspectRatioScale,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "POTENTIAL\nPOINTS",
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary.withAlpha(128),
                ),
                textScaler: displayCharacterstics.textScaler,
              ),
              SizedBox(height: displayCharacterstics.paddingRaw / 4),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: questionState.potentialPoints),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Text(
                    "$value",
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onPrimary,
                    ),
                    textScaler: displayCharacterstics.compundedTextScaler(
                      scale: 1.5,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Vertical line start directly below the circle
        Expanded(
          child: Container(
            width: 4 * displayCharacterstics.aspectRatioScale,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _AnswerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questionState = context.watch<QuestionState>();
    final questionData = context.watch<QuestionData>();
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (questionState.isAnswerRevealed) {
      return Container(
        width: double.infinity,
        padding: displayCharacterstics.fullPadding / 1.5,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withAlpha(100),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ANSWER",
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimary.withAlpha(205),
                fontWeight: FontWeight.bold,
              ),
              textScaler: displayCharacterstics.compundedTextScaler(scale: 1.2),
            ),
            SizedBox(height: displayCharacterstics.paddingRaw / 4),
            Text(
              questionData.answer,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textScaler: displayCharacterstics.compundedTextScaler(scale: 1.5),
            ),
          ],
        ),
      );
    }

    return FilledButton.tonal(
      onPressed: () => questionState.revealAnswer(),
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: displayCharacterstics.paddingRaw * 1.3,
          horizontal: displayCharacterstics.paddingRaw * 2.6,
        ),
        iconSize: displayCharacterstics.iconSize * 1.5,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        "REVEAL ANSWER",
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
        textScaler: displayCharacterstics.textScaler,
      ),
    );
  }
}

class _CluesTimelineList extends StatelessWidget {
  final double leftColumnWidth;

  const _CluesTimelineList({required this.leftColumnWidth});

  @override
  Widget build(BuildContext context) {
    final questionState = context.watch<QuestionState>();
    final clues = context.watch<QuestionData>().clues;
    final displayCharacterstics = context.read<DisplayCharacterstics>();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        final isRevealed = index < questionState.currentClueIndex;
        final isActive = index < questionState.currentClueIndex;
        final clueText = index < clues.length ? clues[index] : "";

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline Column
              SizedBox(
                width: leftColumnWidth,
                child: _TimelineSegment(
                  index: index,
                  isLast: index == 4,
                  isActive: isActive,
                  currentClueIndex: questionState.currentClueIndex,
                ),
              ),
              // Clue Card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: displayCharacterstics.paddingRaw,
                    bottom: displayCharacterstics.paddingRaw,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: isRevealed
                        ? _RevealedClueCard(
                            key: ValueKey('revealed_$index'),
                            index: index,
                            text: clueText,
                          )
                        : GestureDetector(
                            key: ValueKey('locked_$index'),
                            onTap: () => questionState.revealNextClue(),
                            child: _LockedClueCard(),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineSegment extends StatelessWidget {
  final int index;
  final bool isLast;
  final bool isActive;
  final int currentClueIndex;

  const _TimelineSegment({
    required this.index,
    required this.isLast,
    required this.isActive,
    required this.currentClueIndex,
  });

  @override
  Widget build(BuildContext context) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.outlineVariant;

    // Logic:
    // Top line connects from previous item (or header).
    // Filled if THIS item is revealed (meaning line comes down to it).
    // Index < currentClueIndex means this clue is revealed.
    // If index 0 is revealed (currentClueIndex >= 1), line to 0 is filled.
    final bool isTopFilled = index < currentClueIndex;

    // Bottom line connects to next item.
    // Filled if NEXT item is revealed.
    // Index + 1 < currentClueIndex.
    final bool isBottomFilled = (index + 1) < currentClueIndex;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Top Line (from top to center)
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: 4 * displayCharacterstics.aspectRatioScale,
                  color: isTopFilled ? activeColor : inactiveColor,
                ),
              ),
              Expanded(
                child: isLast
                    ? Container() // No bottom line for last item
                    : Container(
                        width: 4 * displayCharacterstics.aspectRatioScale,
                        color: isBottomFilled ? activeColor : inactiveColor,
                      ),
              ),
            ],
          ),
        ),

        // The Checkpoint Dot (visually centered due to Stack alignment)
        Container(
          width: 16 * displayCharacterstics.aspectRatioScale,
          height: 16 * displayCharacterstics.aspectRatioScale,
          decoration: BoxDecoration(
            color: isActive ? activeColor : theme.canvasColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? activeColor : inactiveColor,
              width: 3,
            ),
          ),
        ),
      ],
    );
  }
}

class _RevealedClueCard extends StatelessWidget {
  final int index;
  final String text;

  const _RevealedClueCard({super.key, required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final questionState = context.watch<QuestionState>();
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);

    final isAnswerRevealed = questionState.isAnswerRevealed;
    final backgroundColor = isAnswerRevealed
        ? theme.colorScheme.tertiary.withAlpha(30)
        : theme.colorScheme.tertiary;
    final contentOpacity = isAnswerRevealed ? 0.8 : 1.0;

    return Container(
      width: double.infinity,
      padding:
          displayCharacterstics.fullPadding -
          EdgeInsets.only(top: displayCharacterstics.paddingRaw * 0.25),
      decoration: BoxDecoration(
        color: backgroundColor, // Yellow
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Opacity(
        opacity: contentOpacity,
        child: Column(
          children: [
            Text(
              "CLUE ${index + 1}",
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onTertiary,
                fontWeight: FontWeight.bold,
              ),
              textScaler: displayCharacterstics.compundedTextScaler(scale: 1.2),
            ),
            SizedBox(height: displayCharacterstics.paddingRaw / 4),
            Text(
              text,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onTertiary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              textScaler: displayCharacterstics.compundedTextScaler(scale: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedClueCard extends StatelessWidget {
  const _LockedClueCard();

  @override
  Widget build(BuildContext context) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 80 * displayCharacterstics.aspectRatioScale,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.lock_outline,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          size: 24 * displayCharacterstics.aspectRatioScale,
        ),
      ),
    );
  }
}
