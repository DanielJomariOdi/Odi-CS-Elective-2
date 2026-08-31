import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/adaptive_platform.dart';
import '../core/responsive_layout.dart';
import '../models/dashboard_destination.dart';
import 'wireframe_widgets.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    required this.layout,
    required this.platform,
    required this.currentTitle,
    this.onMenuPressed,
    super.key,
  });

  final ResponsiveLayoutInfo layout;
  final AdaptivePlatform platform;
  final String currentTitle;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final barHeight = layout.isDesktop ? 64.0 : 58.0;

    return Container(
      color: DashboardPalette.darkBar,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: barHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: layout.isDesktop ? 22 : 12,
            ),
            child: Row(
              children: [
                if (onMenuPressed != null)
                  _TopBarButton(
                    platform: platform,
                    icon: platform.usesCupertinoControls
                        ? CupertinoIcons.line_horizontal_3
                        : Icons.menu_rounded,
                    tooltip: 'Menu',
                    onPressed: onMenuPressed,
                  )
                else
                  const _WindowDots(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    layout.isMobile ? currentTitle : 'responsive dashboard',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                PlatformBadge(label: platform.label, isWeb: platform.isWeb),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdaptiveBottomNavigationBar extends StatelessWidget {
  const AdaptiveBottomNavigationBar({
    required this.platform,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final AdaptivePlatform platform;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (platform.usesCupertinoControls) {
      return CupertinoTabBar(
        currentIndex: selectedIndex,
        activeColor: DashboardPalette.accent,
        inactiveColor: DashboardPalette.muted,
        backgroundColor: DashboardPalette.surface,
        border: const Border(top: BorderSide(color: DashboardPalette.line)),
        onTap: onSelected,
        items: [
          for (final destination in dashboardDestinations)
            BottomNavigationBarItem(
              icon: Icon(destination.cupertinoIcon),
              label: destination.label,
            ),
        ],
      );
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      height: 72,
      backgroundColor: DashboardPalette.surface,
      indicatorColor: DashboardPalette.accent.withAlpha(28),
      onDestinationSelected: onSelected,
      destinations: [
        for (final destination in dashboardDestinations)
          NavigationDestination(
            icon: Icon(destination.materialIcon),
            selectedIcon: Icon(
              destination.materialIcon,
              color: DashboardPalette.accent,
            ),
            label: destination.label,
          ),
      ],
    );
  }
}

class AdaptiveTabletNavigation extends StatelessWidget {
  const AdaptiveTabletNavigation({
    required this.platform,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final AdaptivePlatform platform;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (platform.usesCupertinoControls) {
      return Container(
        width: double.infinity,
        color: DashboardPalette.surfaceSoft,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: CupertinoSlidingSegmentedControl<int>(
          groupValue: selectedIndex,
          children: {
            for (var i = 0; i < dashboardDestinations.length; i++)
              i: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  dashboardDestinations[i].label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
          },
          onValueChanged: (nextValue) {
            if (nextValue != null) {
              onSelected(nextValue);
            }
          },
        ),
      );
    }

    if (platform.isWeb) {
      return Container(
        color: DashboardPalette.surfaceSoft,
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
        alignment: Alignment.center,
        child: SegmentedButton<int>(
          segments: [
            for (var i = 0; i < dashboardDestinations.length; i++)
              ButtonSegment<int>(
                value: i,
                icon: Icon(dashboardDestinations[i].materialIcon),
                label: Text(dashboardDestinations[i].label),
              ),
          ],
          selected: {selectedIndex},
          onSelectionChanged: (selection) => onSelected(selection.first),
        ),
      );
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      height: 68,
      backgroundColor: DashboardPalette.surfaceSoft,
      indicatorColor: DashboardPalette.accent.withAlpha(28),
      onDestinationSelected: onSelected,
      destinations: [
        for (final destination in dashboardDestinations)
          NavigationDestination(
            icon: Icon(destination.materialIcon),
            label: destination.label,
          ),
      ],
    );
  }
}

class DashboardNavigationDrawer extends StatelessWidget {
  const DashboardNavigationDrawer({
    required this.platform,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final AdaptivePlatform platform;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: DashboardPalette.surface,
      child: _NavigationPane(
        platform: platform,
        selectedIndex: selectedIndex,
        onSelected: (index) {
          Navigator.of(context).maybePop();
          onSelected(index);
        },
      ),
    );
  }
}

class DashboardDesktopNavigation extends StatelessWidget {
  const DashboardDesktopNavigation({
    required this.platform,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final AdaptivePlatform platform;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 276,
      child: _NavigationPane(
        platform: platform,
        selectedIndex: selectedIndex,
        onSelected: onSelected,
        showBorder: true,
      ),
    );
  }
}

class _NavigationPane extends StatelessWidget {
  const _NavigationPane({
    required this.platform,
    required this.selectedIndex,
    required this.onSelected,
    this.showBorder = false,
  });

  final AdaptivePlatform platform;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardPalette.surface,
        border: showBorder
            ? const Border(right: BorderSide(color: DashboardPalette.line))
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  platform.usesCupertinoControls
                      ? CupertinoIcons.heart_fill
                      : Icons.favorite_rounded,
                  color: DashboardPalette.ink,
                  size: 48,
                ),
              ),
              const SizedBox(height: 26),
              const Divider(color: DashboardPalette.line),
              const SizedBox(height: 16),
              for (var i = 0; i < dashboardDestinations.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NavigationPaneItem(
                    platform: platform,
                    destination: dashboardDestinations[i],
                    selected: i == selectedIndex,
                    onPressed: () => onSelected(i),
                  ),
                ),
              const Spacer(),
              _NavigationPaneItem(
                platform: platform,
                destination: const DashboardDestination(
                  label: 'Logout',
                  materialIcon: Icons.logout_rounded,
                  cupertinoIcon: CupertinoIcons.square_arrow_right,
                ),
                selected: false,
                muted: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationPaneItem extends StatelessWidget {
  const _NavigationPaneItem({
    required this.platform,
    required this.destination,
    required this.selected,
    required this.onPressed,
    this.muted = false,
  });

  final AdaptivePlatform platform;
  final DashboardDestination destination;
  final bool selected;
  final bool muted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = platform.usesCupertinoControls
        ? destination.cupertinoIcon
        : destination.materialIcon;
    final foreground = selected ? DashboardPalette.ink : DashboardPalette.muted;
    final background = selected
        ? DashboardPalette.accent.withAlpha(26)
        : Colors.transparent;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: muted ? DashboardPalette.muted : foreground,
            size: 21,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              destination.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: muted ? DashboardPalette.muted : foreground,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
          ),
        ],
      ),
    );

    if (platform.usesCupertinoControls) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(48, 48),
        onPressed: onPressed,
        child: child,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: child,
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.platform,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final AdaptivePlatform platform;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (platform.usesCupertinoControls) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white, size: 24),
      );
    }

    return IconButton(
      tooltip: tooltip,
      color: Colors.white,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _WindowDots extends StatelessWidget {
  const _WindowDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _WindowDot(color: Color(0xFFFF5F57)),
        SizedBox(width: 7),
        _WindowDot(color: Color(0xFFFFBD2E)),
        SizedBox(width: 7),
        _WindowDot(color: Color(0xFF28C840)),
      ],
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const SizedBox(width: 12, height: 12),
    );
  }
}
