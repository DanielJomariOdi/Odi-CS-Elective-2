import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

void toggleAppThemeMode() {
  appThemeMode.value = appThemeMode.value == ThemeMode.dark
      ? ThemeMode.light
      : ThemeMode.dark;
}

ThemeData buildAppTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 228, 10, 2),
    brightness: brightness,
  );
  final baseTheme = ThemeData(colorScheme: colorScheme, useMaterial3: true);
  final textTheme = baseTheme.textTheme.copyWith(
    titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w800,
    ),
    titleSmall: baseTheme.textTheme.titleSmall?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w800,
    ),
    titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w900,
    ),
    bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.25,
    ),
    headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    ),
  );

  return baseTheme.copyWith(
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
        foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
        fixedSize: const WidgetStatePropertyAll(Size.square(36)),
        iconSize: const WidgetStatePropertyAll(22),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: const WidgetStatePropertyAll(CircleBorder()),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 3,
      shape: const CircleBorder(),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
      ),
    ),
  );
}
