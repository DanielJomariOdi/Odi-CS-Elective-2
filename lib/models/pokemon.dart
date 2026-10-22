/// Original API data; nicknames and favorites are stored separately in app state.
class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  /// The list endpoint includes a resource URL containing the Pokémon's ID.
  /// This lightweight record identifies which detail resources to request.
  factory Pokemon.fromListJson(Map<String, dynamic> json) {
    final name = json['name'];
    final resourceUrl = json['url'];
    if (name is! String || name.trim().isEmpty || resourceUrl is! String) {
      throw const FormatException('Missing Pokémon name or resource URL.');
    }

    final uri = Uri.tryParse(resourceUrl);
    final segments = uri?.pathSegments
        .where((part) => part.isNotEmpty)
        .toList();
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        segments == null ||
        segments.length < 2 ||
        segments[segments.length - 2] != 'pokemon') {
      throw const FormatException('Invalid Pokémon resource URL.');
    }

    final id = int.tryParse(segments.last);
    if (id == null || id <= 0) {
      throw const FormatException('Invalid Pokémon ID.');
    }

    return Pokemon(
      id: id,
      name: name.trim(),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/'
          'pokemon/other/official-artwork/$id.png',
    );
  }

  /// Types come from the detail response rather than guesses based on the ID.
  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final rawTypes = json['types'];
    if (id is! int ||
        id <= 0 ||
        name is! String ||
        name.trim().isEmpty ||
        rawTypes is! List ||
        rawTypes.isEmpty) {
      throw const FormatException('Missing Pokémon details or types.');
    }
    final types = rawTypes
        .map((entry) {
          if (entry is! Map || entry['type'] is! Map) {
            throw const FormatException('Invalid Pokémon type.');
          }
          final type = (entry['type'] as Map)['name'];
          if (type is! String || type.trim().isEmpty) {
            throw const FormatException('Invalid Pokémon type name.');
          }
          return type.trim().toLowerCase();
        })
        .toSet()
        .toList();
    final sprites = json['sprites'];
    final other = sprites is Map ? sprites['other'] : null;
    final artwork = other is Map ? other['official-artwork'] : null;
    final image = artwork is Map ? artwork['front_default'] : null;
    return Pokemon(
      id: id,
      name: name.trim(),
      imageUrl: image is String && Uri.tryParse(image)?.scheme == 'https'
          ? image
          : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/'
                'pokemon/other/official-artwork/$id.png',
      types: List.unmodifiable(types),
    );
  }

  String get displayName => name
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  String get formattedId => '#${id.toString().padLeft(3, '0')}';
}
