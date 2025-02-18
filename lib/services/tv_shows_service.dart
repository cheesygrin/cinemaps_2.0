import '../models/tv_show.dart';
import '../models/filming_location.dart';

class TVShowsService {
  static final TVShowsService _instance = TVShowsService._internal();
  factory TVShowsService() => _instance;
  TVShowsService._internal();

  final List<TVShow> _shows = [];
  String _searchQuery = '';

  Future<void> loadShows() async {
    // TODO: Load from API, for now using sample data
    _shows.clear();
    _shows.addAll(_getSampleShows());
  }

  List<TVShow> getShows() {
    if (_searchQuery.isEmpty) return _shows;

    return _shows
        .where((show) =>
            show.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            show.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
  }

  TVShow? getShowById(String showId) {
    return _shows.firstWhere((show) => show.id == showId);
  }

  Future<List<TVShow>> getPopularShows() async {
    if (_shows.isEmpty) {
      await loadShows();
    }
    return _shows;
  }

  Future<List<TVShow>> searchShows(String query) async {
    if (_shows.isEmpty) {
      await loadShows();
    }
    if (query.isEmpty) return _shows;

    return _shows
        .where((show) =>
            show.title.toLowerCase().contains(query.toLowerCase()) ||
            show.description.toLowerCase().contains(query.toLowerCase()) ||
            show.overview.toLowerCase().contains(query.toLowerCase()) ||
            show.genres.any(
                (genre) => genre.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  Future<void> toggleWatchlist(String showId) async {
    final index = _shows.indexWhere((s) => s.id == showId);
    if (index != -1) {
      final show = _shows[index];
      _shows[index] = TVShow(
        id: show.id,
        title: show.title,
        posterUrl: show.posterUrl,
        startYear: show.startYear,
        endYear: show.endYear,
        description: show.description,
        overview: show.overview,
        genres: show.genres,
        filmingLocations: show.filmingLocations,
        rating: show.rating,
        isWatchlisted: !show.isWatchlisted,
      );
    }
  }

  List<TVShow> _getSampleShows() {
    return [
      TVShow(
        id: 'friends',
        title: 'Friends',
        posterUrl: '',
        rating: 8.4,
        overview: 'Six young people from New York City, on their own and struggling to survive in the real world, find the companionship, comfort and support they get from each other to be the perfect solution to the problems that they face.',
        genres: ['Comedy'],
        startYear: 1994,
        endYear: 2004,
        description: 'The misadventures of a group of friends as they navigate the pitfalls of work, life and love in Manhattan.',
        filmingLocations: [
          FilmingLocation(
            id: '1',
            name: 'Friends Apartment Building',
            address: '90 Bedford Street, New York, NY 10014',
            latitude: 40.7326,
            longitude: -74.0063,
            season: 1,
            episode: 1,
            description:
                'Exterior shots of Monica and Rachel\'s apartment building',
            scenes: ['Exterior shots', 'Building entrance scenes'],
          ),
          FilmingLocation(
            id: '2',
            name: 'Central Perk',
            address: '199 Lafayette Street, New York, NY 10012',
            latitude: 40.7215,
            longitude: -73.9989,
            season: 1,
            episode: 1,
            description: 'The iconic coffee shop where the friends hang out',
            scenes: ['Coffee shop scenes', 'Group hangout scenes'],
          ),
        ],
      ),
      TVShow(
        id: 'stranger_things',
        title: 'Stranger Things',
        posterUrl: '',
        rating: 8.6,
        overview: 'Set in the 1980s in Hawkins, Indiana, this thrilling series follows the mysterious disappearance of a young boy and the supernatural events that unfold in the small town.',
        genres: ['Drama', 'Mystery', 'Sci-Fi & Fantasy'],
        startYear: 2016,
        endYear: 2022,
        description: 'When a young boy vanishes, a small town uncovers a mystery involving secret experiments, terrifying supernatural forces and one strange little girl.',
        filmingLocations: [
          FilmingLocation(
            id: '3',
            name: 'Starcourt Mall',
            address:
                'Gwinnett Place Mall, 2100 Pleasant Hill Rd, Duluth, GA 30096',
            latitude: 33.9689,
            longitude: -84.1228,
            season: 3,
            episode: 1,
            description: 'The mall featured prominently in Season 3',
            scenes: ['Mall battle scenes', 'Shopping montages'],
          ),
        ],
      ),
      TVShow(
        id: 'the_office',
        title: 'The Office',
        posterUrl: '',
        rating: 8.5,
        overview: 'A high school chemistry teacher turned methamphetamine manufacturer partners with a former student to secure his family\'s financial future as he battles terminal lung cancer.',
        genres: ['Comedy'],
        startYear: 2005,
        endYear: 2013,
        description: 'A mockumentary on a group of typical office workers, where the workday consists of ego clashes, inappropriate behavior, and tedium.',
        filmingLocations: [
          FilmingLocation(
            id: '4',
            name: 'Walter White\'s House',
            address: '3828 Piermont Dr NE, Albuquerque, NM 87111',
            latitude: 35.1260,
            longitude: -106.5370,
            season: 1,
            episode: 1,
            description: 'The White family residence',
            scenes: ['Family dinner scenes', 'Garage lab scenes'],
          ),
          FilmingLocation(
            id: '5',
            name: 'Los Pollos Hermanos',
            address: '4257 Isleta Blvd SW, Albuquerque, NM 87105',
            latitude: 35.0162,
            longitude: -106.6748,
            season: 2,
            episode: 1,
            description:
                'Gus Fring\'s restaurant chain, actually Twisters restaurant',
            scenes: ['Restaurant meetings', 'Underground lab scenes'],
          ),
        ],
      ),
    ];
  }
}
