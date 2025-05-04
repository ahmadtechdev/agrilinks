import 'package:weather/weather.dart';

import '../../utils/consts.dart';


class WeatherService {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  /// Fetches current weather data for the specified city
  Future<Weather> getWeatherByCity(String city) async {
    try {
      final weather = await _wf.currentWeatherByCityName(city);
      return weather;
    } catch (e) {
      throw WeatherException('Failed to fetch weather for $city: $e');
    }
  }

  /// Fetches current weather based on geographic coordinates
  Future<Weather> getWeatherByLocation(double latitude, double longitude) async {
    try {
      final weather = await _wf.currentWeatherByLocation(latitude, longitude);
      return weather;
    } catch (e) {
      throw WeatherException('Failed to fetch weather for location ($latitude,$longitude): $e');
    }
  }

  /// Fetches 5-day forecast for the specified city
  Future<List<Weather>> getForecastByCity(String city) async {
    try {
      final forecast = await _wf.fiveDayForecastByCityName(city);
      return forecast;
    } catch (e) {
      throw WeatherException('Failed to fetch forecast for $city: $e');
    }
  }
}

class WeatherException implements Exception {
  final String message;

  WeatherException(this.message);

  @override
  String toString() => message;
}