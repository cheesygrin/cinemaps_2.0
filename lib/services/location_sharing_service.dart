import 'package:share_plus/share_plus.dart';
import '../models/filming_location.dart';

class LocationSharingService {
  Future<void> shareLocation(FilmingLocation location, String showTitle) async {
    final String shareText = '''
Check out this filming location from $showTitle!

📍 ${location.name}
📝 ${location.scenes.isNotEmpty ? location.scenes[0] : 'No scene description available'}
🏠 ${location.address}

View it on Cinemaps: cinemaps://location/${location.id}
''';

    await Share.share(shareText, subject: 'Check out this filming location!');
  }

  Future<void> shareRoute(
      List<FilmingLocation> locations, String showTitle) async {
    final String locationList = locations
        .map((loc) => '📍 ${loc.name}\n   ${loc.address}')
        .join('\n\n');

    final String shareText = '''
Check out this ${locations.length}-stop tour of $showTitle filming locations!

$locationList

Plan your visit on Cinemaps: cinemaps://tour/${locations.map((l) => l.id).join(',')}
''';

    await Share.share(shareText, subject: 'Movie Location Tour');
  }
}
