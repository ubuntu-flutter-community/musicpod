import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../extensions/object_x.dart';
import 'no_search_result_page.dart';
import '../../extensions/build_context_x.dart';

class ErrorRetryBody extends StatelessWidget with WatchItMixin {
  const ErrorRetryBody({
    super.key,
    required this.error,
    required this.onRetry,
    this.sliver = false,
    required this.cooldown,
    this.errorText,
    this.errorTextStyle,
  });

  final Object error;
  final String? errorText;
  final void Function()? onRetry;
  final bool sliver;
  final SafeValueNotifier<int> cooldown;
  final TextStyle? errorTextStyle;

  @override
  Widget build(BuildContext context) {
    final cooldownValue = watch(cooldown).value;
    if (sliver) {
      return SliverNoSearchResultPage(
        icon: FilledButton(
          onPressed: onRetry,
          child: Text(
            cooldownValue == 0
                ? context.l10n.retry
                : context.l10n.retryngInSeconds(cooldownValue.toString()),
          ),
        ),
        message: Text(
          errorText ?? error.localizedErrorMessage(context.l10n),
          style: errorTextStyle,
        ),
      );
    }

    return NoSearchResultPage(
      icon: FilledButton(
        onPressed: onRetry,
        child: Text(
          cooldownValue == 0
              ? context.l10n.retry
              : context.l10n.retryngInSeconds(cooldownValue.toString()),
        ),
      ),
      message: Text(
        errorText ?? error.localizedErrorMessage(context.l10n),
        style: errorTextStyle,
      ),
    );
  }
}
