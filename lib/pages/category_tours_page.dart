import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../services/tour_management_service.dart';
import '../models/custom_tour.dart';
import 'tour_details_page.dart';

class CategoryToursPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String userId;
  final IconData icon;
  final Color color;

  const CategoryToursPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.userId,
    required this.icon,
    required this.color,
  });

  @override
  State<CategoryToursPage> createState() => _CategoryToursPageState();
}

class _CategoryToursPageState extends State<CategoryToursPage> {
  final TourManagementService _tourService = TourManagementService();
  List<CustomTour> _tours = [];
  bool _isLoading = false;
  String _sortBy = 'rating';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    setState(() => _isLoading = true);
    try {
      final tours = _tourService.getToursByCategory(widget.categoryId);
      setState(() => _tours = tours);
      _sortTours();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortTours() {
    setState(() {
      _tours.sort((a, b) {
        int comparison;
        switch (_sortBy) {
          case 'rating':
            comparison = (a.rating ?? 0).compareTo(b.rating ?? 0);
            break;
          case 'duration':
            comparison = (a.totalDuration ?? 0).compareTo(b.totalDuration ?? 0);
            break;
          case 'distance':
            comparison = (a.totalDistance ?? 0).compareTo(b.totalDistance ?? 0);
            break;
          default:
            comparison = 0;
        }
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.sort,
        color: Colors.white.withOpacity(0.7),
      ),
      color: CinemapsTheme.deepSpaceBlack,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'rating',
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: _sortBy == 'rating'
                    ? CinemapsTheme.hotPink
                    : Colors.white.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Rating',
                style: TextStyle(
                  color: _sortBy == 'rating'
                      ? CinemapsTheme.hotPink
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'duration',
          child: Row(
            children: [
              Icon(
                Icons.timer,
                color: _sortBy == 'duration'
                    ? CinemapsTheme.hotPink
                    : Colors.white.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Duration',
                style: TextStyle(
                  color: _sortBy == 'duration'
                      ? CinemapsTheme.hotPink
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'distance',
          child: Row(
            children: [
              Icon(
                Icons.directions_walk,
                color: _sortBy == 'distance'
                    ? CinemapsTheme.hotPink
                    : Colors.white.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Distance',
                style: TextStyle(
                  color: _sortBy == 'distance'
                      ? CinemapsTheme.hotPink
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        setState(() {
          if (_sortBy == value) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = value;
            _sortAscending = false;
          }
          _sortTours();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.categoryName),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.color.withOpacity(0.3),
                      CinemapsTheme.deepSpaceBlack,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 64,
                    color: widget.color,
                  ),
                ),
              ),
            ),
            actions: [
              _buildSortButton(),
            ],
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_tours.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_filter,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tours found in this category',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _tours.length) return null;
                    final tour = _tours[index];
                    return Card(
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                  image: tour.imageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(tour.imageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: tour.imageUrl == null
                                    ? Center(
                                        child: Icon(
                                          Icons.movie,
                                          size: 48,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: CinemapsTheme.neonYellow,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          (tour.rating ?? 0.0).toStringAsFixed(1),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 14,
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
                  childCount: _tours.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
