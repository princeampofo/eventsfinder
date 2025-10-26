import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class LocationService {
  // Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Get user's current location
  Future<Position?> getUserLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permission
      bool hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        // Request permission
        hasPermission = await requestLocationPermission();
        if (!hasPermission) {
          return null;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  // Returns distance in kilometers
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;

    // Convert degrees to radians
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    lat1 = _degreesToRadians(lat1);
    lat2 = _degreesToRadians(lat2);

    // Haversine formula
    double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadiusKm * c;

    return distance;
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Format distance for display
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      // Show in meters if less than 1 km
      int meters = (distanceKm * 1000).round();
      return '$meters m';
    } else if (distanceKm < 10) {
      // Show 1 decimal place for distances under 10 km
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      // Show whole number for distances over 10 km
      return '${distanceKm.round()} km';
    }
  }

  // Open app settings for manual permission grant
  Future<void> openSettings() async {
    await openAppSettings();
  }
}