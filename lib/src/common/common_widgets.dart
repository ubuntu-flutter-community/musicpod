import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../constants.dart';
import '../../theme.dart';
import '../../theme_data_x.dart';
import 'icons.dart';

class NavBackButton extends StatelessWidget {
  const NavBackButton({super.key, this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    void onTap() {
      if (onPressed == null) {
        Navigator.maybePop(context);
      } else {
        onPressed?.call();
        Future.delayed(const Duration(milliseconds: 400))
            .then((value) => Navigator.maybePop(context));
      }
    }

    if (yaruStyled) {
      return const YaruBackButton(
        style: YaruBackButtonStyle.rounded,
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
    return yaruStyled
        ? const SizedBox(
            height: 18,
            width: 18,
            child: Progress(),
          )
        : SizedBox(
            height: iconSize,
            width: iconSize,
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
            foregroundColor: foregroundColor,
          )
        : AppBar(
            centerTitle: true,
            leading: leading,
            title: title,
            actions: actions,
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

class SearchingBar extends StatelessWidget {
  const SearchingBar({super.key, this.text, this.onClear, this.onSubmitted});

  final String? text;
  final void Function()? onClear;
  final void Function(String?)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? YaruSearchField(
            radius: const Radius.circular(kYaruButtonRadius),
            clearIcon: yaruStyled ? null : Icon(Iconz().clear),
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
    return SizedBox(
      height: 38,
      child: TextField(
        controller: _controller,
        key: widget.key,
        autofocus: true,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.only(top: 10, bottom: 8, left: 10, right: 10),
          filled: true,
          suffixIcon: IconButton(
            onPressed: () {
              widget.onClear?.call();
              _controller.clear();
            },
            icon: const Icon(Icons.clear),
          ),
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

double get podcastProgressSize => yaruStyled ? 34 : 45;

double get likeButtonWidth => yaruStyled ? 62 : 70;

double? get avatarIconSize => yaruStyled ? kYaruTitleBarItemHeight / 2 : null;

double? get snackBarWidth => yaruStyled ? kSnackBarWidth : null;

double get searchBarWidth => isMobile ? kSearchBarWidth : 600;

bool get showSideBarFilter => yaruStyled ? true : false;

FontWeight get smallTextFontWeight =>
    yaruStyled ? FontWeight.w100 : FontWeight.w400;

FontWeight get mediumTextWeight =>
    yaruStyled ? FontWeight.w400 : FontWeight.w400;

FontWeight get largeTextWeight =>
    yaruStyled ? FontWeight.w200 : FontWeight.w300;

bool get shrinkTitleBarItems => yaruStyled;

double get chipHeight => yaruStyled ? kYaruTitleBarItemHeight : 35;

EdgeInsetsGeometry get tabViewPadding =>
    isMobile ? const EdgeInsets.only(top: 15) : const EdgeInsets.only(top: 5);

EdgeInsetsGeometry get gridPadding =>
    isMobile ? kMobileGridPadding : kGridPadding;

SliverGridDelegate get imageGridDelegate =>
    isMobile ? kMobileImageGridDelegate : kImageGridDelegate;

EdgeInsetsGeometry get appBarActionSpacing => Platform.isMacOS
    ? const EdgeInsets.only(right: 5, left: 40)
    : const EdgeInsets.only(right: 20, left: 40);

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
        : appleStyled
            ? CupertinoSwitch(value: value, onChanged: onChanged)
            : Switch(value: value, onChanged: onChanged);
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

Future<Object?> showStyledPopover({
  required BuildContext context,
  required Widget content,
  PopoverDirection direction = PopoverDirection.bottom,
  double? height,
  double? width,
}) {
  final theme = context.t;
  final light = theme.isLight;
  return showPopover(
    context: context,
    // onPop: () => print('Popover was popped!'),
    direction: direction,
    shadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        offset: const Offset(0, 0),
        spreadRadius: 2,
        blurRadius: 4,
      ),
    ],
    backgroundColor:
        light ? Colors.white : theme.colorScheme.surface.scale(lightness: 0.05),
    barrierColor: Colors.transparent,
    width: width ?? 250,
    height: height,
    arrowHeight: 15,
    arrowWidth: 30,
    bodyBuilder: (context) {
      return content;
    },
    transitionDuration: Duration.zero,
  );
}

TextStyle getControlPanelStyle(TextTheme textTheme) =>
    textTheme.headlineSmall?.copyWith(fontWeight: largeTextWeight) ??
    const TextStyle(fontSize: 25);
