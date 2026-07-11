import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/object_x.dart';
import '../data/retry_capsule.dart';
import '../logging.dart';
import '../manager/retry_manager.dart';
import 'error_page.dart';
import 'no_search_result_page.dart';
import 'ui_constants.dart';

class ErrorRetryBody extends StatelessWidget with WatchItMixin {
  const ErrorRetryBody({
    super.key,
    required this.error,
    required this.retryCapsule,
    required this.stackTrace,
    this.sliver = false,
    this.errorText,
    this.errorTextStyle,
    this.logError = false,
  });

  final Object error;
  final StackTrace stackTrace;
  final String? errorText;
  final RetryCapsule retryCapsule;
  final bool sliver;
  final TextStyle? errorTextStyle;
  final bool logError;

  @override
  Widget build(BuildContext context) {
    if (logError) {
      callOnceAfterThisBuild((_) {
        Logger.e(error, trace: stackTrace, tag: '$ErrorRetryBody');
      });
    }

    final cooldownValue = watchValue(
      (RetryManager m) => m.cooldown,
      param1: retryCapsule,
    );

    final errorText = Text(
      this.errorText ?? error.localizedErrorMessage(context.l10n),
      style: errorTextStyle,
    );

    final retryButton = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: kMediumSpace,
      children: [
        FilledButton(
          onPressed: cooldownValue > 0
              ? null
              : retryCapsule.autoRetry
              ? retryCapsule.onRetry
              : di<RetryManager>(param1: retryCapsule).manualRetry,
          child: Text(
            cooldownValue == 0
                ? context.l10n.retry
                : context.l10n.retryngInSeconds(cooldownValue.toString()),
          ),
        ),
        if (!retryCapsule.autoRetry && cooldownValue == 0)
          ErrorReportButton(error: error, stackTrace: stackTrace),
      ],
    );

    if (sliver) {
      return SliverNoSearchResultPage(icon: retryButton, message: errorText);
    }

    return NoSearchResultPage(icon: retryButton, message: errorText);
  }
}
