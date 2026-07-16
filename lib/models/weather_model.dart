class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final String description;
  final String icon;
  final int visibility;
  final int pressure;
  final int clouds;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime dateTime;
  final List<HourlyForecast> hourlyForecasts;
  final List<DailyForecast> dailyForecasts;

  Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.description,
    required this.icon,
    required this.visibility,
    required this.pressure,
    required this.clouds,
    required this.sunrise,
    required this.sunset,
    required this.dateTime,
    this.hourlyForecasts = const [],
    this.dailyForecasts = const [],
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? '',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDeg: (json['wind']['deg'] ?? 0) as int,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      visibility: (json['visibility'] ?? 0) as int,
      pressure: json['main']['pressure'] as int,
      clouds: json['clouds']['all'] as int,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunrise'] as int) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunset'] as int) * 1000),
      dateTime: DateTime.fromMillisecondsSinceEpoch(
          (json['dt'] as int) * 1000),
      hourlyForecasts: const [],
      dailyForecasts: const [],
    );
  }

  double get tempCelsius => temperature - 273.15;
  double get feelsLikeCelsius => feelsLike - 273.15;
  double get tempMinCelsius => tempMin - 273.15;
  double get tempMaxCelsius => tempMax - 273.15;

  String get windDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((windDeg + 22.5) / 45).floor() % 8];
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  bool get isDaytime {
    final now = DateTime.now();
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  Weather copyWith({
    String? cityName,
    String? country,
    double? temperature,
    double? feelsLike,
    double? tempMin,
    double? tempMax,
    int? humidity,
    double? windSpeed,
    int? windDeg,
    String? description,
    String? icon,
    int? visibility,
    int? pressure,
    int? clouds,
    DateTime? sunrise,
    DateTime? sunset,
    DateTime? dateTime,
    List<HourlyForecast>? hourlyForecasts,
    List<DailyForecast>? dailyForecasts,
  }) {
    return Weather(
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      windDeg: windDeg ?? this.windDeg,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      visibility: visibility ?? this.visibility,
      pressure: pressure ?? this.pressure,
      clouds: clouds ?? this.clouds,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      dateTime: dateTime ?? this.dateTime,
      hourlyForecasts: hourlyForecasts ?? this.hourlyForecasts,
      dailyForecasts: dailyForecasts ?? this.dailyForecasts,
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double tempCelsius;
  final String icon;
  final String description;
  final double windSpeed;

  HourlyForecast({
    required this.time,
    required this.tempCelsius,
    required this.icon,
    required this.description,
    required this.windSpeed,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

class DailyForecast {
  final DateTime date;
  final double minTempCelsius;
  final double maxTempCelsius;
  final String icon;
  final String description;

  DailyForecast({
    required this.date,
    required this.minTempCelsius,
    required this.maxTempCelsius,
    required this.icon,
    required this.description,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
