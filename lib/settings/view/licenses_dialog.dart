import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';

class LicensesDialog extends StatefulWidget with WatchItStatefulWidgetMixin {
  const LicensesDialog({super.key});

  @override
  State<LicensesDialog> createState() => _LicensesDialogState();
}

class _LicensesDialogState extends State<LicensesDialog> {
  @override
  void initState() {
    super.initState();
    di<LicenseStore>().load(LicenseRegistry.licenses);
  }

  @override
  Widget build(BuildContext context) {
    final packages = watchPropertyValue((LicenseStore s) => s.packages);
    final model = di<LicenseStore>();
    return Dialog(
      child: SizedBox(
        height: 800,
        width: 800,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kYaruContainerRadius),
          child: YaruMasterDetailPage(
            appBar: YaruDialogTitleBar(
              shape: const RoundedRectangleBorder(),
              backgroundColor: YaruMasterDetailTheme.of(context).sideBarColor,
              border: BorderSide.none,
              isClosable: false,
              title: Text(context.l10n.dependencies),
            ),
            length: packages.length,
            tileBuilder: (context, index, selected, availableWidth) =>
                YaruMasterTile(
                  selected: selected,
                  title: Text(packages[index]),
                ),
            pageBuilder: (context, index) =>
                LicenseView(licenses: model.licenses(model.packages[index])),
          ),
        ),
      ),
    );
  }
}

class LicenseStore extends SafeChangeNotifier {
  final _licenses = <String, List<LicenseEntry>>{};

  List<String> get packages => _licenses.keys.toList();
  List<LicenseEntry> licenses(String package) => _licenses[package]!;

  Future<void> load(Stream<LicenseEntry> licenses) async {
    _licenses.clear();
    await for (final license in licenses) {
      final package = license.packages.first;
      _licenses.putIfAbsent(package, () => []).add(license);
    }
    notifyListeners();
  }
}

class LicenseView extends StatefulWidget {
  const LicenseView({super.key, required this.licenses});

  final List<LicenseEntry> licenses;

  @override
  State<LicenseView> createState() => _LicenseViewState();
}

class _LicenseViewState extends State<LicenseView> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YaruDetailPage(
      appBar: YaruDialogTitleBar(
        shape: const RoundedRectangleBorder(),
        border: BorderSide.none,
        onClose: (p0) => Navigator.of(context, rootNavigator: true).pop(),
        backgroundColor: Colors.transparent,
        leading: Visibility(
          visible: Navigator.of(context).canPop(),
          child: YaruBackButton(
            style: YaruBackButtonStyle.rounded,
            icon: Icon(Iconz.goBack),
          ),
        ),
        title: Text(widget.licenses.first.packages.first),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.licenses.length,
        itemBuilder: (context, index) =>
            LicenseText(license: widget.licenses[index]),
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: Visibility(
        visible: widget.licenses.length > 1,
        child: NaviBar(controller: _controller, length: widget.licenses.length),
      ),
    );
  }
}

class LicenseText extends StatelessWidget {
  const LicenseText({super.key, required this.license});

  final LicenseEntry license;

  @override
  Widget build(BuildContext context) {
    final paragraphs = license.paragraphs.toList();
    const padding = EdgeInsetsDirectional.all(kLargestSpace);
    return ListView.builder(
      padding: padding,
      itemCount: paragraphs.length,
      itemBuilder: (context, index) {
        final paragraph = paragraphs[index];
        final indent = paragraph.indent * 16.0;
        return Padding(
          padding: padding + EdgeInsetsDirectional.only(start: indent),
          child: Text(
            paragraph.text,
            textAlign: paragraph.indent == LicenseParagraph.centeredIndent
                ? TextAlign.center
                : TextAlign.left,
          ),
        );
      },
    );
  }
}

class NaviBar extends StatelessWidget {
  const NaviBar({super.key, required this.length, required this.controller});

  final int length;
  final PageController controller;

  int get _currentPage => controller.page?.round() ?? 0;
  bool get _hasPreviousPage => _currentPage > 0;
  bool get _hasNextPage => _currentPage < length - 1;

  void _animateToPage(int page) {
    controller.animateToPage(
      page,
      duration: kSlideDuration,
      curve: kSlideCurve,
    );
  }

  void _previousPage() {
    controller.previousPage(duration: kSlideDuration, curve: kSlideCurve);
  }

  void _nextPage() {
    controller.nextPage(duration: kSlideDuration, curve: kSlideCurve);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(kNaviBarPadding),
            child: NaviButton(
              onPressed: _hasPreviousPage ? _previousPage : null,
              icon: Icon(Iconz.goBack),
            ),
          ),
          Expanded(
            child: YaruPageIndicator(
              length: length,
              page: _currentPage,
              onTap: _animateToPage,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(kNaviBarPadding),
            child: NaviButton(
              onPressed: _hasNextPage ? _nextPage : null,
              icon: Icon(Iconz.goNext),
            ),
          ),
        ],
      ),
    );
  }
}

class NaviButton extends StatefulWidget {
  const NaviButton({
    super.key,
    this.enabled = true,
    required this.onPressed,
    required this.icon,
  });

  final bool enabled;
  final VoidCallback? onPressed;
  final Widget icon;

  @override
  State<NaviButton> createState() => _NaviButtonState();
}

class _NaviButtonState extends State<NaviButton> {
  Timer? _repeatTimer;

  void _startRepeat() {
    _repeatTimer ??= Timer.periodic(
      kSlideDuration,
      (_) => widget.onPressed?.call(),
    );
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void didUpdateWidget(NaviButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) {
      _stopRepeat();
    }
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => widget.enabled ? _startRepeat() : null,
      onLongPressEnd: (_) => _stopRepeat(),
      onLongPressCancel: _stopRepeat,
      child: IconButton(
        onPressed: widget.enabled ? widget.onPressed : null,
        icon: widget.icon,
      ),
    );
  }
}

const kLicensePadding = 8.0;
const kLicenseIndent = 16.0;
const kNaviBarPadding = 10.0;
const kSlideCurve = Curves.easeInOut;
const kSlideDuration = Duration(milliseconds: 200);
