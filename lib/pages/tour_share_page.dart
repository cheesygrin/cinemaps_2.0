import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tour.dart';
import '../services/social_service.dart';
import '../services/user_data_service.dart';
import '../theme/cinemaps_theme.dart';

class TourSharePage extends StatefulWidget {
  final CustomTour tour;
  final List<String> photos;
  final double rating;

  const TourSharePage({
    super.key,
    required this.tour,
    required this.photos,
    required this.rating,
  });

  @override
  State<TourSharePage> createState() => _TourSharePageState();
}

class _TourSharePageState extends State<TourSharePage> {
  final TextEditingController _captionController = TextEditingController();
  final List<String> _selectedPhotos = [];
  bool _isSharing = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _shareTour() async {
    if (_captionController.text.isEmpty && _selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a caption or select photos to share'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSharing = true);

    try {
      final userId =
          Provider.of<UserDataService>(context, listen: false).currentUserId;
      final socialService = Provider.of<SocialService>(context, listen: false);

      // Create the social post
      await socialService.createPost(
        content: _captionController.text,
        imageUrl: _selectedPhotos.isNotEmpty ? _selectedPhotos.first : null,
      );

      // Share the tour
      await socialService.shareTour(userId, widget.tour.id);

      // Upload additional photos if any
      for (final photoUrl in _selectedPhotos.skip(1)) {
        await socialService.uploadPhoto(
          userId: userId,
          locationId: widget.tour.stops.first.id,
          photoUrl: photoUrl,
          caption: widget.tour.title,
          tags: [
            'tour',
            'movies',
            widget.tour.title.toLowerCase().replaceAll(' ', '')
          ],
        );
      }

      // Add activity points
      socialService.addPoints(userId, 50);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing tour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      appBar: AppBar(
        title: const Text('Share Tour Experience'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: CinemapsTheme.neonYellow,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send),
            onPressed: _isSharing ? null : _shareTour,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour Info Card
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tour.title,
                      style: const TextStyle(
                        color: CinemapsTheme.neonYellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.tour.stops.length} stops • ${widget.tour.estimatedDuration} min',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 20,
                            color: index < widget.rating
                                ? Colors.amber
                                : Colors.grey[600],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Caption Input
            TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Photos Grid
            const Text(
              'Select Photos to Share',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.photos.length,
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                final isSelected = _selectedPhotos.contains(photo);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedPhotos.remove(photo);
                      } else {
                        _selectedPhotos.add(photo);
                      }
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        photo,
                        fit: BoxFit.cover,
                      ),
                      if (isSelected)
                        Container(
                          color: CinemapsTheme.neonYellow.withOpacity(0.5),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
