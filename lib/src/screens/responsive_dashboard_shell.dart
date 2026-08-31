import 'package:flutter/material.dart';

import '../core/adaptive_platform.dart';
import '../core/responsive_layout.dart';
import '../models/dashboard_destination.dart';
import '../pages/about_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/settings_page.dart';
import '../widgets/dashboard_chrome.dart';

class ResponsiveDashboardShell extends StatefulWidget {
  const ResponsiveDashboardShell({super.key});

  @override
  State<ResponsiveDashboardShell> createState() =>
      _ResponsiveDashboardShellState();
}

class _ResponsiveDashboardShellState extends State<ResponsiveDashboardShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final platform = AdaptivePlatform.current();

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayoutInfo.fromConstraints(constraints);
        final currentTitle = dashboardDestinations[_selectedIndex].label;
        final pages = [
          DashboardPage(layout: layout, platform: platform),
          SettingsPage(layout: layout, platform: platform),
          AboutPage(layout: layout, platform: platform),
        ];

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: layout.isDesktop
              ? null
              : DashboardNavigationDrawer(
                  platform: platform,
                  selectedIndex: _selectedIndex,
                  onSelected: _selectDestination,
                ),
          bottomNavigationBar: layout.isMobile
              ? AdaptiveBottomNavigationBar(
                  platform: platform,
                  selectedIndex: _selectedIndex,
                  onSelected: _selectDestination,
                )
              : null,
          body: Column(
            children: [
              DashboardTopBar(
                layout: layout,
                platform: platform,
                currentTitle: currentTitle,
                onMenuPressed: layout.isDesktop
                    ? null
                    : () => _scaffoldKey.currentState?.openDrawer(),
              ),
              if (layout.isTablet)
                AdaptiveTabletNavigation(
                  platform: platform,
                  selectedIndex: _selectedIndex,
                  onSelected: _selectDestination,
                ),
              Expanded(
                child: layout.isDesktop
                    ? Row(
                        children: [
                          DashboardDesktopNavigation(
                            platform: platform,
                            selectedIndex: _selectedIndex,
                            onSelected: _selectDestination,
                          ),
                          Expanded(
                            child: IndexedStack(
                              index: _selectedIndex,
                              children: pages,
                            ),
                          ),
                        ],
                      )
                    : IndexedStack(index: _selectedIndex, children: pages),
              ),
            ],
          ),
        );
      },
    );
  }
}
