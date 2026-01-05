import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../controller/navigation_controller.dart';
import '../model/weather_model.dart';
import '../model/route_model.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationController>().checkPermissionAndStartTracking(
        context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NavigationController>();
    final routeData = controller.routeInfo;

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(controller),
          _buildTopInfo(),
          _buildWeatherButton(context, controller),
          _buildTrackingButton(controller),
          _buildRoutePanel(controller, routeData),
        ],
      ),
    );
  }

  Widget _buildMap(NavigationController c) => FlutterMap(
    mapController: c.mapController,
    options: MapOptions(
      initialCenter: LatLng(
        (c.basecampKaliangkrik.latitude + c.puncakSumbing.latitude) / 2,
        (c.basecampKaliangkrik.longitude + c.puncakSumbing.longitude) / 2,
      ),
      initialZoom: 13,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.new_gotrip',
      ),
      PolylineLayer(
        polylines: [
          Polyline(
            points: [
              c.basecampKaliangkrik,
              c.pos1,
              c.pos2,
              c.pos3,
              c.puncakSumbing,
            ],
            color: c.selectedRoute == 'normal' ? Colors.green : Colors.orange,
            strokeWidth: 4,
          ),
        ],
      ),
      MarkerLayer(
        markers: [
          _marker(c.basecampKaliangkrik, Colors.blue, Icons.cabin),
          _marker(c.pos1, Colors.orange, Icons.flag),
          _marker(c.pos2, Colors.orange, Icons.flag),
          _marker(c.pos3, Colors.orange, Icons.flag),
          _marker(c.puncakSumbing, Colors.red, Icons.landscape),
          if (c.currentPosition != null)
            _marker(
              LatLng(c.currentPosition!.latitude, c.currentPosition!.longitude),
              Colors.purple,
              Icons.person_pin_circle,
            ),
        ],
      ),
    ],
  );

  Marker _marker(LatLng point, Color color, IconData icon) => Marker(
    point: point,
    width: 40,
    height: 40,
    child: CircleAvatar(
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );

  Widget _buildTopInfo() => Positioned(
    top: MediaQuery.of(context).padding.top + 10,
    left: 16,
    right: 16,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.blue),
            title: Text('Basecamp Kaliangkrik (1.722 mdpl)'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.terrain, color: Colors.red),
            title: Text('Puncak Gunung Sumbing (3.371 mdpl)'),
          ),
        ],
      ),
    ),
  );

  Widget _buildWeatherButton(BuildContext context, NavigationController c) =>
      Positioned(
        top: MediaQuery.of(context).padding.top + 150,
        right: 16,
        child: FloatingActionButton(
          mini: true,
          onPressed: () async {
            final basecamp = await c.fetchWeather(
              context,
              c.basecampKaliangkrik.latitude,
              c.basecampKaliangkrik.longitude,
              'Basecamp Kaliangkrik',
            );
            final summit = await c.fetchWeather(
              context,
              c.puncakSumbing.latitude,
              c.puncakSumbing.longitude,
              'Puncak Sumbing',
            );

            if (basecamp != null && summit != null) {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => _weatherSheet(basecamp, summit),
              );
            }
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.wb_sunny, color: Colors.orange),
        ),
      );

  Widget _weatherSheet(WeatherData basecamp, WeatherData summit) => Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Kondisi Cuaca Pendakian',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _weatherRow('🏕️', basecamp),
        const SizedBox(height: 12),
        _weatherRow('⛰️', summit),
      ],
    ),
  );

  Widget _weatherRow(String emoji, WeatherData data) => Row(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 32)),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          '${data.locationName}\n${data.temperature.toStringAsFixed(1)}°C - ${data.condition}',
        ),
      ),
    ],
  );

  Widget _buildTrackingButton(NavigationController c) => Positioned(
    top: MediaQuery.of(context).padding.top + 200,
    right: 16,
    child: FloatingActionButton(
      mini: true,
      onPressed: c.toggleTracking,
      backgroundColor: c.isTracking ? Colors.purple : Colors.white,
      heroTag: 'trackingButton',
      child: Icon(
        Icons.my_location,
        color: c.isTracking ? Colors.white : Colors.purple,
      ),
    ),
  );

  Widget _buildRoutePanel(NavigationController c, RouteInfo routeData) =>
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToggleButtons(
                isSelected: [
                  c.selectedRoute == 'normal',
                  c.selectedRoute == 'alternative',
                ],
                onPressed: (index) =>
                    c.changeRoute(index == 0 ? 'normal' : 'alternative'),
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                color: Colors.grey,
                fillColor: routeData.color,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Jalur Utama'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Jalur Alternatif'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                routeData.routeName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: routeData.color,
                ),
              ),
              const SizedBox(height: 8),
              Text('Tingkat Kesulitan: ${routeData.difficulty}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoTile(Icons.timer, routeData.time),
                  _infoTile(Icons.straighten, routeData.distance),
                  _infoTile(Icons.terrain, routeData.elevation),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _infoTile(IconData icon, String text) => Column(
    children: [
      Icon(icon, color: Colors.grey[700]),
      const SizedBox(height: 4),
      Text(text, style: const TextStyle(fontSize: 12)),
    ],
  );
}
