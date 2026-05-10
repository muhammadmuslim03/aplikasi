import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../model/weather_model.dart';
import '../model/route_model.dart';

class NavigationController extends ChangeNotifier {
  final MapController mapController = MapController();

  Position? currentPosition;
  bool isTracking = false;
  bool isFetchingWeather = false;
  String selectedRoute = 'normal';

  static const double basecampElevation = 1722;
  static const double summitElevation = 3371;
  static const Duration _weatherTimeout = Duration(seconds: 10);

  final LatLng basecampKaliangkrik = const LatLng(-7.3800, 110.1500);
  final LatLng pos1 = const LatLng(-7.3820, 110.1400);
  final LatLng pos2 = const LatLng(-7.3835, 110.1300);
  final LatLng pos3 = const LatLng(-7.3840, 110.1200);
  final LatLng puncakSumbing = const LatLng(-7.3847, 110.0755);

  /// Cek izin lokasi dan mulai tracking.
  Future<void> checkPermissionAndStartTracking(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!context.mounted) return;

    if (!serviceEnabled) {
      _showSnack(context, 'Aktifkan layanan lokasi terlebih dahulu.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (!context.mounted) return;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!context.mounted) return;
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      _showSnack(context, 'Izin lokasi ditolak.');
      return;
    }

    startLocationTracking();
  }

  void startLocationTracking() {
    isTracking = true;
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      currentPosition = position;
      if (isTracking) {
        mapController.move(
          LatLng(position.latitude, position.longitude),
          mapController.camera.zoom,
        );
      }
      notifyListeners();
    });
  }

  void toggleTracking() {
    isTracking = !isTracking;
    notifyListeners();
  }

  void changeRoute(String route) {
    selectedRoute = route;
    notifyListeners();
  }

  RouteInfo get routeInfo => selectedRoute == 'alternative'
      ? RouteInfo(
          routeName: 'Jalur Alternatif',
          time: '10-12 jam',
          distance: '15 km',
          elevation: '+1.800m',
          difficulty: 'Sulit',
          color: Colors.orange,
        )
      : RouteInfo(
          routeName: 'Jalur Utama',
          time: '8-10 jam',
          distance: '12 km',
          elevation: '+1.800m',
          difficulty: 'Sedang',
          color: Colors.green,
        );

  Future<List<WeatherData>?> fetchSumbingWeather(BuildContext context) async {
    if (isFetchingWeather) return null;

    isFetchingWeather = true;
    notifyListeners();

    try {
      return Future.wait([
        _fetchWeather(
          lat: basecampKaliangkrik.latitude,
          lon: basecampKaliangkrik.longitude,
          name: 'Basecamp Kaliangkrik',
          elevation: basecampElevation,
        ),
        _fetchWeather(
          lat: puncakSumbing.latitude,
          lon: puncakSumbing.longitude,
          name: 'Puncak Gunung Sumbing',
          elevation: summitElevation,
        ),
      ]);
    } catch (e) {
      if (context.mounted) {
        _showSnack(
          context,
          'Gagal memuat cuaca Gunung Sumbing. Periksa koneksi internet.',
        );
      }
      return null;
    } finally {
      isFetchingWeather = false;
      notifyListeners();
    }
  }

  Future<WeatherData> _fetchWeather({
    required double lat,
    required double lon,
    required String name,
    required double elevation,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toStringAsFixed(4),
      'longitude': lon.toStringAsFixed(4),
      'elevation': elevation.toStringAsFixed(0),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,'
          'precipitation,rain,weather_code,cloud_cover,wind_speed_10m,'
          'wind_direction_10m,wind_gusts_10m',
      'hourly':
          'temperature_2m,precipitation_probability,precipitation,'
          'weather_code,wind_speed_10m,wind_gusts_10m',
      'forecast_hours': '6',
      'timezone': 'auto',
      'wind_speed_unit': 'kmh',
      'precipitation_unit': 'mm',
    });

    final res = await http.get(uri).timeout(_weatherTimeout);
    final decoded = json.decode(res.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Response cuaca tidak valid');
    }

    if (res.statusCode != 200) {
      final reason = decoded['reason'];
      final message = reason is String && reason.isNotEmpty
          ? reason
          : 'Status ${res.statusCode}';
      throw Exception(message);
    }

    return WeatherData.fromOpenMeteo(
      decoded,
      name,
      fallbackElevation: elevation,
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
