import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../constants.dart';
import 'icons.dart';

class NavBackButton extends StatelessWidget {
  const NavBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isLinux
        ? const YaruBackButton(
            style: YaruBackButtonStyle.rounded,
          )
        : const Center(child: BackButton());
  }
}

class SideBarProgress extends StatelessWidget {
  const SideBarProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return _yaruStyled
        ? const SizedBox(
            height: 18,
            width: 18,
            child: Progress(),
          )
        : SizedBox(
            height: iconSize(),
            width: iconSize(),
            child: const Progress(),
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
    return _yaruStyled
        ? YaruCircularProgressIndicator(
            strokeWidth: strokeWidth,
            value: value,
          )
        : Padding(
            padding: padding ?? const EdgeInsets.all(4),
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              value: value,
            ),
          );
  }
}

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.style = YaruTitleBarStyle.normal,
    this.titleSpacing,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final YaruTitleBarStyle style;
  final double? titleSpacing;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return !isMobile
        ? YaruWindowTitleBar(
            titleSpacing: titleSpacing,
            actions: actions,
            leading: leading,
            title: title,
            border: BorderSide.none,
            backgroundColor: backgroundColor,
            style: style,
          )
        : AppBar(
            centerTitle: true,
            leading: leading,
            title: title,
            actions: actions,
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

class TabsBar extends StatelessWidget {
  const TabsBar({super.key, required this.tabs, this.onTap});

  final List<Widget> tabs;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    return _yaruStyled
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
    return _yaruStyled
        ? YaruSearchButton(
            searchActive: active,
            onPressed: onPressed,
          )
        : IconButton(
            isSelected: active,
            onPressed: onPressed,
            selectedIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
            ),
            icon: const Icon(Icons.search),
          );
  }
}

class SearchingBar extends StatelessWidget {
  const SearchingBar({super.key, this.text, this.onClear, this.onSubmitted});

  final String? text;
  final void Function()? onClear;
  final void Function(String?)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return _yaruStyled
        ? YaruSearchField(
            clearIcon: Iconz().clearIcon,
            key: key,
            text: text,
            onClear: onClear,
            onSubmitted: onSubmitted,
          )
        : MaterialSearchBar(
            text: text,
            key: key,
            onSubmitted: onSubmitted,
            onClear: onClear,
          );
  }
}

class MaterialSearchBar extends StatefulWidget {
  const MaterialSearchBar({
    super.key,
    this.text,
    this.onClear,
    this.onSubmitted,
  });
  final String? text;
  final void Function()? onClear;
  final void Function(String?)? onSubmitted;

  @override
  State<MaterialSearchBar> createState() => _NormalSearchBarState();
}

class _NormalSearchBarState extends State<MaterialSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      controller: _controller,
      key: widget.key,
      autofocus: true,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: widget.onClear,
          icon: const Icon(Icons.clear),
        ),
      ),
    );
  }
}

class DropDownArrow extends StatelessWidget {
  const DropDownArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return _yaruStyled
        ? const Icon(YaruIcons.pan_down)
        : const Icon(Icons.arrow_drop_down);
  }
}

double? get avatarIconSize => _yaruStyled ? kYaruTitleBarItemHeight / 2 : null;

double? get snackBarWidth => _yaruStyled ? kSnackBarWidth : null;

double get searchBarWidth => isMobile ? kSearchBarWidth : 600;

bool get showSideBarFilter => _yaruStyled ? true : false;

FontWeight get smallTextFontWeight =>
    _yaruStyled ? FontWeight.w100 : FontWeight.w400;

FontWeight get mediumTextWeight =>
    _yaruStyled ? FontWeight.w200 : FontWeight.w500;

bool get _yaruStyled => Platform.isLinux;

bool get isMobile => Platform.isAndroid || Platform.isIOS || Platform.isFuchsia;

bool get shrinkTitleBarItems => _yaruStyled;

double get chipHeight => _yaruStyled ? kYaruTitleBarItemHeight : 40;

EdgeInsetsGeometry get gridPadding =>
    isMobile ? kMobileGridPadding : kGridPadding;

SliverGridDelegate get imageGridDelegate =>
    isMobile ? kMobileImageGridDelegate : kImageGridDelegate;

Gradient? getAudioPageHeaderGradient(ThemeData theme) {
  if (_yaruStyled) {
    return theme.brightness == Brightness.light
        ? null
        : LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.transparent,
              theme.scaffoldBackgroundColor,
            ],
          );
  }

  return LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Colors.transparent,
      theme.colorScheme.primary.withOpacity(0.15),
      Colors.transparent,
    ],
  );
}
