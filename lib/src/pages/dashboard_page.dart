import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/adaptive_platform.dart';
import '../core/responsive_layout.dart';
import '../widgets/adaptive_controls.dart';
import '../widgets/wireframe_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.layout,
    required this.platform,
    super.key,
  });

  final ResponsiveLayoutInfo layout;
  final AdaptivePlatform platform;

  @override
  Widget build(BuildContext context) {
    return DashboardPageFrame(
      layout: layout,
      title: 'Dashboard',
      subtitle: 'Overview, activity, and quick actions',
      actions: [
        AdaptiveActionButton(
          label: 'Refresh',
          materialIcon: Icons.refresh_rounded,
          cupertinoIcon: CupertinoIcons.refresh,
          onPressed: () {},
        ),
      ],
      child: layout.isDesktop
          ? _DesktopDashboard(layout: layout)
          : _CompactDashboard(layout: layout),
    );
  }
}

class _CompactDashboard extends StatelessWidget {
  const _CompactDashboard({required this.layout});

  final ResponsiveLayoutInfo layout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryGrid(layout: layout),
        SizedBox(height: layout.gap),
        WireListSection(
          title: 'Recent Activity',
          itemCount: layout.isMobile ? 4 : 5,
          layout: layout,
        ),
        SizedBox(height: layout.gap),
        _WideStatusPanel(layout: layout),
      ],
    );
  }
}

class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({required this.layout});

  final ResponsiveLayoutInfo layout;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _SummaryGrid(layout: layout),
              SizedBox(height: layout.gap),
              WireListSection(
                title: 'Recent Activity',
                itemCount: 6,
                layout: layout,
              ),
            ],
          ),
        ),
        SizedBox(width: layout.gap),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              WireframePanel(
                height: 348,
                fill: DashboardPalette.wire,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Preview',
                      style: TextStyle(
                        color: DashboardPalette.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    Spacer(),
                    Center(
                      child: Icon(
                        Icons.insights_rounded,
                        color: Colors.white,
                        size: 68,
                      ),
                    ),
                    Spacer(),
                    SkeletonColumn(lines: 3),
                  ],
                ),
              ),
              SizedBox(height: layout.gap),
              _WideStatusPanel(layout: layout),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.layout});

  final ResponsiveLayoutInfo layout;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWireGrid(
      columns: layout.summaryColumns,
      spacing: layout.gap,
      childAspectRatio: layout.summaryAspectRatio,
      children: const [
        WireMetricCard(
          icon: Icons.folder_rounded,
          label: 'Files',
          value: '128',
          accent: DashboardPalette.accent,
        ),
        WireMetricCard(
          icon: Icons.schedule_rounded,
          label: 'Pending',
          value: '24',
          accent: DashboardPalette.mint,
        ),
        WireMetricCard(
          icon: Icons.check_circle_rounded,
          label: 'Approved',
          value: '76',
          accent: Color(0xFF2D9C68),
        ),
        WireMetricCard(
          icon: Icons.flag_rounded,
          label: 'Flagged',
          value: '8',
          accent: Color(0xFFD28B2C),
        ),
      ],
    );
  }
}

class _WideStatusPanel extends StatelessWidget {
  const _WideStatusPanel({required this.layout});

  final ResponsiveLayoutInfo layout;

  @override
  Widget build(BuildContext context) {
    return WireframePanel(
      minHeight: layout.isMobile ? 126 : 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: layout.isMobile ? 52 : 68,
            height: layout.isMobile ? 52 : 68,
            decoration: BoxDecoration(
              color: DashboardPalette.accent.withAlpha(34),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.stacked_bar_chart_rounded,
              color: DashboardPalette.accent,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(child: SkeletonColumn(lines: 4, compact: true)),
        ],
      ),
    );
  }
}
