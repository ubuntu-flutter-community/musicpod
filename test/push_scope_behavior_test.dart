import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/logging.dart';
import 'package:watch_it/watch_it.dart';

class ItemModel extends ChangeNotifier {
  ItemModel(this.name);
  final String name;
}

class ItemWidget extends WatchingWidget {
  const ItemWidget({super.key, required this.itemName, required this.counter});
  final String itemName;
  final int counter;

  @override
  Widget build(BuildContext context) {
    pushScope(
      init: (getIt) {
        getIt.registerSingleton<ItemModel>(ItemModel(itemName));
      },
    );

    final model = watchIt<ItemModel>();
    return Text('Model name: ${model.name} (counter: $counter)');
  }
}

void main() {
  testWidgets('what happens when ItemWidget First rebuilds while Second exists?', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ItemWidget(itemName: 'First', counter: 0),
              ItemWidget(itemName: 'Second', counter: 0),
            ],
          ),
        ),
      ),
    );

    Logger.i('Initial build:');
    Logger.i(
      'First has First: ${find.text('Model name: First (counter: 0)').evaluate().length}',
    );
    Logger.i(
      'Second has Second: ${find.text('Model name: Second (counter: 0)').evaluate().length}',
    );

    // Now rebuild ItemWidget First with counter = 1
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ItemWidget(itemName: 'First', counter: 1),
              ItemWidget(itemName: 'Second', counter: 0),
            ],
          ),
        ),
      ),
    );

    Logger.i('After rebuilding First:');
    Logger.i(
      'First has First: ${find.text('Model name: First (counter: 1)').evaluate().length}',
    );
    Logger.i(
      'First has Second (SHADOWED!): ${find.text('Model name: Second (counter: 1)').evaluate().length}',
    );
  });
}
