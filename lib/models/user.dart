class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime joinDate;
  final int successCount;
  final int completedTasks;
  final List<String> badges;
  final int confidenceLevel;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.joinDate,
    this.successCount = 0,
    this.completedTasks = 0,
    this.badges = const [],
    this.confidenceLevel = 1,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    DateTime? joinDate,
    int? successCount,
    int? completedTasks,
    List<String>? badges,
    int? confidenceLevel,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      joinDate: joinDate ?? this.joinDate,
      successCount: successCount ?? this.successCount,
      completedTasks: completedTasks ?? this.completedTasks,
      badges: badges ?? this.badges,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'joinDate': joinDate.toIso8601String(),
      'successCount': successCount,
      'completedTasks': completedTasks,
      'badges': badges,
      'confidenceLevel': confidenceLevel,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      joinDate: DateTime.parse(json['joinDate']),
      successCount: json['successCount'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      confidenceLevel: json['confidenceLevel'] ?? 1,
    );
  }
}