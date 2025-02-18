import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/check_in.dart';
import '../services/check_in_service.dart';
import '../theme/cinemaps_theme.dart';
import 'photo_upload_dialog.dart';

class CheckInDialog extends StatefulWidget {
  final String userId;
  final String locationId;
  final String movieId;
  final String locationName;
  final LatLng coordinates;

  const CheckInDialog({
    super.key,
    required this.userId,
    required this.locationId,
    required this.movieId,
    required this.locationName,
    required this.coordinates,
  });

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  final _noteController = TextEditingController();
  List<String> _photos = [];
  CheckInPrivacy _privacy = CheckInPrivacy.public;
  final List<String> _tags = [];
  bool _isCheckinIn = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn() async {
    if (_isCheckinIn) return;

    setState(() {
      _isCheckinIn = true;
    });

    try {
      final checkInService = context.read<CheckInService>();
      final checkIn = await checkInService.checkIn(
        userId: widget.userId,
        locationId: widget.locationId,
        movieId: widget.movieId,
        userLocation: widget.coordinates,
        note: _noteController.text.trim(),
        photos: _photos,
        privacy: _privacy,
        tags: _tags,
      );

      if (!mounted) return;

      // Show success dialog with points and badges
      await showDialog(
        context: context,
        builder: (context) => _CheckInSuccessDialog(checkIn: checkIn!),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckinIn = false;
        });
      }
    }
  }

  Future<void> _addPhotos() async {
    final photos = await showDialog<List<String>>(
      context: context,
      builder: (context) => PhotoUploadDialog(
        locationId: widget.locationId,
        userId: widget.userId,
        onUpload: (photo, caption, tags) async {
          // TODO: Handle photo upload
          return;
        },
      ),
    );

    if (photos != null) {
      setState(() {
        _photos = [..._photos, ...photos];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Check In at ${widget.locationName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a note about your visit...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CinemapsTheme.hotPink),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_camera),
                    label: Text('Add Photos (${_photos.length})'),
                    onPressed: _addPhotos,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CheckInPrivacy>(
              value: _privacy,
              dropdownColor: CinemapsTheme.deepSpaceBlack,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Privacy',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: CheckInPrivacy.public,
                  child: Text('Public'),
                ),
                DropdownMenuItem(
                  value: CheckInPrivacy.friends,
                  child: Text('Friends Only'),
                ),
                DropdownMenuItem(
                  value: CheckInPrivacy.private,
                  child: Text('Private'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _privacy = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isCheckinIn ? null : _handleCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: CinemapsTheme.hotPink,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isCheckinIn
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Check In',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInSuccessDialog extends StatelessWidget {
  final CheckIn checkIn;

  const _CheckInSuccessDialog({
    required this.checkIn,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: CinemapsTheme.hotPink,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Check-in Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+${checkIn.points} points',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (checkIn.unlockedBadges.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'New Badges Unlocked!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: checkIn.unlockedBadges.map((badgeId) {
                  return Chip(
                    backgroundColor: Colors.amber,
                    label: Text(badgeId),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: CinemapsTheme.hotPink,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
