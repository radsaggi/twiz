import 'dart:math' as math;
import 'package:flutter/material.dart';

class PowerDial extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const PowerDial({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _DialButton(
          icon: Icons.chevron_left,
          onTap: onDecrement,
          color: primaryColor,
          enabled: value > min,
          isLeft: true,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: _DialPainter(
              value: value,
              min: min,
              max: max,
              color: primaryColor,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                '$value',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _DialButton(
          icon: Icons.chevron_right,
          onTap: onIncrement,
          color: primaryColor,
          enabled: value < max,
          isLeft: false,
        ),
      ],
    );
  }
}

class _DialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final bool enabled;
  final bool isLeft;

  const _DialButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.enabled = true,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        hoverColor: Colors.transparent,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.3,
          child: Container(
            width: 30,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.only(
                topLeft: isLeft
                    ? const Radius.circular(20)
                    : const Radius.circular(5),
                bottomLeft: isLeft
                    ? const Radius.circular(20)
                    : const Radius.circular(5),
                topRight: !isLeft
                    ? const Radius.circular(20)
                    : const Radius.circular(5),
                bottomRight: !isLeft
                    ? const Radius.circular(20)
                    : const Radius.circular(5),
              ),
              border: Border.all(color: color.withAlpha(128), width: 2),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final int value;
  final int min;
  final int max;
  final Color color;
  final Color backgroundColor;

  _DialPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Outer decorative rings
    paint.color = color.withAlpha(25);
    // paint.strokeWidth = 2;
    // canvas.drawCircle(center, radius - 1, paint);

    paint.strokeWidth = 1;
    canvas.drawCircle(center, radius - 8, paint);

    // Segmented progress ring
    final totalSegments = max;
    // If range is zero or less, just draw full circle or nothing
    if (totalSegments <= 0) return;

    final gap = 0.08; // Gap in radians

    paint.strokeWidth = 12;

    for (int i = 0; i < totalSegments; i++) {
      final isLit = i < value;

      final startAngle =
          -math.pi / 2 - ((i + 1) * (2 * math.pi / max)) + gap / 2;
      final sweepAngle = (2 * math.pi / max) - gap;

      paint.color = isLit ? color : color.withAlpha(25);

      // if (isLit) {
      //   paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
      //   paint.color = color.withAlpha(225);
      // } else {
      //   paint.maskFilter = null;
      // }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 18),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Reset mask
      paint.maskFilter = null;
    }

    // Inner ring
    paint.strokeWidth = 2;
    paint.color = color.withAlpha(77);
    canvas.drawCircle(center, radius - 30, paint);

    // // Tech ticks on inner ring
    // paint.strokeWidth = 2;
    // for (int i = 0; i < 12; i++) {
    //   final angle = i * (2 * math.pi / 12);
    //   final p1 = Offset(
    //     center.dx + (radius - 30) * math.cos(angle),
    //     center.dy + (radius - 30) * math.sin(angle),
    //   );
    //   final p2 = Offset(
    //     center.dx + (radius - 36) * math.cos(angle),
    //     center.dy + (radius - 36) * math.sin(angle),
    //   );
    //   canvas.drawLine(p1, p2, paint);
    // }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.min != min ||
        oldDelegate.max != max ||
        oldDelegate.color != color;
  }
}
