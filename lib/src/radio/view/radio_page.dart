import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../app.dart';
import '../../../common.dart';
import '../../../get.dart';
import '../../../globals.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../radio_model.dart';
import 'radio_discover_page.dart';
import 'radio_lib_page.dart';

class RadioPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final model = getIt<RadioModel>();
      final appModel = getIt<AppModel>();
      final playerModel = getIt<PlayerModel>();
      final libraryModel = getIt<LibraryModel>();
      final index = libraryModel.radioindex;
      model
          .init(
        countryCode: appModel.countryCode,
        index: index,
      )
          .then(
        (connectedHost) {
          if (!playerModel.isOnline) {
            return;
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              _buildConnectSnackBar(
                connectedHost: connectedHost,
                context: context,
              ),
            );
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    if (!isOnline) return const OfflinePage();
    final connectedHost = watchPropertyValue((RadioModel m) => m.connectedHost);

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
              child: connectedHost == null
                  ? const _RadioReconnectButton()
                  : SearchButton(
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
      body: const AdaptiveContainer(child: RadioLibPage()),
    );
  }
}

class _RadioReconnectButton extends StatelessWidget {
  const _RadioReconnectButton();

  @override
  Widget build(BuildContext context) {
    final model = getIt<RadioModel>();
    final libraryModel = getIt<LibraryModel>();
    final appModel = getIt<AppModel>();

    return IconButton(
      tooltip:
          '${context.l10n.noRadioServerFound}: ${context.l10n.tryReconnect}',
      onPressed: () => model
          .init(
        countryCode: appModel.countryCode,
        index: libraryModel.radioindex,
      )
          .then(
        (host) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            _buildConnectSnackBar(
              connectedHost: host,
              context: context,
            ),
          );
        },
      ),
      icon: const DisconnectedServerIcon(),
    );
  }
}

SnackBar _buildConnectSnackBar({
  required String? connectedHost,
  required BuildContext context,
}) {
  final appModel = getIt<AppModel>();
  final model = getIt<RadioModel>();
  final libraryModel = getIt<LibraryModel>();
  final index = libraryModel.radioindex;

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
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              model
                  .init(
                    countryCode: appModel.countryCode,
                    index: index,
                  )
                  .then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                      _buildConnectSnackBar(
                        connectedHost: value,
                        context: context,
                      ),
                    ),
                  );
            },
            label: context.l10n.tryReconnect,
          )
        : null,
  );
}
