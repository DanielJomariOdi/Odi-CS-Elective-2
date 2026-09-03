import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/item_data.dart';
import '../models/item.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = appThemeMode.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Odi Shop'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: toggleAppThemeMode,
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(child: _ProductGrid(items: items)),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Cart',
        onPressed: () {},
        child: Badge(child: const Icon(Icons.shopping_cart_sharp)),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<Item> items;

  const _ProductGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 900
            ? 4
            : width >= 600
            ? 3
            : 2;
        final cardHeight = width >= 600 ? 300.0 : 260.0;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) {
            return ProductCard(item: items[index]);
          },
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Item item;

  const ProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go('/item/${item.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: colorScheme.onSecondaryContainer,
                    size: 58,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '\$${item.price.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  SizedBox.square(
                    dimension: 36,
                    child: FilledButton(
                      onPressed: () {},
                      child: const Icon(Icons.add_rounded),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
