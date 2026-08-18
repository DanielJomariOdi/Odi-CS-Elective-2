import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/fruit.dart';

class FruitCard extends StatelessWidget {
  final Fruit fruit;

  const FruitCard({
    super.key,
    required this.fruit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            fruit.icon,
          ),
        ),

        title: Text(
          fruit.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: const Text(
          'Tap to view details',
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),

        onTap: () {
          final String fruitName =
              fruit.name.toLowerCase();

          context.go(
            '/fruit/$fruitName',
          );
        },
      ),
    );
  }
}