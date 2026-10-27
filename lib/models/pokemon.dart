class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String imageUrl;

  /// The list endpoint includes a resource URL containing the Pokémon's ID.
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

  String get displayName => name
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  String get formattedId => '#${id.toString().padLeft(3, '0')}';
}
