import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tour_schedule.dart';
import '../services/tour_schedule_service.dart';
import '../theme/cinemaps_theme.dart';

class TourScheduleWidget extends StatelessWidget {
  final String userId;

  const TourScheduleWidget({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TourScheduleService>(
      builder: (context, scheduleService, child) {
        final upcomingSchedules = scheduleService.getUpcomingSchedules(userId);
        
        if (upcomingSchedules.isEmpty) {
          return const Center(
            child: Text(
              'No upcoming tours scheduled',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: upcomingSchedules.length,
          itemBuilder: (context, index) {
            final schedule = upcomingSchedules[index];
            final group = scheduleService.getGroupForSchedule(schedule.id);
            
            return Card(
              color: CinemapsTheme.deepSpaceBlack,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            schedule.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusChip(schedule.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedule.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: CinemapsTheme.hotPink,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateTime(schedule.scheduledDate, schedule.startTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (group != null) ...[
                      const Divider(color: Colors.white24),
                      _buildGroupSection(group),
                    ],
                    const SizedBox(height: 16),
                    _buildActionButtons(context, scheduleService, schedule),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(TourScheduleStatus status) {
    Color color;
    String label;

    switch (status) {
      case TourScheduleStatus.scheduled:
        color = Colors.blue;
        label = 'Scheduled';
        break;
      case TourScheduleStatus.started:
        color = Colors.green;
        label = 'In Progress';
        break;
      case TourScheduleStatus.completed:
        color = CinemapsTheme.hotPink;
        label = 'Completed';
        break;
      case TourScheduleStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGroupSection(TourGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group Members',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: group.members.length,
            itemBuilder: (context, index) {
              final member = group.members[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: member.avatarUrl != null
                              ? NetworkImage(member.avatarUrl!)
                              : null,
                          child: member.avatarUrl == null
                              ? Text(
                                  member.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        if (member.isLeader)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: CinemapsTheme.hotPink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.name.split(' ')[0],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    TourScheduleService scheduleService,
    TourSchedule schedule,
  ) {
    if (schedule.status != TourScheduleStatus.scheduled) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!schedule.confirmedUsers.contains(userId))
          TextButton(
            onPressed: () => scheduleService.confirmParticipation(
              schedule.id,
              userId,
            ),
            child: const Text('Join Tour'),
          ),
        if (schedule.userId == userId) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => scheduleService.cancelScheduledTour(schedule.id),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Tour'),
          ),
        ],
        if (schedule.canStart && schedule.userId == userId) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => scheduleService.startScheduledTour(schedule.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: CinemapsTheme.hotPink,
            ),
            child: const Text('Start Tour'),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final now = DateTime.now();
    final scheduleDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (scheduleDateTime.year == now.year &&
        scheduleDateTime.month == now.month &&
        scheduleDateTime.day == now.day) {
      return 'Today at ${_formatTime(time)}';
    }

    if (scheduleDateTime.difference(now).inDays == 1) {
      return 'Tomorrow at ${_formatTime(time)}';
    }

    return '${_formatDate(date)} at ${_formatTime(time)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
