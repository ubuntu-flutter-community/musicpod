import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import 'global_keys.dart';
import 'icons.dart';
import 'theme.dart';

const kMacOsWindowControlMitigationPadding = EdgeInsets.only(top: 16, left: 13);

class NavBackButton extends StatelessWidget {
  const NavBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    void onTap() => di<LibraryModel>().pop();

    if (yaruStyled) {
      return YaruBackButton(
        style: YaruBackButtonStyle.rounded,
        onPressed: onTap,
      );
    } else {
      if (Platform.isMacOS) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, left: 13),
          child: Center(
            child: SizedBox(
              height: 15,
              width: 15,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Icon(
                  Iconz().goBack,
                  size: 10,
                ),
              ),
            ),
          ),
        );
      } else {
        return Center(
          child: BackButton(
            onPressed: onTap,
          ),
        );
      }
    }
  }
}

class SideBarProgress extends StatelessWidget {
  const SideBarProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: yaruStyled ? 18 : iconSize,
      child: const Progress(
        strokeWidth: 2,
      ),
    );
  }
}

class Progress extends StatelessWidget {
  const Progress({
    super.key,
    this.value,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeCap,
    this.strokeWidth = 3.0,
    this.padding,
  });

  final double? value;
  final Color? backgroundColor;
  final Color? color;
  final Animation<Color?>? valueColor;
  final double strokeWidth;
  final String? semanticsLabel;
  final String? semanticsValue;
  final StrokeCap? strokeCap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? YaruCircularProgressIndicator(
            strokeWidth: strokeWidth,
            value: value,
            color: color,
            trackColor: backgroundColor,
          )
        : Padding(
            padding: padding ?? const EdgeInsets.all(4),
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              value: value,
              color: color,
              backgroundColor: value == null
                  ? null
                  : (backgroundColor ??
                      context.t.colorScheme.primary.withOpacity(0.3)),
            ),
          );
  }
}

class HeaderBar extends StatelessWidget
    with WatchItMixin
    implements PreferredSizeWidget {
  const HeaderBar({
    super.key,
    this.title,
    this.actions,
    this.style = YaruTitleBarStyle.normal,
    this.titleSpacing = 0,
    this.backgroundColor,
    this.foregroundColor,
    required this.adaptive,
    this.includeBackButton = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final YaruTitleBarStyle style;
  final double? titleSpacing;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool adaptive;
  final bool includeBackButton;

  @override
  Widget build(BuildContext context) {
    final canPop = watchPropertyValue((LibraryModel m) => m.canPop);

    if (isMobile) {
      return AppBar(
        titleSpacing: titleSpacing,
        centerTitle: true,
        leading: includeBackButton && canPop
            ? const NavBackButton()
            : const SizedBox.shrink(),
        title: title,
        actions: actions,
        foregroundColor: foregroundColor,
      );
    }

    var theStyle = style;
    if (adaptive) {
      theStyle = watchPropertyValue((AppModel m) => m.showWindowControls)
          ? YaruTitleBarStyle.normal
          : YaruTitleBarStyle.undecorated;
    }

    return YaruWindowTitleBar(
      titleSpacing: titleSpacing,
      actions: actions,
      leading: !context.showMasterPanel &&
              masterScaffoldKey.currentState?.isDrawerOpen == false
          ? const SidebarButton()
          : (includeBackButton && canPop)
              ? const NavBackButton()
              : null,
      title: title,
      border: BorderSide.none,
      backgroundColor: backgroundColor ?? context.theme.scaffoldBackgroundColor,
      style: theStyle,
      foregroundColor: foregroundColor,
    );
  }

  @override
  Size get preferredSize => Size(
        0,
        isMobile
            ? (style == YaruTitleBarStyle.hidden ? 0 : kYaruTitleBarHeight)
            : kToolbarHeight,
      );
}

class SidebarButton extends StatelessWidget {
  const SidebarButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return Center(
        child: Padding(
          padding: kMacOsWindowControlMitigationPadding,
          child: SizedBox(
            height: 15,
            width: 15,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              child: Icon(
                Iconz().sidebar,
                size: 10,
              ),
              onTap: () => masterScaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () => masterScaffoldKey.currentState?.openDrawer(),
      icon: Icon(
        Iconz().sidebar,
      ),
    );
  }
}

class TabsBar extends StatelessWidget {
  const TabsBar({super.key, required this.tabs, this.onTap});

  final List<Widget> tabs;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    return yaruStyled || appleStyled
        ? YaruTabBar(
            onTap: onTap,
            tabs: tabs,
          )
        : TabBar(
            onTap: onTap,
            tabs: tabs,
          );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({super.key, this.onPressed, this.active});

  final void Function()? onPressed;
  final bool? active;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? YaruSearchButton(
            searchActive: active,
            onPressed: onPressed,
          )
        : IconButton(
            isSelected: active,
            onPressed: onPressed,
            selectedIcon: Icon(
              Iconz().search,
              color: context.t.colorScheme.primary,
            ),
            icon: Icon(Iconz().search),
          );
  }
}

class SearchingBar extends StatefulWidget {
  const SearchingBar({
    super.key,
    this.text,
    this.onClear,
    this.onSubmitted,
    this.onChanged,
    this.hintText,
    this.suffixIcon,
    this.autoFocus = true,
  });
  final String? text;
  final void Function()? onClear;
  final void Function(String?)? onSubmitted;
  final void Function(String)? onChanged;
  final String? hintText;
  final Widget? suffixIcon;
  final bool autoFocus;

  @override
  State<SearchingBar> createState() => _SearchingBarState();
}

class _SearchingBarState extends State<SearchingBar> {
  late TextEditingController _controller;
  Timer? _debounce;

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged?.call(query);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    return SizedBox(
      height: yaruStyled ? null : 38,
      child: TextField(
        onTap: () {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.value.text.length,
          );
        },
        controller: _controller,
        key: widget.key,
        autofocus: widget.autoFocus,
        onSubmitted: widget.onSubmitted,
        onChanged: _onSearchChanged,
        style: yaruStyled ? theme.textTheme.bodyMedium : null,
        decoration: yaruStyled
            ? createYaruDecoration(
                theme: theme,
                hintText: widget.hintText,
                suffixIcon: widget.suffixIcon,
              )
            : createMaterialDecoration(
                colorScheme: theme.colorScheme,
                hintText: widget.hintText,
                suffixIcon: widget.suffixIcon,
              ),
      ),
    );
  }
}

