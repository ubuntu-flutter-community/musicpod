import 'dart:io';

import 'package:flutter/foundation.dart';

bool get isDesktop => !kIsWeb && !isMobile;
bool get isMobile => !kIsWeb && (isIOS || isAndroid || isFuchsia);
bool get isLinux => !kIsWeb && Platform.isLinux;
bool get isMacOS => !kIsWeb && Platform.isMacOS;
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isIOS => !kIsWeb && Platform.isIOS;
bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isFuchsia => !kIsWeb && Platform.isFuchsia;
