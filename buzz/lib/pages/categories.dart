import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../display.dart';
import '../global_state.dart';
import '../widgets/scoreboard_mini.dart';
import 'team_options.dart';
import 'question.dart';

class CategoriesDisplayWidget extends StatelessWidget {
  static const route = "/categories";

  const CategoriesDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DisplayCharacterstics.wrapped(
            childBuilder: (context, _) => _buildSubtree(context))
        .call(context, null);
  }

  Widget _buildSubtree(BuildContext context) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: displayCharacterstics.appBarHeight,
        elevation: 4,
        title: Text("Categories",
             textScaler: displayCharacterstics.compundedTextScaler(scale: 1.1),
             style: theme.textTheme.displaySmall!.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
             ),
        ),
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
          displayCharacterstics.halfSpacer,
        ],
      ),
      body: _CategoriesGrid(),
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
    VoidCallback? onPressed,
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

class _CategoriesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final globalData = context.watch<GlobalData>();
    final categories = globalData.categories.items;
    final displayCharacterstics = context.read<DisplayCharacterstics>();

    return SingleChildScrollView(
      padding: displayCharacterstics.fullPadding,
      child: Center(
        child: Wrap(
          spacing: displayCharacterstics.paddingRaw,
          runSpacing: displayCharacterstics.paddingRaw,
          alignment: WrapAlignment.center,
          children: categories.asMap().entries.map((entry) {
            return _CategoryTile(index: entry.key, item: entry.value);
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final int index;
  final CategoryItem item;
  
  static const formattedSize = Size(250, 300);
  static const textAlignment = Alignment(0, -0.5);

  const _CategoryTile({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final status = item.status;
    
    // Assign colors cyclically or randomly if preferred
    final color = Colors.primaries[index % Colors.primaries.length];
    
    final isExhausted = status == CategoryStatus.EXHAUSTED;
    
    final size = displayCharacterstics.scaleSize(formattedSize);
    final borderColor = isExhausted ? Colors.grey : Colors.black;
    final mainColor = isExhausted ? Colors.grey[300]! : color;

    return Container(
      width: size.width,
      height: size.height,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        color: borderColor,
        shadows: kElevationToShadow[6],
      ),
      padding: EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Container(
          color: mainColor,
          child: Stack(
            children: [
              Align(
                alignment: textAlignment,
                child: Padding(
                  padding: displayCharacterstics.fullPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.headlineMedium!.copyWith(
                          color: isExhausted ? Colors.grey[600] : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: displayCharacterstics.textScaler,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isExhausted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                             item.getProgress(),
                             style: theme.textTheme.titleMedium!.copyWith(
                                 color: Colors.white70,
                                 fontWeight: FontWeight.w500
                             ),
                             textScaler: displayCharacterstics.textScaler,
                          ),
                        )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: displayCharacterstics.fullPadding,
                  child: IconButton.filled(
                    onPressed: isExhausted ? null : () => _onTap(context),
                    icon: Icon(
                      isExhausted ? Icons.done : Icons.navigate_next,
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
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) async {
     final globalData = context.read<GlobalData>();
     final question = item.getCurrentQuestion();
     
     if (question != null) {
        await Navigator.pushNamed(
            context, 
            QuestionDisplayWidget.route,
            arguments: (item.name, question)
        );
        // Advance to next question after returning
        globalData.advanceCategory(index);
     }
  }
}

