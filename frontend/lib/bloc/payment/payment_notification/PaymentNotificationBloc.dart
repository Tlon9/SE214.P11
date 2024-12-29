import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:travelowkey/bloc/payment/payment_notification/PaymentNotificationEvent.dart';
import 'package:travelowkey/bloc/payment/payment_notification/PaymentNotificationState.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final String apiUrl;
  final String accessToken;
  final List<Map<String, dynamic>> _notifications = [];

  NotificationBloc(this.apiUrl, this.accessToken)
      : super(NotificationInitial());

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    if (event is LoadNotifications) {
      yield NotificationLoading();
      try {
        final response = await http.get(
          Uri.parse('$apiUrl/notifications'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          _notifications.clear();
          _notifications.addAll(data.map((e) => e as Map<String, dynamic>));
          yield NotificationLoaded(List.from(_notifications));
        } else {
          yield NotificationError("Failed to load notifications");
        }
      } catch (error) {
        yield NotificationError("An error occurred: $error");
      }
    } else if (event is MarkNotificationAsRead) {
      final index =
          _notifications.indexWhere((n) => n['id'] == event.notificationId);
      if (index != -1) {
        _notifications[index]['isSeen'] = true;

        // Call the API to mark the notification as read
        await http.put(
          Uri.parse('$apiUrl/notifications'),
          headers: {'Authorization': 'Bearer $accessToken'},
          body: json.encode({'notification_id': event.notificationId}),
        );

        yield NotificationLoaded(List.from(_notifications));
      }
    }
  }
}
