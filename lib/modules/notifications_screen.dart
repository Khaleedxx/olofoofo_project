import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.delete, color: Colors.black),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _notificationTile(
            'assets/avatar.png',
            'ahmed',
            'Followed you',
            'Just Now',
          ),
          _notificationTile(
            'assets/avatar-2.png',
            'islam',
            'Followed you',
            '2mins ago',
          ),
          _notificationTile(
            'assets/avatar-3.png',
            'essam',
            'Liked your photo',
            '15mins ago',
            italic: true,
          ),
          _notificationTile(
            'assets/avatar.png',
            'ibrahim',
            'commented on your post',
            '1hour ago',
            italic: true,
          ),
          const SizedBox(height: 20),
          const Text(
            '12 January 2022',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _notificationTile(
            'assets/avatar-2.png',
            'essam',
            'Followed you',
            '11:20am',
          ),
          _notificationTile(
            'assets/avatar-3.png',
            'marwan',
            'Followed you',
            '10:00am',
          ),
          _notificationTile(
            'assets/avatar.png',
            'khaled',
            'Liked your photo',
            '09:00am',
            italic: true,
          ),
          _notificationTile(
            'assets/avatar-2.png',
            'ali',
            'commented on your post',
            '07:00am',
            italic: true,
          ),
        ],
      ),
    );
  }

  Widget _notificationTile(
    String image,
    String user,
    String action,
    String time, {
    bool italic = false,
  }) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage(image)),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: '$user ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: action,
              style:
                  italic
                      ? const TextStyle(fontStyle: FontStyle.italic)
                      : const TextStyle(),
            ),
          ],
        ),
      ),
      subtitle: Text(time),
    );
  }
}
