import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';

import '../constants.dart';

class ExposeService {
  ExposeService({required FlutterDiscordRPC? discordRPC})
      : _discordRPC = discordRPC;

  final FlutterDiscordRPC? _discordRPC;

  Future<void>? exposeTitleOnline({
    required String songDetails,
    required String state,
  }) {
    return _discordRPC?.setActivity(
      activity: RPCActivity(
        assets: RPCAssets(
          largeText: songDetails,
          smallText: kAppTitle,
        ),
        details: songDetails,
        state: state,
      ),
    );
  }
}