class DropDownArrow extends StatelessWidget {
  const DropDownArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? const Icon(YaruIcons.pan_down)
        : const Icon(Icons.arrow_drop_down);
  }
}

class LinearProgress extends StatelessWidget {
  const LinearProgress({
    super.key,
    this.color,
    this.trackHeight,
    this.value,
    this.backgroundColor,
  });

  final double? value;
  final Color? color, backgroundColor;
  final double? trackHeight;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? YaruLinearProgressIndicator(
            value: value,
            minHeight: trackHeight,
            strokeWidth: trackHeight,
            color: color,
          )
        : LinearProgressIndicator(
            value: value,
            minHeight: trackHeight,
            color: color,
            backgroundColor: backgroundColor,
            borderRadius: BorderRadius.circular(2),
          );
  }
}

double get podcastProgressSize => yaruStyled ? 34 : 45;

double get likeButtonWidth => yaruStyled ? 62 : 70;

double? get avatarIconSize => yaruStyled ? kYaruTitleBarItemHeight / 2 : null;

double get bigPlayButtonSize => 25;

double get searchBarWidth => isMobile ? kSearchBarWidth : 600;

bool get showSideBarFilter => yaruStyled ? true : false;

FontWeight get smallTextFontWeight =>
    yaruStyled ? FontWeight.w100 : FontWeight.w400;

FontWeight get mediumTextWeight =>
    yaruStyled ? FontWeight.w400 : FontWeight.w400;

FontWeight get largeTextWeight =>
    yaruStyled ? FontWeight.w200 : FontWeight.w300;

bool get shrinkTitleBarItems => yaruStyled;

double get chipHeight => yaruStyled ? kYaruTitleBarItemHeight : 38;

EdgeInsetsGeometry get tabViewPadding =>
    isMobile ? const EdgeInsets.only(top: 15) : const EdgeInsets.only(top: 5);

EdgeInsetsGeometry get gridPadding =>
    isMobile ? kMobileGridPadding : kGridPadding;

SliverGridDelegate get audioCardGridDelegate =>
    isMobile ? kMobileAudioCardGridDelegate : kAudioCardGridDelegate;

EdgeInsetsGeometry get appBarActionSpacing => Platform.isMacOS
    ? const EdgeInsets.only(right: 5, left: 20)
    : const EdgeInsets.only(right: 10, left: 20);

EdgeInsetsGeometry get radioHistoryListPadding =>
    EdgeInsets.only(left: yaruStyled ? 0 : 5);

class CommonSwitch extends StatelessWidget {
  const CommonSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? YaruSwitch(
            value: value,
            onChanged: onChanged,
          )
        : Switch(value: value, onChanged: onChanged);
  }
}

class CommonCheckBox extends StatelessWidget {
  const CommonCheckBox({super.key, required this.value, this.onChanged});

  final bool value;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? YaruCheckbox(
            value: value,
            onChanged: onChanged,
          )
        : Checkbox(value: value, onChanged: onChanged);
  }
}

class ImportantButton extends StatelessWidget {
  const ImportantButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? ElevatedButton(
            onPressed: onPressed,
            child: child,
          )
        : FilledButton(onPressed: onPressed, child: child);
  }
}

TextStyle getControlPanelStyle(TextTheme textTheme) =>
    textTheme.headlineSmall?.copyWith(fontWeight: largeTextWeight) ??
    const TextStyle(fontSize: 25);
