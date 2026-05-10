class WeatherData {
  final String locationName;
  final double elevation;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final double rain;
  final int cloudCover;
  final double windSpeed;
  final double windGusts;
  final int windDirection;
  final int weatherCode;
  final bool isDay;
  final DateTime time;
  final List<WeatherForecastHour> hourlyForecast;

  WeatherData({
    required this.locationName,
    required this.elevation,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.rain,
    required this.cloudCover,
    required this.windSpeed,
    required this.windGusts,
    required this.windDirection,
    required this.weatherCode,
    required this.isDay,
    required this.time,
    required this.hourlyForecast,
  });

  factory WeatherData.fromOpenMeteo(
    Map<String, dynamic> json,
    String locationName, {
    required double fallbackElevation,
  }) {
    final current = json['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException(
        'Response cuaca tidak memiliki data saat ini',
      );
    }

    return WeatherData(
      locationName: locationName,
      elevation: _readDouble(json, 'elevation', fallback: fallbackElevation),
      temperature: _readDouble(current, 'temperature_2m'),
      apparentTemperature: _readDouble(current, 'apparent_temperature'),
      humidity: _readInt(current, 'relative_humidity_2m'),
      precipitation: _readDouble(current, 'precipitation'),
      rain: _readDouble(current, 'rain'),
      cloudCover: _readInt(current, 'cloud_cover'),
      windSpeed: _readDouble(current, 'wind_speed_10m'),
      windGusts: _readDouble(current, 'wind_gusts_10m'),
      windDirection: _readInt(current, 'wind_direction_10m'),
      weatherCode: _readInt(current, 'weather_code'),
      isDay: _readInt(current, 'is_day', fallback: 1) == 1,
      time:
          DateTime.tryParse((current['time'] as String?) ?? '') ??
          DateTime.now(),
      hourlyForecast: _parseHourlyForecast(json),
    );
  }

  String get condition => describeWeatherCode(weatherCode);

  static String describeWeatherCode(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah berawan';
      case 2:
        return 'Berawan sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 56:
      case 57:
        return 'Gerimis dingin';
      case 61:
        return 'Hujan ringan';
      case 63:
        return 'Hujan sedang';
      case 65:
        return 'Hujan lebat';
      case 66:
      case 67:
        return 'Hujan dingin';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return 'Hujan es/salju';
      case 80:
        return 'Hujan lokal ringan';
      case 81:
        return 'Hujan lokal sedang';
      case 82:
        return 'Hujan lokal lebat';
      case 95:
        return 'Badai petir';
      case 96:
      case 99:
        return 'Badai petir dengan es';
      default:
        return 'Tidak diketahui';
    }
  }
}

class WeatherForecastHour {
  final DateTime time;
  final double temperature;
  final int precipitationProbability;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final double windGusts;

  WeatherForecastHour({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.windGusts,
  });

  String get condition => WeatherData.describeWeatherCode(weatherCode);
}

List<WeatherForecastHour> _parseHourlyForecast(Map<String, dynamic> json) {
  final hourly = json['hourly'];
  if (hourly is! Map<String, dynamic>) return const [];

  final times = hourly['time'];
  if (times is! List) return const [];

  final forecast = <WeatherForecastHour>[];
  for (var index = 0; index < times.length && forecast.length < 6; index++) {
    final rawTime = times[index];
    if (rawTime is! String) continue;

    final parsedTime = DateTime.tryParse(rawTime);
    if (parsedTime == null) continue;

    forecast.add(
      WeatherForecastHour(
        time: parsedTime,
        temperature: _readListDouble(hourly, 'temperature_2m', index),
        precipitationProbability: _readListInt(
          hourly,
          'precipitation_probability',
          index,
        ),
        precipitation: _readListDouble(hourly, 'precipitation', index),
        weatherCode: _readListInt(hourly, 'weather_code', index),
        windSpeed: _readListDouble(hourly, 'wind_speed_10m', index),
        windGusts: _readListDouble(hourly, 'wind_gusts_10m', index),
      ),
    );
  }

  return forecast;
}

double _readDouble(
  Map<String, dynamic> source,
  String key, {
  double fallback = 0,
}) {
  final value = source[key];
  if (value is num) return value.toDouble();
  return fallback;
}

int _readInt(Map<String, dynamic> source, String key, {int fallback = 0}) {
  final value = source[key];
  if (value is num) return value.round();
  return fallback;
}

double _readListDouble(
  Map<String, dynamic> source,
  String key,
  int index, {
  double fallback = 0,
}) {
  final values = source[key];
  if (values is List && index < values.length) {
    final value = values[index];
    if (value is num) return value.toDouble();
  }
  return fallback;
}

int _readListInt(
  Map<String, dynamic> source,
  String key,
  int index, {
  int fallback = 0,
}) {
  final values = source[key];
  if (values is List && index < values.length) {
    final value = values[index];
    if (value is num) return value.round();
  }
  return fallback;
}
