class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profileImageUrl;
  final String goal;
  final String experienceLevel;
  final Map<String, dynamic> metrics; // age, height, weight, bodyFat
  final Map<String, dynamic> lifestyle; // sleep, activityLevel, gymAccess
  final Map<String, dynamic>? protocol; // AI-generated plan

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.goal,
    required this.experienceLevel,
    required this.metrics,
    required this.lifestyle,
    this.protocol,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'goal': goal,
      'experienceLevel': experienceLevel,
      'metrics': metrics,
      'lifestyle': lifestyle,
      'protocol': protocol,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      goal: map['goal'] ?? '',
      experienceLevel: map['experienceLevel'] ?? '',
      metrics: Map<String, dynamic>.from(map['metrics'] ?? {}),
      lifestyle: Map<String, dynamic>.from(map['lifestyle'] ?? {}),
      protocol: map['protocol'] != null ? Map<String, dynamic>.from(map['protocol']) : null,
    );
  }
}
