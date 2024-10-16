// TODO(#946): make discord work inside the snap
// or leave it for linux disabled if this won't work
import 'package:flutter/foundation.dart';

bool allowDiscordRPC = kDebugMode ||
    bool.tryParse(const String.fromEnvironment('ALLOW_DISCORD_RPC')) == true;
