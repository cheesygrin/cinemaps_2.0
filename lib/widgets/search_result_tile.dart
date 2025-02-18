import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../theme/cinemaps_theme.dart';

class SearchResultTile extends StatelessWidget {
  final SearchResult result;

  const SearchResultTile({super.key, required this.result});

  IconData _getIconForType() {
    switch (result.type) {
      case 'movie':
        return Icons.movie;
      case 'tv':
        return Icons.tv;
      case 'location':
        return Icons.location_on;
      case 'tour':
        return Icons.tour;
      default:
        return Icons.search;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: CinemapsTheme.hotPink.withOpacity(0.2),
        child: Icon(_getIconForType(), color: CinemapsTheme.hotPink),
      ),
      title: Text(
        result.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        result.description,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // TODO: Navigate to detail page based on type
      },
    );
  }
}
