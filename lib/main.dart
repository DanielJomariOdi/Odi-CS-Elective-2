import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/pokemon_provider.dart';
import 'screens/pokedex_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF202938);
    const accent = Color(0xFFE34C4C);

    return ChangeNotifierProvider<PokemonProvider>(
      create: (_) => PokemonProvider()..fetchPokemon(),
      child: MaterialApp(
        title: 'Pokédex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: accent,
            primary: accent,
            surface: const Color(0xFFF7F8FA),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F8FA),
          fontFamily: 'Arial',
          textTheme: ThemeData.light().textTheme.apply(
            bodyColor: ink,
            displayColor: ink,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const PokedexScreen(),
      ),
    );
  }
}
