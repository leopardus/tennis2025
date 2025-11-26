
import 'package:flutter/material.dart';
import 'package:padel_one/app_styles.dart';

class HourColumn extends StatelessWidget {
  final int hourCount;
  final double startHour;
  final double rowHeight;

  const HourColumn({
    super.key,
    required this.hourCount,
    required this.startHour,
    required this.rowHeight,
  });

  static String formatHour(double hour) {
    final int h = hour.floor();
    final int m = ((hour - h) * 60).round();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(70.0, hourCount * rowHeight),
          painter: _HourLinePainter(
            hourCount: hourCount,
            rowHeight: rowHeight,
            lineColor: AppStyles.uxDividerColor,
          ),
        ),
        Column(
          children: List.generate(hourCount + 1, (index) {
            // +1 to include the last hour label
            final hour = startHour + index;
            return Container(
              height: rowHeight,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppStyles.uxDividerColor),
                ),
              ),
              padding: const EdgeInsets.only(
                  left: 24.0, top: 4.0, right: 4.0, bottom: 4.0),
              alignment: Alignment.topLeft,
              child: Text(
                HourColumn.formatHour(hour),
                style: const TextStyle(
                    color: AppStyles.uxSecondaryText,
                    fontSize: AppStyles.fontSizeSmall,
                    fontWeight: FontWeight.bold),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HourLinePainter extends CustomPainter {
  final int hourCount;
  final double rowHeight;
  final Color lineColor;

  _HourLinePainter({
    required this.hourCount,
    required this.rowHeight,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5;

    final circlePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final double lineX = 12.0;

    for (int i = 0; i < hourCount + 1; i++) {
      // +1 to include the last hour circle
      final currentY = i * rowHeight + 12.0;
      canvas.drawCircle(Offset(lineX, currentY), 2.5, circlePaint);

      if (i < hourCount) {
        // Draw line only between the slots
        final nextY = (i + 1) * rowHeight + 12.0;
        canvas.drawLine(Offset(lineX, currentY + 2.5 + 2.0),
            Offset(lineX, nextY - 2.5 - 2.0), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HourLinePainter oldDelegate) {
    return oldDelegate.hourCount != hourCount ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.lineColor != lineColor;
  }
}
