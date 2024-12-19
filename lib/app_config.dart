import 'dart:io';

import 'package:flutter/foundation.dart';

// TODO(#946): make discord work inside the snap
// or leave it for linux disabled if this won't work
bool allowDiscordRPC = (kDebugMode && !Platform.isAndroid) ||
    Platform.isMacOS ||
    Platform.isWindows ||
    bool.tryParse(const String.fromEnvironment('ALLOW_DISCORD_RPC')) == true;

bool get useSystemTheme => !Platform.isLinux;

bool get yaruStyled => Platform.isLinux;

bool get appleStyled => Platform.isMacOS || Platform.isIOS;

// TODO(#1022): fix linux video fullscreen
bool get allowVideoFullScreen => !Platform.isLinux;

bool get isGtkApp => Platform.isLinux;

bool get isMobilePlatform =>
    Platform.isAndroid || Platform.isIOS || Platform.isFuchsia;
