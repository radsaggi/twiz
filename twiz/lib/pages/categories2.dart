import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twiz/global_state.dart';

import '../display.dart';
import 'question.dart';
import '../widgets/scoreboard_mini.dart';
import '../widgets/team_options.dart';

class _CategoriesState extends ChangeNotifier {
  _CategoriesState({required int count})
      : categoriesList = List.filled(count, CategoryStatus.HIDDEN);

  final List<CategoryStatus> categoriesList;

  CategoryStatus? getCategoryStatus(int index) {
    return categoriesList[index];
  }

  CategoryStatus doStatusUpdate(int index) {
    if (categoriesList[index] == CategoryStatus.EXHAUSTED) {
      return CategoryStatus.EXHAUSTED;
    }

    final oldStatus = this.categoriesList[index];
    categoriesList[index] = switch (categoriesList[index]) {
      CategoryStatus.HIDDEN => CategoryStatus.REVEALED,
      CategoryStatus.REVEALED => CategoryStatus.EXHAUSTED,
      CategoryStatus.EXHAUSTED => CategoryStatus.EXHAUSTED,
    };
    notifyListeners();

    return oldStatus;
  }
}

class CategoriesDisplayWidget2 extends StatelessWidget  with TeamOptionsPopopWidgetProvider {
  static const route = "/categories";

  @override
  Widget build(BuildContext context) {
    final categoriesData = context.watch<GlobalData>().categories;

    return ChangeNotifierProvider.value(
      value: _CategoriesState(count: categoriesData.getCount()),
      builder: DisplayCharacterstics.wrapped(childBuilder: _buildSubtree),
    );
  }

  Widget _buildSubtree(BuildContext context, _child) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final scoreboardState = context.watch<GlobalScoreboard>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: displayCharacterstics.appBarHeight,
        elevation: 4,
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
          _DataLoaderIcon(),
          displayCharacterstics.fullSpacer,
          ScoreBoardMiniWidget(),
        ],
      ),
      body: _CategoriesBoard(),
    );
  }
}

class _DataLoaderIcon extends StatefulWidget {
  const _DataLoaderIcon({super.key});

  @override
  State<_DataLoaderIcon> createState() => _DataLoaderIconState();
}

class _DataLoaderIconState extends State<_DataLoaderIcon> {
  late Future<void> dataFuture;

  @override
  void initState() {
    super.initState();

    dataFuture = Future.sync(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: dataFuture,
        builder: (context, snapshot) {
          final globalData = context.watch<GlobalData>();
          if (snapshot.hasError) {
            print("Dataset loading Error: ${snapshot.error}");
            return _buildIconButton(context, child: Icon(Icons.report));
          } else if (snapshot.connectionState == ConnectionState.done) {
            return _buildIconButton(
              context,
              child: Icon(Icons.upload),
              onPressed: () => setState(() {
                this.dataFuture = globalData
                    .uploadJson()
                    .then((_) =>
                        Future.delayed(Duration(milliseconds: 1000), () {}));
              }),
            );
          } else {
            return _buildIconButton(context,
                child: CircularProgressIndicator(strokeWidth: 6));
          }
        });
  }

  Widget _buildIconButton(
    BuildContext context, {
    required Widget child,
    OnPressedHandler? onPressed,
  }) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      icon: child,
      color: colorScheme.secondary,
      iconSize: displayCharacterstics.iconSize * 1.5,
      padding: displayCharacterstics.fullPadding / 2,
    );
  }
}

typedef OnPressedHandler = void Function();

class _CategoriesBoard extends StatelessWidget {
  _CategoriesBoard({Key? super.key});

  @override
  Widget build(BuildContext context) {
    final categoriesData = context.read<CategoriesData>();
    final totalCategories = categoriesData.getCount();
    final firstRowCount = categoriesData.getMaxRowCount();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < firstRowCount; i++)
              _AnimatedCategoriesWidget(index: i)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = firstRowCount; i < totalCategories; i++)
              _AnimatedCategoriesWidget(index: i)
          ],
        ),
      ],
    );
  }
}

