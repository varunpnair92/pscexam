class NotificationModel {
  final int id;
  final String title;
  final String notificationData;
  final bool active;

  NotificationModel({
    required this.id,
    required this.title,
    required this.notificationData,
    required this.active,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      notificationData: json['notification_data'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
