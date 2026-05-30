import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../extensions/build_context_x.dart';
import '../radio_manager.dart';

class RadioErrorRetryBody extends StatelessWidget with WatchItMixin {
  const RadioErrorRetryBody({
    super.key,
    required this.error,
    required this.onRetry,
    this.sliver = false,
  });

  final Object error;
  final void Function()? onRetry;
  final bool sliver;

  @override
  Widget build(BuildContext context) {
    final cooldown = watchValue((RadioManager m) => m.cooldown);

    if (sliver) {
      return SliverNoSearchResultPage(
        icon: FilledButton(
          onPressed: onRetry,
          child: Text(
            cooldown == 0
                ? context.l10n.retry
                : context.l10n.retryngInSeconds(cooldown.toString()),
          ),
        ),
        message: Text(error.toString()),
      );
    }

    return NoSearchResultPage(
      icon: FilledButton(
        onPressed: onRetry,
        child: Text(
          cooldown == 0
              ? context.l10n.retry
              : context.l10n.retryngInSeconds(cooldown.toString()),
        ),
      ),
      message: Text(error.toString()),
    );
  }
}
