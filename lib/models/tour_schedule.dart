import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'tour_tracking.dart';

enum TourScheduleStatus {
  scheduled,
  started,
  completed,
  cancelled
}

enum TourVisibility {
  private,
  friendsOnly,
  public
}

class TourSchedule {
  final String id;
  final String tourId;
  final String userId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final TimeOfDay startTime;
  final List<String> invitedUsers;
  final List<String> confirmedUsers;
  final TourScheduleStatus status;
  final TourVisibility visibility;
  final Map<String, String> userNotes;
  final Map<String, dynamic> preferences;

  const TourSchedule({
    required this.id,
    required this.tourId,
    required this.userId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.startTime,
    required this.invitedUsers,
    required this.confirmedUsers,
    required this.status,
    required this.visibility,
    required this.userNotes,
    required this.preferences,
  });

  bool get isUpcoming => 
    scheduledDate.isAfter(DateTime.now()) || 
    (scheduledDate.year == DateTime.now().year && 
     scheduledDate.month == DateTime.now().month && 
     scheduledDate.day == DateTime.now().day);

  bool get canStart => 
    status == TourScheduleStatus.scheduled && 
    isUpcoming && 
    confirmedUsers.isNotEmpty;

  bool get isPast => !isUpcoming;
}

class GroupMember {
  final String userId;
  final String name;
  final String? avatarUrl;
  final bool isLeader;
  final bool hasConfirmed;
  final DateTime? lastActive;
  final LatLng? lastLocation;
  final TourStop? currentStop;
  final bool isOnline;

  const GroupMember({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.isLeader,
    required this.hasConfirmed,
    this.lastActive,
    this.lastLocation,
    this.currentStop,
    required this.isOnline,
  });
}

class TourGroup {
  final String id;
  final String scheduleId;
  final List<GroupMember> members;
  final Map<String, String> chatMessages;
  final Map<String, dynamic> groupSettings;
  final DateTime createdAt;
  final DateTime? disbandedAt;

  const TourGroup({
    required this.id,
    required this.scheduleId,
    required this.members,
    required this.chatMessages,
    required this.groupSettings,
    required this.createdAt,
    this.disbandedAt,
  });

  bool get isActive => disbandedAt == null;
  
  GroupMember? get leader => 
    members.firstWhere((member) => member.isLeader);
  
  List<GroupMember> get activeMembers => 
    members.where((member) => member.isOnline).toList();
  
  bool get canStart => 
    members.where((member) => member.hasConfirmed).length >= 2;
}
