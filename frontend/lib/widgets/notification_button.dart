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
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final userJson = await _storage.read(key: 'user_info');
    final accessToken = userJson != null
        ? AccountLogin.fromJson(jsonDecode(userJson)).accessToken
        : null;
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8800/user/verify/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${accessToken}",
      },
    );
    final user_id = jsonDecode(response.body)['user_id'];
    print('User ID: $user_id');
    if (user_id != null) {
      setState(() {
        _isLoggedIn = true;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
    if (_isLoggedIn) {
      print('User is logged in');
      _updateUnreadCount();
      _loadUnreadCount();
    } else {
      _cleanUnreadCount();
    }
  }

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
    final _storage = FlutterSecureStorage();
    final userJson = await _storage.read(key: 'user_info');
    final accessToken = userJson != null
        ? AccountLogin.fromJson(jsonDecode(userJson)).accessToken
        : null;
    if (accessToken != null) {
      try {
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
      } catch (e) {
        print('Failed to update unread count: $e');
      }
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
                  content: Text('Bạn cần đăng nhập để xem thông báo')),
            );
          }
        },
      ),
    );
  }
}
