import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/firebase_db_model.dart';
import '../services/user_service.dart';
import 'package:intl/intl.dart';
import '../models/chat_models.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final FirebaseDbModel _dbModel = FirebaseDbModel();
  final UserService _userService = UserService();
  bool _isLoading = true;
  UserModel? _currentUser;
  UserModel? _profileUser; // The user whose profile we're viewing
  bool _isCurrentUserProfile = true;
  bool _isFollowing = false;
  bool _isLoadingFollow = false;

  // Mock posts data
  final List<Map<String, dynamic>> _posts = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?q=80&w=1332&auto=format&fit=crop',
      'likes': 124,
      'comments': 32,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1287&auto=format&fit=crop',
      'likes': 89,
      'comments': 15,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1473&auto=format&fit=crop',
      'likes': 247,
      'comments': 57,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1526779259212-939e64788e3c?q=80&w=1374&auto=format&fit=crop',
      'likes': 185,
      'comments': 24,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1511988617509-a57c8a288659?q=80&w=1471&auto=format&fit=crop',
      'likes': 302,
      'comments': 41,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1511920170033-f8396924c348?q=80&w=1374&auto=format&fit=crop',
      'likes': 156,
      'comments': 19,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user from AuthService
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Get full current user model from database
      final currentUserModel = await _dbModel.getUserFromDb(currentUser.uid);

      // Check if viewing other user's profile
      if (widget.userId != null && widget.userId != currentUser.uid) {
        // Get the user model for the specified userId
        final profileUserModel = await _userService.getUserById(widget.userId!);

        // Check if the current user is following this user
        final following =
            await _userService.isFollowing(currentUser.uid, widget.userId!);

        if (mounted) {
          setState(() {
            _currentUser = currentUserModel;
            _profileUser = profileUserModel;
            _isCurrentUserProfile = false;
            _isFollowing = following;
            _isLoading = false;
          });
        }
      } else {
        // Viewing own profile
        if (mounted) {
          setState(() {
            _currentUser = currentUserModel;
            _profileUser = currentUserModel;
            _isCurrentUserProfile = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _followUser() async {
    if (_currentUser == null || _profileUser == null) return;

    setState(() {
      _isLoadingFollow = true;
    });

    try {
      final success =
          await _userService.followUser(_currentUser!.uid, _profileUser!.uid);

      if (success && mounted) {
        setState(() {
          _isFollowing = true;
          // Update the follower count in the UI
          if (_profileUser != null) {
            _profileUser = _profileUser!
                .copyWith(followersCount: _profileUser!.followersCount + 1);
          }
          _isLoadingFollow = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Following ${_profileUser!.username}')),
        );
      }
    } catch (e) {
      print('Error following user: $e');
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to follow user')),
        );
      }
    }
  }

  Future<void> _unfollowUser() async {
    if (_currentUser == null || _profileUser == null) return;

    setState(() {
      _isLoadingFollow = true;
    });

    try {
      final success =
          await _userService.unfollowUser(_currentUser!.uid, _profileUser!.uid);

      if (success && mounted) {
        setState(() {
          _isFollowing = false;
          // Update the follower count in the UI
          if (_profileUser != null) {
            _profileUser = _profileUser!
                .copyWith(followersCount: _profileUser!.followersCount - 1);
          }
          _isLoadingFollow = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed ${_profileUser!.username}')),
        );
      }
    } catch (e) {
      print('Error unfollowing user: $e');
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to unfollow user')),
        );
      }
    }
  }

  void _messageUser() {
    if (_currentUser == null || _profileUser == null) return;

    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'currentUserId': _currentUser!.uid,
        'otherUser': ChatUser(
          id: _profileUser!.uid,
          name: _profileUser!.username,
          profileImage: _profileUser!.profileImageUrl,
        ),
      },
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            _buildOptionTile(Icons.settings, 'Settings', () {
              Navigator.pop(context);
              // Navigate to settings page
            }),
            _buildOptionTile(Icons.bookmark_border, 'Saved', () {
              Navigator.pop(context);
              // Navigate to saved posts
            }),
            _buildOptionTile(Icons.history, 'Your Activity', () {
              Navigator.pop(context);
              // Navigate to activity history
            }),
            _buildOptionTile(Icons.qr_code, 'QR Code', () {
              Navigator.pop(context);
              // Show QR code
            }),
            _buildOptionTile(Icons.logout, 'Log Out', () {
              Navigator.pop(context);
              _showLogoutConfirmation();
            }),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(context); // Close the dialog
                await _authService.signOut();
                // The auth state change listener in main.dart will handle navigation
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logging out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile() {
    // Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile feature coming soon')),
    );
  }

  Widget _buildOptionTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('User not logged in'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/sign_in');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          _currentUser!.username,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/add_status');
            },
          ),
          if (_isCurrentUserProfile)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () => _showLogoutConfirmation(),
            ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = _profileUser;
    if (user == null) return Container();

    final profileImageUrl = user.profileImageUrl ??
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1287&auto=format&fit=crop';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(user.postsCount.toString(), 'Posts'),
                    _buildStatColumn(
                        user.followersCount.toString(), 'Followers'),
                    _buildStatColumn(
                        user.followingCount.toString(), 'Following'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName ?? user.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.bio ?? 'Hello! I am using OFOFO',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (_isCurrentUserProfile)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
          if (!_isCurrentUserProfile)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoadingFollow
                        ? null
                        : (_isFollowing ? _unfollowUser : _followUser),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFollowing ? Colors.white : Colors.blue,
                      foregroundColor:
                          _isFollowing ? Colors.black : Colors.white,
                      side: _isFollowing
                          ? const BorderSide(color: Colors.grey)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoadingFollow
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_isFollowing ? 'Following' : 'Follow'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _messageUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStoryHighlight(String title, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Navigate to post detail
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                _posts[index]['imageUrl'],
                fit: BoxFit.cover,
              ),
              if (_posts[index]['likes'] > 200)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
