import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'glass_container.dart';

class SavedLocationsDrawer extends StatelessWidget {
  const SavedLocationsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final cities = provider.savedCities;

        return Drawer(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: GlassContainer(
            borderRadius: 0,
            blur: 24,
            borderOpacity: 0.1,
            backgroundOpacity: 0.2,
            padding: EdgeInsets.zero,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bookmark_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'My Locations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                    const SizedBox(height: 16),
                    if (cities.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border_rounded,
                                size: 50,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No saved locations yet',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap the bookmark icon next to a city to save it.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: cities.length,
                          itemBuilder: (context, index) {
                            final cityName = cities[index];
                            final isCurrent = provider.weather?.cityName.toLowerCase() ==
                                cityName.toLowerCase();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? Colors.white.withValues(alpha: 0.22)
                                      : Colors.white.withValues(alpha: 0.07),
                                  border: Border.all(
                                    color: isCurrent
                                        ? Colors.white.withValues(alpha: 0.4)
                                        : Colors.white.withValues(alpha: 0.12),
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  title: Text(
                                    cityName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          isCurrent ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isCurrent)
                                        Container(
                                          margin: const EdgeInsets.only(right: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Active',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                        onPressed: () => provider.toggleFavorite(cityName),
                                        tooltip: 'Remove',
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    provider.fetchWeatherByCity(cityName);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
