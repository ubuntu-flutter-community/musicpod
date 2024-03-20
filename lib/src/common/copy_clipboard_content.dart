import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../l10n/l10n.dart';
import 'stream_provider_share_button.dart';

class CopyClipboardContent extends StatelessWidget {
  const CopyClipboardContent({
    super.key,
    required this.text,
    this.onSearch,
    this.showActions = true,
  });

  final String text;
  final void Function()? onSearch;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final textColor =
        theme.snackBarTheme.contentTextStyle?.color?.withOpacity(0.8);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Text(
                  context.l10n.copiedToClipBoard,
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
                Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (showActions)
            StreamProviderRow(
              iconColor: theme.snackBarTheme.actionTextColor,
              onSearch: onSearch,
              text: text,
            ),
        ],
      ),
    );
  }
}
