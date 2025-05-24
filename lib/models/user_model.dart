class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? password;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePicture;
  final String? bio;
  final String? location;
  final String? website;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final bool isEmailVerified;
  final String? gender;
  final DateTime? birthDate;
  final Map<String, dynamic>? preferences;
  final List<String>? interests;
  final String? profileImageUrl;
  final int followersCount;
  final int followingCount;
  final int postsCount;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.password,
    this.fullName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePicture,
    this.bio,
    this.location,
    this.website,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.isEmailVerified = false,
    this.gender,
    this.birthDate,
    this.preferences,
    this.interests,
    this.profileImageUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
  });

  // Convert model to JSON for storing in Realtime Database
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'fullName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'bio': bio,
      'location': location,
      'website': website,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'gender': gender,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'preferences': preferences,
      'interests': interests,
      'profileImageUrl': profileImageUrl,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
    };
  }

  // Create model from JSON retrieved from Realtime Database
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastLoginAt'])
          : null,
      isActive: json['isActive'] ?? true,
      isEmailVerified: json['isEmailVerified'] ?? false,
      gender: json['gender'],
      birthDate: json['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['birthDate'])
          : null,
      preferences: json['preferences'],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      profileImageUrl: json['profileImageUrl'],
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
    );
  }

  // Create a copy of this UserModel with some fields updated
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? password,
    String? fullName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    String? bio,
    String? location,
    String? website,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    bool? isEmailVerified,
    String? gender,
    DateTime? birthDate,
    Map<String, dynamic>? preferences,
    List<String>? interests,
    String? profileImageUrl,
    int? followersCount,
    int? followingCount,
    int? postsCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      preferences: preferences ?? this.preferences,
      interests: interests ?? this.interests,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
    );
  }
}
