import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0E17), Color(0xFF1E1B29)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing location marker / weather icon
              Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      size: 40,
                      color: Colors.blueAccent,
                    ),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    duration: 1000.ms,
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.15, 1.15),
                    curve: Curves.easeInOut,
                  )
                  .boxShadow(
                    begin: const BoxShadow(color: Colors.transparent),
                    end: BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ),
              const SizedBox(height: 32),
              // Message
              Text(
                'Detecting your location...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
              ).animate().fade(duration: 500.ms),
              const SizedBox(height: 8),
              Text(
                'Fetching weather data for your area',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
              ).animate().fade(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 32),
              // Progress indicator
              SizedBox(
                width: 40,
                child:
                    const LinearProgressIndicator(
                          color: Colors.blueAccent,
                          backgroundColor: Colors.white12,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 1500.ms, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
