import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import 'glass_container.dart';

class HourlyForecastCard extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final bool isCelsius;

  const HourlyForecastCard({
    super.key,
    required this.forecasts,
    required this.isCelsius,
  });

  double _toFahrenheit(double celsius) => (celsius * 9 / 5) + 32;

  String _formatTemp(double tempCelsius) {
    final temp = isCelsius ? tempCelsius : _toFahrenheit(tempCelsius);
    return '${temp.toStringAsFixed(0)}°';
  }

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_filled_rounded,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'HOURLY FORECAST',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: forecasts.length,
              itemBuilder: (context, index) {
                final item = forecasts[index];
                final isFirst = index == 0;
                final timeStr = isFirst
                    ? 'Now'
                    : DateFormat('ha').format(item.time);

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 68,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? Colors.white.withValues(alpha: 0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: isFirst
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: isFirst ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight: isFirst
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        Image.network(
                          item.iconUrl,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.wb_cloudy_outlined,
                                size: 26,
                                color: Colors.white70,
                              ),
                        ),
                        Text(
                          _formatTemp(item.tempCelsius),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: isFirst
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.air,
                              size: 8,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${item.windSpeed.toStringAsFixed(0)}m/s',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
