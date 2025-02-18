import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tour_schedule.dart';
import 'tour_tracking_service.dart';
import 'social_service.dart';

class TourScheduleService extends ChangeNotifier {
  final Map<String, TourSchedule> _schedules = {};
  final Map<String, TourGroup> _groups = {};
  final SocialService _socialService;
  final TourTrackingService _trackingService;

  TourScheduleService({
    required SocialService socialService,
    required TourTrackingService trackingService,
  })  : _socialService = socialService,
        _trackingService = trackingService;

  Future<TourSchedule> scheduleTour({
    required String tourId,
    required String userId,
    required String title,
    required String description,
    required DateTime scheduledDate,
    required TimeOfDay startTime,
    required List<String> invitedUsers,
    required TourVisibility visibility,
    required Map<String, dynamic> preferences,
  }) async {
    final schedule = TourSchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tourId: tourId,
      userId: userId,
      title: title,
      description: description,
      scheduledDate: scheduledDate,
      startTime: startTime,
      invitedUsers: invitedUsers,
      confirmedUsers: [userId], // Creator automatically confirms
      status: TourScheduleStatus.scheduled,
      visibility: visibility,
      userNotes: {},
      preferences: preferences,
    );

    _schedules[schedule.id] = schedule;

    // Create tour group
    await _createTourGroup(schedule);

    // Notify invited users
    for (final invitedUserId in invitedUsers) {
      await _socialService.sendNotification(
        userId: invitedUserId,
        type: 'tour_invitation',
        message: 'You\'ve been invited to join "$title" tour!',
        data: {
          'scheduleId': schedule.id,
          'tourId': tourId,
          'organizerId': userId,
        },
      );
    }

