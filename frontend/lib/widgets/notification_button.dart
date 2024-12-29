import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
import 'notification_manager.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;

class NotificationIconButton extends StatefulWidget {
  final VoidCallback onLoggedIn;

  const NotificationIconButton({Key? key, required this.onLoggedIn})
      : super(key: key);

  @override
  _NotificationIconButtonState createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _cleanUnreadCount();
    _checkLoginStatus();
    _updateUnreadCount();
    _loadUnreadCount();
  }

  Future<void> _checkLoginStatus() async {
    final userJson = await _storage.read(key: 'user_info');
    final accessToken = userJson != null
        ? AccountLogin.fromJson(jsonDecode(userJson)).accessToken
        : null;
    setState(() {
      _isLoggedIn = accessToken != null;
    });
  }

  // Future<void> _fetchUnreadCount() async {
  //    // Extract unread count from JSON response
  //     // Example unread count from server
  //     setState(() {
  //       unreadCount = fetchedUnreadCount;
  //     });
  //   }
  // }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationManager().getUnreadCount();
    setState(() {
      unreadCount = count;
    });
  }

  Future<void> _cleanUnreadCount() async {
    await NotificationManager().clearUnreadCount();
    setState(() {
      unreadCount = 0;
    });
  }

  Future<void> _updateUnreadCount() async {
    final accessToken = await _storage.read(key: 'access_token');
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/payment/notification/?type=count'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      final jsonResponse = jsonDecode(response.body);
      final updatedCount = jsonResponse['unread_count'];
      print('Updated count: $updatedCount');
      await NotificationManager().setUnreadCount(updatedCount);
      setState(() {
        unreadCount = updatedCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // _updateUnreadCount();
    // _loadUnreadCount();
    // print('Unread count: $unreadCount');
    return badges.Badge(
      badgeContent: Text(
        unreadCount > 99 ? '99+' : '$unreadCount',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      showBadge: unreadCount > 0,
      position: badges.BadgePosition.topEnd(top: 4, end: 4),
      child: IconButton(
        icon: const Icon(Icons.notifications, color: Colors.white, size: 30),
        onPressed: () {
          if (_isLoggedIn) {
            widget.onLoggedIn(); // Trigger the action when logged in
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('You need to log in to view notifications.')),
            );
          }
        },
      ),
    );
  }
}
