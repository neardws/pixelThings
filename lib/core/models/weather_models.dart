import 'package:flutter/material.dart';

class WeatherData {
  final String location;
  final double temperature;
  final String condition;
  final WeatherCondition conditionType;
  final int humidity;
  final double windSpeed;
  final DateTime updatedAt;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.conditionType,
    required this.humidity,
    required this.windSpeed,
    required this.updatedAt,
  });

  String get temperatureString => '${temperature.round()}°';
  
  IconData get icon {
    switch (conditionType) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny;
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.partlyCloudy:
        return Icons.cloud_queue;
      case WeatherCondition.rainy:
        return Icons.water_drop;
      case WeatherCondition.stormy:
        return Icons.thunderstorm;
      case WeatherCondition.snowy:
        return Icons.ac_unit;
      case WeatherCondition.foggy:
        return Icons.blur_on;
      case WeatherCondition.windy:
        return Icons.air;
      case WeatherCondition.unknown:
        return Icons.help_outline;
    }
  }

  Color get color {
    switch (conditionType) {
      case WeatherCondition.sunny:
        return const Color(0xFFFFD700);
      case WeatherCondition.cloudy:
        return const Color(0xFF9E9E9E);
      case WeatherCondition.partlyCloudy:
        return const Color(0xFFB0BEC5);
      case WeatherCondition.rainy:
        return const Color(0xFF64B5F6);
      case WeatherCondition.stormy:
        return const Color(0xFF5C6BC0);
      case WeatherCondition.snowy:
        return const Color(0xFFE0E0E0);
      case WeatherCondition.foggy:
        return const Color(0xFFBDBDBD);
      case WeatherCondition.windy:
        return const Color(0xFF81D4FA);
      case WeatherCondition.unknown:
        return const Color(0xFF757575);
    }
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final condition = json['weather']?[0]?['main']?.toString().toLowerCase() ?? 'unknown';
    
    return WeatherData(
      location: json['name'] ?? 'Unknown',
      temperature: (json['main']?['temp'] ?? 0).toDouble(),
      condition: json['weather']?[0]?['description'] ?? 'Unknown',
      conditionType: _parseCondition(condition),
      humidity: json['main']?['humidity'] ?? 0,
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
      updatedAt: DateTime.now(),
    );
  }

  static WeatherCondition _parseCondition(String condition) {
    switch (condition) {
      case 'clear':
        return WeatherCondition.sunny;
      case 'clouds':
        return WeatherCondition.cloudy;
      case 'rain':
      case 'drizzle':
        return WeatherCondition.rainy;
      case 'thunderstorm':
        return WeatherCondition.stormy;
      case 'snow':
        return WeatherCondition.snowy;
      case 'mist':
      case 'fog':
      case 'haze':
        return WeatherCondition.foggy;
      default:
        return WeatherCondition.unknown;
    }
  }

  static WeatherData mock() {
    return WeatherData(
      location: 'Demo City',
      temperature: 22,
      condition: 'Partly Cloudy',
      conditionType: WeatherCondition.partlyCloudy,
      humidity: 65,
      windSpeed: 5.5,
      updatedAt: DateTime.now(),
    );
  }
}

enum WeatherCondition {
  sunny,
  cloudy,
  partlyCloudy,
  rainy,
  stormy,
  snowy,
  foggy,
  windy,
  unknown,
}
