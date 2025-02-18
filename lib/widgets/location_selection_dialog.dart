import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/cinemaps_theme.dart';
import '../services/tour_management_service.dart';

class LocationSelectionDialog extends StatefulWidget {
  final LatLng initialLocation;

  const LocationSelectionDialog({
    super.key,
    required this.initialLocation,
  });

  @override
  State<LocationSelectionDialog> createState() => _LocationSelectionDialogState();
}

class _LocationSelectionDialogState extends State<LocationSelectionDialog> {
  final TourManagementService _tourService = TourManagementService();
  final TextEditingController _searchController = TextEditingController();
  List<TourStop> _nearbyStops = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNearbyStops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyStops() async {
    setState(() => _isLoading = true);
    try {
      final stops = _tourService.getStopsNearLocation(
        widget.initialLocation,
        5.0, // 5km radius
      );
      setState(() => _nearbyStops = stops);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStopCard(TourStop stop) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      child: ListTile(
        leading: stop.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  stop.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CinemapsTheme.hotPink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.movie,
                  color: CinemapsTheme.hotPink,
                ),
              ),
        title: Text(
          stop.name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stop.movieTitle,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            Text(
              '${stop.estimatedDuration} min',
              style: TextStyle(
                color: CinemapsTheme.hotPink.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () => Navigator.pop(context, stop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Add Stop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search locations...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: CinemapsTheme.hotPink.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: CinemapsTheme.hotPink.withOpacity(0.3),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: CinemapsTheme.hotPink),
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'NEARBY LOCATIONS',
              style: TextStyle(
                color: CinemapsTheme.neonYellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_nearbyStops.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No locations found nearby',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _nearbyStops.length,
                  itemBuilder: (context, index) {
                    return _buildStopCard(_nearbyStops[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
