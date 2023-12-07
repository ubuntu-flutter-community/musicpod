import 'dart:io';

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool get isMobile => Platform.isAndroid || Platform.isIOS || Platform.isFuchsia;
