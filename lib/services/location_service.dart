import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied) {
        final result = await requestLocationPermission();
        if (!result) return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  // Alias for getCurrentPosition for compatibility
  Future<Position?> getCurrentLocation() async {
    return getCurrentPosition();
  }

  Future<List<Placemark>?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      return placemarks.isNotEmpty ? placemarks : null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      return locations.isNotEmpty ? locations : null;
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  /// Search for properties within a specified radius using distance calculation
  /// radius in kilometers (1, 3, 5, 10 km)
  Stream<List<DocumentSnapshot>> searchNearbyProperties({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    try {
      return FirebaseFirestore.instance
          .collection('properties')
          .where('latitude', isGreaterThan: latitude - radiusKm)
          .where('latitude', isLessThan: latitude + radiusKm)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.where((doc) {
          final docLat = (doc['latitude'] ?? 0.0) as double;
          final docLon = (doc['longitude'] ?? 0.0) as double;
          final distance = calculateDistance(
            lat1: latitude,
            lon1: longitude,
            lat2: docLat,
            lon2: docLon,
          );
          return distance <= radiusKm;
        }).toList();
      }).asBroadcastStream();
    } catch (e) {
      print('Error searching nearby properties: $e');
      return Stream.value([]);
    }
  }

  /// Save property location with GeoPoint for Firestore
  Future<void> savePropertyLocation({
    required String propertyId,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('properties').doc(propertyId).update({
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'geopoint': GeoPoint(latitude, longitude),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving property location: $e');
    }
  }

  /// Get properties within radius with additional filters
  Stream<List<DocumentSnapshot>> searchPropertiesWithFilters({
    required double latitude,
    required double longitude,
    required double radiusKm,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
  }) {
    try {
      var query = FirebaseFirestore.instance.collection('properties')
          .where('status', isEqualTo: 'available')
          .where('latitude', isGreaterThan: latitude - radiusKm)
          .where('latitude', isLessThan: latitude + radiusKm);
      
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }
      if (minBedrooms != null) {
        query = query.where('bedrooms', isGreaterThanOrEqualTo: minBedrooms);
      }
      
      return query.snapshots().map((snapshot) {
        return snapshot.docs.where((doc) {
          final docLat = (doc['latitude'] ?? 0.0) as double;
          final docLon = (doc['longitude'] ?? 0.0) as double;
          final distance = calculateDistance(
            lat1: latitude,
            lon1: longitude,
            lat2: docLat,
            lon2: docLon,
          );
          return distance <= radiusKm;
        }).toList();
      }).asBroadcastStream();
    } catch (e) {
      print('Error searching with filters: $e');
      return Stream.value([]);
    }
  }
}
