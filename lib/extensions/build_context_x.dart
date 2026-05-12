import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../common/view/ui_constants.dart';
import 'navigator_state_x.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  double get buttonRadius => kYaruButtonRadius;
  double get buttonHeight => kYaruButtonHeight + 2;

  Size get mediaQuerySize => MediaQuery.sizeOf(this);
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  bool get isAndroidGestureNavigationEnabled {
    final value = MediaQuery.of(this).systemGestureInsets.bottom;
    return value < 48.0 && value != 0.0;
  }

  bool get smallWindow => mediaQuerySize.width < kMasterDetailBreakPoint;
  bool get wideWindow => mediaQuerySize.width < kAdaptivContainerBreakPoint;
  bool get showMasterPanel => mediaQuerySize.width > kMasterDetailBreakPoint;

  NavigatorState get navigator => Navigator.of(this);
  Future<T?> teleport<T extends Object?>(
    Widget Function(BuildContext) builder,
  ) => navigator.teleport(builder);
  bool canPop() => navigator.canPop();
  void pop<T extends Object?>([T? result]) => navigator.pop(result);
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> toast(
    Widget content, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
    bool clear = true,
    bool showCloseIcon = false,
    double? actionOverflowThreshold,
  }) {
    final messenger = ScaffoldMessenger.of(this);
    if (clear) {
      messenger.clearSnackBars();
    }
    return messenger.showSnackBar(
      SnackBar(
        content: content,
        duration: duration,
        action: action,
        showCloseIcon: showCloseIcon,
        actionOverflowThreshold: actionOverflowThreshold ?? 0.65,
      ),
    );
  }

  void clearToasts() => ScaffoldMessenger.of(this).clearSnackBars();

  Future<T?> dialog<T>(
    WidgetBuilder builder, {
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    bool fullscreenDialog = false,
    bool? requestFocus,
    AnimationStyle? animationStyle,
  }) => showDialog<T>(
    context: this,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    traversalEdgeBehavior: traversalEdgeBehavior,
    fullscreenDialog: fullscreenDialog,
    requestFocus: requestFocus,
    animationStyle: animationStyle,
  );

  Future<T?> bottomSheet<T>(
    WidgetBuilder builder, {

    Color? backgroundColor,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    double? scrollControlDisabledMaxHeightRatio,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    AnimationStyle? sheetAnimationStyle,
    bool? requestFocus,
  }) => showModalBottomSheet<T>(
    context: this,
    builder: builder,
    backgroundColor: backgroundColor,
    barrierLabel: barrierLabel,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
    sheetAnimationStyle: sheetAnimationStyle,
    requestFocus: requestFocus,
  );
}
