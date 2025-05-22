import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import 'package:flutter/cupertino.dart';

class DisconnectedServerIcon extends StatelessWidget {
  const DisconnectedServerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Iconz.cloud, color: theme.disabledColor),
        Positioned(
          bottom: -2,
          right: -2,
          child: Icon(Iconz.close, color: theme.colorScheme.error, size: 16),
        ),
      ],
    );
  }
}
