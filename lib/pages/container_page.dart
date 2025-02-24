import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/cinemaps_theme.dart';
import 'map_page.dart';
import 'movies_page.dart';
import 'home_page.dart';
import 'gallery_page.dart';
import 'tours_page.dart';
import '../widgets/navigation_drawer.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  int _currentIndex = 2; // Home page
  final _pageController = PageController(initialPage: 2);
  bool _isLoading = true;
  final List<Widget> _pages = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (mounted) {
        setState(() {
          _userId = user?.uid;
          _isLoading = false;
          
          // Initialize pages after we have user ID
          _pages.addAll([
            const MapPage(),
            const MoviesPage(),
            HomePage(onNavigate: _onNavigate),
            GalleryPage(userId: _userId ?? 'guest'),
            const ToursPage(),
          ]);
        });
      }

      // If no user, redirect to login
      if (user == null && mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('Error checking auth state: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _handleLogout() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error signing out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CinemapsTheme.neonYellow),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement global search
            },
          ),
        ],
      ),
      drawer: CinemapsDrawer(
        userId: _userId ?? 'guest',
        currentRoute: _getCurrentRoute(),
        onNavigate: (String route) {
          Navigator.pop(context); // Close drawer
          if (route == '/logout') {
            _handleLogout();
          } else {
            Navigator.pushNamed(context, route);
          }
        },
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onNavigate,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigate,
        type: BottomNavigationBarType.fixed,
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        selectedItemColor: CinemapsTheme.neonYellow,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tour),
            label: 'Tours',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Movie Locations';
      case 1:
        return 'Movies';
      case 2:
        return 'Cinemaps';
      case 3:
        return 'Gallery';
      case 4:
        return 'Movie Tours';
      default:
        return 'Cinemaps';
    }
  }

  String _getCurrentRoute() {
    switch (_currentIndex) {
      case 0:
        return '/map';
      case 1:
        return '/movies';
      case 2:
        return '/home';
      case 3:
        return '/gallery';
      case 4:
        return '/tours';
      default:
        return '/home';
    }
  }
} 