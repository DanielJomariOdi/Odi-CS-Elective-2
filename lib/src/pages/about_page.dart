import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/adaptive_platform.dart';
import '../core/responsive_layout.dart';
import '../widgets/adaptive_controls.dart';
import '../widgets/wireframe_widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({required this.layout, required this.platform, super.key});

  final ResponsiveLayoutInfo layout;
  final AdaptivePlatform platform;

  @override
  Widget build(BuildContext context) {
    return DashboardPageFrame(
      layout: layout,
      title: 'About',
      subtitle: 'Profile, notes, and dashboard metadata',
      actions: [
        AdaptiveActionButton(
          label: 'Share',
          materialIcon: Icons.ios_share_rounded,
          cupertinoIcon: CupertinoIcons.share,
          filled: false,
          onPressed: () {},
        ),
      ],
      child: layout.isDesktop
          ? _DesktopAbout(layout: layout, platform: platform)
          : _CompactAbout(layout: layout, platform: platform),
    );
  }
}

class _CompactAbout extends StatelessWidget {
  const _CompactAbout({required this.layout, required this.platform});

  final ResponsiveLayoutInfo layout;
  final AdaptivePlatform platform;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileCard(layout: layout, platform: platform),
        SizedBox(height: layout.gap),
        _InfoGrid(layout: layout),
        SizedBox(height: layout.gap),
        WireListSection(
          title: 'Notes',
          itemCount: layout.isMobile ? 3 : 4,
          layout: layout,
        ),
      ],
    );
  }
}

class _DesktopAbout extends StatelessWidget {
  const _DesktopAbout({required this.layout, required this.platform});

  final ResponsiveLayoutInfo layout;
  final AdaptivePlatform platform;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 330,
          child: _ProfileCard(layout: layout, platform: platform),
        ),
        SizedBox(width: layout.gap),
        Expanded(
          child: Column(
            children: [
              _InfoGrid(layout: layout),
              SizedBox(height: layout.gap),
              WireListSection(title: 'Notes', itemCount: 5, layout: layout),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.layout, required this.platform});

  final ResponsiveLayoutInfo layout;
  final AdaptivePlatform platform;

  @override
  Widget build(BuildContext context) {
    return WireframePanel(
      minHeight: layout.isMobile ? 250 : 300,
      fill: DashboardPalette.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: DashboardPalette.wire,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  platform.usesCupertinoControls
                      ? CupertinoIcons.person_fill
                      : Icons.person_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Responsive Dashboard',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: DashboardPalette.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PlatformBadge(label: platform.label, isWeb: platform.isWeb),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SkeletonColumn(lines: 6),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.layout});

  final ResponsiveLayoutInfo layout;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWireGrid(
      columns: layout.isMobile ? 1 : 3,
      spacing: layout.gap,
      childAspectRatio: layout.isMobile ? 3.2 : 1.45,
      children: const [
        WireMetricCard(
          icon: Icons.phone_iphone_rounded,
          label: 'Mobile',
          value: '< 700',
          accent: DashboardPalette.accent,
        ),
        WireMetricCard(
          icon: Icons.tablet_mac_rounded,
          label: 'Tablet',
          value: '700+',
          accent: DashboardPalette.mint,
        ),
        WireMetricCard(
          icon: Icons.desktop_windows_rounded,
          label: 'Desktop',
          value: '1100+',
          accent: Color(0xFFD28B2C),
        ),
      ],
    );
  }
}
