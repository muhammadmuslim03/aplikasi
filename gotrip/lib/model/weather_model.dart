class WeatherData {
  final String locationName;
  final double temperature;
  final String condition;
  final String icon;

  WeatherData({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.icon,
  });

  /// Factory constructor untuk parsing dari JSON API OpenWeatherMap
  factory WeatherData.fromJson(Map<String, dynamic> json, String locationName) {
    return WeatherData(
      locationName: locationName,
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '',
    );
  }

  /// URL ikon cuaca dari OpenWeatherMap
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
