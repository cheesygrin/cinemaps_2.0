import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatelessWidget {
  final Function(int)? onNavigate;
  
  const HomePage({
    super.key,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/ui/social_header.jpg',
            fit: BoxFit.cover,
          ),
          
          // Overlay gradient to ensure text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Cinemaps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore iconic movie locations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 48),
                // Movies Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: _buildNeonButton(
                    context,
                    'EXPLORE MOVIES',
                    () {
                      HapticFeedback.mediumImpact();
                      if (onNavigate != null) {
                        onNavigate!(1); // Navigate to Movies tab
                      }
                    },
                    Colors.pink,
                    Colors.orange,
                    Icons.movie,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Map Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: _buildNeonButton(
                    context,
                    'VIEW MAP',
                    () {
                      HapticFeedback.mediumImpact();
                      if (onNavigate != null) {
                        onNavigate!(0); // Navigate to Map tab
                      }
                    },
                    Colors.blue,
                    Colors.green,
                    Icons.map,
                  ),
                ),

                const SizedBox(height: 16),
                
                // Tours Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: _buildNeonButton(
                    context,
                    'MOVIE TOURS',
                    () {
                      HapticFeedback.mediumImpact();
                      if (onNavigate != null) {
                        onNavigate!(4); // Navigate to Tours tab
                      }
                    },
                    Colors.purple,
                    Colors.yellow,
                    Icons.tour,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonButton(
    BuildContext context,
    String text,
    VoidCallback onTap,
    Color startColor,
    Color endColor,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  startColor,
                  endColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: startColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 