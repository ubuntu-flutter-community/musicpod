import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'online_art_service.dart';

class OnlineArtModel extends SafeChangeNotifier {
  OnlineArtModel({required OnlineArtService service}) : _service = service;

  final OnlineArtService _service;

  Stream<String?> get error => _service.error;
}
