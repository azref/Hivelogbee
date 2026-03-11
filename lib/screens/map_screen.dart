import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../providers/hive_provider.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import 'hive_details_screen.dart'; // <-- استيراد ضروري لـ _onHiveMarkerTapped

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<ApiaryCluster> _clusters = [];
  bool _showClusters = false;
  WeatherData? _currentWeather;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadWeather();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers();
    });
  }

  Future<void> _loadWeather() async {
    final weather = await WeatherService.getCurrentWeather();
    if (mounted) {
      setState(() => _currentWeather = weather);
    }
  }

  Future<void> _updateMarkers() async {
    if (!mounted) return;
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    final hives = hiveProvider.hives;

    List<HiveLocationData> locationData = hives
        .where((hive) => hive.latitude != null && hive.longitude != null)
        .where((hive) => _filterHive(hive))
        .map((hive) => HiveLocationData(
      id: hive.id,
      number: hive.hiveNumber,
      latitude: hive.latitude!,
      longitude: hive.longitude!,
      type: hive.isNucleus ? 'nucleus' : 'hive',
      status: hive.status.name,
      frameCount: hive.frameCount,
      address: hive.location,
    ))
        .toList();

    if (_showClusters && locationData.length > 5) {
      _clusters = await LocationService.clusterHives(locationData, 1.0);
      _markers = _createClusterMarkers();
    } else {
      _markers = LocationService.createHiveMarkers(
        locationData,
        onMarkerTapped: _onHiveMarkerTapped,
      );
    }

    if (_mapController != null && locationData.isNotEmpty) {
      final positions = locationData.map((h) => LatLng(h.latitude, h.longitude)).toList();
      final cameraPosition = LocationService.calculateCameraPosition(positions);
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }

    setState(() {});
  }

  bool _filterHive(HiveModel hive) {
    switch (_selectedFilter) {
      case 'active':
        return hive.status == HiveStatus.active;
      case 'nucleus':
        return hive.isNucleus;
      case 'problems':
        return hive.tags.contains('problem');
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveProvider>(
      builder: (context, hiveProvider, child) {
        return Column(
          children: [
            _buildWeatherBar(),
            _buildFilterBar(),
            Expanded(child: _buildMap(hiveProvider.isLoading)),
          ],
        );
      },
    );
  }

  Widget _buildMap(bool isLoading) {
    if (isLoading && _markers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: const CameraPosition(target: LatLng(24.7136, 46.6753), zoom: 10),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  // --- تمت إعادة هذه الدوال بالكامل ---
  Widget _buildWeatherBar() {
    if (_currentWeather == null) return const SizedBox.shrink();
    final advice = WeatherService.getBeekeepingAdvice(_currentWeather!);
    final icon = WeatherService.getWeatherIcon(_currentWeather!.condition);
    return Container(
      padding: const EdgeInsets.all(8),
      color: advice.isGoodForInspection ? Colors.green[50] : Colors.orange[50],
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_currentWeather!.temperature.round()}°C - ${_currentWeather!.description}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Text(advice.advice, style: const TextStyle(fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildFilterChip('الكل', 'all'),
          _buildFilterChip('نشطة', 'active'),
          _buildFilterChip('طرود', 'nucleus'),
          _buildFilterChip('مشاكل', 'problems'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 8, color: isSelected ? Colors.white : Colors.black87)),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
          _updateMarkers();
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.amber[700],
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Set<Marker> _createClusterMarkers() {
    return _clusters.map((cluster) {
      return Marker(
        markerId: MarkerId(cluster.id),
        position: cluster.center,
        infoWindow: InfoWindow(title: '${cluster.hiveCount} خلايا', snippet: '${cluster.activeHives} نشطة'),
        onTap: () => _onClusterMarkerTapped(cluster),
      );
    }).toSet();
  }

  void _onHiveMarkerTapped(String hiveId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HiveDetailsScreen(hiveId: hiveId)));
  }

  void _onClusterMarkerTapped(ApiaryCluster cluster) {
    // ... (منطق عرض الـ bottom sheet)
  }
}
