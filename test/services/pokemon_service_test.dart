import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex/services/pokemon_service.dart';

String responseBody({int count = 30}) => jsonEncode({
  'results': List.generate(
    count,
    (index) => {
      'name': index == 0 ? 'bulbasaur' : 'pokemon-${index + 1}',
      'url': 'https://pokeapi.co/api/v2/pokemon/${index + 1}/',
    },
  ),
});

http.Response _detailResponse(http.Request request) {
  final id = int.parse(request.url.pathSegments.last);
  return http.Response(
    jsonEncode({
      'id': id,
      'name': id == 1 ? 'bulbasaur' : 'pokemon-$id',
      'sprites': {
        'other': {
          'official-artwork': {
            'front_default': 'https://example.com/official-artwork/$id.png',
          },
        },
      },
      'types': [
        {
          'slot': 1,
          'type': {'name': 'grass'},
        },
        {
          'slot': 2,
          'type': {'name': 'poison'},
        },
      ],
    }),
    200,
  );
}

bool _isList(http.Request request) => request.url.path == '/api/v2/pokemon';

Matcher serviceErrorContaining(String text) => isA<PokemonServiceException>()
    .having((error) => error.message, 'message', contains(text));

void main() {
  test('requests the first 30 Pokémon and their types from details', () async {
    var listRequests = 0;
    final detailIds = <int>[];
    final service = PokemonService(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'pokeapi.co');
        if (_isList(request)) {
          listRequests++;
          expect(request.url.queryParameters, {'limit': '30', 'offset': '0'});
          return http.Response(responseBody(), 200);
        }
        expect(request.url.path, matches(r'^/api/v2/pokemon/\d+$'));
        detailIds.add(int.parse(request.url.pathSegments.last));
        return _detailResponse(request);
      }),
    );
    addTearDown(service.close);

    final pokemon = await service.fetchPokemon();

    expect(pokemon, hasLength(30));
    expect(pokemon.first.id, 1);
    expect(pokemon.first.name, 'bulbasaur');
    expect(pokemon.first.imageUrl, endsWith('/official-artwork/1.png'));
    expect(pokemon.first.types, ['grass', 'poison']);
    expect(pokemon.last.id, 30);
    expect(listRequests, 1);
    expect(detailIds, unorderedEquals(List.generate(30, (index) => index + 1)));
  });

  test('caps an oversized response at 30 Pokémon', () async {
    var detailRequests = 0;
    final service = PokemonService(
      client: MockClient((request) async {
        if (_isList(request)) {
          return http.Response(responseBody(count: 40), 200);
        }
        detailRequests++;
        return _detailResponse(request);
      }),
    );
    addTearDown(service.close);

    expect(await service.fetchPokemon(), hasLength(30));
    expect(detailRequests, 30);
  });

  test('preserves and caches an empty result', () async {
    var requests = 0;
    final service = PokemonService(
      client: MockClient((_) async {
        requests++;
        return http.Response(responseBody(count: 0), 200);
      }),
    );
    addTearDown(service.close);

    expect(await service.fetchPokemon(), isEmpty);
    expect(await service.fetchPokemon(), isEmpty);
    expect(requests, 1);
  });

  test('refreshes the list while reusing cached Pokémon details', () async {
    var listRequests = 0;
    final detailRequests = <int, int>{};
    final service = PokemonService(
      client: MockClient((request) async {
        if (_isList(request)) {
          listRequests++;
          return http.Response(responseBody(count: listRequests), 200);
        }
        final id = int.parse(request.url.pathSegments.last);
        detailRequests.update(id, (count) => count + 1, ifAbsent: () => 1);
        return _detailResponse(request);
      }),
    );
    addTearDown(service.close);

    final first = await service.fetchPokemon();
    final cached = await service.fetchPokemon();
    expect(cached, same(first));
    expect(listRequests, 1);
    expect(() => first.clear(), throwsUnsupportedError);
    expect(await service.fetchPokemon(forceRefresh: true), hasLength(2));
    expect(listRequests, 2);
    expect(detailRequests, {1: 1, 2: 1});
  });

  test('reports HTTP errors and allows a subsequent retry', () async {
    var listRequests = 0;
    final service = PokemonService(
      client: MockClient((request) async {
        if (!_isList(request)) return _detailResponse(request);
        listRequests++;
        return listRequests == 1
            ? http.Response('Service unavailable', 503)
            : http.Response(responseBody(), 200);
      }),
    );
    addTearDown(service.close);

    await expectLater(
      service.fetchPokemon(),
      throwsA(serviceErrorContaining('HTTP 503')),
    );
    expect(await service.fetchPokemon(), hasLength(30));
  });

  test('reports malformed JSON, result lists, and records', () async {
    final invalidBodies = [
      'not json',
      'null',
      '[]',
      '{}',
      '{"results": null}',
      '{"results": {}}',
      '{"results": [1]}',
      '{"results": [{"name": "bulbasaur"}]}',
      '{"results": [{"name": "bulbasaur", "url": "bad-url"}]}',
    ];

    for (final body in invalidBodies) {
      final service = PokemonService(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      addTearDown(service.close);

      await expectLater(
        service.fetchPokemon(),
        throwsA(serviceErrorContaining('unexpected')),
        reason: body,
      );
    }
  });

  test('reports malformed or unavailable Pokémon details', () async {
    for (final response in [
      http.Response('{"id": 1, "name": "bulbasaur", "types": []}', 200),
      http.Response('Unavailable', 503),
    ]) {
      final service = PokemonService(
        client: MockClient(
          (request) async => _isList(request)
              ? http.Response(responseBody(count: 1), 200)
              : response,
        ),
      );
      addTearDown(service.close);

      await expectLater(
        service.fetchPokemon(),
        throwsA(
          serviceErrorContaining(
            response.statusCode == 200 ? 'unexpected' : 'HTTP 503',
          ),
        ),
      );
    }
  });

  test('reports connection errors with a helpful message', () async {
    final service = PokemonService(
      client: MockClient((_) async => throw http.ClientException('Offline')),
    );
    addTearDown(service.close);

    await expectLater(
      service.fetchPokemon(),
      throwsA(serviceErrorContaining('Check your connection')),
    );
  });

  test('reports a request timeout', () async {
    final pending = Completer<http.Response>();
    final service = PokemonService(
      client: MockClient((_) => pending.future),
      timeout: const Duration(milliseconds: 1),
    );
    addTearDown(service.close);

    await expectLater(
      service.fetchPokemon(),
      throwsA(serviceErrorContaining('took too long')),
    );
    pending.complete(http.Response(responseBody(), 200));
  });

  test(
    'a failed refresh leaves the previous successful cache available',
    () async {
      var listRequests = 0;
      final service = PokemonService(
        client: MockClient((request) async {
          if (!_isList(request)) return _detailResponse(request);
          listRequests++;
          return listRequests == 1
              ? http.Response(responseBody(), 200)
              : http.Response('Unavailable', 503);
        }),
      );
      addTearDown(service.close);

      final original = await service.fetchPokemon();
      await expectLater(
        service.fetchPokemon(forceRefresh: true),
        throwsA(isA<PokemonServiceException>()),
      );
      expect(await service.fetchPokemon(), same(original));
      expect(listRequests, 2);
    },
  );

  test('exception string is suitable for display', () {
    const exception = PokemonServiceException('Please try again.');
    expect(exception.toString(), 'Please try again.');
  });
}
