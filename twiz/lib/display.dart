import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisplayCharacterstics {
  DisplayCharacterstics._private({
    required this.aspectRatioScale,
    required this.paddingRaw,
    required this.appBarHeight,
    required this.textScale,
    required this.iconSize,
  });

  factory DisplayCharacterstics.forSize(Size size) {
    final verticalScale = (size.height / 800);
    final horizontalScale = (size.width / 1600);
    final avgScale = (verticalScale + horizontalScale) / 2;

    return DisplayCharacterstics._private(
      aspectRatioScale: avgScale,
      paddingRaw: 18 * horizontalScale,
      appBarHeight: kToolbarHeight * verticalScale,
      textScale: avgScale * 2 / 3,
      iconSize: 18 * verticalScale,
    );
  }

  final double aspectRatioScale;

  final double paddingRaw;
  final double appBarHeight;
  final double textScale;
  final double iconSize;

  EdgeInsets get fullPadding => EdgeInsets.all(paddingRaw);
  SizedBox get fullSpacer => SizedBox.square(dimension: paddingRaw);
  SizedBox get halfSpacer => SizedBox.square(dimension: paddingRaw / 2);
  SizedBox get quarterSpacer => SizedBox.square(dimension: paddingRaw / 4);

  TextScaler get textScaler => TextScaler.linear(textScale);
  TextScaler compundedTextScaler({double scale = 1}) =>
      TextScaler.linear(textScale * scale);

  Size scaleSize(Size size) => Size(
      size.width * this.aspectRatioScale, size.height * this.aspectRatioScale);

  /// Helper function to create a Provider builder.
  static TransitionBuilder wrapped(
          {TransitionBuilder? childBuilder, Widget? child}) =>
      (context, _child) => Provider.value(
          value: DisplayCharacterstics.forSize(MediaQuery.sizeOf(context)),
          builder: childBuilder,
          child: child);
}
