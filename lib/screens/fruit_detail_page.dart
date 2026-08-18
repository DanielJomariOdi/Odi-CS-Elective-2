import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/fruit_data.dart';
import '../models/fruit.dart';

class FruitDetailPage extends StatelessWidget {
  final String fruitName;

  const FruitDetailPage({
    super.key,
    required this.fruitName,
  });

  @override
  Widget build(BuildContext context) {
    Fruit? selectedFruit;

    for (final fruit in fruits) {
      if (fruit.name.toLowerCase() ==
          fruitName.toLowerCase()) {
        selectedFruit = fruit;
        break;
      }
    }

    if (selectedFruit == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fruit Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
              ),

              const SizedBox(height: 20),

              Text(
                'Fruit "$fruitName" was not found.',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  context.go('/');
                },
                child: const Text(
                  'Back to Fruits',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedFruit.name),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selectedFruit.icon,
                size: 120,
              ),

              const SizedBox(height: 30),

              Text(
                selectedFruit.name,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                selectedFruit.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () {
                  context.go('/');
                },
                icon: const Icon(
                  Icons.arrow_back,
                ),
                label: const Text(
                  'Back to Fruits',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}