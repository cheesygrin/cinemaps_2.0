import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/recommendation_service.dart';
import 'services/watchlist_service.dart';
import 'services/social_service.dart';
import 'services/location_reviews_service.dart';
import 'services/user_data_service.dart';
import 'services/movie_details_service.dart';
import 'services/movies_service.dart';
import 'pages/home_page.dart';
import 'pages/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserDataService()),
        ChangeNotifierProvider(create: (_) => WatchlistService()),
        ChangeNotifierProvider(create: (_) => SocialService()),
        ChangeNotifierProvider(create: (_) => LocationReviewsService()),
        ChangeNotifierProvider(create: (_) => MoviesService()),
        ChangeNotifierProvider(create: (_) => MovieDetailsService()),
        ChangeNotifierProvider(
          create: (context) => RecommendationService(
            watchlistService: context.read<WatchlistService>(),
            socialService: context.read<SocialService>(),
            locationService: context.read<LocationReviewsService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Cinemaps',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: FutureBuilder(
          // Add a slight delay to show the splash screen
          future: Future.delayed(const Duration(seconds: 3)),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SplashScreen();
            }
            return const HomePage();
          },
        ),
      ),
    );
  }
}












