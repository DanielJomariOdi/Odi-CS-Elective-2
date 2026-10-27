import 'package:flutter/material.dart';

import '../models/pokemon.dart';

/// Displays a Pokémon from app state and opens its shared-state details page.
class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, required this.pokemon, required this.onTap});

  final Pokemon pokemon;
  final VoidCallback onTap;

  static const _backdrops = [
    Color(0xFFEAF4ED),
    Color(0xFFEDF0FA),
    Color(0xFFFAF0E5),
    Color(0xFFE8F2F6),
    Color(0xFFF6ECF2),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Material(
        color: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x0D0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E8ED)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pokemon.formattedId,
                        style: const TextStyle(
                          color: Color(0xFF7C8493),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_outward,
                      size: 18,
                      color: Color(0xFFD6DBE3),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.85,
                        heightFactor: 0.85,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                                _backdrops[(pokemon.id - 1) %
                                    _backdrops.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Color(0xFF7C8493),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Image unavailable',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF667085),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  pokemon.displayName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
