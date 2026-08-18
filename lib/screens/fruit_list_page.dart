import 'package:flutter/material.dart';

import '../data/fruit_data.dart';
import '../widgets/fruit_card.dart';

class FruitListPage extends StatelessWidget {
  const FruitListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruits'),
        centerTitle: true,
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),

        itemCount: fruits.length,

        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },

        itemBuilder: (context, index) {
          final fruit = fruits[index];

          return FruitCard(
            fruit: fruit,
          );
        },
      ),
    );
  }
}