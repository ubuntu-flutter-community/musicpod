import 'dart:io';

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> playlistNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> settingsNavigatorKey = GlobalKey();

bool get isMobile => Platform.isAndroid || Platform.isIOS || Platform.isFuchsia;
