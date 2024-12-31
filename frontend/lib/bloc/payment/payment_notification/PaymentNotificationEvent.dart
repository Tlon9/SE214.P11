abstract class NotificationEvent {}

class NotificationReceived extends NotificationEvent {
  final Map<String, dynamic> notification;

  NotificationReceived(this.notification);
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  MarkNotificationAsRead(this.notificationId);
}

class LoadNotifications extends NotificationEvent {}
