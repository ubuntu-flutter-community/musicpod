import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

/// A width responsive widget combining a [TabBar] and a [TabBarView].
///
/// [tabIcons], [views] and [tabTitles] must have the same amount of children. The [width] and [height] must be provided.
/// If there is not enough space only the [tabIcons] are shown.
class TabbedPage extends StatefulWidget {
  const TabbedPage({
    super.key,
    this.tabIcons,
    required this.tabTitles,
    required this.views,
    this.width,
    this.padding = const EdgeInsets.only(
      bottom: 10,
      top: kYaruPagePadding / 2,
      right: kYaruPagePadding,
      left: kYaruPagePadding,
    ),
    this.initialIndex = 0,
    this.onTap,
  });

  /// A list of [Widget]s used inside the tabs - must have the same length as [tabTitles] and [views].
  final List<Widget>? tabIcons;

  /// The list of titles as [String]s - must have the same length as [tabIcons] and [views].
  final List<String> tabTitles;

  /// The list of [Widget]-views  - must have the same length as [tabTitles] and [tabIcons].
  final List<Widget> views;

  /// The width used for the [TabBarView]
  final double? width;

  /// The padding [EdgeInsets] which defaults to [kDefaultPadding] at top, right and left.
  final EdgeInsetsGeometry padding;

  /// The initialIndex of the [TabController]
  final int initialIndex;

  /// The [Function] used when one of the [Tab] is tapped.
  final Function(int index)? onTap;

  @override
  State<TabbedPage> createState() => _TabbedPageState();
}

class _TabbedPageState extends State<TabbedPage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      initialIndex: widget.initialIndex,
      length: widget.views.length,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: widget.padding,
          child: Container(
            width: widget.width,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kYaruContainerRadius),
            ),
            child: TabBar(
              labelStyle: theme.textTheme.headlineMedium,
              // indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              controller: tabController,
              splashBorderRadius: BorderRadius.circular(kYaruContainerRadius),
              onTap: widget.onTap,
              tabs: [
                for (var i = 0; i < widget.views.length; i++)
                  Tab(
                    text: widget.tabTitles[i],
                    icon: widget.tabIcons?[i],
                  )
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: widget.views,
          ),
        ),
      ],
    );
  }
}
