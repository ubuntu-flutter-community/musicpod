import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../radio_manager.dart';
import 'disconnected_server_icon.dart';

class RadioReconnectButton extends StatelessWidget {
  const RadioReconnectButton({super.key});

  @override
  Widget build(BuildContext context) => TextButton.icon(
    label: Text(
      '${context.l10n.noRadioServerFound}: ${context.l10n.tryReconnect}',
    ),
    onPressed: () => di<RadioManager>().maybeConnect(clearErrors: true),
    icon: const DisconnectedServerIcon(),
  );
}
