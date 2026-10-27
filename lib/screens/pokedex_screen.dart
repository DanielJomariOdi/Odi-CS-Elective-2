import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import '../widgets/collection_state.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_details_screen.dart';

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Consumer<PokemonProvider>(
              builder: (context, pokedex, child) {
                final isLoading =
                    pokedex.isLoading ||
                    pokedex.state == PokemonLoadState.initial;
                final pokemon = pokedex.pokemon;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 600;
                    final horizontalPadding = isCompact ? 20.0 : 40.0;
                    final columns = constraints.maxWidth < 350
                        ? 1
                        : isCompact
                        ? 2
                        : constraints.maxWidth < 900
                        ? 3
                        : 5;
                    final textScaler = MediaQuery.textScalerOf(context);
                    final cardHeight =
                        (isCompact ? 220.0 : 240.0) +
                        (textScaler.scale(17) - 17) * 2 +
                        (textScaler.scale(12) - 12);

                    return CustomScrollView(
                      key: const PageStorageKey('pokedex-scroll'),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Masthead(isCompact: isCompact),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE3E7ED),
                                ),
                                _Introduction(
                                  isCompact: isCompact,
                                  limit: pokedex.limit,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 22),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'The collection',
                                              style: TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              isLoading
                                                  ? 'Getting your field guide ready'
                                                  : pokedex.hasError
                                                  ? 'Let’s get you back to exploring'
                                                  : '${pokemon.length} Pokémon · By Pokédex number',
                                              style: const TextStyle(
                                                color: Color(0xFF667085),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Tooltip(
                                        message: 'Refresh',
                                        child: OutlinedButton.icon(
                                          onPressed: isLoading
                                              ? null
                                              : pokedex.refresh,
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 18,
                                          ),
                                          label: const Text('Refresh'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFF394355,
                                            ),
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                              color: Color(0xFFDDE2E9),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading)
                          const SliverToBoxAdapter(
                            child: CollectionState(
                              title: 'Finding Pokémon…',
                              message: 'Your next discovery is on its way.',
                              isLoading: true,
                            ),
                          )
                        else if (pokedex.hasError)
                          SliverToBoxAdapter(
                            child: CollectionState(
                              title: 'Couldn’t load the Pokédex',
                              message:
                                  pokedex.errorMessage ??
                                  'Something went wrong. Please try again.',
                              icon: Icons.cloud_off_outlined,
                              onRetry: pokedex.refresh,
                            ),
                          )
                        else if (pokemon.isEmpty)
                          SliverToBoxAdapter(
                            child: CollectionState(
                              title: 'No Pokémon found',
                              message: 'The collection is empty right now. Try again to make a new discovery.',
                              icon: Icons.travel_explore,
                              onRetry: pokedex.refresh,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              40,
                            ),
                            sliver: SliverGrid.builder(
                              key: const Key('pokemon-grid'),
                              itemCount: pokemon.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: isCompact ? 12 : 18,
                                    mainAxisSpacing: isCompact ? 12 : 18,
                                    mainAxisExtent: cardHeight,
                                  ),
                              itemBuilder: (context, index) => PokemonCard(
                                key: ValueKey('pokemon-${pokemon[index].id}'),
                                pokemon: pokemon[index],
                                onTap: () {
                                  pokedex.selectPokemon(pokemon[index].id);
                                  _openDetails(context);
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

void _openDetails(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const PokemonDetailsScreen()));
}

class _Masthead extends StatelessWidget {
  const _Masthead({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE34C4C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.catching_pokemon,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Text(
              'pokédex.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
          ),
          if (!isCompact)
            const Text(
              'A FIELD GUIDE FOR THE CURIOUS',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF7C8493),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _Introduction extends StatelessWidget {
  const _Introduction({required this.isCompact, required this.limit});

  final bool isCompact;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isCompact ? 30 : 44),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (!isCompact)
            const Positioned(
              right: 20,
              child: ExcludeSemantics(
                child: Icon(
                  Icons.catching_pokemon,
                  size: 190,
                  color: Color(0xFFE9ECF1),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'KANTO · THE FIRST $limit',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB83B3B),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Small creatures.\nBig discoveries.',
                style: TextStyle(
                  fontSize: isCompact ? 36 : 48,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1.8,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Get to know the first $limit Pokémon.\nTap a Pokémon to take a closer look.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
