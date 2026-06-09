import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_config.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../logging.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    required this.error,
    this.onRetry,
    this.onRetryLabel,
    this.addQuitButton = false,
    this.stackTrace,
  });

  final Object? error;
  final StackTrace? stackTrace;
  final void Function()? onRetry;
  final String? onRetryLabel;
  final bool addQuitButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaruWindowTitleBar(
        title: Text(context.l10n.oopsSomethingWentWrong),
        border: BorderSide.none,
        backgroundColor: Colors.transparent,
      ),
      body: ErrorBody(
        error: error,
        stackTrace: stackTrace,
        onRetryLabel: onRetryLabel,
        onRetry: onRetry,
        addQuitButton: addQuitButton,
      ),
    );
  }
}

class ErrorBody extends StatelessWidget with WatchItMixin {
  const ErrorBody({
    super.key,
    required this.error,
    required this.stackTrace,
    this.onRetry,
    this.onRetryLabel,
    this.addQuitButton = false,
  });

  final Object? error;
  final StackTrace? stackTrace;
  final void Function()? onRetry;
  final String? onRetryLabel;
  final bool addQuitButton;

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild(
      (_) => printErrorInDebugMode(
        'ErrorPage: ${error.toString()} \n StackTrace: ${stackTrace.toString()}',
        tag: '$ErrorPage',
        trace: stackTrace,
      ),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kLargestSpace),
        child: SizedBox(
          width: 350,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Icon(Icons.bug_report_outlined, size: 100),
              const SizedBox(height: kMediumSpace),
              YaruExpandable(
                header: Text(
                  error.toString().split(': ').firstOrNull ?? error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                child: SelectableText(error.toString()),
              ),
              const SizedBox(height: 2 * kLargestSpace),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: kMediumSpace,
                children: [
                  if (onRetry != null)
                    ...[
                      ElevatedButton.icon(
                        icon: const Icon(YaruIcons.refresh),
                        onPressed: onRetry,
                        label: Text(onRetryLabel ?? context.l10n.tryReconnect),
                      ),
                      Tooltip(
                        message: AppConfig.repoReportIssueUrl,
                        child: OutlinedButton.icon(
                          icon: const Icon(YaruIcons.send),
                          onPressed: () {
                            final String body =
                                '''
**Describe the bug**

A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Additional context**
Add any other context about the problem here.

**Error Log**
```
------------ Platform: ------------
Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem} ${kIsWeb ? '' : Platform.operatingSystemVersion}

------------ Error: ------------
${error.toString().splitMapJoin(RegExp('.{1,100}'), onMatch: (m) => '${m.group(0)}\n', onNonMatch: (n) => n)}
${StackTrace.current.toString()}
```
                      ''';
                            launchUrl(
                              Uri(
                                scheme: AppConfig.scheme,
                                host: AppConfig.host,
                                path: AppConfig.repoReportIssueUrl,
                                queryParameters: {
                                  'title':
                                      'fix: ${error.toString().split(':').firstOrNull ?? 'error'}',
                                  'body': body,
                                },
                              ),
                            );
                          },
                          label: Text(context.l10n.reportIssue),
                        ),
                      ),
                      if (addQuitButton)
                        OutlinedButton.icon(
                          icon: const Icon(YaruIcons.window_close),
                          onPressed: () => exit(0),
                          label: Text(context.l10n.closeApp),
                        ),
                    ].map((e) => SizedBox(width: 250.0, child: e)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
