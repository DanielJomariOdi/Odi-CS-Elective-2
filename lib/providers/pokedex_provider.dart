import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

enum PokemonLoadStatus { initial, loading, success, error }

final pokemonServiceProvider = Provider<PokemonService>((ref) {
  final service = PokemonService();
  ref.onDispose(service.close);
  return service;
});

final pokedexProvider = NotifierProvider<PokedexNotifier, PokedexState>(
  PokedexNotifier.new,
);

/// One immutable snapshot shared by the grid, favorites, and details page.
class PokedexState {
  PokedexState({
    List<Pokemon> pokemon = const [],
    this.status = PokemonLoadStatus.initial,
    this.errorMessage,
    Map<int, String> nicknames = const {},
    Set<int> favoriteIds = const {},
    this.selectedPokemonId,
    this.selectedType,
    this.favoritesExpanded = false,
  }) : pokemon = List.unmodifiable(pokemon),
       nicknames = Map.unmodifiable(nicknames),
       favoriteIds = Set.unmodifiable(favoriteIds);

  final List<Pokemon> pokemon;
  final PokemonLoadStatus status;
  final String? errorMessage;
  final Map<int, String> nicknames;
  final Set<int> favoriteIds;
  final int? selectedPokemonId;
  final String? selectedType;
  final bool favoritesExpanded;

  bool get isLoading => status == PokemonLoadStatus.loading;
  bool get hasError => status == PokemonLoadStatus.error;
  bool get isEmpty => status == PokemonLoadStatus.success && pokemon.isEmpty;
  int get limit => PokemonService.pokemonLimit;

  List<Pokemon> get visiblePokemon => selectedType == null
      ? pokemon
      : List.unmodifiable(
          pokemon.where((entry) => entry.types.contains(selectedType)),
        );

  // Favorites use the full collection, even when the grid has a type filter.
  List<Pokemon> get favorites => List.unmodifiable(
    pokemon.where((entry) => favoriteIds.contains(entry.id)),
  );

  Pokemon? get selectedPokemon {
    for (final entry in pokemon) {
      if (entry.id == selectedPokemonId) return entry;
    }
    return null;
  }

  List<String> get availableTypes {
    final types = pokemon.expand((entry) => entry.types).toSet().toList()
      ..sort();
    return List.unmodifiable(types);
  }

  String? nicknameFor(int id) => nicknames[id];
  bool isFavorite(int id) => favoriteIds.contains(id);

  PokedexState copyWith({
    List<Pokemon>? pokemon,
    PokemonLoadStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    Map<int, String>? nicknames,
    Set<int>? favoriteIds,
    int? selectedPokemonId,
    bool clearSelection = false,
    String? selectedType,
    bool clearTypeFilter = false,
    bool? favoritesExpanded,
  }) => PokedexState(
    pokemon: pokemon ?? this.pokemon,
    status: status ?? this.status,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    nicknames: nicknames ?? this.nicknames,
    favoriteIds: favoriteIds ?? this.favoriteIds,
    selectedPokemonId: clearSelection
        ? null
        : selectedPokemonId ?? this.selectedPokemonId,
    selectedType: clearTypeFilter ? null : selectedType ?? this.selectedType,
    favoritesExpanded: favoritesExpanded ?? this.favoritesExpanded,
  );
}

class PokedexNotifier extends Notifier<PokedexState> {
  Future<void>? _activeRequest;

  @override
  PokedexState build() {
    // Wait until the initial state is installed before starting the first load.
    scheduleMicrotask(() {
      if (ref.mounted) unawaited(fetch());
    });
    return PokedexState();
  }

  /// Fetch, retry, and refresh all use this method and always request fresh data.
  Future<void> fetch() {
    if (!ref.mounted) return Future<void>.value();
    final activeRequest = _activeRequest;
    if (activeRequest != null) return activeRequest;

    final completion = Completer<void>();
    _activeRequest = completion.future;
    state = state.copyWith(
      status: PokemonLoadStatus.loading,
      clearErrorMessage: true,
    );
    unawaited(_loadPokemon(completion));
    return completion.future;
  }

  Future<void> _loadPokemon(Completer<void> completion) async {
    try {
      if (!ref.mounted) return;
      final result = await ref
          .read(pokemonServiceProvider)
          .fetchPokemon(forceRefresh: true);
      if (!ref.mounted) return;

      final pokemon = result.take(PokemonService.pokemonLimit).toList();
      state = state.copyWith(
        pokemon: pokemon,
        status: PokemonLoadStatus.success,
        clearErrorMessage: true,
        clearSelection: !pokemon.any(
          (entry) => entry.id == state.selectedPokemonId,
        ),
      );
    } on PokemonServiceException catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: PokemonLoadStatus.error,
        errorMessage: error.message,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: PokemonLoadStatus.error,
        errorMessage: 'Could not load Pokémon. Please try again.',
      );
    } finally {
      _activeRequest = null;
      completion.complete();
    }
  }

  void selectPokemon(int id) {
    if (!ref.mounted) return;
    final exists = state.pokemon.any((entry) => entry.id == id);
    state = state.copyWith(selectedPokemonId: id, clearSelection: !exists);
  }

  void setNickname(int id, String nickname) {
    if (!ref.mounted) return;
    final value = String.fromCharCodes(
      nickname.trim().runes.take(24),
    ).trimRight();
    final nicknames = Map<int, String>.of(state.nicknames);
    if (value.isEmpty) {
      nicknames.remove(id);
    } else {
      nicknames[id] = value;
    }
    state = state.copyWith(nicknames: nicknames);
  }

  void removeNickname(int id) {
    if (!ref.mounted) return;
    final nicknames = Map<int, String>.of(state.nicknames)..remove(id);
    state = state.copyWith(nicknames: nicknames);
  }

  void toggleFavorite(int id) {
    if (!ref.mounted) return;
    final favoriteIds = Set<int>.of(state.favoriteIds);
    if (!favoriteIds.remove(id)) favoriteIds.add(id);
    state = state.copyWith(favoriteIds: favoriteIds);
  }

  void setTypeFilter(String? type) {
    if (!ref.mounted) return;
    state = state.copyWith(selectedType: type, clearTypeFilter: type == null);
  }

  void toggleFavoritesPanel() {
    if (!ref.mounted) return;
    state = state.copyWith(favoritesExpanded: !state.favoritesExpanded);
  }
}
