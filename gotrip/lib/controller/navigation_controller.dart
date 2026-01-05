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
  String selectedRoute = 'normal';
  final String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';

  final LatLng basecampKaliangkrik = const LatLng(-7.3800, 110.1500);
  final LatLng pos1 = const LatLng(-7.3820, 110.1400);
  final LatLng pos2 = const LatLng(-7.3835, 110.1300);
  final LatLng pos3 = const LatLng(-7.3840, 110.1200);
  final LatLng puncakSumbing = const LatLng(-7.3847, 110.0755);

  /// ✅ Cek izin lokasi dan mulai tracking
  Future<void> checkPermissionAndStartTracking(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack(context, 'Aktifkan layanan lokasi terlebih dahulu.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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

  Future<WeatherData?> fetchWeather(
    BuildContext context,
    double lat,
    double lon,
    String name,
  ) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return WeatherData.fromJson(data, name);
      } else {
        throw Exception('Gagal memuat data cuaca (${res.statusCode})');
      }
    } catch (e) {
      _showSnack(context, 'Error cuaca: $e');
      return null;
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
