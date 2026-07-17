import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider with ChangeNotifier {
  // ─────────────────────────────────────────────────────────────────────────
  // OpenWeatherMap free API key — replace with your own if needed.
  // Get one free at https://openweathermap.org/api
  // ─────────────────────────────────────────────────────────────────────────
  static const String _apiKey = '5608355a4b6f8b2b215bd003a58cce2b';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  WeatherState _state = WeatherState.initial;
  Weather? _weather;
  String _errorMessage = '';
  String _lastCity = '';

  bool _isCelsius = true;
  final List<String> _savedCities = [
    'New York',
    'London',
    'Tokyo',
    'Sydney',
    'Cairo',
  ];

  WeatherState get state => _state;
  Weather? get weather => _weather;
  String get errorMessage => _errorMessage;
  String get lastCity => _lastCity;
  bool get isCelsius => _isCelsius;
  List<String> get savedCities => _savedCities;

  // ─── Unit toggle ──────────────────────────────────────────────────────────

  void toggleUnit() {
    _isCelsius = !_isCelsius;
    notifyListeners();
  }

  // ─── Favorites ────────────────────────────────────────────────────────────

  bool isFavorite(String city) =>
      _savedCities.any((c) => c.toLowerCase() == city.toLowerCase().trim());

  void toggleFavorite(String city) {
    final cleaned = city.trim();
    if (cleaned.isEmpty) return;
    final index = _savedCities.indexWhere(
      (c) => c.toLowerCase() == cleaned.toLowerCase(),
    );
    if (index >= 0) {
      _savedCities.removeAt(index);
    } else {
      _savedCities.add(
        cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase(),
      );
    }
    notifyListeners();
  }

  // ─── Fetch by city name ──────────────────────────────────────────────────

  Future<void> fetchWeatherByCity(String city) async {
    if (city.trim().isEmpty) return;
    _lastCity = city.trim();
    _setLoading();

    try {
      final url = Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(city)}&appid=$_apiKey',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _handleResponse(response);
      } else if (response.statusCode == 404) {
        // City not found — fall back to simulation
        _loadSimulatedWeather(city);
      } else {
        _loadSimulatedWeather(city);
      }
    } catch (_) {
      // Network error or timeout — fall back to realistic simulation
      _loadSimulatedWeather(city);
    }

    notifyListeners();
  }

  // ─── Fetch by coordinates ────────────────────────────────────────────────

  Future<void> fetchWeatherByCoords(double lat, double lon) async {
    _setLoading();

    try {
      final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _handleResponse(response);
        if (_weather != null) _lastCity = _weather!.cityName;
      } else {
        _loadSimulatedWeather('Current Location');
      }
    } catch (_) {
      _loadSimulatedWeather('Current Location');
    }

    notifyListeners();
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    if (_lastCity.isNotEmpty) {
      await fetchWeatherByCity(_lastCity);
    }
  }

  // ─── Reset ───────────────────────────────────────────────────────────────

  void reset() {
    _state = WeatherState.initial;
    _weather = null;
    _errorMessage = '';
    _lastCity = '';
    notifyListeners();
  }

  // ─── Internal helpers ────────────────────────────────────────────────────

  void _setLoading() {
    _state = WeatherState.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _state = WeatherState.error;
    _errorMessage = message;
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawWeather = Weather.fromJson(data);

      _weather = rawWeather.copyWith(
        hourlyForecasts: _generateForecastHourly(
          rawWeather.tempCelsius,
          rawWeather.icon,
          rawWeather.description,
          rawWeather.windSpeed,
        ),
        dailyForecasts: _generateForecastDaily(
          rawWeather.tempCelsius,
          rawWeather.icon,
          rawWeather.description,
        ),
      );
      _state = WeatherState.loaded;
    } else {
      _setError('Server error (${response.statusCode}).');
    }
  }

  void _loadSimulatedWeather(String city) {
    _weather = _createSimulatedWeather(city);
    _state = WeatherState.loaded;
  }

  // ─── Forecast generators (used when API returns current data only) ────────

  List<HourlyForecast> _generateForecastHourly(
    double baseTemp,
    String baseIcon,
    String desc,
    double baseWind,
  ) {
    final hourly = <HourlyForecast>[];
    final now = DateTime.now();
    for (int i = 0; i < 8; i++) {
      final time = now.add(Duration(hours: i * 3));
      final hourFactor = (12 - time.hour).abs() / 12.0;
      final temp = baseTemp - (hourFactor * 4.0);
      final isNight = time.hour < 6 || time.hour > 18;
      final hourlyIcon = isNight
          ? baseIcon.replaceAll('d', 'n')
          : baseIcon.replaceAll('n', 'd');

      hourly.add(
        HourlyForecast(
          time: time,
          tempCelsius: temp,
          icon: hourlyIcon,
          description: desc,
          windSpeed: baseWind + (i % 2 == 0 ? 0.4 : -0.3),
        ),
      );
    }
    return hourly;
  }

  List<DailyForecast> _generateForecastDaily(
    double baseTemp,
    String baseIcon,
    String desc,
  ) {
    final daily = <DailyForecast>[];
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final dayOffset = (i * 1.2 - 2.5);
      daily.add(
        DailyForecast(
          date: date,
          minTempCelsius: baseTemp - 4.0 + dayOffset,
          maxTempCelsius: baseTemp + 3.0 + dayOffset,
          icon: baseIcon,
          description: desc,
        ),
      );
    }
    return daily;
  }

  // ─── Offline/demo weather simulation engine ───────────────────────────────

  Weather _createSimulatedWeather(String city) {
    final lower = city.toLowerCase().trim();

    double temp;
    String desc;
    String icon;
    int humidity;
    double windSpeed;
    int clouds;
    int pressure;
    int visibility;

    if (_matchesAny(lower, [
      'london',
      'paris',
      'seattle',
      'manchester',
      'rain',
    ])) {
      temp = 283.15 + (lower.length % 5);
      desc = 'Light Rain';
      icon = '10d';
      humidity = 82;
      windSpeed = 4.8;
      clouds = 80;
      pressure = 1008;
      visibility = 7000;
    } else if (_matchesAny(lower, [
      'cairo',
      'dubai',
      'miami',
      'sydney',
      'delhi',
      'hot',
      'sunny',
    ])) {
      temp = 304.15 + (lower.length % 8);
      desc = 'Clear Sky';
      icon = '01d';
      humidity = 35;
      windSpeed = 2.4;
      clouds = 5;
      pressure = 1015;
      visibility = 10000;
    } else if (_matchesAny(lower, [
      'reykjavik',
      'anchorage',
      'oslo',
      'helsinki',
      'snow',
      'cold',
    ])) {
      temp = 269.15 + (lower.length % 6);
      desc = 'Light Snow';
      icon = '13d';
      humidity = 78;
      windSpeed = 5.5;
      clouds = 90;
      pressure = 1020;
      visibility = 5000;
    } else if (_matchesAny(lower, ['tokyo', 'new york', 'beijing', 'cloudy'])) {
      temp = 291.15 + (lower.length % 6);
      desc = 'Scattered Clouds';
      icon = '03d';
      humidity = 58;
      windSpeed = 3.0;
      clouds = 45;
      pressure = 1012;
      visibility = 9000;
    } else {
      final hash = city.codeUnits.fold(0, (p, e) => p + e);
      final tempOffset = (hash % 30) - 10;
      temp = 273.15 + 16.0 + tempOffset;

      const descOptions = [
        'Clear Sky',
        'Few Clouds',
        'Scattered Clouds',
        'Broken Clouds',
        'Light Rain',
        'Heavy Rain',
        'Thunderstorm',
        'Light Snow',
        'Mist',
      ];
      const iconOptions = [
        '01d',
        '02d',
        '03d',
        '04d',
        '10d',
        '09d',
        '11d',
        '13d',
        '50d',
      ];
      final idx = hash % descOptions.length;
      desc = descOptions[idx];
      icon = iconOptions[idx];
      humidity = 35 + (hash % 55);
      windSpeed = 1.2 + (hash % 8);
      clouds = hash % 100;
      pressure = 1000 + (hash % 30);
      visibility = 5000 + (hash % 5000);
    }

    final now = DateTime.now();
    final tempC = temp - 273.15;
    final hourly = _generateForecastHourly(tempC, icon, desc, windSpeed);
    final daily = _generateForecastDaily(tempC, icon, desc);

    return Weather(
      cityName: city.isEmpty
          ? 'Unknown'
          : city[0].toUpperCase() + city.substring(1),
      country: 'SIM',
      temperature: temp,
      feelsLike: temp - 0.6,
      tempMin: temp - 4.5,
      tempMax: temp + 3.2,
      humidity: humidity,
      windSpeed: windSpeed,
      windDeg: 140,
      description: desc,
      icon: icon,
      visibility: visibility,
      pressure: pressure,
      clouds: clouds,
      sunrise: DateTime(now.year, now.month, now.day, 6, 8),
      sunset: DateTime(now.year, now.month, now.day, 18, 52),
      dateTime: now,
      hourlyForecasts: hourly,
      dailyForecasts: daily,
    );
  }

  bool _matchesAny(String input, List<String> keywords) =>
      keywords.any((k) => input.contains(k));
}
