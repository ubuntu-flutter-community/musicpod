import 'package:desktop_notifications/desktop_notifications.dart';

class NotificationsService {
  NotificationsService([this._notificationsClient]);

  final NotificationsClient? _notificationsClient;

  Future<void> notifiy(String message) async {
    if (_notificationsClient != null) {
      _notificationsClient?.notify(
        message,
        appIcon: 'music-app',
        appName: 'MusicPod',
      );
    }
  }

  Future<void> dispose() async {
    _notificationsClient?.close();
  }
}
