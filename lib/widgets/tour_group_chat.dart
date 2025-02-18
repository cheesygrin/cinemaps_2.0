import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tour_schedule.dart';
import '../services/tour_schedule_service.dart';
import '../theme/cinemaps_theme.dart';

class TourGroupChat extends StatefulWidget {
  final String scheduleId;
  final String userId;

  const TourGroupChat({
    super.key,
    required this.scheduleId,
    required this.userId,
  });

  @override
  State<TourGroupChat> createState() => _TourGroupChatState();
}

class _TourGroupChatState extends State<TourGroupChat> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TourScheduleService>(
      builder: (context, scheduleService, child) {
        final group = scheduleService.getGroupForSchedule(widget.scheduleId);
        
        if (group == null || !group.isActive) {
          return const Center(
            child: Text(
              'Chat unavailable',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final allowChat = group.groupSettings['allowChat'] as bool? ?? true;
        if (!allowChat) {
          return const Center(
            child: Text(
              'Chat is disabled for this group',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: group.chatMessages.length,
                itemBuilder: (context, index) {
                  final timestamp = group.chatMessages.keys.elementAt(index);
                  final message = group.chatMessages[timestamp]!;
                  final sender = group.members.firstWhere(
                    (m) => m.userId == widget.userId,
                    orElse: () => group.members.first,
                  );

                  return _buildMessageBubble(
                    message: message,
                    sender: sender,
                    timestamp: DateTime.parse(timestamp),
                  );
                },
              ),
            ),
            _buildMessageInput(scheduleService, group),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required GroupMember sender,
    required DateTime timestamp,
  }) {
    final isCurrentUser = sender.userId == widget.userId;
    final time = _formatTime(timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: sender.avatarUrl != null
                  ? NetworkImage(sender.avatarUrl!)
                  : null,
              child: sender.avatarUrl == null
                  ? Text(
                      sender.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      sender.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? CinemapsTheme.hotPink.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: sender.avatarUrl != null
                  ? NetworkImage(sender.avatarUrl!)
                  : null,
              child: sender.avatarUrl == null
                  ? Text(
                      sender.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    TourScheduleService scheduleService,
    TourGroup group,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (message) => _sendMessage(
                scheduleService,
                message,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: CinemapsTheme.hotPink,
            ),
            onPressed: () => _sendMessage(
              scheduleService,
              _messageController.text,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(TourScheduleService service, String message) {
    if (message.trim().isEmpty) return;

    service.addGroupMessage(
      widget.scheduleId,
      widget.userId,
      message.trim(),
    );

    _messageController.clear();
    _scrollToBottom();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }

    if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }

    return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
