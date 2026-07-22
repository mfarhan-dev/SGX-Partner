class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.deepLink,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? deepLink;
}
