import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'services/movies_service.dart';
import 'services/watchlist_service.dart';
import 'services/social_service.dart';
import 'services/location_reviews_service.dart';
import 'services/recommendation_service.dart';
import 'theme/cinemaps_theme.dart';
import 'pages/splash_screen.dart';
import 'pages/container_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/movies_page.dart';
import 'pages/gallery_page.dart';
import 'pages/tours_page.dart';

void main() async {
  try {
    // Ensure Flutter bindings are initialized first
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Initialize Supabase
    await SupabaseService.instance.initialize();
    
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Run the app anyway, it will show appropriate error states
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        Provider<SupabaseService>.value(
          value: SupabaseService.instance,
        ),
        ChangeNotifierProxyProvider<SupabaseService, MoviesService>(
          create: (context) => MoviesService(context.read<SupabaseService>()),
          update: (context, supabase, previous) => previous ?? MoviesService(supabase),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchlistService(),
        ),
        ChangeNotifierProvider(
          create: (_) => SocialService(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationReviewsService(),
        ),
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: CinemapsTheme.deepSpaceBlack,
          appBarTheme: const AppBarTheme(
            backgroundColor: CinemapsTheme.deepSpaceBlack,
            foregroundColor: CinemapsTheme.neonYellow,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: CinemapsTheme.deepSpaceBlack,
            selectedItemColor: CinemapsTheme.neonYellow,
            unselectedItemColor: Colors.white70,
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => const ContainerPage());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/signup':
              return MaterialPageRoute(builder: (_) => const SignupPage());
            case '/movies':
              return MaterialPageRoute(builder: (_) => const MoviesPage());
            case '/gallery':
              return MaterialPageRoute(
                builder: (_) => GalleryPage(
                  userId: settings.arguments as String? ?? '',
                ),
              );
            case '/tours':
              return MaterialPageRoute(builder: (_) => const ToursPage());
            default:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
        },
      ),
    );
  }
}












