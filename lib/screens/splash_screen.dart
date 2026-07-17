import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'weather_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WeatherScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed), Color(0xFF7F00FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Animated weather icon
              const Hero(
                    tag: 'app_logo',
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    duration: 1200.ms,
                    curve: Curves.easeInOutBack,
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1.1, 1.1),
                  )
                  .then()
                  .scale(
                    duration: 1200.ms,
                    curve: Curves.easeInOutBack,
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(0.7, 0.7),
                  )
                  .animate()
                  .fade(duration: 800.ms),
              const SizedBox(height: 24),
              // App Name
              Text(
                    'WeatherNow',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  )
                  .animate()
                  .fade(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                    'Real-time Weather Forecast',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.5,
                    ),
                  )
                  .animate()
                  .fade(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
              const Spacer(flex: 2),
              // Loading Indicator
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
              ).animate().fade(delay: 700.ms, duration: 400.ms),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
