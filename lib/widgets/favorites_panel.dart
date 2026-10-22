import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pokedex_provider.dart';

/// A shared favorites list whose expansion and contents survive navigation.
class FavoritesPanel extends ConsumerWidget {
  const FavoritesPanel({super.key, this.onPokemonSelected});

  final VoidCallback? onPokemonSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokedexProvider);
    final favorites = state.favorites;

    return Material(
      key: const Key('favorites-panel'),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E8ED)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            expanded: state.favoritesExpanded,
            child: InkWell(
              key: const Key('favorites-toggle'),
              onTap: () =>
                  ref.read(pokedexProvider.notifier).toggleFavoritesPanel(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Color(0xFFE34C4C),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Favorites',
                        style: TextStyle(
                          color: Color(0xFF172033),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${favorites.length}',
                        key: const Key('favorites-count'),
                        semanticsLabel: '${favorites.length} favorites',
                        style: const TextStyle(
                          color: Color(0xFFB83B3B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      state.favoritesExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: const Color(0xFF667085),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.favoritesExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E8ED)),
            if (favorites.isEmpty)
              const Padding(
                padding: EdgeInsets.all(22),
                child: Text(
                  'Your favorites will appear here. Tap a heart to save a Pokémon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.separated(
                  primary: false,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: favorites.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: 72,
                    color: Color(0xFFF1F3F6),
                  ),
                  itemBuilder: (context, index) {
                    final pokemon = favorites[index];
                    final nickname = state.nicknameFor(pokemon.id);
                    return ListTile(
                      key: Key('favorite-entry-${pokemon.id}'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: SizedBox.square(
                        dimension: 42,
                        child: Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.catching_pokemon,
                                color: Color(0xFF7C8493),
                              ),
                        ),
                      ),
                      title: Text(
                        pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF172033),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: nickname == null || nickname.isEmpty
                          ? null
                          : Text(
                              'Nickname: $nickname',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 12,
                              ),
                            ),
                      trailing: IconButton(
                        key: Key('favorite-remove-${pokemon.id}'),
                        tooltip: 'Remove ${pokemon.displayName} from favorites',
                        onPressed: () => ref
                            .read(pokedexProvider.notifier)
                            .toggleFavorite(pokemon.id),
                        icon: const Icon(
                          Icons.favorite,
                          color: Color(0xFFE34C4C),
                          size: 21,
                        ),
                      ),
                      onTap: () {
                        ref
                            .read(pokedexProvider.notifier)
                            .selectPokemon(pokemon.id);
                        onPokemonSelected?.call();
                      },
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}
