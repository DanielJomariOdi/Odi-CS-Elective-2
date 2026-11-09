import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const url = String.fromEnvironment('SUPABASE_URL');
  const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (url.isEmpty || publishableKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration. Run with '
      '--dart-define-from-file=supabase.config.json',
    );
  }

  await Supabase.initialize(url: url, publishableKey: publishableKey);
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
