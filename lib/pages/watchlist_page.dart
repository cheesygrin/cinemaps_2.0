import 'package:flutter/material.dart';
import '../models/watchlist_item.dart';
import '../services/watchlist_service.dart';
import '../services/movie_details_service.dart';
import '../theme/cinemaps_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class WatchlistPage extends StatefulWidget {
  final String userId;

  const WatchlistPage({
    super.key,
    required this.userId,
  });

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WatchlistItemType _selectedType = WatchlistItemType.movie;
  bool _showWatched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedType = _tabController.index == 0 
            ? WatchlistItemType.movie 
            : WatchlistItemType.tvShow;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: CinemapsTheme.hotPink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Watchlist'),
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'TV Shows'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showWatched ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showWatched = !_showWatched;
              });
            },
          ),
        ],
      ),
      body: Consumer<WatchlistService>(
        builder: (context, watchlistService, child) {
          final items = watchlistService.getFilteredWatchlist(
            widget.userId,
            type: _selectedType,
            isWatched: _showWatched,
          );

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedType == WatchlistItemType.movie
                        ? Icons.movie_outlined
                        : Icons.tv_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showWatched
                        ? 'No watched ${_selectedType == WatchlistItemType.movie ? 'movies' : 'TV shows'} yet'
                        : 'Add some ${_selectedType == WatchlistItemType.movie ? 'movies' : 'TV shows'} to your watchlist!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _WatchlistItemTile(
                item: items[index],
                userId: widget.userId,
              );
            },
          );
        },
      ),
    );
  }
}

class _WatchlistItemTile extends StatelessWidget {
  final WatchlistItem item;
  final String userId;

  const _WatchlistItemTile({
    required this.item,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final watchlistService = context.read<WatchlistService>();
    final movieService = context.read<MovieDetailsService>();

    return Card(
      color: Colors.white.withOpacity(0.05),
      child: ListTile(
        leading: Icon(
          item.type == WatchlistItemType.movie
              ? Icons.movie_outlined
              : Icons.tv_outlined,
          color: CinemapsTheme.hotPink,
        ),
        title: Text(
          item.mediaId, // TODO: Get actual title from movie/TV show service
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Added ${DateFormat.yMMMd().format(item.addedAt)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            if (item.note != null)
              Text(
                item.note!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                item.isWatched ? Icons.check_circle : Icons.check_circle_outline,
                color: item.isWatched ? CinemapsTheme.hotPink : Colors.white54,
              ),
              onPressed: () {
                if (!item.isWatched) {
                  watchlistService.markAsWatched(userId, item.mediaId);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white54),
              onPressed: () {
                watchlistService.removeFromWatchlist(userId, item.mediaId);
              },
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to movie/show details
        },
      ),
    );
  }
}