    notifyListeners();
    return schedule;
  }

  Future<void> _createTourGroup(TourSchedule schedule) async {
    final organizer = await _socialService.getUserProfile(schedule.userId);

    final group = TourGroup(
      id: 'group_${schedule.id}',
      scheduleId: schedule.id,
      members: [
        GroupMember(
          userId: organizer?.id ?? 'unknown',
          name: organizer?.username ?? 'Unknown User',
          avatarUrl: organizer?.avatarUrl,
          isLeader: true,
          hasConfirmed: true,
          isOnline: true,
        ),
      ],
      chatMessages: {},
      groupSettings: {
        'waitForAll': true,
        'shareLocation': true,
        'allowPhotos': true,
        'allowChat': true,
      },
      createdAt: DateTime.now(),
    );

    _groups[group.id] = group;
    notifyListeners();
  }

  Future<void> confirmParticipation(String scheduleId, String userId) async {
    final schedule = _schedules[scheduleId];
    if (schedule == null) return;

    if (!schedule.confirmedUsers.contains(userId)) {
      final updatedSchedule = TourSchedule(
        id: schedule.id,
        tourId: schedule.tourId,
        userId: schedule.userId,
        title: schedule.title,
        description: schedule.description,
        scheduledDate: schedule.scheduledDate,
        startTime: schedule.startTime,
        invitedUsers: schedule.invitedUsers,
        confirmedUsers: [...schedule.confirmedUsers, userId],
        status: schedule.status,
        visibility: schedule.visibility,
        userNotes: schedule.userNotes,
        preferences: schedule.preferences,
      );

      _schedules[scheduleId] = updatedSchedule;

      // Add user to group
      await _addUserToGroup(scheduleId, userId);

      notifyListeners();
    }
  }

  Future<void> _addUserToGroup(String scheduleId, String userId) async {
    final groupId = 'group_$scheduleId';
    final group = _groups[groupId];
    if (group == null) return;

    final userProfile = await _socialService.getUserProfile(userId);

    final updatedMembers = [
      ...group.members,
      GroupMember(
        userId: userProfile?.id ?? 'unknown',
        name: userProfile?.username ?? 'Unknown User',
        avatarUrl: userProfile?.avatarUrl,
        isLeader: false,
        hasConfirmed: true,
        isOnline: true,
      ),
    ];

    _groups[groupId] = TourGroup(
      id: group.id,
      scheduleId: group.scheduleId,
      members: updatedMembers,
      chatMessages: group.chatMessages,
      groupSettings: group.groupSettings,
      createdAt: group.createdAt,
    );

    notifyListeners();
  }

  Future<void> startScheduledTour(String scheduleId) async {
    final schedule = _schedules[scheduleId];
    if (schedule == null || !schedule.canStart) return;

    // Update schedule status
    final updatedSchedule = TourSchedule(
      id: schedule.id,
      tourId: schedule.tourId,
      userId: schedule.userId,
      title: schedule.title,
      description: schedule.description,
      scheduledDate: schedule.scheduledDate,
      startTime: schedule.startTime,
      invitedUsers: schedule.invitedUsers,
      confirmedUsers: schedule.confirmedUsers,
      status: TourScheduleStatus.started,
      visibility: schedule.visibility,
      userNotes: schedule.userNotes,
      preferences: schedule.preferences,
    );

    _schedules[scheduleId] = updatedSchedule;

    // Start tracking for all confirmed users
    for (final userId in schedule.confirmedUsers) {
      await _trackingService.startTour(
        tourId: schedule.tourId,
        userId: userId,
        stops: [], // TODO: Get stops from tour service
      );
    }

    notifyListeners();
  }

  Future<void> cancelScheduledTour(String scheduleId) async {
    final schedule = _schedules[scheduleId];
    if (schedule == null) return;

    // Update schedule status
    final updatedSchedule = TourSchedule(
      id: schedule.id,
      tourId: schedule.tourId,
      userId: schedule.userId,
      title: schedule.title,
      description: schedule.description,
      scheduledDate: schedule.scheduledDate,
      startTime: schedule.startTime,
      invitedUsers: schedule.invitedUsers,
      confirmedUsers: schedule.confirmedUsers,
      status: TourScheduleStatus.cancelled,
      visibility: schedule.visibility,
      userNotes: schedule.userNotes,
      preferences: schedule.preferences,
    );

    _schedules[scheduleId] = updatedSchedule;

    // Notify confirmed users
    for (final userId in schedule.confirmedUsers) {
      await _socialService.sendNotification(
        userId: userId,
        type: 'tour_cancelled',
        message: 'Tour "${schedule.title}" has been cancelled.',
        data: {
          'scheduleId': schedule.id,
          'tourId': schedule.tourId,
        },
      );
    }

    // Disband group
    await _disbandGroup(scheduleId);

    notifyListeners();
  }

  Future<void> _disbandGroup(String scheduleId) async {
    final groupId = 'group_$scheduleId';
    final group = _groups[groupId];
    if (group == null) return;

    _groups[groupId] = TourGroup(
      id: group.id,
      scheduleId: group.scheduleId,
      members: group.members,
      chatMessages: group.chatMessages,
      groupSettings: group.groupSettings,
      createdAt: group.createdAt,
      disbandedAt: DateTime.now(),
    );

    notifyListeners();
  }

  Future<void> addGroupMessage(
    String scheduleId,
    String userId,
    String message,
  ) async {
    final groupId = 'group_$scheduleId';
    final group = _groups[groupId];
    if (group == null || !group.isActive) return;

    final updatedMessages = Map<String, String>.from(group.chatMessages);
    updatedMessages[DateTime.now().toIso8601String()] = message;

    _groups[groupId] = TourGroup(
      id: group.id,
      scheduleId: group.scheduleId,
      members: group.members,
      chatMessages: updatedMessages,
      groupSettings: group.groupSettings,
      createdAt: group.createdAt,
    );

    notifyListeners();
  }

  Future<void> updateGroupSettings(
    String scheduleId,
    Map<String, dynamic> settings,
  ) async {
    final groupId = 'group_$scheduleId';
    final group = _groups[groupId];
    if (group == null || !group.isActive) return;

    _groups[groupId] = TourGroup(
      id: group.id,
      scheduleId: group.scheduleId,
      members: group.members,
      chatMessages: group.chatMessages,
      groupSettings: settings,
      createdAt: group.createdAt,
    );

    notifyListeners();
  }

  List<TourSchedule> getUserSchedules(String userId) {
    return _schedules.values
        .where((schedule) =>
            schedule.userId == userId || schedule.invitedUsers.contains(userId))
        .toList();
  }

  List<TourSchedule> getUpcomingSchedules(String userId) {
    return getUserSchedules(userId)
        .where((schedule) => schedule.isUpcoming)
        .toList();
  }

  TourGroup? getGroupForSchedule(String scheduleId) {
    final groupId = 'group_$scheduleId';
    return _groups[groupId];
  }

  @override
  void dispose() {
    _schedules.clear();
    _groups.clear();
    super.dispose();
  }
}
