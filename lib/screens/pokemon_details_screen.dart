import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/collection_state.dart';

/// The selected Pokémon is read from shared app state, not route arguments.
class PokemonDetailsScreen extends StatelessWidget {
  const PokemonDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PokemonProvider>();
    final pokemon = state.selectedPokemon;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 700;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 20 : 40,
                      24,
                      isCompact ? 20 : 40,
                      40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            key: const Key('back-to-collection'),
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back, size: 19),
                            label: const Text('Back to collection'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF394355),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1, color: Color(0xFFE3E7ED)),
                        const SizedBox(height: 24),
                        if (state.isLoading ||
                            state.state == PokemonLoadState.initial)
                          const CollectionState(
                            title: 'Finding Pokémon…',
                            message: 'Your next discovery is on its way.',
                            isLoading: true,
                          )
                        else if (state.hasError)
                          CollectionState(
                            title: 'Couldn’t load the Pokémon',
                            message:
                                state.errorMessage ??
                                'Something went wrong. Please try again.',
                            icon: Icons.cloud_off_outlined,
                            onRetry: state.refresh,
                          )
                        else if (pokemon == null)
                          const CollectionState(
                            title: 'Pokémon not found',
                            message:
                                'Return to the collection and choose a Pokémon to explore.',
                            icon: Icons.travel_explore,
                          )
                        else
                          _PokemonProfile(
                            pokemon: pokemon,
                            isCompact: isCompact,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PokemonProfile extends StatelessWidget {
  const _PokemonProfile({required this.pokemon, required this.isCompact});

  final Pokemon pokemon;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'POKÉMON PROFILE',
          style: TextStyle(
            color: Color(0xFF7C8493),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFDECEC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            pokemon.formattedId,
            key: const Key('detail-id'),
            semanticsLabel: 'Pokédex number ${pokemon.id}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB83B3B),
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            pokemon.displayName,
            key: const Key('detail-name'),
            style: TextStyle(
              color: const Color(0xFF172033),
              fontSize: isCompact ? 38 : 48,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE34C4C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(isCompact ? 20 : 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E8ED)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PokemonArtwork(pokemon: pokemon),
                const SizedBox(height: 28),
                identity,
                const SizedBox(height: 12),
              ],
            )
          : Row(
              children: [
                Expanded(child: _PokemonArtwork(pokemon: pokemon)),
                const SizedBox(width: 48),
                Expanded(child: identity),
              ],
            ),
    );
  }
}

class _PokemonArtwork extends StatelessWidget {
  const _PokemonArtwork({required this.pokemon});

  final Pokemon pokemon;

  static const _backdrops = [
    Color(0xFFEAF4ED),
    Color(0xFFEDF0FA),
    Color(0xFFFAF0E5),
    Color(0xFFE8F2F6),
    Color(0xFFF6ECF2),
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FractionallySizedBox(
            widthFactor: 0.9,
            heightFactor: 0.9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _backdrops[(pokemon.id - 1) % _backdrops.length],
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: Image.network(
              pokemon.imageUrl,
              key: const Key('detail-image'),
              fit: BoxFit.contain,
              semanticLabel: 'Official artwork of ${pokemon.displayName}',
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: SizedBox.square(
                    dimension: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      semanticsLabel: 'Loading ${pokemon.displayName} artwork',
                      value: progress.expectedTotalBytes == null
                          ? null
                          : progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 32,
                          color: Color(0xFF7C8493),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Image unavailable',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF667085)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
