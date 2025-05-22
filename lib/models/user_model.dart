class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? fullName;
  final String? profilePicture;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.fullName,
    this.profilePicture,
    required this.createdAt,
    this.isActive = true,
  });

  // Convert model to JSON for storing in Realtime Database
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  // Create model from JSON retrieved from Realtime Database
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
      profilePicture: json['profilePicture'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}
