import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final GoRouter? router;

  const MyApp({super.key, this.router});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Odi Shop',
          themeMode: themeMode,
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          routerConfig: router ?? appRouter,
        );
      },
    );
  }
}
