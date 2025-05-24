import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class FirebaseDbModel {
  static final FirebaseDbModel _instance = FirebaseDbModel._internal();
  factory FirebaseDbModel() => _instance;
  FirebaseDbModel._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String _databaseUrl =
      "https://olofoofo-f4a3a-default-rtdb.firebaseio.com/";

  Future<void> createUserInDb(UserModel user) async {
    try {
      await _database.child('users/${user.uid}').set(user.toJson());
      await _database
          .child('usernames/${user.username.toLowerCase()}')
          .set(user.uid);
      await _database.child('user_profiles/${user.uid}').set({
        'bio': user.bio ?? '',
        'location': user.location ?? '',
        'website': user.website ?? '',
        'phone': user.phoneNumber ?? '',
        'profile_image_url': user.profileImageUrl ?? '',
        'created_at': user.createdAt.millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await _database.child('user_settings/${user.uid}').set({
        'notifications_enabled': true,
        'private_account': false,
        'theme': 'light',
        'language': 'en',
      });

      await _database.child('user_stats/${user.uid}').set({
        'posts_count': 0,
        'followers_count': 0,
        'following_count': 0,
        'last_active': DateTime.now().millisecondsSinceEpoch,
      });

      await _database
          .child('user_posts/${user.uid}')
          .set({'initialized': true});
      await _database
          .child('user_followers/${user.uid}')
          .set({'initialized': true});
      await _database
          .child('user_following/${user.uid}')
          .set({'initialized': true});

      final response = await http.put(
        Uri.parse('$_databaseUrl/users/${user.uid}.json'),
        body: json.encode(user.toJson()),
      );

      if (response.statusCode != 200) {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }

  Future<UserModel?> getUserFromDb(String uid) async {
    try {
      final snapshot = await _database.child('users/$uid').get();
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);

        final statsSnapshot = await _database.child('user_stats/$uid').get();
        if (statsSnapshot.exists) {
          final statsData =
              Map<String, dynamic>.from(statsSnapshot.value as Map);
          userData['followers_count'] = statsData['followers_count'] ?? 0;
          userData['following_count'] = statsData['following_count'] ?? 0;
          userData['posts_count'] = statsData['posts_count'] ?? 0;
        }

        final profileSnapshot =
            await _database.child('user_profiles/$uid').get();
        if (profileSnapshot.exists) {
          final profileData =
              Map<String, dynamic>.from(profileSnapshot.value as Map);
          userData['bio'] = profileData['bio'];
          userData['location'] = profileData['location'];
          userData['website'] = profileData['website'];
          userData['profile_image_url'] = profileData['profile_image_url'];
        }

        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<UserModel> getOrCreateUserProfile(
      String uid, String email, String username) async {
    try {
      final existingUser = await getUserFromDb(uid);
      if (existingUser != null) {
        return existingUser;
      }

      final newUser = UserModel(
        uid: uid,
        email: email,
        username: username,
        fullName: username,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        bio: 'Hello! I am using OFOFO',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
      );

      await createUserInDb(newUser);
      return newUser;
    } catch (e) {
      print('Error: $e');
      return UserModel(
        uid: uid,
        email: email,
        username: username,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> deleteUser(String uid, String username) async {
    try {
      await _database.child('users/$uid').remove();
      await _database.child('usernames/${username.toLowerCase()}').remove();
      await _database.child('user_profiles/$uid').remove();
      await _database.child('user_settings/$uid').remove();
      await _database.child('user_stats/$uid').remove();
      await _database.child('user_posts/$uid').remove();
      await _database.child('user_followers/$uid').remove();
      await _database.child('user_following/$uid').remove();
    } catch (e) {
      print('Error deleting user: $e');
      throw e;
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final snapshot =
          await _database.child('usernames/${username.toLowerCase()}').get();
      return !snapshot.exists;
    } catch (e) {
      print('Error checking username availability: $e');
      throw e;
    }
  }

  // Update user stats
  Future<void> updateUserStats(String uid, Map<String, dynamic> stats) async {
    try {
      await _database.child('user_stats/$uid').update(stats);
    } catch (e) {
      print('Error updating user stats: $e');
      throw e;
    }
  }

  // Get user profile from database
  Future<Map<String, dynamic>> getUserProfileFromDb(String uid) async {
    try {
      final snapshot = await _database.child('user_profiles/$uid').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return {};
    } catch (e) {
      print('Error getting user profile: $e');
      return {};
    }
  }

  // Get user settings from database
  Future<Map<String, dynamic>> getUserSettingsFromDb(String uid) async {
    try {
      final snapshot = await _database.child('user_settings/$uid').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return {
        'notifications_enabled': true,
        'private_account': false,
        'theme': 'light',
        'language': 'en',
      };
    } catch (e) {
      print('Error getting user settings: $e');
      return {
        'notifications_enabled': true,
        'private_account': false,
        'theme': 'light',
        'language': 'en',
      };
    }
  }

  // Get user stats from database
  Future<Map<String, dynamic>> getUserStatsFromDb(String uid) async {
    try {
      final snapshot = await _database.child('user_stats/$uid').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return {
        'posts_count': 0,
        'followers_count': 0,
        'following_count': 0,
        'last_active': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'posts_count': 0,
        'followers_count': 0,
        'following_count': 0,
        'last_active': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _database.child('user_profiles/$uid').update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  // Update user settings
  Future<void> updateUserSettings(String uid, Map<String, dynamic> data) async {
    try {
      await _database.child('user_settings/$uid').update(data);
    } catch (e) {
      print('Error updating user settings: $e');
      throw e;
    }
  }
}
