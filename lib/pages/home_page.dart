
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/item_data.dart';

class HomePage extends StatelessWidget {
  final String itemName;

  const HomePage({
    super.key,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        centerTitle: true,
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),

        itemCount: items.length,

        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },

        itemBuilder: (context, index) {
          final item = items[index];

          return ItemCard(
            item: item,
          );
        },
      ),
    );
  }
}