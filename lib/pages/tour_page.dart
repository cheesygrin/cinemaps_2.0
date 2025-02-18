import 'package:flutter/material.dart';
import '../widgets/tour_tracking_widget.dart';
import '../widgets/tour_schedule_widget.dart';
import '../widgets/tour_group_chat.dart';
import '../widgets/create_tour_dialog.dart';
import '../theme/cinemaps_theme.dart';

class TourPage extends StatefulWidget {
  final String userId;

  const TourPage({
    super.key,
    required this.userId,
  });

  @override
  State<TourPage> createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _activeScheduleId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      appBar: AppBar(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: const Text('Movie Tours'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Tours'),
            Tab(text: 'Schedule'),
            Tab(text: 'Group Chat'),
          ],
          indicatorColor: CinemapsTheme.hotPink,
          labelColor: CinemapsTheme.hotPink,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Tours Tab
          _activeScheduleId != null
              ? TourTrackingWidget(
                  tourId: _activeScheduleId!,
                  userId: widget.userId,
                )
              : const Center(
                  child: Text(
                    'No active tours',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
          
          // Schedule Tab
          TourScheduleWidget(userId: widget.userId),
          
          // Group Chat Tab
          _activeScheduleId != null
              ? TourGroupChat(
                  scheduleId: _activeScheduleId!,
                  userId: widget.userId,
                )
              : const Center(
                  child: Text(
                    'Join a tour to chat',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CreateTourDialog(
                    userId: widget.userId,
                    tourId: 'current_tour_id', // TODO: Get from route params
                  ),
                );
              },
              backgroundColor: CinemapsTheme.hotPink,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
