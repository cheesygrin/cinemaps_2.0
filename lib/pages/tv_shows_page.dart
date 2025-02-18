import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../services/tv_shows_service.dart';
import '../models/tv_show.dart';
import '../widgets/tv_show_card.dart';

class TVShowsPage extends StatefulWidget {
  const TVShowsPage({super.key});

  @override
  State<TVShowsPage> createState() => _TVShowsPageState();
}

class _TVShowsPageState extends State<TVShowsPage> {
  final TVShowsService _tvShowsService = TVShowsService();
  final TextEditingController _searchController = TextEditingController();
  List<TVShow> _shows = [];

  @override
  void initState() {
    super.initState();
    _loadShows();
  }

  Future<void> _loadShows() async {
    final shows = await _tvShowsService.getPopularShows();
    setState(() => _shows = shows);
  }

  void _onSearchChanged(String query) {
    _tvShowsService.searchShows(query).then((shows) {
      setState(() => _shows = shows);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV Shows'),
        backgroundColor: CinemapsTheme.deepSpaceBlack,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search TV shows...',
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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _shows.length,
              itemBuilder: (context, index) {
                return TVShowCard(show: _shows[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
