import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteService {
  static const apiUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  
  static Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
  }) async {
    final url = Uri.parse(
      '$apiUrl?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&key=$apiKey'
    );
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final points = _decodePolyline(
            data['routes'][0]['overview_polyline']['points']
          );
          return points;
        }
      }
    } catch (e) {
      debugPrint('Error getting route: $e');
    }
    
    return [];
  }
  
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    
    return points;
  }
  
  static String generateShareableLink({
    required String locationId,
    required LatLng position,
  }) {
    final params = {
      'id': locationId,
      'lat': position.latitude.toString(),
      'lng': position.longitude.toString(),
    };
    
    return 'https://cinemaps.app/location?${Uri(queryParameters: params)}';
  }
  
  static Future<void> shareLocation({
    required String locationId,
    required String title,
    required LatLng position,
  }) async {
    final link = generateShareableLink(
      locationId: locationId,
      position: position,
    );
    
    // Here you would implement the actual sharing functionality
    // using a platform-specific sharing plugin
    debugPrint('Sharing location: $title\n$link');
  }
}
