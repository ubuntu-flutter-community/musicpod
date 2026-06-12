import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../extensions/object_x.dart';
import 'no_search_result_page.dart';
import '../../extensions/build_context_x.dart';

class ErrorRetryBody extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ErrorRetryBody({
    super.key,
    required this.error,
    required this.onRetry,
    this.sliver = false,
    this.errorText,
    this.errorTextStyle,
  });

  final Object error;
  final String? errorText;
  final void Function() onRetry;
  final bool sliver;
  final TextStyle? errorTextStyle;

  @override
  State<ErrorRetryBody> createState() => _ErrorRetryBodyState();
}

class _ErrorRetryBodyState extends State<ErrorRetryBody> {
  Timer? _cooldownTimer;
  SafeValueNotifier<int> _cooldown = SafeValueNotifier<int>(20);

  @override
  Widget build(BuildContext context) {
    onDispose(() => _cooldownTimer?.cancel());

    callOnceAfterThisBuild((context) {
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_cooldown.value > 0) {
          _cooldown.value--;
        } else {
          timer.cancel();
          _cooldownTimer = null;
          widget.onRetry();
        }
      });
    });

    final cooldownValue = watch(_cooldown).value;

    final errorText = Text(
      widget.errorText ?? widget.error.localizedErrorMessage(context.l10n),
      style: widget.errorTextStyle,
    );

    final retryButton = FilledButton(
      onPressed: cooldownValue > 0 ? null : widget.onRetry,
      child: Text(
        cooldownValue == 0
            ? context.l10n.retry
            : context.l10n.retryngInSeconds(cooldownValue.toString()),
      ),
    );

    if (widget.sliver) {
      return SliverNoSearchResultPage(icon: retryButton, message: errorText);
    }

    return NoSearchResultPage(icon: retryButton, message: errorText);
  }
}

@Injectable(cache: true)
class RetryManager {
  RetryManager({
    @factoryParam required this.source,
    @ignoreParam this.onRetry,
  }) {
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldown.value > 0) {
        cooldown.value--;
      } else {
        timer.cancel();
        _cooldownTimer = null;
        onRetry?.call();
      }
    });
  }

  final String source;
  final dynamic Function()? onRetry;

  Timer? _cooldownTimer;
  Timer? get cooldownTimer => _cooldownTimer;
  SafeValueNotifier<int> cooldown = SafeValueNotifier<int>(20);
}
