import 'package:flutter_test/flutter_test.dart';
import 'package:new_gotrip/model/weather_model.dart';

void main() {
  test('parses Open-Meteo current weather and hourly forecast', () {
    final data = WeatherData.fromOpenMeteo(
      {
        'elevation': 3371.0,
        'current': {
          'time': '2026-05-07T09:30',
          'temperature_2m': 12.4,
          'relative_humidity_2m': 91,
          'apparent_temperature': 11.2,
          'is_day': 1,
          'precipitation': 0.7,
          'rain': 0.7,
          'weather_code': 63,
          'cloud_cover': 88,
          'wind_speed_10m': 18.5,
          'wind_direction_10m': 142,
          'wind_gusts_10m': 32.1,
        },
        'hourly': {
          'time': ['2026-05-07T10:00', '2026-05-07T11:00', '2026-05-07T12:00'],
          'temperature_2m': [12.1, 12.8, 13.0],
          'precipitation_probability': [80, 72, 64],
          'precipitation': [0.8, 0.5, 0.2],
          'weather_code': [63, 61, 3],
          'wind_speed_10m': [20.0, 18.2, 17.4],
          'wind_gusts_10m': [34.0, 30.0, 29.0],
        },
      },
      'Puncak Gunung Sumbing',
      fallbackElevation: 3371,
    );

    expect(data.locationName, 'Puncak Gunung Sumbing');
    expect(data.elevation, 3371);
    expect(data.temperature, 12.4);
    expect(data.humidity, 91);
    expect(data.condition, 'Hujan sedang');
    expect(data.hourlyForecast, hasLength(3));
    expect(data.hourlyForecast.first.precipitationProbability, 80);
    expect(data.hourlyForecast.first.condition, 'Hujan sedang');
  });

  test('uses fallback elevation when response elevation is missing', () {
    final data = WeatherData.fromOpenMeteo(
      {
        'current': {
          'time': '2026-05-07T09:30',
          'temperature_2m': 19,
          'weather_code': 0,
        },
      },
      'Basecamp Kaliangkrik',
      fallbackElevation: 1722,
    );

    expect(data.elevation, 1722);
    expect(data.condition, 'Cerah');
    expect(data.hourlyForecast, isEmpty);
  });

  test('rejects responses without current weather', () {
    expect(
      () => WeatherData.fromOpenMeteo(
        const {},
        'Puncak Gunung Sumbing',
        fallbackElevation: 3371,
      ),
      throwsFormatException,
    );
  });
}
