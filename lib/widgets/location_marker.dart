import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';

class LocationMarker extends StatelessWidget {
  final String locationName;
  final bool isVisited;
  final VoidCallback? onTap;

  const LocationMarker({
    super.key,
    required this.locationName,
    this.isVisited = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isVisited ? CinemapsTheme.hotPink : CinemapsTheme.deepSpaceBlack,
              shape: BoxShape.circle,
              border: Border.all(
                color: CinemapsTheme.hotPink,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: CinemapsTheme.hotPink.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.movie,
              color: isVisited ? Colors.white : CinemapsTheme.hotPink,
              size: 24,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CinemapsTheme.deepSpaceBlack.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CinemapsTheme.hotPink,
                width: 1,
              ),
            ),
            child: Text(
              locationName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
