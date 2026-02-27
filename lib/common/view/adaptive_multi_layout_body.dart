import 'package:flutter/material.dart';

import 'sliver_audio_page_control_panel.dart';
import 'ui_constants.dart';

const _trashHold = 900.0;
const _singleWidth = 400.0;

class AdaptiveMultiLayoutBody extends StatelessWidget {
  const AdaptiveMultiLayoutBody({
    super.key,
    required this.header,
    required this.sliverBody,
    required this.controlPanel,
    this.secondControlPanel,
    this.secondSliverControlPanel,
    this.trashHold = _trashHold,
    this.singleWidth = _singleWidth,
  });

  final Widget header;
  final Widget controlPanel;
  final Widget? secondControlPanel;
  final Widget? secondSliverControlPanel;
  final Widget Function(BoxConstraints constraints) sliverBody;
  final double trashHold;
  final double singleWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < trashHold) {
        return Center(
          child: _SingleLayout(
            header: header,
            sliverBody: SliverPadding(
              padding: const EdgeInsets.only(
                left: kLargestSpace,
                right: kLargestSpace,
                bottom: kLargestSpace,
              ),
              sliver: sliverBody(constraints),
            ),
            controlPanel: controlPanel,
            secondControlPanel: secondControlPanel,
            secondSliverControlPanel: secondSliverControlPanel,
          ),
        );
      } else {
        return _PanedLayout(
          singleWidth: singleWidth,
          header: header,
          controlPanel: controlPanel,
          sliverBody: sliverBody(constraints),
          secondControlPanel: secondControlPanel,
          secondSliverControlPanel: secondSliverControlPanel,
        );
      }
    },
  );
}

class _SingleLayout extends StatelessWidget {
  const _SingleLayout({
    required this.header,
    this.sliverBody,
    required this.controlPanel,
    this.secondControlPanel,
    this.secondSliverControlPanel,
  });

  final Widget? header;
  final Widget? controlPanel;
  final Widget? sliverBody;
  final Widget? secondControlPanel;
  final Widget? secondSliverControlPanel;

  @override
  Widget build(BuildContext context) => sliverBody != null
      ? CustomScrollView(
          slivers: [
            if (header != null) SliverToBoxAdapter(child: header),
            if (controlPanel != null)
              SliverAudioPageControlPanel(controlPanel: controlPanel!),
            ?secondSliverControlPanel,
            ?sliverBody,
          ],
        )
      : Center(
          child: ListView(
            children: [?header, ?controlPanel, ?secondControlPanel],
          ),
        );
}

class _PanedLayout extends StatelessWidget {
  const _PanedLayout({
    this.header,
    required this.sliverBody,
    this.controlPanel,
    this.secondControlPanel,
    this.secondSliverControlPanel,
    required this.singleWidth,
  });

  final Widget? header;
  final Widget? controlPanel;
  final Widget sliverBody;
  final Widget? secondControlPanel;
  final Widget? secondSliverControlPanel;
  final double singleWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 3 * kLargestSpace,
            left: 3 * kLargestSpace,
          ),
          child: SizedBox(
            width: singleWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: kLargestSpace),
              child: _SingleLayout(
                header: header,
                controlPanel: controlPanel,
                secondControlPanel: secondControlPanel,
                secondSliverControlPanel: secondSliverControlPanel,
              ),
            ),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: kLargestSpace,
                  right: 4 * kLargestSpace,
                  bottom: kLargestSpace,
                  top: 3 * kLargestSpace,
                ),
                sliver: sliverBody,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
