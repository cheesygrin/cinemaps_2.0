import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'services/recommendation_service.dart';
import 'services/watchlist_service.dart';
import 'services/social_service.dart';
import 'services/location_reviews_service.dart';
import 'services/user_data_service.dart';
import 'services/movie_details_service.dart';
import 'services/movies_service.dart';
import 'services/storage_service.dart';
import 'services/gallery_service.dart';
import 'pages/container_page.dart';
import 'pages/splash_screen.dart';
import 'theme/cinemaps_theme.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => WatchlistService()),
        ChangeNotifierProvider(create: (_) => SocialService()),
        ChangeNotifierProvider(create: (_) => LocationReviewsService()),
        ChangeNotifierProvider(create: (_) => MoviesService()),
        ChangeNotifierProvider(create: (_) => UserDataService()),
        ChangeNotifierProvider(create: (_) => MovieDetailsService()),
        ChangeNotifierProvider(create: (_) => GalleryService()),
        Provider(create: (_) => StorageService()),
        ChangeNotifierProxyProvider3<WatchlistService, SocialService, LocationReviewsService, RecommendationService>(
          create: (context) => RecommendationService(
            watchlistService: context.read<WatchlistService>(),
            socialService: context.read<SocialService>(),
            locationService: context.read<LocationReviewsService>(),
          ),
          update: (context, watchlistService, socialService, locationService, previous) =>
            previous ?? RecommendationService(
              watchlistService: watchlistService,
              socialService: socialService,
              locationService: locationService,
            ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinemaps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: CinemapsTheme.deepSpaceBlack,
      ),
      home: FutureBuilder(
        // Initialize auth and wait for splash screen animation
        future: Future.delayed(const Duration(seconds: 3), () {
          // Ensure auth is initialized
          final authService = Provider.of<AuthService>(context, listen: false);
          return authService.currentUser != null;
        }),
        builder: (context, snapshot) {
          // Show splash screen while waiting
          if (!snapshot.hasData) {
            return const SplashScreen();
          }
          // Navigate to container page after initialization
          return const ContainerPage();
        },
      ),
    );
  }
}












