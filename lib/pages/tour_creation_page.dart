import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/cinemaps_theme.dart';
import '../services/tour_management_service.dart';
import '../widgets/location_selection_dialog.dart';

class TourCreationPage extends StatefulWidget {
  final String userId;

  const TourCreationPage({
    super.key,
    required this.userId,
  });

  @override
  State<TourCreationPage> createState() => _TourCreationPageState();
}

class _TourCreationPageState extends State<TourCreationPage> {
  final TourManagementService _tourService = TourManagementService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPublic = true;
  final List<TourStop> _selectedStops = [];
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _createTour() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a tour name')),
      );
      return;
    }

    if (_selectedStops.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 2 stops to create a tour')),
      );
      return;
    }

    try {
      final tour = await _tourService.createTour(
        name: _nameController.text,
        description: _descriptionController.text,
        creatorId: widget.userId,
        stops: _selectedStops,
        isPublic: _isPublic,
      );

      if (mounted) {
        Navigator.pop(context, tour);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating tour: $e')),
        );
      }
    }
  }

  void _addStop(TourStop stop) {
    setState(() {
      _selectedStops.add(stop);
      _markers.add(
        Marker(
          markerId: MarkerId(stop.id),
          position: stop.location,
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: stop.movieTitle,
          ),
        ),
      );
    });

    // Update map camera to show all markers
    if (_markers.length > 1 && _mapController != null) {
      final bounds = _markers.fold(
        LatLngBounds(
          southwest: _markers.first.position,
          northeast: _markers.first.position,
        ),
        (bounds, marker) => bounds.extend(marker.position),
      );
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    }
  }

  void _removeStop(TourStop stop) {
    setState(() {
      _selectedStops.remove(stop);
      _markers.removeWhere((marker) => marker.markerId.value == stop.id);
    });
  }

  void _reorderStops(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final stop = _selectedStops.removeAt(oldIndex);
      _selectedStops.insert(newIndex, stop);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      appBar: AppBar(
        title: const Text('Create Tour'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tour Name',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
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
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
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
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text(
                    'Public Tour',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Make this tour visible to other users',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  value: _isPublic,
                  onChanged: (value) => setState(() => _isPublic = value),
                  activeColor: CinemapsTheme.hotPink,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'TOUR STOPS',
                          style: TextStyle(
                            color: CinemapsTheme.neonYellow,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: CinemapsTheme.hotPink.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _selectedStops.length,
                          onReorder: _reorderStops,
                          itemBuilder: (context, index) {
                            final stop = _selectedStops[index];
                            return Card(
                              key: ValueKey(stop.id),
                              color: Colors.white.withOpacity(0.05),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: CinemapsTheme.hotPink,
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(
                                  stop.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  stop.movieTitle,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  color: CinemapsTheme.hotPink,
                                  onPressed: () => _removeStop(stop),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(
                  color: CinemapsTheme.hotPink,
                  width: 1,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(0, 0),
                            zoom: 2,
                          ),
                          markers: _markers,
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          border: Border(
                            top: BorderSide(
                              color: CinemapsTheme.hotPink.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Duration: ${_selectedStops.fold(0, (sum, stop) => sum + stop.estimatedDuration)} min',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Stops: ${_selectedStops.length}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _createTour,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CinemapsTheme.hotPink,
                              ),
                              child: const Text('CREATE TOUR'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_mapController == null) return;

          final position = await _mapController!.getVisibleRegion();
          final center = LatLng(
            (position.northeast.latitude + position.southwest.latitude) / 2,
            (position.northeast.longitude + position.southwest.longitude) / 2,
          );

          if (!mounted) return;

          final stop = await showDialog<TourStop>(
            context: context,
            builder: (context) => LocationSelectionDialog(
              initialLocation: center,
            ),
          );

          if (stop != null) {
            _addStop(stop);
          }
        },
        backgroundColor: CinemapsTheme.hotPink,
        child: const Icon(Icons.add_location),
      ),
    );
  }
}
