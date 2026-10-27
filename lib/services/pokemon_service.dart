import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonServiceException implements Exception {
  const PokemonServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

class PokemonService {
  PokemonService({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  static const int pokemonLimit = 30;
  final http.Client _client;
  final Duration timeout;
  List<Pokemon>? _cachedPokemon;

  Future<List<Pokemon>> fetchPokemon({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPokemon != null) return _cachedPokemon!;
    final data = await _getJson(
      Uri.https('pokeapi.co', '/api/v2/pokemon', {
        'limit': '$pokemonLimit',
        'offset': '0',
      }),
    );
    try {
      final results = data['results'];
      if (results is! List) throw const FormatException('Missing results.');
      final pokemon = results.take(pokemonLimit).map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Invalid Pokémon record.');
        }
        return Pokemon.fromListJson(entry);
      }).toList();
      _cachedPokemon = List.unmodifiable(pokemon);
      return _cachedPokemon!;
    } on FormatException {
      throw const PokemonServiceException(
        'PokéAPI returned unexpected Pokémon data. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw PokemonServiceException(
          'PokéAPI is unavailable (HTTP ${response.statusCode}). Please try again.',
        );
      }
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid response.');
      }
      return data;
    } on PokemonServiceException {
      rethrow;
    } on TimeoutException {
      throw const PokemonServiceException(
        'The request took too long. Please try again.',
      );
    } on FormatException {
      throw const PokemonServiceException(
        'PokéAPI returned unexpected data. Please try again.',
      );
    } on http.ClientException {
      throw const PokemonServiceException(
        'Could not reach PokéAPI. Check your connection and try again.',
      );
    } catch (_) {
      throw const PokemonServiceException(
        'Could not load Pokémon. Please try again.',
      );
    }
  }

  void close() => _client.close();
}
