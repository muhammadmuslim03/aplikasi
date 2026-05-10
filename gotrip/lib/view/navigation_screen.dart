import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
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
            color: Colors.black.withValues(alpha: 0.1),
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

  Widget _buildWeatherButton(
    BuildContext context,
    NavigationController c,
  ) => Positioned(
    top: MediaQuery.of(context).padding.top + 150,
    right: 16,
    child: FloatingActionButton(
      heroTag: 'weatherButton',
      tooltip: 'Cuaca Gunung Sumbing',
      mini: true,
      onPressed: c.isFetchingWeather
          ? null
          : () async {
              final weather = await c.fetchSumbingWeather(context);
              if (!context.mounted || weather == null || weather.length < 2) {
                return;
              }

              final basecamp = weather[0];
              final summit = weather[1];

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (sheetContext) =>
                    _weatherSheet(sheetContext, basecamp, summit),
              );
            },
      backgroundColor: Colors.white,
      child: c.isFetchingWeather
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            )
          : const Icon(Icons.cloud_outlined, color: Colors.orange),
    ),
  );

  Widget _weatherSheet(
    BuildContext sheetContext,
    WeatherData basecamp,
    WeatherData summit,
  ) => SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(sheetContext).size.height * 0.82,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Cuaca Gunung Sumbing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _weatherCard(
              basecamp,
              icon: Icons.cabin,
              color: const Color(0xFF1D4F44),
            ),
            const SizedBox(height: 12),
            _weatherCard(summit, icon: Icons.terrain, color: Colors.red),
            const SizedBox(height: 18),
            _forecastSection(summit),
            const SizedBox(height: 14),
            _weatherNote(),
          ],
        ),
      ),
    ),
  );

  Widget _weatherCard(
    WeatherData data, {
    required IconData icon,
    required Color color,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06),
      border: Border.all(color: color.withValues(alpha: 0.18)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.locationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${data.elevation.toStringAsFixed(0)} mdpl - ${_formatWeatherTime(data.time)}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              _weatherIcon(data.weatherCode, isDay: data.isDay),
              color: color,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          _formatTemperature(data.temperature),
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data.condition,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _weatherMetric(
              Icons.thermostat,
              'Terasa',
              _formatTemperature(data.apparentTemperature),
            ),
            _weatherMetric(
              Icons.opacity,
              'Hujan',
              '${data.precipitation.toStringAsFixed(1)} mm',
            ),
            _weatherMetric(Icons.water_drop, 'Lembap', '${data.humidity}%'),
            _weatherMetric(
              Icons.air,
              'Angin',
              '${data.windSpeed.toStringAsFixed(0)} km/jam',
            ),
            _weatherMetric(
              Icons.speed,
              'Hembusan',
              '${data.windGusts.toStringAsFixed(0)} km/jam',
            ),
            _weatherMetric(Icons.cloud, 'Awan', '${data.cloudCover}%'),
          ],
        ),
      ],
    ),
  );

  Widget _weatherMetric(IconData icon, String label, String value) => Container(
    width: 140,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.76),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 11),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _forecastSection(WeatherData summit) {
    if (summit.hourlyForecast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prakiraan Puncak 6 Jam',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...summit.hourlyForecast.map(_forecastRow),
      ],
    );
  }

  Widget _forecastRow(WeatherForecastHour forecast) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7F6),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            _formatHour(forecast.time),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Icon(_weatherIcon(forecast.weatherCode), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                forecast.condition,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'Hujan ${forecast.precipitationProbability}% - angin ${forecast.windSpeed.toStringAsFixed(0)} km/jam',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTemperature(forecast.temperature),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  Widget _weatherNote() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.amber[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.amber.shade200),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, color: Colors.amber[800], size: 20),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Prakiraan dapat berubah cepat di gunung. Konfirmasi kondisi terakhir ke petugas basecamp sebelum mulai pendakian.',
            style: TextStyle(fontSize: 12, height: 1.35),
          ),
        ),
      ],
    ),
  );

  IconData _weatherIcon(int weatherCode, {bool isDay = true}) {
    if (weatherCode == 0) return isDay ? Icons.wb_sunny : Icons.nights_stay;
    if (weatherCode == 45 || weatherCode == 48) return Icons.blur_on;
    if (weatherCode >= 95) return Icons.flash_on;
    if (_isRainCode(weatherCode)) return Icons.grain;
    return Icons.wb_cloudy;
  }

  bool _isRainCode(int weatherCode) {
    const rainCodes = <int>{
      51,
      53,
      55,
      56,
      57,
      61,
      63,
      65,
      66,
      67,
      71,
      73,
      75,
      77,
      80,
      81,
      82,
      85,
      86,
    };

    return rainCodes.contains(weatherCode);
  }

  String _formatWeatherTime(DateTime time) =>
      DateFormat('dd MMM HH:mm', 'id').format(time);

  String _formatHour(DateTime time) => DateFormat('HH:mm', 'id').format(time);

  String _formatTemperature(double temperature) =>
      '${temperature.toStringAsFixed(1)}°C';

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
