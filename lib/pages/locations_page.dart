import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Locations'),
        backgroundColor: CinemapsTheme.deepSpaceBlack,
      ),
      body: const Center(
        child: Text(
          'Coming Soon: Movie Locations',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
