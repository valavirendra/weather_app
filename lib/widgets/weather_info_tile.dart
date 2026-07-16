import 'package:flutter/material.dart';
import 'glass_container.dart';

class WeatherInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const WeatherInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      borderRadius: 20,
      backgroundOpacity: 0.12,
      borderOpacity: 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.white).withValues(alpha: 0.18),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (iconColor ?? Colors.white).withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
