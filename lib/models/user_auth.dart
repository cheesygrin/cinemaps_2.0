class UserAuth {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime lastSignInTime;
  final bool isAnonymous;

  UserAuth({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.emailVerified,
    required this.createdAt,
    required this.lastSignInTime,
    required this.isAnonymous,
  });

  factory UserAuth.guest() {
    final now = DateTime.now();
    return UserAuth(
      uid: 'guest-${now.millisecondsSinceEpoch}',
      email: 'guest@cinemaps.app',
      displayName: 'Guest User',
      photoURL: null,
      emailVerified: false,
      createdAt: now,
      lastSignInTime: now,
      isAnonymous: true,
    );
  }

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInTime: DateTime.parse(json['lastSignInTime'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInTime': lastSignInTime.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  UserAuth copyWith({
    String? displayName,
    String? photoURL,
    bool? emailVerified,
  }) {
    return UserAuth(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt,
      lastSignInTime: lastSignInTime,
      isAnonymous: isAnonymous,
    );
  }
}
