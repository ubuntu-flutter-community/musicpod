import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../globals.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import 'radio_discover_page.dart';
import 'radio_lib_page.dart';
import 'radio_model.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({
    super.key,
    required this.isOnline,
    this.countryCode,
  });

  final bool isOnline;
  final String? countryCode;

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final model = context.read<RadioModel>();
      final libraryModel = context.read<LibraryModel>();
      final service = getService<AppStateService>();
      final index = service.radioIndex;
      model
          .init(
        countryCode: widget.countryCode,
        index: index.value,
      )
          .then(
        (connectedHost) {
          if (!widget.isOnline) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: connectedHost?.isNotEmpty == true
                  ? const Duration(seconds: 4)
                  : const Duration(seconds: 30),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    connectedHost?.isNotEmpty == true
                        ? '${context.l10n.connectedTo}: $connectedHost'
                        : context.l10n.noRadioServerFound,
                  ),
                  if (connectedHost == null)
                    ImportantButton(
                      onPressed: () => model.init(
                        countryCode: widget.countryCode,
                        index: index.value,
                      ),
                      child: Text(
                        context.l10n.tryReconnect,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ).then((_) {
        if (libraryModel.starredStations.isEmpty) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => widget.isOnline
                  ? const RadioDiscoverPage()
                  : const OfflinePage(),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = getService<AppStateService>();
    final showWindowControls = service.showWindowControls;

    context.select((LibraryModel m) => m.favTagsLength);

    if (!widget.isOnline) {
      return const OfflinePage();
    } else {
      return Scaffold(
        appBar: HeaderBar(
          style: showWindowControls.watch(context)
              ? YaruTitleBarStyle.normal
              : YaruTitleBarStyle.undecorated,
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
        body: RadioLibPage(
          isOnline: widget.isOnline,
        ),
      );
    }
  }
}
