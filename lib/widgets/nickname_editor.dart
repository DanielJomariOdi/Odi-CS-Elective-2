import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokedex_provider.dart';

/// Only the unsaved input draft is local; saved nicknames live in shared state.
class NicknameEditor extends ConsumerStatefulWidget {
  const NicknameEditor({super.key, required this.pokemonId});

  final int pokemonId;

  @override
  ConsumerState<NicknameEditor> createState() => _NicknameEditorState();
}

class _NicknameEditorState extends ConsumerState<NicknameEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(pokedexProvider).nicknameFor(widget.pokemonId) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final nickname = _controller.text.trim();
    if (nickname.isEmpty) return;
    ref.read(pokedexProvider.notifier).setNickname(widget.pokemonId, nickname);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokedexProvider);
    Pokemon? pokemon;
    for (final item in state.pokemon) {
      if (item.id == widget.pokemonId) {
        pokemon = item;
        break;
      }
    }
    final savedNickname = state.nicknameFor(widget.pokemonId);

    return AlertDialog(
      title: const Text('Give a nickname'),
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pokemon?.displayName ?? 'Pokémon #${widget.pokemonId}',
              style: const TextStyle(
                color: Color(0xFF172033),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The original Pokémon name will always stay visible.',
              style: TextStyle(color: Color(0xFF667085), height: 1.5),
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('nickname-input'),
              controller: _controller,
              autofocus: true,
              maxLength: 24,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) => _save(),
              decoration: const InputDecoration(
                labelText: 'Nickname',
                hintText: 'Choose a name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('remove-nickname'),
          onPressed: savedNickname == null || savedNickname.isEmpty
              ? null
              : () {
                  ref
                      .read(pokedexProvider.notifier)
                      .removeNickname(widget.pokemonId);
                  Navigator.of(context).pop();
                },
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFB83B3B)),
          child: const Text('Remove'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save-nickname'),
          onPressed: _controller.text.trim().isEmpty ? null : _save,
          child: const Text('Save nickname'),
        ),
      ],
    );
  }
}
