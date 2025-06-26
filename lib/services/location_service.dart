import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a location suggestion
class LocationSuggestion {
  final String address;
  final String? description;
  final GeoPoint? coordinates;
  final LocationType type;
  final bool isCampusLocation;

  const LocationSuggestion({
    required this.address,
    this.description,
    this.coordinates,
    required this.type,
    this.isCampusLocation = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationSuggestion &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;

  @override
  String toString() => address;
}

/// Types of locations
enum LocationType {
  campus,
  residence,
  academic,
  shopping,
  transport,
  restaurant,
  other;
}

/// Service for handling location-related operations
class LocationService {
  // Stellenbosch University campus locations with coordinates
  static const List<LocationSuggestion> _campusLocations = [
    // Main Campus
    LocationSuggestion(
      address: 'Main Campus, Stellenbosch University',
      description: 'Central campus with most faculties',
      coordinates: GeoPoint(-33.9316, 18.8648),
      type: LocationType.campus,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Administration Building, Stellenbosch University',
      description: 'Main admin building',
      coordinates: GeoPoint(-33.9320, 18.8640),
      type: LocationType.academic,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Engineering Faculty, Stellenbosch University',
      description: 'Faculty of Engineering',
      coordinates: GeoPoint(-33.9330, 18.8670),
      type: LocationType.academic,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Business School, Stellenbosch University',
      description: 'USB Business School',
      coordinates: GeoPoint(-33.9340, 18.8630),
      type: LocationType.academic,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Arts and Social Sciences, Stellenbosch University',
      description: 'Faculty of Arts and Social Sciences',
      coordinates: GeoPoint(-33.9310, 18.8620),
      type: LocationType.academic,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Library, Stellenbosch University',
      description: 'JS Gericke Library',
      coordinates: GeoPoint(-33.9325, 18.8645),
      type: LocationType.academic,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Student Centre, Stellenbosch University',
      description: 'Neelsie Student Centre',
      coordinates: GeoPoint(-33.9315, 18.8635),
      type: LocationType.campus,
      isCampusLocation: true,
    ),

    // Welgevallen Campus
    LocationSuggestion(
      address: 'Welgevallen Campus, Stellenbosch University',
      description: 'Sports and recreation campus',
      coordinates: GeoPoint(-33.9280, 18.8580),
      type: LocationType.campus,
      isCampusLocation: true,
    ),

    // Tygerberg Campus
    LocationSuggestion(
      address: 'Tygerberg Campus, Stellenbosch University',
      description: 'Medical campus in Bellville',
      coordinates: GeoPoint(-33.8960, 18.6130),
      type: LocationType.campus,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Medical School, Tygerberg',
      description: 'Faculty of Medicine and Health Sciences',
      coordinates: GeoPoint(-33.8950, 18.6120),
      type: LocationType.academic,
      isCampusLocation: true,
    ),

    // Popular Student Residences
    LocationSuggestion(
      address: 'Huis Marais',
      description: 'Male residence',
      coordinates: GeoPoint(-33.9300, 18.8600),
      type: LocationType.residence,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Goldfields',
      description: 'Male residence',
      coordinates: GeoPoint(-33.9290, 18.8590),
      type: LocationType.residence,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Helshoogte',
      description: 'Female residence',
      coordinates: GeoPoint(-33.9340, 18.8700),
      type: LocationType.residence,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Huis ten Bosch',
      description: 'Female residence',
      coordinates: GeoPoint(-33.9280, 18.8620),
      type: LocationType.residence,
      isCampusLocation: true,
    ),
    LocationSuggestion(
      address: 'Wilgenhof',
      description: 'Male residence',
      coordinates: GeoPoint(-33.9305, 18.8580),
      type: LocationType.residence,
      isCampusLocation: true,
    ),

    // Popular Stellenbosch Areas
    LocationSuggestion(
      address: 'Stellenbosch Central',
      description: 'Town centre',
      coordinates: GeoPoint(-33.9350, 18.8600),
      type: LocationType.other,
    ),
    LocationSuggestion(
      address: 'Dorp Street, Stellenbosch',
      description: 'Historic main street',
      coordinates: GeoPoint(-33.9340, 18.8590),
      type: LocationType.other,
    ),
    LocationSuggestion(
      address: 'Eikestad Mall',
      description: 'Shopping centre',
      coordinates: GeoPoint(-33.9250, 18.8480),
      type: LocationType.shopping,
    ),
    LocationSuggestion(
      address: 'Stellenbosch Square',
      description: 'Shopping and lifestyle centre',
      coordinates: GeoPoint(-33.9180, 18.8420),
      type: LocationType.shopping,
    ),

    // Transport Hubs
    LocationSuggestion(
      address: 'Stellenbosch Train Station',
      description: 'Metro rail station',
      coordinates: GeoPoint(-33.9370, 18.8530),
      type: LocationType.transport,
    ),
    LocationSuggestion(
      address: 'Stellenbosch Taxi Rank',
      description: 'Main taxi terminal',
      coordinates: GeoPoint(-33.9360, 18.8580),
      type: LocationType.transport,
    ),

    // Nearby Areas (for longer trips)
    LocationSuggestion(
      address: 'Somerset West',
      description: 'Nearby town',
      coordinates: GeoPoint(-34.0780, 18.8430),
      type: LocationType.other,
    ),
    LocationSuggestion(
      address: 'Paarl',
      description: 'Nearby town',
      coordinates: GeoPoint(-33.7370, 18.9640),
      type: LocationType.other,
    ),
    LocationSuggestion(
      address: 'Cape Town CBD',
      description: 'Cape Town city centre',
      coordinates: GeoPoint(-33.9249, 18.4241),
      type: LocationType.other,
    ),
    LocationSuggestion(
      address: 'Cape Town International Airport',
      description: 'Main airport',
      coordinates: GeoPoint(-33.9715, 18.6021),
      type: LocationType.transport,
    ),
  ];

  /// Get all campus locations
  Future<List<LocationSuggestion>> getCampusLocations() async {
    // In a real app, this might come from a database or API
    await Future.delayed(Duration(milliseconds: 100)); // Simulate network delay
    return _campusLocations.where((location) => location.isCampusLocation).toList();
  }

  /// Get all predefined locations
  Future<List<LocationSuggestion>> getAllLocations() async {
    await Future.delayed(Duration(milliseconds: 100));
    return List.from(_campusLocations);
  }

  /// Search locations based on query
  Future<List<LocationSuggestion>> searchLocations(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    await Future.delayed(Duration(milliseconds: 200)); // Simulate network delay

    final queryLower = query.toLowerCase().trim();
    
    // Filter locations based on query
    final filteredLocations = _campusLocations.where((location) {
      return location.address.toLowerCase().contains(queryLower) ||
             (location.description?.toLowerCase().contains(queryLower) ?? false);
    }).toList();

    // Sort results: campus locations first, then by relevance
    filteredLocations.sort((a, b) {
      // Campus locations first
      if (a.isCampusLocation && !b.isCampusLocation) return -1;
      if (!a.isCampusLocation && b.isCampusLocation) return 1;
      
      // Then by how early the query appears in the address
      final aIndex = a.address.toLowerCase().indexOf(queryLower);
      final bIndex = b.address.toLowerCase().indexOf(queryLower);
      
      if (aIndex != bIndex) {
        return aIndex.compareTo(bIndex);
      }
      
      // Finally, alphabetically
      return a.address.compareTo(b.address);
    });

    return filteredLocations.take(10).toList(); // Limit results
  }

  /// Get popular destinations for students
  Future<List<LocationSuggestion>> getPopularDestinations() async {
    await Future.delayed(Duration(milliseconds: 100));
    
    final popular = [
      'Main Campus, Stellenbosch University',
      'Stellenbosch Central',
      'Eikestad Mall',
      'Stellenbosch Square',
      'Cape Town CBD',
      'Somerset West',
      'Stellenbosch Train Station',
      'Tygerberg Campus, Stellenbosch University',
    ];

    return _campusLocations
        .where((location) => popular.contains(location.address))
        .toList();
  }

  /// Get locations by type
  Future<List<LocationSuggestion>> getLocationsByType(LocationType type) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _campusLocations.where((location) => location.type == type).toList();
  }

  /// Get nearby locations (placeholder - would use actual geolocation in production)
  Future<List<LocationSuggestion>> getNearbyLocations(GeoPoint userLocation) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    // Simple distance calculation (would use proper geospatial queries in production)
    final nearbyLocations = _campusLocations.where((location) {
      if (location.coordinates == null) return false;
      
      final distance = _calculateDistance(
        userLocation.latitude, 
        userLocation.longitude,
        location.coordinates!.latitude, 
        location.coordinates!.longitude,
      );
      
      return distance <= 5.0; // Within 5km
    }).toList();

    // Sort by distance
    nearbyLocations.sort((a, b) {
      final distanceA = _calculateDistance(
        userLocation.latitude, 
        userLocation.longitude,
        a.coordinates!.latitude, 
        a.coordinates!.longitude,
      );
      final distanceB = _calculateDistance(
        userLocation.latitude, 
        userLocation.longitude,
        b.coordinates!.latitude, 
        b.coordinates!.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

    return nearbyLocations.take(10).toList();
  }

  /// Create a location suggestion from address text
  LocationSuggestion createLocationSuggestion(String address, {GeoPoint? coordinates}) {
    // Check if it's a known campus location
    final knownLocation = _campusLocations.firstWhere(
      (location) => location.address.toLowerCase() == address.toLowerCase(),
      orElse: () => LocationSuggestion(
        address: address,
        coordinates: coordinates,
        type: _inferLocationType(address),
        isCampusLocation: _isCampusAddress(address),
      ),
    );

    return knownLocation;
  }

  /// Validate if an address is reasonable for the Stellenbosch area
  bool validateAddress(String address) {
    if (address.trim().isEmpty) return false;
    if (address.trim().length < 3) return false;
    
    // Basic validation - in production, you might use a geocoding service
    final addressLower = address.toLowerCase();
    
    // Check for common South African location indicators
    final validIndicators = [
      'stellenbosch', 'cape town', 'bellville', 'paarl', 'somerset west',
      'tygerberg', 'campus', 'university', 'street', 'road', 'drive', 'avenue',
      'mall', 'centre', 'center', 'station', 'airport'
    ];
    
    return validIndicators.any((indicator) => addressLower.contains(indicator));
  }

  /// Get route suggestions between two locations
  Future<List<String>> getRouteSuggestions(String origin, String destination) async {
    await Future.delayed(Duration(milliseconds: 150));
    
    // This would typically call a routing service
    // For now, return some basic route suggestions
    return [
      'Via $origin to $destination (Direct)',
      'Via Main Road to $destination',
      'Via R44 to $destination',
    ];
  }

  // === PRIVATE HELPER METHODS ===

  /// Simple distance calculation using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth radius in kilometers
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);

  /// Infer location type from address text
  LocationType _inferLocationType(String address) {
    final addressLower = address.toLowerCase();
    
    if (addressLower.contains('campus') || addressLower.contains('university')) {
      return LocationType.campus;
    } else if (addressLower.contains('residence') || addressLower.contains('huis')) {
      return LocationType.residence;
    } else if (addressLower.contains('faculty') || addressLower.contains('school') || 
               addressLower.contains('library') || addressLower.contains('lab')) {
      return LocationType.academic;
    } else if (addressLower.contains('mall') || addressLower.contains('shop') || 
               addressLower.contains('store')) {
      return LocationType.shopping;
    } else if (addressLower.contains('station') || addressLower.contains('airport') || 
               addressLower.contains('taxi') || addressLower.contains('bus')) {
      return LocationType.transport;
    } else if (addressLower.contains('restaurant') || addressLower.contains('cafe') || 
               addressLower.contains('food')) {
      return LocationType.restaurant;
    } else {
      return LocationType.other;
    }
  }

  /// Check if address is likely a campus location
  bool _isCampusAddress(String address) {
    final addressLower = address.toLowerCase();
    return addressLower.contains('stellenbosch university') ||
           addressLower.contains('campus') ||
           addressLower.contains('tygerberg') ||
           addressLower.contains('welgevallen') ||
           addressLower.contains('huis ') ||
           addressLower.contains('residence');
  }
}