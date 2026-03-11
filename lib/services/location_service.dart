import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedForeverException();
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return _formatAddress(placemark);
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return null;
  }

  static Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  static String _formatAddress(Placemark placemark) {
    List<String> addressParts = [];
    
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressParts.add(placemark.country!);
    }
    
    return addressParts.join(', ');
  }

  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} متر';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} كم';
    }
  }

  static LatLng? parseCoordinates(String? coordinates) {
    if (coordinates == null || coordinates.isEmpty) return null;
    
    try {
      final parts = coordinates.split(',');
      if (parts.length == 2) {
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        return LatLng(lat, lng);
      }
    } catch (e) {
      print('Error parsing coordinates: $e');
    }
    
    return null;
  }

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  static Set<Marker> createHiveMarkers(List<HiveLocationData> hives, {
    Function(String)? onMarkerTapped,
  }) {
    return hives.map((hive) {
      return Marker(
        markerId: MarkerId(hive.id),
        position: LatLng(hive.latitude, hive.longitude),
        infoWindow: InfoWindow(
          title: 'خلية رقم ${hive.number}',
          snippet: '${hive.status} - ${hive.frameCount} إطار',
        ),
        icon: _getHiveMarkerIcon(hive.type, hive.status),
        onTap: () => onMarkerTapped?.call(hive.id),
      );
    }).toSet();
  }

  static BitmapDescriptor _getHiveMarkerIcon(String type, String status) {
    if (type == 'nucleus') {
      return status == 'active' 
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else {
      return status == 'active'
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  static LatLngBounds calculateBounds(List<LatLng> positions) {
    if (positions.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(0, 0),
      );
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final position in positions) {
      minLat = math.min(minLat, position.latitude);
      maxLat = math.max(maxLat, position.latitude);
      minLng = math.min(minLng, position.longitude);
      maxLng = math.max(maxLng, position.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  static CameraPosition calculateCameraPosition(List<LatLng> positions) {
    if (positions.isEmpty) {
      return const CameraPosition(
        target: LatLng(24.7136, 46.6753), // Riyadh, Saudi Arabia
        zoom: 10,
      );
    }

    if (positions.length == 1) {
      return CameraPosition(
        target: positions.first,
        zoom: 15,
      );
    }

    final bounds = calculateBounds(positions);
    final center = LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );

    double zoom = _calculateZoomLevel(bounds);

    return CameraPosition(
      target: center,
      zoom: zoom,
    );
  }

  static double _calculateZoomLevel(LatLngBounds bounds) {
    const double padding = 0.1;
    
    final double latDiff = bounds.northeast.latitude - bounds.southwest.latitude;
    final double lngDiff = bounds.northeast.longitude - bounds.southwest.longitude;
    
    final double maxDiff = math.max(latDiff, lngDiff) + padding;
    
    if (maxDiff > 10) return 5;
    if (maxDiff > 5) return 7;
    if (maxDiff > 2) return 9;
    if (maxDiff > 1) return 11;
    if (maxDiff > 0.5) return 13;
    if (maxDiff > 0.1) return 15;
    return 17;
  }

  static List<HiveLocationData> filterHivesByDistance(
    List<HiveLocationData> hives,
    LatLng center,
    double maxDistanceKm,
  ) {
    return hives.where((hive) {
      final distance = calculateDistance(
        center.latitude,
        center.longitude,
        hive.latitude,
        hive.longitude,
      );
      return distance <= maxDistanceKm * 1000;
    }).toList();
  }

  static List<HiveLocationData> sortHivesByDistance(
    List<HiveLocationData> hives,
    LatLng center,
  ) {
    hives.sort((a, b) {
      final distanceA = calculateDistance(
        center.latitude,
        center.longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = calculateDistance(
        center.latitude,
        center.longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
    return hives;
  }

  static Future<List<ApiaryCluster>> clusterHives(
    List<HiveLocationData> hives,
    double clusterRadiusKm,
  ) async {
    List<ApiaryCluster> clusters = [];
    List<HiveLocationData> unprocessed = List.from(hives);

    while (unprocessed.isNotEmpty) {
      final center = unprocessed.first;
      unprocessed.removeAt(0);

      List<HiveLocationData> clusterHives = [center];
      
      unprocessed.removeWhere((hive) {
        final distance = calculateDistance(
          center.latitude,
          center.longitude,
          hive.latitude,
          hive.longitude,
        );
        
        if (distance <= clusterRadiusKm * 1000) {
          clusterHives.add(hive);
          return true;
        }
        return false;
      });

      final clusterCenter = _calculateClusterCenter(clusterHives);
      final address = await getAddressFromCoordinates(
        clusterCenter.latitude,
        clusterCenter.longitude,
      );

      clusters.add(ApiaryCluster(
        id: 'cluster_${clusters.length}',
        center: clusterCenter,
        hives: clusterHives,
        address: address ?? 'موقع غير محدد',
      ));
    }

    return clusters;
  }

  static LatLng _calculateClusterCenter(List<HiveLocationData> hives) {
    double totalLat = 0;
    double totalLng = 0;

    for (final hive in hives) {
      totalLat += hive.latitude;
      totalLng += hive.longitude;
    }

    return LatLng(
      totalLat / hives.length,
      totalLng / hives.length,
    );
  }

  static bool isValidCoordinate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  static String getCardinalDirection(double bearing) {
    const directions = [
      'شمال', 'شمال شرق', 'شرق', 'جنوب شرق',
      'جنوب', 'جنوب غرب', 'غرب', 'شمال غرب'
    ];
    
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  static double calculateBearing(double lat1, double lng1, double lat2, double lng2) {
    final dLng = (lng2 - lng1) * (math.pi / 180);
    final lat1Rad = lat1 * (math.pi / 180);
    final lat2Rad = lat2 * (math.pi / 180);

    final y = math.sin(dLng) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) - 
              math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLng);

    final bearing = math.atan2(y, x) * (180 / math.pi);
    return (bearing + 360) % 360;
  }
}

class HiveLocationData {
  final String id;
  final String number;
  final double latitude;
  final double longitude;
  final String type;
  final String status;
  final int frameCount;
  final String? address;

  HiveLocationData({
    required this.id,
    required this.number,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.status,
    required this.frameCount,
    this.address,
  });
}

class ApiaryCluster {
  final String id;
  final LatLng center;
  final List<HiveLocationData> hives;
  final String address;

  ApiaryCluster({
    required this.id,
    required this.center,
    required this.hives,
    required this.address,
  });

  int get hiveCount => hives.length;
  int get activeHives => hives.where((h) => h.status == 'active').length;
  int get totalFrames => hives.fold(0, (sum, h) => sum + h.frameCount);
}

class LocationServiceDisabledException implements Exception {
  @override
  String toString() => 'خدمة الموقع غير مفعلة';
}

class LocationPermissionDeniedException implements Exception {
  @override
  String toString() => 'تم رفض إذن الموقع';
}

class LocationPermissionDeniedForeverException implements Exception {
  @override
  String toString() => 'تم رفض إذن الموقع نهائياً';
}
