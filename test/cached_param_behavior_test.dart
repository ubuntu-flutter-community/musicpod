import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watch_it/watch_it.dart';

class Model {
  Model(this.id) : notifier = ValueNotifier('initial-$id');
  final String id;
  final ValueNotifier<String> notifier;
}

Model? lastModel1;

class TwoInstancesWidget extends WatchingWidget {
  const TwoInstancesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final val1 = watchValue((Model m) => m.notifier, param1: 'item1');
    final val2 = watchValue((Model m) => m.notifier, param1: 'item2');

    return Column(children: [Text('val1: $val1'), Text('val2: $val2')]);
  }
}

void main() {
  test('does get_it cachedFactoryParam cache multiple instances by param?', () {
    final getIt = GetIt.asNewInstance();
    int creations = 0;
    getIt.registerCachedFactoryParam<Model, String, void>((id, _) {
      creations++;
      return Model(id);
    });

    final m1 = getIt<Model>(param1: 'a');
    expect(creations, 1);

    final m1Again = getIt<Model>(param1: 'a');
    expect(creations, 1);
    expect(identical(m1, m1Again), isTrue);

    getIt<Model>(param1: 'b');
    expect(creations, 2);

    // Requesting 'a' again creates a 3rd instance because get_it only caches the last param
    final m1Third = getIt<Model>(param1: 'a');
    expect(creations, 3);
    expect(identical(m1, m1Third), isFalse);
  });

  testWidgets('mutating state when watching multiple instances in same widget', (
    tester,
  ) async {
    di.registerCachedFactoryParam<Model, String, void>((id, _) {
      final m = Model(id);
      if (id == 'item1') lastModel1 = m;
      return m;
    });

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TwoInstancesWidget())),
    );
    expect(find.text('val1: initial-item1'), findsOneWidget);
    expect(find.text('val2: initial-item2'), findsOneWidget);

    // Now update lastModel1's notifier!
    final activeM1 = lastModel1!;
    activeM1.notifier.value = 'updated-item1';

    // Pump to let the widget rebuild from the notification
    await tester.pump();

    // In current get_it, the update is lost because the rebuild re-instantiates item1
    expect(find.text('val1: initial-item1'), findsOneWidget);
  });
}
