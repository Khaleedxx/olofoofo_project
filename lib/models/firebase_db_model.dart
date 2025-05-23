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

  // User related database operations
  Future<void> createUserInDb(UserModel user) async {
    try {
      // Create main user record
      await _database.child('users/${user.uid}').set(user.toJson());

      // Create username mapping for uniqueness checks
      await _database
          .child('usernames/${user.username.toLowerCase()}')
          .set(user.uid);

      // Create user profile section
      await _database.child('user_profiles/${user.uid}').set({
        'bio': user.bio ?? '',
        'location': user.location ?? '',
        'website': user.website ?? '',
        'phone': user.phoneNumber ?? '',
        'profile_image_url': user.profileImageUrl ?? '',
        'created_at': user.createdAt.millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Create user settings
      await _database.child('user_settings/${user.uid}').set({
        'notifications_enabled': true,
        'private_account': false,
        'theme': 'light',
        'language': 'en',
      });

      // Create empty user stats
      await _database.child('user_stats/${user.uid}').set({
        'posts_count': 0,
        'followers_count': 0,
        'following_count': 0,
        'last_active': DateTime.now().millisecondsSinceEpoch,
      });

      // Create empty collections for user content
      await _database
          .child('user_posts/${user.uid}')
          .set({'initialized': true});

      await _database
          .child('user_followers/${user.uid}')
          .set({'initialized': true});

      await _database
          .child('user_following/${user.uid}')
          .set({'initialized': true});

      // Also store directly using HTTP for verification (optional)
      final response = await http.put(
        Uri.parse('$_databaseUrl/users/${user.uid}.json'),
        body: json.encode(user.toJson()),
      );

      if (response.statusCode != 200) {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error creating user in database: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserFromDb(String uid) async {
    try {
      final snapshot = await _database.child('users/$uid').get();
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);

        // Get user stats to include followers and following counts
        final statsSnapshot = await _database.child('user_stats/$uid').get();
        if (statsSnapshot.exists) {
          final statsData =
              Map<String, dynamic>.from(statsSnapshot.value as Map);
          userData['followers_count'] = statsData['followers_count'] ?? 0;
          userData['following_count'] = statsData['following_count'] ?? 0;
          userData['posts_count'] = statsData['posts_count'] ?? 0;
        }

        // Get profile data
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
      print('Error getting user from database: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserProfileFromDb(String uid) async {
    try {
      final snapshot = await _database.child('user_profiles/$uid').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return {};
    } catch (e) {
      print('Error getting user profile from database: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getUserSettingsFromDb(String uid) async {
    try {
      final snapshot = await _database.child('user_settings/$uid').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return {};
    } catch (e) {
      print('Error getting user settings from database: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getUserStatsFromDb(String uid) async {
    try {
      final snapshot = await _database.child('user_stats/$uid').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return {};
    } catch (e) {
      print('Error getting user stats from database: $e');
      return {};
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      final snapshot =
          await _database.child('usernames/${username.toLowerCase()}').get();
      return !snapshot.exists;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      // Update timestamp
      data['updated_at'] = DateTime.now().millisecondsSinceEpoch;

      // Update profile data
      await _database.child('user_profiles/$uid').update(data);

      // Update main user record if needed
      final userUpdates = <String, dynamic>{};
      if (data.containsKey('bio')) userUpdates['bio'] = data['bio'];
      if (data.containsKey('location'))
        userUpdates['location'] = data['location'];
      if (data.containsKey('website')) userUpdates['website'] = data['website'];
      if (data.containsKey('profile_image_url'))
        userUpdates['profile_image_url'] = data['profile_image_url'];

      if (userUpdates.isNotEmpty) {
        await _database.child('users/$uid').update(userUpdates);
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserSettings(String uid, Map<String, dynamic> data) async {
    try {
      await _database.child('user_settings/$uid').update(data);
    } catch (e) {
      print('Error updating user settings: $e');
      rethrow;
    }
  }

  Future<void> updateUserStats(String uid, Map<String, dynamic> data) async {
    try {
      await _database.child('user_stats/$uid').update(data);
    } catch (e) {
      print('Error updating user stats: $e');
      rethrow;
    }
  }

  Future<void> resetUserFollowers(String uid) async {
    try {
      await _database.child('user_stats/$uid').update({
        'followers_count': 0,
        'following_count': 0,
      });

      // Clear followers and following lists
      await _database.child('user_followers/$uid').remove();
      await _database.child('user_following/$uid').remove();

      // Recreate empty collections
      await _database.child('user_followers/$uid').set({'initialized': true});
      await _database.child('user_following/$uid').set({'initialized': true});

      print('Reset followers and following for user $uid');
    } catch (e) {
      print('Error resetting followers: $e');
      rethrow;
    }
  }

  Future<UserModel> getOrCreateUserProfile(
      String uid, String email, String username) async {
    try {
      // Try to get existing user
      final existingUser = await getUserFromDb(uid);
      if (existingUser != null) {
        // Reset followers if requested
        await resetUserFollowers(uid);
        return existingUser;
      }

      // Create new user if not found
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
      print('Error in getOrCreateUserProfile: $e');
      // Return a basic user model as fallback
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
      // Delete all user data
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
      rethrow;
    }
  }
}
