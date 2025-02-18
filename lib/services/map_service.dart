import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class MapService {
  static const defaultLocation = LatLng(40.7128, -74.0060); // New York City
  static const defaultZoom = 12.0;

  static final DefaultCacheManager _cacheManager = DefaultCacheManager();

  // Convert address to coordinates
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
    }
    return null;
  }

  // Get user's current location
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  // Create custom marker icon
  static Future<BitmapDescriptor> createCustomMarkerIcon({
    required bool isMovie,
    required double rating,
    bool useCustomDesign = false,
  }) async {
    if (!useCustomDesign) {
      return BitmapDescriptor.defaultMarkerWithHue(
        isMovie ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueRose,
      );
    }

    final Color markerColor = isMovie ? Colors.red : Colors.blue;
    final double size = 120;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = markerColor;

    // Draw marker background
    canvas.drawCircle(Offset(size / 2, size / 2), size / 3, paint);

    // Draw rating text
    final textPainter = TextPainter(
      text: TextSpan(
        text: rating.toStringAsFixed(1),
        style: TextStyle(
          color: Colors.white,
          fontSize: size / 4,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final img = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  // Calculate distance between two points
  static double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // Create marker info window
  static InfoWindow createInfoWindow({
    required String title,
    required String snippet,
  }) {
    return InfoWindow(
      title: title,
      snippet: snippet,
    );
  }

  // Group nearby markers (simple clustering)
  static List<Marker> clusterMarkers({
    required List<Marker> markers,
    required double clusterRadius, // in meters
  }) {
    if (markers.length <= 1) return markers;

    List<Marker> clusteredMarkers = [];
    List<bool> processed = List.filled(markers.length, false);

    for (int i = 0; i < markers.length; i++) {
      if (processed[i]) continue;

      List<Marker> cluster = [markers[i]];
      processed[i] = true;

      for (int j = i + 1; j < markers.length; j++) {
        if (processed[j]) continue;

        double distance = calculateDistance(
          markers[i].position,
          markers[j].position,
        );

        if (distance <= clusterRadius) {
          cluster.add(markers[j]);
          processed[j] = true;
        }
      }

      if (cluster.length == 1) {
        clusteredMarkers.add(cluster.first);
      } else {
        // Create a cluster marker
        clusteredMarkers.add(
          Marker(
            markerId: MarkerId('cluster_$i'),
            position: _calculateClusterCenter(cluster),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
            infoWindow: InfoWindow(
              title: 'Location Cluster',
              snippet: '${cluster.length} locations in this area',
            ),
          ),
        );
      }
    }

    return clusteredMarkers;
  }

  // Calculate the center point of a cluster
  static LatLng _calculateClusterCenter(List<Marker> cluster) {
    double lat = 0;
    double lng = 0;

    for (var marker in cluster) {
      lat += marker.position.latitude;
      lng += marker.position.longitude;
    }

    return LatLng(
      lat / cluster.length,
      lng / cluster.length,
    );
  }
}
