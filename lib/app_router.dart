import 'package:flutter/material.dart';
import 'pages/tour_page.dart';
import 'pages/movies_page.dart';
import 'pages/map_page.dart';
import 'pages/profile_page.dart';
import 'pages/watchlist_page.dart';
import 'pages/settings_page.dart';
import 'pages/locations_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract userId from settings if available
    final userId = 'test_user'; // TODO: Get from auth service

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const MapPage(),
          settings: settings,
        );

      case '/movies':
        return MaterialPageRoute(
          builder: (_) => const MoviesPage(),
          settings: settings,
        );

      case '/locations':
        return MaterialPageRoute(
          builder: (_) => const LocationsPage(),
          settings: settings,
        );

      case '/tours':
        return MaterialPageRoute(
          builder: (_) => TourPage(userId: userId),
          settings: settings,
        );

      case '/watchlist':
        return MaterialPageRoute(
          builder: (_) => WatchlistPage(userId: userId),
          settings: settings,
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
