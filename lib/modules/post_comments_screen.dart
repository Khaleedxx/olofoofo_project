import 'package:flutter/material.dart';

class PostCommentsScreen extends StatelessWidget {
  const PostCommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/add_status');
            },
          ),
          centerTitle: true,
          title: const Text(
            'Post',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PostHeader(),
            const SizedBox(height: 20),
            const Divider(),
            ..._comments.map((comment) => _CommentTile(comment)).toList(),
          ],
        ),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/avatar-2.png'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Khaleeeed',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('3hr ago', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text('This is our first project in Flutter'),
        const SizedBox(height: 10),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLB4j5rYJ-y20u5lqI1OExm_dFWZpxId_ECw&s',
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/avatar-2.png'),
            ),
            const SizedBox(width: 4),
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/avatar-3.png'),
            ),
            const SizedBox(width: 4),
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Liked by ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: 'essam',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' and 200+ others',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.favorite, color: Colors.red, size: 18),
            const SizedBox(width: 2),
            const Text('247'),
            const SizedBox(width: 8),
            const Icon(Icons.mode_comment_outlined, size: 18),
            const SizedBox(width: 2),
            const Text('57'),
          ],
        ),
      ],
    );
  }
}

final List<Map<String, String>> _comments = [
  {
    'name': 'Dr.Yara',
    'image': 'assets/avatar-3.png',
    'time': '2hrs Ago',
    'comment': 'Nice one',
  },
  {
    'name': 'Dr.Ahmed',
    'image': 'assets/avatar.png',
    'time': '2hrs Ago',
    'comment': 'Good job students',
  },
];

class _CommentTile extends StatelessWidget {
  final Map<String, String> data;
  const _CommentTile(this.data);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(backgroundImage: AssetImage(data['image']!)),
      title: Row(
        children: [
          Text(
            data['name']!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Text(
            data['time']!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['comment']!),
          const SizedBox(height: 5),
          Row(
            children: const [
              Icon(Icons.favorite, color: Colors.red, size: 16),
              SizedBox(width: 4),
              Text('25'),
            ],
          ),
        ],
      ),
    );
  }
}
