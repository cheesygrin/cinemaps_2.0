import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/cinemaps_theme.dart';
import '../services/tour_management_service.dart';
import '../services/user_data_service.dart';
import '../models/tour.dart';
import 'tour_details_page.dart';

class ToursPage extends StatefulWidget {
  const ToursPage({super.key});

  @override
  State<ToursPage> createState() => _ToursPageState();
}

class _ToursPageState extends State<ToursPage> {
  final TourManagementService _tourService = TourManagementService();
  List<CustomTour> _tours = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Action',
    'Romance',
    'Drama',
    'Sci-Fi',
    'Comedy',
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

  void _loadTours() {
    setState(() {
      if (_selectedCategory == 'All') {
        _tours = _tourService.getRecommendedTours();
      } else {
        _tours = _tourService.getToursByCategory(_selectedCategory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserDataService>(context).currentUserId;
    
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      appBar: AppBar(
        title: const Text('Movie Tours'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                Provider.of<TourManagementService>(context, listen: false)
                    .setSearchQuery(value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search tours...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: CinemapsTheme.neonYellow),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Category Filter
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _loadTours();
                      });
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: CinemapsTheme.neonYellow,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Tours Grid
          Expanded(
            child: _tours.isEmpty
                ? const Center(
                    child: Text(
                      'No tours available in this category',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _tours.length,
                    itemBuilder: (context, index) {
                      final tour = _tours[index];
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TourDetailsPage(
                                tour: tour,
                                userId: userId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.grey[900],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tour Image
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                  child: Image.network(
                                    tour.imageUrl ?? 'https://via.placeholder.com/400x200?text=No+Image',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: Colors.grey.shade800,
                                        child: const Center(
                                          child: Icon(
                                            Icons.movie_outlined,
                                            color: Colors.white70,
                                            size: 48,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              
                              // Tour Info
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tour.title,
                                        style: const TextStyle(
                                          color: CinemapsTheme.neonYellow,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${tour.stops.length} stops • ${tour.estimatedDuration} min',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            tour.rating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
