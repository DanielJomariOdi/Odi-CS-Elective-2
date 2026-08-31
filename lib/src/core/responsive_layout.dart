import 'package:flutter/widgets.dart';

enum DashboardSizeClass { mobile, tablet, desktop }

class ResponsiveLayoutInfo {
  const ResponsiveLayoutInfo({required this.width, required this.sizeClass});

  final double width;
  final DashboardSizeClass sizeClass;

  factory ResponsiveLayoutInfo.fromConstraints(BoxConstraints constraints) {
    final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 1200.0;

    if (width >= 1100) {
      return ResponsiveLayoutInfo(
        width: width,
        sizeClass: DashboardSizeClass.desktop,
      );
    }

    if (width >= 700) {
      return ResponsiveLayoutInfo(
        width: width,
        sizeClass: DashboardSizeClass.tablet,
      );
    }

    return ResponsiveLayoutInfo(
      width: width,
      sizeClass: DashboardSizeClass.mobile,
    );
  }

  bool get isMobile => sizeClass == DashboardSizeClass.mobile;

  bool get isTablet => sizeClass == DashboardSizeClass.tablet;

  bool get isDesktop => sizeClass == DashboardSizeClass.desktop;

  double get pagePadding {
    return switch (sizeClass) {
      DashboardSizeClass.mobile => 16,
      DashboardSizeClass.tablet => 22,
      DashboardSizeClass.desktop => 28,
    };
  }

  double get gap {
    return switch (sizeClass) {
      DashboardSizeClass.mobile => 12,
      DashboardSizeClass.tablet => 16,
      DashboardSizeClass.desktop => 18,
    };
  }

  int get summaryColumns {
    return switch (sizeClass) {
      DashboardSizeClass.mobile => 2,
      DashboardSizeClass.tablet => 4,
      DashboardSizeClass.desktop => 4,
    };
  }

  double get summaryAspectRatio {
    return switch (sizeClass) {
      DashboardSizeClass.mobile => 1.04,
      DashboardSizeClass.tablet => 1.35,
      DashboardSizeClass.desktop => 1.22,
    };
  }

  double get navigationWidth => isDesktop ? 276 : 0;

  double get maxContentWidth => isDesktop ? 1320 : double.infinity;
}
