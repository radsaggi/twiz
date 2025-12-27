import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../display.dart';
import '../global_state.dart';
import 'scoreboard_full.dart';

class ScoreBoardMiniWidget extends StatelessWidget {
  const ScoreBoardMiniWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scoreboardState = context.watch<GlobalScoreboard>();
    var displayCharacterstics = context.read<DisplayCharacterstics>();

    return Container(
      padding: displayCharacterstics.fullPadding / 2,
      child: TextButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (context) => _fullScoreboardDialogBuilder(
            context,
            scoreboardState,
            displayCharacterstics,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate((scoreboardState.teamCount * 2 - 1), (
              int index,
            ) {
              if (index % 2 != 0) {
                return SizedBox.fromSize(
                  size: Size.fromWidth(displayCharacterstics.paddingRaw / 4),
                );
              } else {
                return _buildScoreTile(
                  context,
                  index ~/ 2,
                  displayCharacterstics,
                );
              }
            }, growable: false),
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: displayCharacterstics.paddingRaw / 2,
            horizontal: displayCharacterstics.paddingRaw / 4,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreTile(
    BuildContext context,
    int idx,
    DisplayCharacterstics displayCharacterstics,
  ) {
    final scoreboardState = context.watch<GlobalScoreboard>();
    final theme = Theme.of(context);
    final scoreboardTeamColorScheme = scoreboardState.getColorScheme(idx);
    return Container(
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: scoreboardTeamColorScheme.secondary,
      ),
      alignment: Alignment.center,
      constraints: BoxConstraints(
        maxHeight: displayCharacterstics.iconSize * 2.5,
        maxWidth: displayCharacterstics.iconSize * 2.5,
      ),
      child: Text(
        scoreboardState.getScore(idx).toString(),
        style: theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: scoreboardTeamColorScheme.onPrimary,
        ),
        textScaler: displayCharacterstics.textScaler,
      ),
    );
  }

  Widget _fullScoreboardDialogBuilder(
    BuildContext context,
    GlobalScoreboard scoreboardState,
    DisplayCharacterstics displayCharacterstics,
  ) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    final scoreboardWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: scoreboardState),
        Provider.value(value: displayCharacterstics),
      ],
      child: ScoreBoardFullWidget(),
    );

    if (size.width < 1000) {
      return Dialog.fullscreen(child: scoreboardWidget);
    } else {
      return AlertDialog(
        title: Padding(
          padding: displayCharacterstics.fullPadding / 2,
          child: Text(
            'Scoreboard',
            style: theme.textTheme.displayLarge!.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textScaler: displayCharacterstics.textScaler,
            textAlign: TextAlign.center,
          ),
        ),
        content: scoreboardWidget,
      );
    }
  }
}
