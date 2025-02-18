class UserActivityService {
  static final UserActivityService _instance = UserActivityService._internal();
  factory UserActivityService() => _instance;
  UserActivityService._internal();

  void logActivity(String activity) {
    // TODO: Implement activity logging
  }
}
