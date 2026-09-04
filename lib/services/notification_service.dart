import '../models/app_notification.dart';
import 'api_client.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<List<AppNotification>> list({bool? lu}) async {
    final data = await ApiClient.instance.get(
      '/notifications',
      query: {if (lu != null) 'lu': lu},
    );
    return (data as List)
        .map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> marquerLue(int id) {
    return ApiClient.instance.put('/notifications/$id/lu');
  }
}
