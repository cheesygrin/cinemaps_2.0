import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../services/achievement_service.dart';

class PassportPage extends StatefulWidget {
  const PassportPage({super.key});

  @override
  State<PassportPage> createState() => _PassportPageState();
}

class _PassportPageState extends State<PassportPage> {
  final AchievementService _achievementService = AchievementService();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildPassportPages()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CinemapsTheme.deepSpaceBlack,
        border: Border(
          bottom: BorderSide(
            color: CinemapsTheme.hotPink.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              Icons.airplane_ticket,
              color: CinemapsTheme.neonYellow,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              'MOVIE PASSPORT',
              style: TextStyle(
                color: CinemapsTheme.neonYellow,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: CinemapsTheme.hotPink.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: CinemapsTheme.hotPink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CinemapsTheme.hotPink.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: CinemapsTheme.neonYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_achievementService.totalPoints} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportPages() {
    final achievements = _achievementService.allAchievements;
    return PageView.builder(
      controller: _pageController,
      itemCount: (achievements.length / 6).ceil(),
      itemBuilder: (context, pageIndex) {
        final startIndex = pageIndex * 6;
        final endIndex = (startIndex + 6).clamp(0, achievements.length);
        final pageAchievements = achievements.sublist(startIndex, endIndex);

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: CinemapsTheme.hotPink.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: CinemapsTheme.hotPink.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPageHeader(pageIndex + 1),
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: pageAchievements.map((achievement) {
                    return _buildAchievementStamp(achievement);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageHeader(int pageNumber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CinemapsTheme.hotPink.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PAGE $pageNumber',
            style: TextStyle(
              color: CinemapsTheme.neonYellow,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _achievementService.getRank(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementStamp(Achievement achievement) {
    final progress = _achievementService.getProgress(achievement);
    final isUnlocked = achievement.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? CinemapsTheme.neonYellow.withOpacity(0.5)
              : CinemapsTheme.hotPink.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          if (isUnlocked)
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CinemapsTheme.neonYellow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CinemapsTheme.neonYellow.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: isUnlocked
                    ? CinemapsTheme.neonYellow
                    : Colors.white.withOpacity(0.3),
                size: 32,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isUnlocked
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${achievement.points} pts',
                style: TextStyle(
                  color: isUnlocked
                      ? CinemapsTheme.neonYellow
                      : Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 80,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(
                    isUnlocked
                        ? CinemapsTheme.neonYellow
                        : CinemapsTheme.hotPink,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
