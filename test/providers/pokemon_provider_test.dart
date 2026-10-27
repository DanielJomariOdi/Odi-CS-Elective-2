import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/providers/pokemon_provider.dart';
import 'package:pokedex/services/pokemon_service.dart';

List<Pokemon> _pokemon({int count = 30, String firstName = 'bulbasaur'}) =>
    List.generate(
      count,
      (index) => Pokemon(
        id: index + 1,
        name: index == 0 ? firstName : 'pokemon-${index + 1}',
        imageUrl: 'https://example.com/${index + 1}.png',
      ),
    );

class _FakePokemonService extends PokemonService {
  _FakePokemonService(this.respond);

  final Future<List<Pokemon>> Function() respond;
  final refreshes = <bool>[];
  bool closed = false;

  @override
  Future<List<Pokemon>> fetchPokemon({bool forceRefresh = false}) {
    refreshes.add(forceRefresh);
    return respond();
  }

  @override
  void close() {
    closed = true;
    super.close();
  }
}

PokemonProvider _provider(_FakePokemonService service) {
  final provider = PokemonProvider(service: service);
  addTearDown(service.close);
  addTearDown(provider.dispose);
  return provider;
}

void main() {
  test('publishes loading followed by 30 results', () async {
    final response = Completer<List<Pokemon>>();
    final service = _FakePokemonService(() => response.future);
    final provider = _provider(service);
    final states = <PokemonLoadState>[];
    provider.addListener(() => states.add(provider.state));

    expect(provider.state, PokemonLoadState.initial);
    final pending = provider.fetchPokemon();
    expect(provider.isLoading, isTrue);
    expect(provider.pokemon, isEmpty);
    expect(provider.selectedPokemon, isNull);
    expect(provider.limit, 30);
    expect(service.refreshes, [false]);

    response.complete(_pokemon());
    await pending;

    expect(states, [PokemonLoadState.loading, PokemonLoadState.success]);
    expect(provider.pokemon, hasLength(30));
    expect(provider.pokemon.first.name, 'bulbasaur');
    expect(provider.isLoading, isFalse);
    expect(provider.hasError, isFalse);
    expect(provider.isEmpty, isFalse);
    expect(() => provider.pokemon.clear(), throwsUnsupportedError);
  });

  test('publishes a successful empty state', () async {
    final provider = _provider(_FakePokemonService(() async => []));
    await provider.fetchPokemon();

    expect(provider.state, PokemonLoadState.success);
    expect(provider.isEmpty, isTrue);
    expect(provider.errorMessage, isNull);
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
    final provider = _provider(service);
    await provider.fetchPokemon();
    expect(provider.hasError, isTrue);
    expect(provider.errorMessage, contains('HTTP 503'));

    final retry = provider.fetchPokemon();
    expect(provider.isLoading, isTrue);
    expect(provider.errorMessage, isNull);
    retryResponse.complete(_pokemon());
    await retry;

    expect(provider.state, PokemonLoadState.success);
    expect(requests, 2);
  });

  test('converts unexpected failures to a display-safe error', () async {
    final provider = _provider(
      _FakePokemonService(() async {
        throw StateError('An internal error that should not reach the UI.');
      }),
    );
    await provider.fetchPokemon();

    expect(provider.hasError, isTrue);
    expect(provider.errorMessage, 'Could not load Pokémon. Please try again.');
  });

  test('refresh requests fresh data and coalesces pending calls', () async {
    final refreshResponse = Completer<List<Pokemon>>();
    var requests = 0;
    final service = _FakePokemonService(() {
      return ++requests == 1
          ? Future.value(_pokemon(count: 1))
          : refreshResponse.future;
    });
    final provider = _provider(service);
    await provider.fetchPokemon();

    final first = provider.refresh();
    final second = provider.fetchPokemon();
    expect(second, same(first));
    expect(requests, 2);
    expect(service.refreshes, [false, true]);
    refreshResponse.complete(_pokemon(count: 2));
    await Future.wait([first, second]);

    expect(provider.pokemon, hasLength(2));
    expect(requests, 2);
  });

  test('selection resolves from refreshed data and clears if removed', () async {
    var records = _pokemon(count: 2);
    final provider = _provider(_FakePokemonService(() async => records));
    await provider.fetchPokemon();
    provider.selectPokemon(1);
    final original = provider.selectedPokemon;

    records = _pokemon(count: 2, firstName: 'updated-name');
    await provider.refresh();
    expect(provider.selectedPokemonId, 1);
    expect(provider.selectedPokemon, same(provider.pokemon.first));
    expect(provider.selectedPokemon, isNot(same(original)));
    expect(provider.selectedPokemon!.name, 'updated-name');

    provider.selectPokemon(2);
    records = _pokemon(count: 1);
    await provider.refresh();
    expect(provider.selectedPokemonId, isNull);
    expect(provider.selectedPokemon, isNull);
  });

  test('invalid selection clears the selected Pokémon', () async {
    final provider = _provider(_FakePokemonService(() async => _pokemon()));
    await provider.fetchPokemon();

    provider.selectPokemon(1);
    provider.selectPokemon(999);

    expect(provider.selectedPokemonId, isNull);
    expect(provider.selectedPokemon, isNull);
  });

  test('failed refresh preserves selection and supports recovery', () async {
    var requests = 0;
    final provider = _provider(
      _FakePokemonService(() async {
        if (++requests == 2) {
          throw const PokemonServiceException('Unavailable');
        }
        return _pokemon();
      }),
    );
    await provider.fetchPokemon();
    provider.selectPokemon(1);
    final original = provider.selectedPokemon;

    await provider.refresh();
    expect(provider.hasError, isTrue);
    expect(provider.selectedPokemon, same(original));
    await provider.refresh();

    expect(requests, 3);
    expect(provider.state, PokemonLoadState.success);
    expect(provider.selectedPokemonId, 1);
  });

  for (final fails in [false, true]) {
    test(
      'disposal safely ignores a pending ${fails ? 'error' : 'result'}',
      () async {
        final response = Completer<List<Pokemon>>();
        final service = _FakePokemonService(() => response.future);
        final provider = PokemonProvider(service: service);
        addTearDown(service.close);
        var notifications = 0;
        provider.addListener(() => notifications++);
        final pending = provider.fetchPokemon();
        provider.dispose();
        expect(service.closed, isFalse);

        if (fails) {
          response.completeError(const PokemonServiceException('Unavailable'));
        } else {
          response.complete(_pokemon());
        }
        await pending;
        expect(notifications, 1);
      },
    );
  }
}
