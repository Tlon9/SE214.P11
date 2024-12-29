import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travelowkey/widgets/notification_manager.dart';

class NotificationScreen extends StatelessWidget {
  final String accessToken;

  const NotificationScreen({Key? key, required this.accessToken})
      : super(key: key);

  Future<List<dynamic>> fetchNotifications() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/payment/notification/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await http.put(
      Uri.parse(
          'http://10.0.2.2:8080/payment/notification/?notification_id=${notificationId}'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final unreadCount = await NotificationManager().getUnreadCount();
    await NotificationManager().setUnreadCount(unreadCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Thông báo',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  color: notification['status'] == 'UNREAD'
                      ? const Color.fromARGB(255, 230, 230, 230)
                      : Colors.white,
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      notification['status'] == 'UNREAD'
                          ? Icons.notifications_active
                          : Icons.notifications,
                      color: notification['status'] == 'UNREAD'
                          ? Colors.red
                          : Colors.grey,
                      size: 30,
                    ),
                    title: Text(
                      notification['info'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notification['created_at']),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () async {
                        await markAsRead(notification['_id']);
                        Navigator.pushNamed(context, '/invoice', arguments: {
                          'transactionId': notification['transaction_id'],
                          'service': notification['service'],
                        });
                      },
                    ),
                    onTap: () async {
                      await markAsRead(notification['_id']);
                      Navigator.pushNamed(context, '/invoice', arguments: {
                        'transactionId': notification['transaction_id'],
                        'service': notification['service'],
                      });
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No notifications available.'));
          }
        },
      ),
    );
  }
}
