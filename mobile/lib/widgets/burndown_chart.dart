import 'package:flutter/material.dart';

class BurndownChart extends StatelessWidget {
  const BurndownChart({super.key, required this.points});

  final List<int> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _BurndownPainter(
          points: points,
          lineColor: Theme.of(context).colorScheme.primary,
          axisColor: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class _BurndownPainter extends CustomPainter {
  _BurndownPainter({required this.points, required this.lineColor, required this.axisColor});

  final List<int> points;
  final Color lineColor;
  final Color axisColor;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;

    canvas.drawLine(Offset(24, 8), Offset(24, size.height - 24), axisPaint);
    canvas.drawLine(Offset(24, size.height - 24), Offset(size.width - 8, size.height - 24), axisPaint);

    if (points.isEmpty) {
      return;
    }

    final maxPoint = points.reduce((a, b) => a > b ? a : b).toDouble().clamp(1, double.infinity);
    final stepX = points.length == 1 ? 0.0 : (size.width - 40) / (points.length - 1);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = 24 + stepX * i;
      final normalized = points[i] / maxPoint;
      final y = (size.height - 24) - (normalized * (size.height - 36));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _BurndownPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
