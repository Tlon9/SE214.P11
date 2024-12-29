import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  static const String unreadCountKey = 'unread_count';

  // Future<void> fetchUnreadCount() async {
  //   // Fetch unread count from server
  //   // Example unread count from server
  //   final fetchedUnreadCount = 5;
  //   await setUnreadCount(fetchedUnreadCount);
  // }

  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(unreadCountKey) ?? 0;
  }

  Future<void> setUnreadCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(unreadCountKey, count);
  }

  Future<void> clearUnreadCount() async {
    await setUnreadCount(0);
  }
}
