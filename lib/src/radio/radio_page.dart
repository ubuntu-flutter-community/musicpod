import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../common.dart';
import '../../globals.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import 'radio_discover_page.dart';
import 'radio_lib_page.dart';
import 'radio_model.dart';

class RadioPage extends ConsumerStatefulWidget {
  const RadioPage({super.key});

  @override
  ConsumerState<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends ConsumerState<RadioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final model = ref.read(radioModelProvider);
      final appModel = ref.read(appModelProvider);
      final libraryModel = ref.read(libraryModelProvider);
      final index = libraryModel.radioindex;
      model
          .init(
        countryCode: appModel.countryCode,
        index: index,
      )
          .then(
        (connectedHost) {
          if (!appModel.isOnline) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            _buildConnectSnackBar(connectedHost, model, index),
          );
        },
      );
    });
  }

  SnackBar _buildConnectSnackBar(
    String? connectedHost,
    RadioModel model,
    int index,
  ) {
    final appModel = ref.read(appModelProvider);

    return SnackBar(
      duration: connectedHost != null
          ? const Duration(seconds: 1)
          : const Duration(seconds: 30),
      content: Text(
        connectedHost != null
            ? '${context.l10n.connectedTo}: $connectedHost'
            : context.l10n.noRadioServerFound,
      ),
      action: (connectedHost == null)
          ? SnackBarAction(
              onPressed: () => model.init(
                countryCode: appModel.countryCode,
                index: index,
              ),
              label: context.l10n.tryReconnect,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(appModelProvider.select((m) => m.isOnline));
    if (!isOnline) return const OfflinePage();

    ref.watch(libraryModelProvider.select((m) => m.favTagsLength));
    final appModel = ref.read(appModelProvider);

    return YaruDetailPage(
      appBar: HeaderBar(
        adaptive: true,
        titleSpacing: 0,
        leading: navigatorKey.currentState?.canPop() == true
            ? const NavBackButton()
            : const SizedBox.shrink(),
        actions: [
          Flexible(
            child: Padding(
              padding: appBarActionSpacing,
              child: SearchButton(
                active: false,
                onPressed: () {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (context) => const RadioDiscoverPage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        title: Text('${context.l10n.radio} ${context.l10n.collection}'),
      ),
      body: AdaptiveContainer(
        child: RadioLibPage(
          isOnline: appModel.isOnline,
        ),
      ),
    );
  }
}
