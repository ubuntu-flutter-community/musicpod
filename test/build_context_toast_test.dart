import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/extensions/build_context_x.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('context.toast adds copy to clipboard action when none provided', (
    tester,
  ) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copiedText = (methodCall.arguments as Map)['text'] as String?;
          return null;
        }
        if (methodCall.method == 'Clipboard.getData') {
          return {'text': copiedText};
        }
        return null;
      },
    );

    late BuildContext targetContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              targetContext = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    targetContext.toast(const Text('Test error message'));
    await tester.pumpAndSettle();

    expect(find.text('Test error message'), findsOneWidget);
    expect(find.byType(SnackBarAction), findsOneWidget);

    await tester.tap(find.byType(SnackBarAction));
    await tester.pumpAndSettle();

    expect(copiedText, 'Test error message');
  });

  testWidgets('context.toast uses custom action if provided', (
    tester,
  ) async {
    bool customClicked = false;
    late BuildContext targetContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              targetContext = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    targetContext.toast(
      const Text('Custom action test'),
      action: SnackBarAction(
        label: 'Custom',
        onPressed: () => customClicked = true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom'), findsOneWidget);
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    expect(customClicked, isTrue);
  });
}
