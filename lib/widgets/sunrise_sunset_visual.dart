import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import 'glass_container.dart';

class SunriseSunsetVisual extends StatelessWidget {
  final Weather weather;

  const SunriseSunsetVisual({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    final sunriseStr = fmt.format(weather.sunrise);
    final sunsetStr = fmt.format(weather.sunset);
    final now = DateTime.now();

    final totalMinutes = weather.sunset.difference(weather.sunrise).inMinutes;
    final elapsedMinutes = now.difference(weather.sunrise).inMinutes;

    double progress = 0.0;
    bool isDay = false;

    if (totalMinutes > 0) {
      progress = elapsedMinutes / totalMinutes;
      if (progress >= 0.0 && progress <= 1.0) {
        isDay = true;
      } else {
        progress = progress.clamp(0.0, 1.0);
      }
    }

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_twilight_rounded,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'SUNRISE & SUNSET',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                final t = progress;
                final bx = 2 * (1 - t) * t * (width / 2) + t * t * width;
                final by =
                    (1 - t) * (1 - t) * height +
                    2 * (1 - t) * t * (-height * 0.25) +
                    t * t * height;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: SunArcPainter(
                          progress: progress,
                          isDay: isDay,
                        ),
                      ),
                    ),
                    if (isDay)
                      Positioned(
                        left: bx - 14,
                        top: by - 14,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orangeAccent.withValues(
                                  alpha: 0.7,
                                ),
                                blurRadius: 14,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.wb_sunny_rounded,
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),
                      )
                    else
                      Positioned(
                        left: width * 0.5 - 13,
                        top: height - 13,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.nights_stay_rounded,
                            color: Colors.indigoAccent,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sunriseStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sunrise',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Text(
                    isDay
                        ? '${(progress * 100).toStringAsFixed(0)}% elapsed'
                        : 'Sunset was at $sunsetStr',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sunsetStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sunset',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SunArcPainter extends CustomPainter {
  final double progress;
  final bool isDay;

  SunArcPainter({required this.progress, required this.isDay});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final basePaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, height), Offset(width, height), basePaint);

    final path = Path();
    path.moveTo(0, height);
    path.quadraticBezierTo(width / 2, -height * 0.25, width, height);

    final arcPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _drawDashedPath(canvas, path, arcPaint);

    if (isDay && progress > 0.0) {
      final activePaint = Paint()
        ..color = Colors.amberAccent.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      final activePath = Path();
      activePath.moveTo(0, height);

      final steps = (progress * 60).round();
      for (int i = 1; i <= steps; i++) {
        final t = i / 60.0;
        final double bx = 2 * (1 - t) * t * (width / 2) + t * t * width;
        final double by =
            (1 - t) * (1 - t) * height +
            2 * (1 - t) * t * (-height * 0.25) +
            t * t * height;
        activePath.lineTo(bx, by);
      }
      canvas.drawPath(activePath, activePaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 6.0;
    const double dashSpace = 4.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double remaining = metric.length - distance;
        final double w = remaining > dashWidth ? dashWidth : remaining;
        canvas.drawPath(metric.extractPath(distance, distance + w), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant SunArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDay != isDay;
}
