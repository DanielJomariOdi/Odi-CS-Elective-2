import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart' show IconData;

class DashboardDestination {
  const DashboardDestination({
    required this.label,
    required this.materialIcon,
    required this.cupertinoIcon,
  });

  final String label;
  final IconData materialIcon;
  final IconData cupertinoIcon;
}

const dashboardDestinations = [
  DashboardDestination(
    label: 'Dashboard',
    materialIcon: Icons.dashboard_rounded,
    cupertinoIcon: CupertinoIcons.square_grid_2x2_fill,
  ),
  DashboardDestination(
    label: 'Settings',
    materialIcon: Icons.tune_rounded,
    cupertinoIcon: CupertinoIcons.slider_horizontal_3,
  ),
  DashboardDestination(
    label: 'About',
    materialIcon: Icons.info_rounded,
    cupertinoIcon: CupertinoIcons.info_circle_fill,
  ),
];
