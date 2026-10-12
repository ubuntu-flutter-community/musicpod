import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/object_x.dart';
import '../data/retry_capsule.dart';
import '../logging.dart';
import '../manager/retry_manager.dart';
import 'error_page.dart';
import 'no_search_result_page.dart';
import 'ui_constants.dart';

class ErrorRetryBody extends ConsumerStatefulWidget {
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
  ConsumerState<ErrorRetryBody> createState() => _ErrorRetryBodyState();
}

class _ErrorRetryBodyState extends ConsumerState<ErrorRetryBody> {
  @override
  void initState() {
    super.initState();
    if (widget.logError) {
      Logger.e(widget.error, trace: widget.stackTrace, tag: '$ErrorRetryBody');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cooldownValue = ref.watch(retryManagerProvider(widget.retryCapsule));

    final errorText = Text(
      widget.errorText ?? widget.error.localizedErrorMessage(context.l10n),
      style: widget.errorTextStyle,
    );

    final retryButton = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: kMediumSpace,
      children: [
        FilledButton(
          onPressed: cooldownValue > 0
              ? null
              : widget.retryCapsule.autoRetry
              ? widget.retryCapsule.onRetry
              : () => ref
                  .read(retryManagerProvider(widget.retryCapsule).notifier)
                  .manualRetry(),
          child: Text(
            cooldownValue == 0
                ? context.l10n.retry
                : context.l10n.retryngInSeconds(cooldownValue.toString()),
          ),
        ),
        if (!widget.retryCapsule.autoRetry && cooldownValue == 0)
          ErrorReportButton(error: widget.error, stackTrace: widget.stackTrace),
      ],
    );

    if (widget.sliver) {
      return SliverNoSearchResultPage(icon: retryButton, message: errorText);
    }

    return NoSearchResultPage(icon: retryButton, message: errorText);
  }
}
