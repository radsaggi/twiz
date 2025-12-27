import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twiz/global_state.dart';

import '../display.dart';
import 'question.dart';
import '../widgets/scoreboard_mini.dart';
import 'team_options.dart';

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

class CategoriesDisplayWidget2 extends StatelessWidget {
  static const route = "/categories";

  const CategoriesDisplayWidget2({super.key});

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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: displayCharacterstics.appBarHeight,
        elevation: 4,
        actions: [
          IconButton.filledTonal(
            onPressed: () =>
                Navigator.pushNamed(context, TeamOptionsPage.route),
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
  const _DataLoaderIcon();

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
                this.dataFuture = globalData.uploadJson().then(
                    (_) => Future.delayed(Duration(milliseconds: 1000), () {}));
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
  const _CategoriesBoard();

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
      switchInCurve: Curves.easeInBack,
      switchOutCurve: Curves.easeInBack.flipped,
      child: _CategoryWidget(index: index, status: status, key: childKey),
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
        alignment: Alignment.center,
        child: widget,
      );
    },
  );
}

class _CategoryWidget extends StatelessWidget {
  final int index;
  final CategoryStatus status;

  static const formattedSize = Size(250, 300);
  static const textAlignment = Alignment(0, -0.5);

  const _CategoryWidget(
      {required this.index, required this.status, Key? super.key});

  @override
  Widget build(BuildContext context) {
    var categoriesData = context.read<CategoriesData>();
    final titleString = categoriesData.getCategoryName(this.index,
        hidden: status == CategoryStatus.HIDDEN);

    final textTheme = Theme.of(context).textTheme;
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final size = displayCharacterstics.fullPadding
        .deflateSize(displayCharacterstics.scaleSize(formattedSize));

    final mainColor = categoriesData.getColorForStatus(this.index, this.status);

    final borderColor =
        status == CategoryStatus.EXHAUSTED ? Colors.grey : Colors.black;

    return Container(
      margin: displayCharacterstics.fullPadding,
      width: size.width,
      height: size.height,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        color: borderColor, // Border color
        shadows: kElevationToShadow[6],
      ),
      padding: EdgeInsets.all(4.0), // Border width
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: _buildContent(
            context, displayCharacterstics, mainColor, textTheme, titleString),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      DisplayCharacterstics displayCharacterstics,
      Color mainColor,
      TextTheme textTheme,
      String titleString) {
    if (status == CategoryStatus.HIDDEN) {
      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: mainColor,
                  padding: displayCharacterstics.fullPadding / 2,
                  alignment: Alignment.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Material(
                  color: const Color(0xFF222222),
                  child: InkWell(
                    onTap: () => _onPressed(context),
                    child: Center(
                      child: Icon(
                        Icons.visibility_outlined,
                        color: Colors.white,
                        size: displayCharacterstics.iconSize * 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: textAlignment,
            child: Padding(
              padding: displayCharacterstics.fullPadding,
              child: Text(titleString,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.displayMedium
                      ?.apply(color: Colors.black, fontWeightDelta: 3),
                  textScaler: displayCharacterstics.textScaler,
                  textAlign: TextAlign.center),
            ),
          ),
        ],
      );
    } else {
      // REVEALED or EXHAUSTED
      final textColor =
          status == CategoryStatus.REVEALED ? Colors.black : Colors.grey;
      final buttonIcon =
          status == CategoryStatus.REVEALED ? Icons.navigate_next : Icons.done;
      return Container(
        color: mainColor,
        child: Stack(
          children: [
            Align(
              alignment: textAlignment,
              child: Padding(
                padding: displayCharacterstics.fullPadding,
                child: Text(titleString,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.displayMedium
                        ?.apply(color: textColor, fontWeightDelta: 3),
                    textScaler: displayCharacterstics.textScaler,
                    textAlign: TextAlign.center),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: displayCharacterstics.fullPadding,
                child: IconButton.filled(
                  onPressed: status == CategoryStatus.REVEALED
                      ? () => _onPressed(context)
                      : null,
                  icon: Icon(
                    buttonIcon,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[500],
                    disabledForegroundColor: Colors.grey,
                  ),
                  iconSize: displayCharacterstics.iconSize,
                ),
              ),
            ),
          ],
        ),
      );
    }
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
