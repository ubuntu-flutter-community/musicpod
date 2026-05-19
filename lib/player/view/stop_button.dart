import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_manager.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';

class StopButton extends StatelessWidget {
  const StopButton({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.stop,
    onPressed: active
        ? () {
            di<AppManager>().setFullWindowMode(false);
            di<PlayerModel>().stop();
          }
        : null,
    icon: Icon(Iconz.stopFilled),
  );
}
