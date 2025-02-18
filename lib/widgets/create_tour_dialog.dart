import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tour_schedule_service.dart';
import '../models/tour_schedule.dart';
import '../theme/cinemaps_theme.dart';

class CreateTourDialog extends StatefulWidget {
  final String userId;
  final String tourId;

  const CreateTourDialog({
    super.key,
    required this.userId,
    required this.tourId,
  });

  @override
  State<CreateTourDialog> createState() => _CreateTourDialogState();
}

class _CreateTourDialogState extends State<CreateTourDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TourVisibility _visibility = TourVisibility.private;
  final List<String> _invitedUsers = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Tour',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tour Title',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CinemapsTheme.hotPink),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CinemapsTheme.hotPink),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Date',
                        style: TextStyle(color: Colors.white70),
                      ),
                      subtitle: Text(
                        '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Time',
                        style: TextStyle(color: Colors.white70),
                      ),
                      subtitle: Text(
                        '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (time != null) {
                          setState(() => _selectedTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TourVisibility>(
                value: _visibility,
                dropdownColor: CinemapsTheme.deepSpaceBlack,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Visibility',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CinemapsTheme.hotPink),
                  ),
                ),
                items: TourVisibility.values.map((visibility) {
                  return DropdownMenuItem(
                    value: visibility,
                    child: Text(
                      visibility.toString().split('.').last,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _visibility = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _createTour,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CinemapsTheme.hotPink,
                    ),
                    child: const Text('Create Tour'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createTour() {
    if (!_formKey.currentState!.validate()) return;

    final scheduleService = context.read<TourScheduleService>();
    
    scheduleService.scheduleTour(
      tourId: widget.tourId,
      userId: widget.userId,
      title: _titleController.text,
      description: _descriptionController.text,
      scheduledDate: _selectedDate,
      startTime: _selectedTime,
      invitedUsers: _invitedUsers,
      visibility: _visibility,
      preferences: {
        'waitForAll': true,
        'shareLocation': true,
        'allowPhotos': true,
        'allowChat': true,
      },
    );

    Navigator.of(context).pop();
  }
}
