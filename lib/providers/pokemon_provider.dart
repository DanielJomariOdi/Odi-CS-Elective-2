import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

enum PokemonLoadState { initial, loading, success, error }

class PokemonProvider extends ChangeNotifier {
  PokemonProvider({PokemonService? service})
    : _service = service ?? PokemonService(),
      _ownsService = service == null;

  final PokemonService _service;
  final bool _ownsService;
  PokemonLoadState _state = PokemonLoadState.initial;
  List<Pokemon> _pokemon = const [];
  String? _errorMessage;
  int? _selectedPokemonId;
  Future<void>? _activeRequest;
  bool _disposed = false;

  PokemonLoadState get state => _state;
  bool get isLoading => _state == PokemonLoadState.loading;
  bool get hasError => _state == PokemonLoadState.error;
  bool get isEmpty => _state == PokemonLoadState.success && _pokemon.isEmpty;
  String? get errorMessage => _errorMessage;
  List<Pokemon> get pokemon => _pokemon;
  int get limit => PokemonService.pokemonLimit;
  int? get selectedPokemonId => _selectedPokemonId;

  Pokemon? get selectedPokemon {
    for (final entry in _pokemon) {
      if (entry.id == _selectedPokemonId) return entry;
    }
    return null;
  }

  Future<void> fetchPokemon({bool forceRefresh = false}) {
    if (_disposed) return Future<void>.value();
    final activeRequest = _activeRequest;
    if (activeRequest != null) return activeRequest;

    final completion = Completer<void>();
    _activeRequest = completion.future;
    _state = PokemonLoadState.loading;
    _errorMessage = null;
    notifyListeners();
    unawaited(_loadPokemon(completion, forceRefresh: forceRefresh));
    return completion.future;
  }

  Future<void> _loadPokemon(
    Completer<void> completion, {
    required bool forceRefresh,
  }) async {
    try {
      if (_disposed) return;
      final result = await _service.fetchPokemon(forceRefresh: forceRefresh);
      if (_disposed) return;

      _pokemon = List.unmodifiable(result.take(limit));
      _state = PokemonLoadState.success;
      if (selectedPokemon == null) _selectedPokemonId = null;
      notifyListeners();
    } on PokemonServiceException catch (error) {
      if (_disposed) return;
      _state = PokemonLoadState.error;
      _errorMessage = error.message;
      notifyListeners();
    } catch (_) {
      if (_disposed) return;
      _state = PokemonLoadState.error;
      _errorMessage = 'Could not load Pokémon. Please try again.';
      notifyListeners();
    } finally {
      _activeRequest = null;
      completion.complete();
    }
  }

  Future<void> refresh() => fetchPokemon(forceRefresh: true);

  void selectPokemon(int id) {
    if (_disposed) return;
    final selectedId = _pokemon.any((entry) => entry.id == id) ? id : null;
    if (_selectedPokemonId == selectedId) return;
    _selectedPokemonId = selectedId;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_ownsService) _service.close();
    super.dispose();
  }
}
