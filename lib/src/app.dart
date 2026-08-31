import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'core/adaptive_platform.dart';
import 'screens/responsive_dashboard_shell.dart';
import 'widgets/wireframe_widgets.dart';

class ResponsiveDashboardApp extends StatelessWidget {
  const ResponsiveDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = AdaptivePlatform.current();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Responsive Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        platform: platform.targetPlatform,
        visualDensity: platform.isWeb
            ? VisualDensity.compact
            : VisualDensity.standard,
        scaffoldBackgroundColor: DashboardPalette.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DashboardPalette.accent,
          brightness: Brightness.light,
        ),
      ),
      builder: (context, child) {
        return CupertinoTheme(
          data: const CupertinoThemeData(
            brightness: Brightness.light,
            primaryColor: DashboardPalette.accent,
            scaffoldBackgroundColor: DashboardPalette.background,
          ),
          child: ScrollConfiguration(
            behavior: const DashboardScrollBehavior(),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const ResponsiveDashboardShell(),
    );
  }
}

class DashboardScrollBehavior extends MaterialScrollBehavior {
  const DashboardScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices {
    return {
      ...super.dragDevices,
      PointerDeviceKind.mouse,
      PointerDeviceKind.trackpad,
    };
  }
}
