import 'package:flutter/material.dart';

import '../../l10n.dart';

class CacheDialog extends StatelessWidget {
  const CacheDialog({
    super.key,
    required this.disposeCacheSuggestion,
    required this.createCache,
    required this.localAudioLength,
  });

  final Future<void> Function(bool value) disposeCacheSuggestion;
  final Future<void> Function({required bool delete}) createCache;
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
            disposeCacheSuggestion(true)
                .then((value) => Navigator.of(context).pop());
          },
          child: Text(context.l10n.noThankYou),
        ),
        ElevatedButton(
          onPressed: () {
            createCache(delete: false);
            disposeCacheSuggestion(true)
                .then((_) => Navigator.of(context).pop());
          },
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }
}

Future<void> showCacheSuggestion({
  required BuildContext context,
  required Future<void> Function(bool value) disposeCacheSuggestion,
  required Future<void> Function({required bool delete}) createCache,
  required int localAudioLength,
}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return CacheDialog(
        disposeCacheSuggestion: disposeCacheSuggestion,
        localAudioLength: localAudioLength,
        createCache: createCache,
      );
    },
  );
}
