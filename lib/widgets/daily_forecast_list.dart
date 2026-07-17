import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import 'glass_container.dart';

class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final bool isCelsius;

  const DailyForecastList({
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '7-DAY FORECAST',
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
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              final item = forecasts[index];
              final isToday = index == 0;
              final dayStr = isToday
                  ? 'Today'
                  : DateFormat('EEEE').format(item.date);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Day name
                    Expanded(
                      flex: 3,
                      child: Text(
                        dayStr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    // Icon & Condition
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Image.network(
                            item.iconUrl,
                            width: 32,
                            height: 32,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.wb_sunny_outlined,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Temp Range Bar
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _formatTemp(item.minTempCelsius),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 6,
                                  right: 6,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade300,
                                          Colors.orange.shade300,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatTemp(item.maxTempCelsius),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
