import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

/// Location suggestion model
class LocationSuggestion {
  final String id;
  final String name;
  final String address;
  final String? description;
  final GeoPoint coordinates;
  final LocationType type;
  final bool isCampusLocation;

  const LocationSuggestion({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    required this.coordinates,
    required this.type,
    this.isCampusLocation = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'coordinates': coordinates,
      'type': type.name,
      'isCampusLocation': isCampusLocation,
    };
  }

  factory LocationSuggestion.fromMap(Map<String, dynamic> map) {
    return LocationSuggestion(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      description: map['description'],
      coordinates: map['coordinates'] ?? const GeoPoint(0, 0),
      type: LocationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => LocationType.other,
      ),
      isCampusLocation: map['isCampusLocation'] ?? false,
    );
  }
}

/// Location type enumeration
enum LocationType {
  campus,
  residence,
  shopping,
  transport,
  entertainment,
  restaurant,
  other;

  String get displayName {
    switch (this) {
      case LocationType.campus:
        return 'Campus';
      case LocationType.residence:
        return 'Residence';
      case LocationType.shopping:
        return 'Shopping';
      case LocationType.transport:
        return 'Transport';
      case LocationType.entertainment:
        return 'Entertainment';
      case LocationType.restaurant:
        return 'Restaurant';
      case LocationType.other:
        return 'Other';
    }
  }
}

