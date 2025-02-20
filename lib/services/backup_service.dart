import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  Timer? _autoBackupTimer;
  static const String _lastBackupKey = 'last_backup_time';
  
  factory BackupService() {
    return _instance;
  }

  BackupService._internal();

  Future<bool> createBackup(String message) async {
    try {
      if (!kIsWeb) {
        // Check if there are any changes to commit
        final statusResult = await Process.run('git', ['status', '--porcelain']);
        if (statusResult.stdout.toString().trim().isEmpty) {
          debugPrint('No changes to backup');
          return true;
        }

        final result = await Process.run('git', ['add', '.']);
        if (result.exitCode != 0) return false;

        final timestamp = DateTime.now().toIso8601String();
        final commitMessage = message.isNotEmpty 
            ? '$message (Backup: $timestamp)'
            : 'Automatic backup: $timestamp';
            
        final commitResult = await Process.run('git', ['commit', '-m', commitMessage]);
        if (commitResult.exitCode != 0) return false;

        // Save last backup time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastBackupKey, timestamp);

        debugPrint('Backup created successfully. Open GitHub Desktop to push changes.');
      }
      return true;
    } catch (e) {
      debugPrint('Backup failed: $e');
      return false;
    }
  }

  Future<void> startAutoBackup({Duration interval = const Duration(hours: 1)}) async {
    stopAutoBackup();
    
    _autoBackupTimer = Timer.periodic(interval, (timer) async {
      final success = await createBackup('Automatic periodic backup');
      debugPrint(success ? 'Auto backup successful' : 'Auto backup failed');
    });
  }

  void stopAutoBackup() {
    _autoBackupTimer?.cancel();
    _autoBackupTimer = null;
  }

  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackupStr = prefs.getString(_lastBackupKey);
    return lastBackupStr != null ? DateTime.parse(lastBackupStr) : null;
  }
} 