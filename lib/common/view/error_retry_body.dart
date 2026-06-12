import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/object_x.dart';
import '../data/retry_capsule.dart';
import '../retry_manager.dart';
import 'no_search_result_page.dart';

class ErrorRetryBody extends StatelessWidget with WatchItMixin {
  const ErrorRetryBody({
    super.key,
    required this.error,
    required this.retryCapsule,
    this.sliver = false,
    this.errorText,
    this.errorTextStyle,
  });

  final Object error;
  final String? errorText;
  final RetryCapsule retryCapsule;
  final bool sliver;
  final TextStyle? errorTextStyle;

  @override
  Widget build(BuildContext context) {
    final cooldownValue = watch(
      di<RetryManager>(param1: retryCapsule).cooldown,
    ).value;

    final errorText = Text(
      this.errorText ?? error.localizedErrorMessage(context.l10n),
      style: errorTextStyle,
    );

    final retryButton = FilledButton(
      onPressed: cooldownValue > 0 ? null : retryCapsule.onRetry,
      child: Text(
        cooldownValue == 0
            ? context.l10n.retry
            : context.l10n.retryngInSeconds(cooldownValue.toString()),
      ),
    );

    if (sliver) {
      return SliverNoSearchResultPage(icon: retryButton, message: errorText);
    }

    return NoSearchResultPage(icon: retryButton, message: errorText);
  }
}
