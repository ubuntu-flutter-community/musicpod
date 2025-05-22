import 'package:desktop_notifications/desktop_notifications.dart';

class NotificationsService {
  NotificationsService([this._notificationsClient]);

  final NotificationsClient? _notificationsClient;

  Future<void> notify({required String message, String? uri}) async {
    if (_notificationsClient != null) {
      _notificationsClient.notify(
        message,
        appIcon: uri ?? 'music-app',
        appName: 'MusicPod',
      );
    }
  }

  Future<void> dispose() async {
    await _notificationsClient?.close();
  }
}
