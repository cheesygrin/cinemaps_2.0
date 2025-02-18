import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../services/search_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  SearchFilters _filters = SearchFilters();
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final results = await _searchService.search(
        _searchController.text,
        filters: _filters,
        userId: 'current_user', // TODO: Replace with actual user ID
      );
      setState(() => _searchResults = results);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    try {
      final recommendations = await _searchService.getRecommendations(
        userId: 'current_user', // TODO: Replace with actual user ID
      );
      setState(() => _searchResults = recommendations);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: const Text(
          'Filter Results',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Genres',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _searchService.availableGenres.map((genre) {
                  final isSelected = _filters.genres?.contains(genre) ?? false;
                  return FilterChip(
                    label: Text(
                      genre,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        final currentGenres = _filters.genres?.toList() ?? [];
                        if (selected) {
                          currentGenres.add(genre);
                        } else {
                          currentGenres.remove(genre);
                        }
                        _filters = _filters.copyWith(genres: currentGenres);
                      });
                    },
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: CinemapsTheme.hotPink,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Year Range',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'From',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(
                            yearStart: int.tryParse(value),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'To',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(
                            yearEnd: int.tryParse(value),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Minimum Rating',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _filters.minRating ?? 0,
                min: 0,
                max: 5,
                divisions: 10,
                label: (_filters.minRating ?? 0).toStringAsFixed(1),
                activeColor: CinemapsTheme.hotPink,
                inactiveColor: CinemapsTheme.hotPink.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(minRating: value);
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Maximum Distance',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _filters.maxDistance ?? 50,
                min: 1,
                max: 100,
                divisions: 20,
                label: '${(_filters.maxDistance ?? 50).round()} km',
                activeColor: CinemapsTheme.hotPink,
                inactiveColor: CinemapsTheme.hotPink.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(maxDistance: value);
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filters = SearchFilters();
              });
              Navigator.pop(context);
              _performSearch();
            },
            child: Text(
              'RESET',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch();
            },
            child: const Text(
              'APPLY',
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
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search movies, shows, locations...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon:
                    Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
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
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Movies', SearchResultType.movie),
          _buildFilterChip('TV Shows', SearchResultType.tvShow),
          _buildFilterChip('Locations', SearchResultType.location),
          _buildFilterChip('Tours', SearchResultType.tour),
          _buildFilterChip('Users', SearchResultType.user),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SearchResultType type) {
    final isSelected = _filters.types?.contains(type) ?? false;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            final currentTypes = _filters.types?.toList() ?? [];
            if (selected) {
              currentTypes.add(type);
            } else {
              currentTypes.remove(type);
            }
            _filters = _filters.copyWith(types: currentTypes);
          });
          _performSearch();
        },
        backgroundColor: Colors.white.withOpacity(0.05),
        selectedColor: CinemapsTheme.hotPink,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected
              ? CinemapsTheme.hotPink
              : CinemapsTheme.hotPink.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECOMMENDED FOR YOU',
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
            const SizedBox(height: 16),
            if (_searchResults.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search for your favorite movies and shows',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover filming locations near you',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: _buildSearchResults(),
              ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mood_bad,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or filters',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return Card(
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: CinemapsTheme.hotPink.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: result.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      result.imageUrl!,
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForType(result.type),
                      color: CinemapsTheme.hotPink,
                    ),
                  ),
            title: Text(
              result.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: result.subtitle != null
                ? Text(
                    result.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  )
                : null,
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
            ),
            onTap: () {
              // TODO: Navigate to result details
            },
          ),
        );
      },
    );
  }

  IconData _getIconForType(SearchResultType type) {
    switch (type) {
      case SearchResultType.movie:
        return Icons.movie;
      case SearchResultType.tvShow:
        return Icons.tv;
      case SearchResultType.location:
        return Icons.location_on;
      case SearchResultType.tour:
        return Icons.movie_filter;
      case SearchResultType.user:
        return Icons.person;
    }
  }
}
