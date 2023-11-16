import 'package:flutter/material.dart';

import '../../l10n.dart';

class CacheDialog extends StatelessWidget {
  const CacheDialog({
    super.key,
    required this.onUseLocalAudioCache,
    required this.createCache,
    required this.localAudioLength,
  });

  final Future<void> Function(bool value) onUseLocalAudioCache;
  final Future<void> Function() createCache;
  final int localAudioLength;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        context.l10n.localAudioCacheSuggestion(localAudioLength.toString()),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            onUseLocalAudioCache(false)
                .then((value) => Navigator.of(context).pop());
          },
          child: Text(context.l10n.noThankYou),
        ),
        ElevatedButton(
          onPressed: () {
            createCache();
            onUseLocalAudioCache(true).then((_) => Navigator.of(context).pop());
          },
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }
}

Future<void> showCacheSuggestion({
  required BuildContext context,
  required Future<void> Function(bool value) onUseLocalAudioCache,
  required Future<void> Function() createCache,
  required int localAudioLength,
}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return CacheDialog(
        onUseLocalAudioCache: onUseLocalAudioCache,
        localAudioLength: localAudioLength,
        createCache: createCache,
      );
    },
  );
}