/// Service for managing location-related operations
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Stellenbosch University coordinates
  static const GeoPoint _stellenboschMainCampus = GeoPoint(-33.9321, 18.8602);
  static const double _stellenboschRadius = 25.0; // 25km radius

  /// Predefined campus locations with coordinates
  static final List<LocationSuggestion> _campusLocations = [
    LocationSuggestion(
      id: 'main_campus',
      name: 'Main Campus',
      address: 'Ryneveld Street, Stellenbosch, 7600',
      description: 'Stellenbosch University Main Campus',
      coordinates: const GeoPoint(-33.9321, 18.8602),
      type: LocationType.campus,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      id: 'welgevallen_campus',
      name: 'Welgevallen Campus',
      address: 'Welgevallen Experimental Farm, Stellenbosch',
      description: 'Faculty of AgriSciences',
      coordinates: const GeoPoint(-33.9402, 18.8713),
      type: LocationType.campus,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      id: 'tygerberg_campus',
      name: 'Tygerberg Campus',
      address: 'Francie van Zijl Drive, Tygerberg, 7505',
      description: 'Faculty of Medicine and Health Sciences',
      coordinates: const GeoPoint(-33.8561, 18.5122),
      type: LocationType.campus,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      id: 'medical_campus',
      name: 'Medical Campus',
      address: 'Francie van Zijl Drive, Tygerberg, 7505',
      description: 'Tygerberg Hospital and Medical School',
      coordinates: const GeoPoint(-33.8561, 18.5122),
      type: LocationType.campus,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      id: 'bellville_park_campus',
      name: 'Bellville Park Campus',
      address: 'Carl Cronje Drive, Bellville, 7530',
      description: 'Military Science Faculty',
      coordinates: const GeoPoint(-33.8938, 18.6290),
      type: LocationType.campus,
      isCampusLocation: true,
    ),
  ];

  /// Popular destinations around Stellenbosch
  static final List<LocationSuggestion> _popularDestinations = [
    LocationSuggestion(
      id: 'stellenbosch_central',
      name: 'Stellenbosch Central',
      address: 'Church Street, Stellenbosch Central, 7600',
      coordinates: const GeoPoint(-33.9352, 18.8607),
      type: LocationType.other,
    ),
    LocationSuggestion(
      id: 'eikestad_mall',
      name: 'Eikestad Mall',
      address: 'Andringa Street, Stellenbosch, 7600',
      coordinates: const GeoPoint(-33.9297, 18.8551),
      type: LocationType.shopping,
    ),
    LocationSuggestion(
      id: 'kayamandi',
      name: 'Kayamandi',
      address: 'Kayamandi, Stellenbosch, 7600',
      coordinates: const GeoPoint(-33.9158, 18.8432),
      type: LocationType.residence,
    ),
    LocationSuggestion(
      id: 'cloetesville',
      name: 'Cloetesville',
      address: 'Cloetesville, Stellenbosch, 7600',
      coordinates: const GeoPoint(-33.9445, 18.8389),
      type: LocationType.residence,
    ),
    LocationSuggestion(
      id: 'die_boord',
      name: 'Die Boord',
      address: 'Die Boord, Stellenbosch, 7600',
      coordinates: const GeoPoint(-33.9156, 18.8771),
      type: LocationType.residence,
    ),
    LocationSuggestion(
      id: 'paradyskloof',
      name: 'Paradyskloof',
      address: 'Paradyskloof, Stellenbosch, 7600',
      coordinates: const GeoPoint(-33.9089, 18.8889),
      type: LocationType.residence,
    ),
  ];

  /// Get current location
  Future<GeoPoint> getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return GeoPoint(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  /// Get campus locations
  Future<List<LocationSuggestion>> getCampusLocations() async {
    return List.from(_campusLocations);
  }

  /// Get popular destinations
  Future<List<LocationSuggestion>> getPopularDestinations() async {
    return List.from(_popularDestinations);
  }

  /// Get all predefined locations
  Future<List<LocationSuggestion>> getAllLocations() async {
    final all = <LocationSuggestion>[];
    all.addAll(_campusLocations);
    all.addAll(_popularDestinations);
    return all;
  }

  /// Search locations by query
  Future<List<LocationSuggestion>> searchLocations(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllLocations();
      }

      final queryLower = query.toLowerCase();
      final results = <LocationSuggestion>[];

      // Search in predefined locations first
      final allLocations = await getAllLocations();
      final predefinedResults = allLocations.where((location) =>
          location.name.toLowerCase().contains(queryLower) ||
          location.address.toLowerCase().contains(queryLower) ||
          (location.description?.toLowerCase().contains(queryLower) ?? false))
          .toList();

      results.addAll(predefinedResults);

      // If we have fewer than 3 results, try geocoding
      if (results.length < 3) {
        try {
          final geoResults = await _geocodeQuery(query);
          
          // Filter results to Stellenbosch area
          final localResults = geoResults.where((result) =>
              _isInStellenboschArea(result.coordinates)).toList();
          
          results.addAll(localResults);
        } catch (e) {
          // Geocoding failed, continue with predefined results
        }
      }

      // Remove duplicates and limit results
      final uniqueResults = <LocationSuggestion>[];
      final seenAddresses = <String>{};

      for (final result in results) {
        if (!seenAddresses.contains(result.address.toLowerCase())) {
          seenAddresses.add(result.address.toLowerCase());
          uniqueResults.add(result);
          
          if (uniqueResults.length >= 10) break;
        }
      }

      return uniqueResults;
    } catch (e) {
      throw Exception('Failed to search locations: $e');
    }
  }

  /// Geocode a query string to get coordinates
  Future<List<LocationSuggestion>> _geocodeQuery(String query) async {
    try {
      final locations = await locationFromAddress('$query, Stellenbosch, South Africa');
      final results = <LocationSuggestion>[];

      for (int i = 0; i < locations.length && i < 5; i++) {
        final location = locations[i];
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final address = _formatAddress(placemark);
          
          results.add(LocationSuggestion(
            id: 'geocoded_${location.latitude}_${location.longitude}',
            name: placemark.name ?? query,
            address: address,
            coordinates: GeoPoint(location.latitude, location.longitude),
            type: LocationType.other,
          ));
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Format address from placemark
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      parts.add(placemark.postalCode!);
    }

    return parts.join(', ');
  }

  /// Check if coordinates are within Stellenbosch area
  bool _isInStellenboschArea(GeoPoint coordinates) {
    final distance = Geolocator.distanceBetween(
      _stellenboschMainCampus.latitude,
      _stellenboschMainCampus.longitude,
      coordinates.latitude,
      coordinates.longitude,
    );

    return distance <= (_stellenboschRadius * 1000); // Convert km to meters
  }

  /// Get distance between two points
  double getDistanceBetween(GeoPoint point1, GeoPoint point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Get address from coordinates
  Future<String> getAddressFromCoordinates(GeoPoint coordinates) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        return _formatAddress(placemarks.first);
      }

      return 'Unknown location';
    } catch (e) {
      return 'Unknown location';
    }
  }

  /// Get coordinates from address
  Future<GeoPoint?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress('$address, Stellenbosch, South Africa');
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        return GeoPoint(location.latitude, location.longitude);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermissions() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  Future<bool> requestLocationPermissions() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}