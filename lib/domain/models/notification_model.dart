class NotificationModel {
  final String id;
  final String notificationMessage;
  final String contentTypeName;
  final String updatedDateEn;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.notificationMessage,
    required this.contentTypeName,
    required this.updatedDateEn,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      notificationMessage: json['notification_message'] ?? '',
      contentTypeName: json['content_type_name'] ?? '',
      updatedDateEn: json['updated_date_en'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }
}
