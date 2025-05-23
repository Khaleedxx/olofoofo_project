import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class UserService {
  // Singleton instance
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Search users by username or fullName
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final queryLowercase = query.toLowerCase();

      // Query the users node
      final snapshot = await _database.child('users').get();
      if (!snapshot.exists) {
        return [];
      }

      final usersData = Map<String, dynamic>.from(snapshot.value as Map);
      final List<UserModel> users = [];

      // Filter users based on the query
      usersData.forEach((key, value) {
        final userData = Map<String, dynamic>.from(value);
        final username = userData['username']?.toString().toLowerCase() ?? '';
        final fullName = userData['fullName']?.toString().toLowerCase() ?? '';
        final firstName = userData['firstName']?.toString().toLowerCase() ?? '';
        final lastName = userData['lastName']?.toString().toLowerCase() ?? '';

        if (username.contains(queryLowercase) ||
            fullName.contains(queryLowercase) ||
            firstName.contains(queryLowercase) ||
            lastName.contains(queryLowercase)) {
          users.add(UserModel.fromJson(userData));
        }
      });

      return users;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Get user by UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final snapshot = await _database.child('users/$uid').get();
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      // First get the UID from usernames mapping
      final uidSnapshot =
          await _database.child('usernames/${username.toLowerCase()}').get();

      if (!uidSnapshot.exists) {
        return null;
      }

      // Get the actual user with the UID
      final uid = uidSnapshot.value.toString();
      return await getUserById(uid);
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  // Check if the currentUser is following the targetUser
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      final snapshot = await _database
          .child('user_following/$currentUserId/$targetUserId')
          .get();

      return snapshot.exists;
    } catch (e) {
      print('Error checking following status: $e');
      return false;
    }
  }

  // Follow a user
  Future<bool> followUser(String currentUserId, String targetUserId) async {
    try {
      // Update the current user's following list
      await _database
          .child('user_following/$currentUserId/$targetUserId')
          .set(true);

      // Update the target user's followers list
      await _database
          .child('user_followers/$targetUserId/$currentUserId')
          .set(true);

      // Increment the following count for current user
      final currentUserStats =
          await _database.child('user_stats/$currentUserId').get();
      if (currentUserStats.exists) {
        Map<String, dynamic> stats =
            Map<String, dynamic>.from(currentUserStats.value as Map);
        stats['following_count'] = (stats['following_count'] ?? 0) + 1;
        await _database.child('user_stats/$currentUserId').update(stats);
      }

      // Increment the followers count for target user
      final targetUserStats =
          await _database.child('user_stats/$targetUserId').get();
      if (targetUserStats.exists) {
        Map<String, dynamic> stats =
            Map<String, dynamic>.from(targetUserStats.value as Map);
        stats['followers_count'] = (stats['followers_count'] ?? 0) + 1;
        await _database.child('user_stats/$targetUserId').update(stats);
      }

      return true;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  // Unfollow a user
  Future<bool> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      // Remove from the current user's following list
      await _database
          .child('user_following/$currentUserId/$targetUserId')
          .remove();

      // Remove from the target user's followers list
      await _database
          .child('user_followers/$targetUserId/$currentUserId')
          .remove();

      // Decrement the following count for current user
      final currentUserStats =
          await _database.child('user_stats/$currentUserId').get();
      if (currentUserStats.exists) {
        Map<String, dynamic> stats =
            Map<String, dynamic>.from(currentUserStats.value as Map);
        stats['following_count'] = (stats['following_count'] ?? 1) - 1;
        if (stats['following_count'] < 0) stats['following_count'] = 0;
        await _database.child('user_stats/$currentUserId').update(stats);
      }

      // Decrement the followers count for target user
      final targetUserStats =
          await _database.child('user_stats/$targetUserId').get();
      if (targetUserStats.exists) {
        Map<String, dynamic> stats =
            Map<String, dynamic>.from(targetUserStats.value as Map);
        stats['followers_count'] = (stats['followers_count'] ?? 1) - 1;
        if (stats['followers_count'] < 0) stats['followers_count'] = 0;
        await _database.child('user_stats/$targetUserId').update(stats);
      }

      return true;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }
}
