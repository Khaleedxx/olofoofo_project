import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // For pull-to-refresh
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Page controller for bottom navigation
  final PageController _pageController = PageController();
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize pages here after dependencies are ready
    if (_pages.isEmpty) {
      _pages.add(_buildMainContent());
      _pages.add(const SearchScreen());
      _pages.add(const Center(child: Text('Activity')));
      _pages.add(const ProfileScreen());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more content when reaching the bottom
      _loadMoreContent();
    }
  }

  Future<void> _loadMoreContent() async {
    // Simulate loading more content
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // In a real app, you would fetch more posts from your database here
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshContent() async {
    setState(() {
      _isRefreshing = true;
    });

    // In a real app, you would refresh posts from your database here
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _showPostOptions(BuildContext context) {
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
            _buildOptionTile(Icons.bookmark_border, 'Save post', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post saved')),
              );
            }),
            _buildOptionTile(Icons.share, 'Share post', () {
              Navigator.pop(context);
            }),
            _buildOptionTile(Icons.report_outlined, 'Report post', () {
              Navigator.pop(context);
            }),
            _buildOptionTile(Icons.block, 'Hide posts from this user', () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages.isEmpty
            ? [const Center(child: CircularProgressIndicator())]
            : _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/add_status');
              },
            )
          : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 0),
            _buildNavItem(Icons.search, 1),
            _buildNavItem(Icons.favorite_border, 2),
            _buildNavItem(Icons.person_outline, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _pageController.jumpToPage(index);
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshContent,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              elevation: 0,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Text(
                    'OFOFO',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.black87),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                        _pageController.jumpToPage(1);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined,
                        color: Colors.black87),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.message_outlined,
                        color: Colors.black87),
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildFeed(),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesSection() {
    return Container(
      height: 110,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildAddStoryItem(),
          _buildStoryItem(
              'Chris',
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1287&auto=format&fit=crop',
              true),
          _buildStoryItem(
              'General',
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1287&auto=format&fit=crop',
              false),
          _buildStoryItem(
              'Ojagbon',
              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1287&auto=format&fit=crop',
              false),
          _buildStoryItem(
              'Tunde',
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=1287&auto=format&fit=crop',
              false),
          _buildStoryItem(
              'Aisha',
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1287&auto=format&fit=crop',
              true),
        ],
      ),
    );
  }

  Widget _buildAddStoryItem() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.black54),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Story',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String name, String imageUrl, bool isLive) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: isLive ? Colors.red : Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              if (isLive)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildPostItem(
          'Oyin Dolapo',
          '1hr ago',
          'Just had an amazing day at the beach! The sunset was absolutely breathtaking. #BeachDay #Sunset #GoodVibes',
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1473&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?q=80&w=1287&auto=format&fit=crop',
          247,
          57,
          'Blazinshado and 100+ others',
        ),
        const SizedBox(height: 12),
        _buildPostItem(
          'Abdul Quayyum',
          '3hrs ago',
          'Just finished my new tech setup! What do you guys think? #TechSetup #WorkFromHome',
          'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?q=80&w=1332&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1287&auto=format&fit=crop',
          124,
          32,
          'Chris and 50+ others',
        ),
        const SizedBox(height: 12),
        _buildPostItem(
          'Tunde Adeyemi',
          '5hrs ago',
          'Cooking up something special for dinner tonight! #HomeCooking #FoodLover',
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1287&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=1287&auto=format&fit=crop',
          89,
          15,
          'Ojagbon and 20+ others',
        ),
      ],
    );
  }

  Widget _buildPostItem(
    String name,
    String time,
    String description,
    String postImageUrl,
    String profileImageUrl,
    int likes,
    int comments,
    String likedBy,
  ) {
    bool isLiked = false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _showPostOptions(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                isLiked = true;
              });
            },
            child: Image.network(
              postImageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$likes likes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (likedBy.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Liked by $likedBy',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                if (comments > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/post_comments');
                      },
                      child: Text(
                        'View all $comments comments',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
