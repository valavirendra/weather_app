import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/weather_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyPulse Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4286F4),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
      ),
      home: const WeatherScreen(),
    );
  }
}
