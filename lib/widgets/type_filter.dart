import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pokedex_provider.dart';

class TypeFilter extends ConsumerWidget {
  const TypeFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokedexProvider);
    final actions = ref.read(pokedexProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore by type',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All types'),
              selected: state.selectedType == null,
              onSelected: (_) => actions.setTypeFilter(null),
            ),
            for (final type in state.availableTypes)
              ChoiceChip(
                key: ValueKey('type-$type'),
                label: Text('${type[0].toUpperCase()}${type.substring(1)}'),
                selected: state.selectedType == type,
                onSelected: (selected) =>
                    actions.setTypeFilter(selected ? type : null),
              ),
          ],
        ),
      ],
    );
  }
}
