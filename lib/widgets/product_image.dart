import 'package:flutter/material.dart';

import '../models/item.dart';

class ProductImage extends StatelessWidget {
  final Item item;

  const ProductImage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        'assets/images/${item.id}.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        color: colors.onSecondaryContainer,
        semanticLabel: item.name,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            item.icon,
            size: 48,
            color: colors.onSecondaryContainer,
            semanticLabel: item.name,
          ),
        ),
      ),
    );
  }
}