class _AnimatedCategoriesWidget extends StatelessWidget {
  final int index;

  const _AnimatedCategoriesWidget({
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<_CategoriesState>();
    final status = categoriesState.getCategoryStatus(this.index)!;
    final childKey = ValueKey((this.index, status == CategoryStatus.HIDDEN));

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 600),
      transitionBuilder: (widget, animation) =>
          __transitionBuilder(widget, animation, childKey),
      layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
      child: _CategoryWidget(index: index, status: status, key: childKey),
      switchInCurve: Curves.easeInBack,
      switchOutCurve: Curves.easeInBack.flipped,
    );
  }
}

Widget __transitionBuilder(
    Widget widget, Animation<double> animation, ValueKey childKey) {
  final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
  return AnimatedBuilder(
    animation: rotateAnim,
    child: widget,
    builder: (context, widget) {
      final isUnder = (childKey != widget!.key);
      var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
      tilt *= isUnder ? -1.0 : 1.0;
      final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
      return Transform(
        transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
        child: widget,
        alignment: Alignment.center,
      );
    },
  );
}

class _CategoryWidget extends StatelessWidget {
  final int index;
  final CategoryStatus status;

  final Size formattedSize = Size(250, 300);

  _CategoryWidget({required this.index, required this.status, Key? super.key});

  @override
  Widget build(BuildContext context) {
    var categoriesData = context.read<CategoriesData>();
    final titleString = categoriesData.getCategoryName(this.index,
        hidden: status == CategoryStatus.HIDDEN);

    final textTheme = Theme.of(context).textTheme;
    final buttonIcon = switch (this.status) {
      CategoryStatus.HIDDEN => Icons.visibility_outlined,
      CategoryStatus.REVEALED => Icons.navigate_next,
      CategoryStatus.EXHAUSTED => Icons.done,
    };
    final buttonTextColor = switch (this.status) {
      CategoryStatus.HIDDEN => Colors.grey[800]!,
      CategoryStatus.REVEALED => Colors.black,
      CategoryStatus.EXHAUSTED => Colors.grey[600]!,
    };
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final size = displayCharacterstics.fullPadding
        .deflateSize(displayCharacterstics.scaleSize(this.formattedSize));

    return Container(
      margin: displayCharacterstics.fullPadding,
      padding: displayCharacterstics.fullPadding / 2,
      width: size.width,
      height: size.height,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        color: categoriesData.getColorForStatus(this.index, this.status),
        shadows: kElevationToShadow[6],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 16),
          Text(titleString,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.displayMedium
                  ?.apply(color: buttonTextColor, fontWeightDelta: 3),
              textScaler: displayCharacterstics.textScaler,
              textAlign: TextAlign.center),
          const Spacer(flex: 16),
          IconButton.filled(
            icon: Icon(buttonIcon),
            iconSize: displayCharacterstics.iconSize,
            style: FilledButton.styleFrom(
                backgroundColor: buttonTextColor,
                padding: displayCharacterstics.fullPadding / 1.5),
            onPressed: status == CategoryStatus.EXHAUSTED
                ? null
                : () => _onPressed(context),
          ),
          const Spacer(flex: 5),
        ],
      ),
    );
  }

  void _onPressed(BuildContext context) {
    final oldStatus =
        context.read<_CategoriesState>().doStatusUpdate(this.index);
    if (oldStatus == CategoryStatus.REVEALED) {
      final navigator = Navigator.of(context);
      final questionData =
          context.read<CategoriesData>().getCategoryQuestion(this.index);
      Future.delayed(Duration(milliseconds: 600), () {
        navigator.pushNamed(QuestionDisplayWidget.route,
            arguments: questionData);
      });
    }
  }
}
