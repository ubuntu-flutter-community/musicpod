// ignore_for_file: unused_field

import 'package:injectable/injectable.dart';
import 'package:local_notifier/local_notifier.dart';

import '../extensions/taget_platform_x.dart';

@lazySingleton
class NotificationsService {
  NotificationsService({required LocalNotifier localNotifier})
    : _localNotifier = localNotifier;

  final LocalNotifier _localNotifier;

  Future<void> notify({required String message}) async {
    if (!isDesktop) return;
    final notification = LocalNotification(title: message);
    notification.show();
  }
}
