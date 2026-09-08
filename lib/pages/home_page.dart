import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/item_data.dart';
import '../models/item.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format_price.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/cart_button.dart';
import '../widgets/product_image.dart';

class HomePage extends StatelessWidget {
  final CartController cart;

  const HomePage({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
      body: SafeArea(
        child: _ProductGrid(items: items, cart: cart),
      ),
      floatingActionButton: CartButton(cart: cart),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<Item> items;
  final CartController cart;

  const _ProductGrid({required this.items, required this.cart});

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
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final cardHeight =
            (width >= 600 ? 332.0 : 312.0) +
            (textScale > 1 ? (textScale - 1) * 110 : 0);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) {
            return ProductCard(item: items[index], cart: cart);
          },
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Item item;
  final CartController cart;

  const ProductCard({super.key, required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Expanded(child: ProductImage(item: item)),
              const SizedBox(height: 10),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatPrice(item.price),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              AddToCartButton(item: item, cart: cart, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}
