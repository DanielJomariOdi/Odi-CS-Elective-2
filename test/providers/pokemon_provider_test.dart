import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/providers/pokedex_provider.dart';
import 'package:pokedex/services/pokemon_service.dart';

List<Pokemon> _pokemon({int count = 30, String firstName = 'bulbasaur'}) =>
    List.generate(
      count,
      (index) => Pokemon(
        id: index + 1,
        name: index == 0 ? firstName : 'pokemon-${index + 1}',
        imageUrl: 'https://example.com/${index + 1}.png',
        types: index == 0 ? const ['grass', 'poison'] : const ['normal'],
      ),
    );

class _FakePokemonService extends PokemonService {
  _FakePokemonService(this.respond);

  final Future<List<Pokemon>> Function() respond;
  final refreshes = <bool>[];

  @override
  Future<List<Pokemon>> fetchPokemon({bool forceRefresh = false}) {
    refreshes.add(forceRefresh);
    return respond();
  }
}

ProviderContainer _container(_FakePokemonService service) {
  final container = ProviderContainer(
    overrides: [pokemonServiceProvider.overrideWithValue(service)],
  );
  addTearDown(service.close);
  addTearDown(container.dispose);
  return container;
}

Future<void> _load(ProviderContainer container) async {
  container.read(pokedexProvider);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test('automatically publishes loading followed by 30 results', () async {
    final response = Completer<List<Pokemon>>();
    final service = _FakePokemonService(() => response.future);
    final container = _container(service);
    final statuses = <PokemonLoadStatus>[];
    container.listen(
      pokedexProvider,
      (_, state) => statuses.add(state.status),
      fireImmediately: true,
    );

    await _load(container);
    final loading = container.read(pokedexProvider);
    expect(loading.isLoading, isTrue);
    expect(loading.pokemon, isEmpty);
    expect(loading.selectedPokemon, isNull);
    expect(loading.limit, 30);
    expect(service.refreshes, hasLength(1));

    response.complete(_pokemon());
    await Future<void>.delayed(Duration.zero);
    final state = container.read(pokedexProvider);

    expect(
      statuses,
      containsAllInOrder([
        PokemonLoadStatus.loading,
        PokemonLoadStatus.success,
      ]),
    );
    expect(state.pokemon, hasLength(30));
    expect(state.pokemon.first.name, 'bulbasaur');
    expect(state.isLoading, isFalse);
    expect(state.hasError, isFalse);
    expect(state.isEmpty, isFalse);
    expect(() => state.pokemon.clear(), throwsUnsupportedError);
  });

  test('publishes a successful empty state', () async {
    final container = _container(_FakePokemonService(() async => []));
    await _load(container);

    final state = container.read(pokedexProvider);
    expect(state.status, PokemonLoadStatus.success);
    expect(state.isEmpty, isTrue);
    expect(state.errorMessage, isNull);
  });

  test('publishes an API error and clears it when retrying', () async {
    var requests = 0;
    final retryResponse = Completer<List<Pokemon>>();
    final service = _FakePokemonService(() async {
      if (++requests == 1) {
        throw const PokemonServiceException(
          'PokéAPI is unavailable (HTTP 503).',
        );
      }
      return retryResponse.future;
    });
    final container = _container(service);
    await _load(container);
    expect(container.read(pokedexProvider).hasError, isTrue);
    expect(container.read(pokedexProvider).errorMessage, contains('HTTP 503'));

    final retry = container.read(pokedexProvider.notifier).fetch();
    expect(container.read(pokedexProvider).isLoading, isTrue);
    expect(container.read(pokedexProvider).errorMessage, isNull);
    retryResponse.complete(_pokemon());
    await retry;

    expect(container.read(pokedexProvider).status, PokemonLoadStatus.success);
    expect(requests, 2);
  });

  test('converts unexpected failures to a display-safe error', () async {
    final container = _container(
      _FakePokemonService(() async {
        throw StateError('An internal error that should not reach the UI.');
      }),
    );
    await _load(container);

    expect(container.read(pokedexProvider).hasError, isTrue);
    expect(
      container.read(pokedexProvider).errorMessage,
      'Could not load Pokémon. Please try again.',
    );
  });

  test(
    'manual fetch requests fresh data and coalesces pending calls',
    () async {
      final refreshResponse = Completer<List<Pokemon>>();
      var requests = 0;
      final service = _FakePokemonService(() {
        return ++requests == 1
            ? Future.value(_pokemon(count: 1))
            : refreshResponse.future;
      });
      final container = _container(service);
      await _load(container);
      final notifier = container.read(pokedexProvider.notifier);

      final first = notifier.fetch();
      final second = notifier.fetch();
      expect(requests, 2);
      expect(service.refreshes.last, isTrue);
      refreshResponse.complete(_pokemon(count: 2));
      await Future.wait([first, second]);

      expect(container.read(pokedexProvider).pokemon, hasLength(2));
      expect(requests, 2);
    },
  );

  test(
    'selection resolves from refreshed data and clears if removed',
    () async {
      var records = _pokemon(count: 2);
      final container = _container(_FakePokemonService(() async => records));
      await _load(container);
      final notifier = container.read(pokedexProvider.notifier);
      notifier.selectPokemon(1);
      final original = container.read(pokedexProvider).selectedPokemon;

      records = _pokemon(count: 2, firstName: 'updated-name');
      await notifier.fetch();
      final refreshed = container.read(pokedexProvider);
      expect(refreshed.selectedPokemonId, 1);
      expect(refreshed.selectedPokemon, same(refreshed.pokemon.first));
      expect(refreshed.selectedPokemon, isNot(same(original)));
      expect(refreshed.selectedPokemon!.name, 'updated-name');

      notifier.selectPokemon(2);
      records = _pokemon(count: 1);
      await notifier.fetch();
      expect(container.read(pokedexProvider).selectedPokemonId, isNull);
      expect(container.read(pokedexProvider).selectedPokemon, isNull);
    },
  );

  test('invalid selection clears the selected Pokémon', () async {
    final container = _container(_FakePokemonService(() async => _pokemon()));
    await _load(container);
    final notifier = container.read(pokedexProvider.notifier);

    notifier.selectPokemon(1);
    notifier.selectPokemon(999);

    expect(container.read(pokedexProvider).selectedPokemonId, isNull);
    expect(container.read(pokedexProvider).selectedPokemon, isNull);
  });

  test('failed refresh preserves selection and supports recovery', () async {
    var requests = 0;
    final container = _container(
      _FakePokemonService(() async {
        if (++requests == 2) {
          throw const PokemonServiceException('Unavailable');
        }
        return _pokemon();
      }),
    );
    await _load(container);
    final notifier = container.read(pokedexProvider.notifier);
    notifier.selectPokemon(1);
    final original = container.read(pokedexProvider).selectedPokemon;

    await notifier.fetch();
    expect(container.read(pokedexProvider).hasError, isTrue);
    expect(container.read(pokedexProvider).selectedPokemon, same(original));
    await notifier.fetch();

    expect(requests, 3);
    expect(container.read(pokedexProvider).status, PokemonLoadStatus.success);
    expect(container.read(pokedexProvider).selectedPokemonId, 1);
  });

  test(
    'nicknames, favorites and type filtering share the same state',
    () async {
      final container = _container(_FakePokemonService(() async => _pokemon()));
      await _load(container);
      final notifier = container.read(pokedexProvider.notifier);

      notifier.setNickname(1, 'Sprout');
      notifier.toggleFavorite(1);
      notifier.setTypeFilter('grass');
      notifier.toggleFavoritesPanel();

      final state = container.read(pokedexProvider);
      expect(state.nicknameFor(1), 'Sprout');
      expect(state.isFavorite(1), isTrue);
      expect(state.favorites.single.id, 1);
      expect(state.visiblePokemon.single.id, 1);
      expect(state.favoritesExpanded, isTrue);

      notifier.removeNickname(1);
      notifier.toggleFavorite(1);
      notifier.setTypeFilter(null);
      expect(container.read(pokedexProvider).nicknameFor(1), isNull);
      expect(container.read(pokedexProvider).favorites, isEmpty);
      expect(container.read(pokedexProvider).visiblePokemon, hasLength(30));
    },
  );

  for (final fails in [false, true]) {
    test(
      'disposal safely ignores a pending ${fails ? 'error' : 'result'}',
      () async {
        final response = Completer<List<Pokemon>>();
        final service = _FakePokemonService(() => response.future);
        final container = ProviderContainer(
          overrides: [pokemonServiceProvider.overrideWithValue(service)],
        );
        addTearDown(service.close);
        await _load(container);
        final pending = container.read(pokedexProvider.notifier).fetch();
        container.dispose();

        if (fails) {
          response.completeError(const PokemonServiceException('Unavailable'));
        } else {
          response.complete(_pokemon());
        }
        await pending;
      },
    );
  }
}
