import 'package:local_notifier/local_notifier.dart';

class NotificationsService {
  NotificationsService([this._notificationsClient]);

  final LocalNotifier? _notificationsClient;

  Future<void> notify({required String message}) async {
    if (_notificationsClient != null) {
      final notification = LocalNotification(title: message);
      notification.show();
    }
  }

  Future<void> dispose() async {}
}
