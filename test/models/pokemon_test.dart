import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/pokemon.dart';

void main() {
  group('Pokemon.fromListJson', () {
    test('extracts the ID from the URL and supplies official artwork', () {
      final pokemon = Pokemon.fromListJson({
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/',
      });

      expect(pokemon.id, 1);
      expect(pokemon.name, 'bulbasaur');
      expect(pokemon.displayName, 'Bulbasaur');
      expect(pokemon.formattedId, '#001');
      expect(
        pokemon.imageUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/'
        'pokemon/other/official-artwork/1.png',
      );
    });

    test(
      'formats hyphenated names and handles a URL without a trailing slash',
      () {
        final pokemon = Pokemon.fromListJson({
          'name': 'nidoran-f',
          'url': 'https://pokeapi.co/api/v2/pokemon/29',
        });

        expect(pokemon.displayName, 'Nidoran F');
        expect(pokemon.formattedId, '#029');
      },
    );

    test('rejects missing or invalid fields', () {
      final invalidRecords = <Map<String, dynamic>>[
        {},
        {'name': '', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
        {'name': 1, 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
        {'name': 'bulbasaur', 'url': 1},
        {'name': 'bulbasaur', 'url': 'not-a-url'},
        {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/type/1/'},
        {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/abc/'},
        {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/0/'},
      ];

      for (final record in invalidRecords) {
        expect(() => Pokemon.fromListJson(record), throwsFormatException);
      }
    });
  });
}
