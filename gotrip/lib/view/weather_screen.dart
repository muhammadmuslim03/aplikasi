class WeatherData {
  final String locationName;
  final double temperature;
  final String condition;

  WeatherData({
    required this.locationName,
    required this.temperature,
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String name) {
    return WeatherData(
      locationName: name,
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
    );
  }
}
