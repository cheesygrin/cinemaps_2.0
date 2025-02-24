import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/cinemaps_theme.dart';
import '../services/tour_management_service.dart';
import 'tour_details_page.dart';
import 'category_tours_page.dart';

class TourCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const TourCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class TourDiscoveryPage extends StatefulWidget {
  final String userId;

  const TourDiscoveryPage({
    super.key,
    required this.userId,
  });

  @override
  State<TourDiscoveryPage> createState() => _TourDiscoveryPageState();
}

class _TourDiscoveryPageState extends State<TourDiscoveryPage> {
  final TourManagementService _tourService = TourManagementService();
  final TextEditingController _searchController = TextEditingController();
  List<CustomTour> _popularTours = [];
  List<CustomTour> _nearbyTours = [];
  List<CustomTour> _recommendedTours = [];
  bool _isLoading = false;
  LatLng? _currentLocation;

  final List<TourCategory> _categories = [
    const TourCategory(
      id: 'action',
      name: 'Action Movies',
      description: 'Epic chase scenes and explosive locations',
      icon: Icons.local_fire_department,
      color: Colors.orange,
    ),
    const TourCategory(
      id: 'romance',
      name: 'Romance',
      description: 'Iconic romantic movie locations',
      icon: Icons.favorite,
      color: Colors.pink,
    ),
    const TourCategory(
      id: 'scifi',
      name: 'Sci-Fi',
      description: 'Futuristic and otherworldly settings',
      icon: Icons.rocket,
      color: Colors.purple,
    ),
    const TourCategory(
      id: 'classic',
      name: 'Classics',
      description: 'Timeless movie locations',
      icon: Icons.star,
      color: Colors.amber,
    ),
    const TourCategory(
      id: 'horror',
      name: 'Horror',
      description: 'Spooky and thrilling locations',
      icon: Icons.dark_mode,
      color: Colors.grey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTours() async {
    setState(() => _isLoading = true);
    try {
      // Simulate getting user's location
      _currentLocation = const LatLng(40.7128, -74.0060); // New York City

      // Load tours near the user
      if (_currentLocation != null) {
        _nearbyTours = _tourService.getToursNearLocation(
          _currentLocation!,
          5.0, // 5km radius
        );
      }

      // Load recommended tours based on user preferences
      _recommendedTours = await _tourService.getRecommendations(
        userId: widget.userId,
      );

      // Sort tours by rating to get popular tours
      _popularTours = _tourService.getUserTours(widget.userId)
        ..sort((a, b) => b.rating.compareTo(a.rating));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: CinemapsTheme.hotPink.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search tours...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
          suffixIcon: IconButton(
            icon: Icon(Icons.tune, color: Colors.white.withOpacity(0.5)),
            onPressed: _showFilterDialog,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: CinemapsTheme.hotPink.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: CinemapsTheme.hotPink.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: CinemapsTheme.hotPink,
            ),
          ),
        ),
        onChanged: (value) {
          // TODO: Implement search functionality
        },
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryToursPage(
                  categoryId: category.id,
                  categoryName: category.name,
                  userId: widget.userId,
                  icon: category.icon,
                  color: category.color,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: category.color.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  color: category.color,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTourList(String title, List<CustomTour> tours) {
    if (tours.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              color: CinemapsTheme.neonYellow,
              fontSize: 20,
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
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return SizedBox(
                width: 280,
                child: Card(
                  color: Colors.white.withOpacity(0.05),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TourDetailsPage(
                            tour: tour,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: tour.imageUrl != null
                              ? Image.network(
                                  tour.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: CinemapsTheme.hotPink.withOpacity(0.2),
                                  child: const Icon(
                                    Icons.movie_filter,
                                    color: CinemapsTheme.hotPink,
                                    size: 48,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tour.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tour.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: CinemapsTheme.neonYellow,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${tour.rating}/5',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.timer,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${tour.totalDuration} min',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${tour.stops.length} stops',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: const Text(
          'Filter Tours',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Coming soon: Advanced tour filtering',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Filter by duration, distance, rating, and more!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: CinemapsTheme.hotPink),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                const SliverAppBar(
                  title: Text('Discover Tours'),
                  backgroundColor: Colors.transparent,
                  floating: true,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      _buildCategoryGrid(),
                      _buildTourList('NEARBY TOURS', _nearbyTours),
                      _buildTourList('RECOMMENDED FOR YOU', _recommendedTours),
                      _buildTourList('POPULAR TOURS', _popularTours),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
