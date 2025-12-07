import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_things/core/models/weather_models.dart';

class WeatherService {
  static const String _apiKeyPref = 'weather_api_key';
  static const String _cityPref = 'weather_city';
  static const String _cachePref = 'weather_cache';
  static const String _cacheTimePref = 'weather_cache_time';
  static const Duration _cacheValidity = Duration(minutes: 30);

  String? _apiKey;
  String _city = 'Beijing';
  WeatherData? _cachedData;
  DateTime? _cacheTime;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyPref);
    _city = prefs.getString(_cityPref) ?? 'Beijing';
    
    // 加载缓存
    final cacheJson = prefs.getString(_cachePref);
    final cacheTimeMs = prefs.getInt(_cacheTimePref);
    
    if (cacheJson != null && cacheTimeMs != null) {
      try {
        _cachedData = WeatherData.fromJson(jsonDecode(cacheJson));
        _cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimeMs);
      } catch (e) {
        debugPrint('Failed to load weather cache: $e');
      }
    }
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey);
  }

  Future<void> setCity(String city) async {
    _city = city;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityPref, city);
    // 清除缓存以获取新城市数据
    _cachedData = null;
    _cacheTime = null;
  }

  String get city => _city;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<WeatherData?> getWeather({bool forceRefresh = false}) async {
    // 检查缓存是否有效
    if (!forceRefresh && _cachedData != null && _cacheTime != null) {
      final now = DateTime.now();
      if (now.difference(_cacheTime!) < _cacheValidity) {
        return _cachedData;
      }
    }

    // 如果没有API key，返回mock数据
    if (!hasApiKey) {
      return WeatherData.mock();
    }

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?q=$_city'
        '&appid=$_apiKey'
        '&units=metric'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _cachedData = WeatherData.fromJson(json);
        _cacheTime = DateTime.now();
        
        // 保存缓存
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cachePref, response.body);
        await prefs.setInt(_cacheTimePref, _cacheTime!.millisecondsSinceEpoch);
        
        return _cachedData;
      } else {
        debugPrint('Weather API error: ${response.statusCode}');
        return _cachedData ?? WeatherData.mock();
      }
    } catch (e) {
      debugPrint('Weather fetch error: $e');
      return _cachedData ?? WeatherData.mock();
    }
  }

  WeatherData? get cachedWeather => _cachedData;
}
