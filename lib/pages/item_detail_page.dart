import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/item_data.dart';
import '../state/cart_controller.dart';
import '../utils/format_price.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/cart_button.dart';
import '../widgets/product_image.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemId;
  final CartController cart;

  const ItemDetailPage({super.key, required this.itemId, required this.cart});

  @override
  Widget build(BuildContext context) {
    final item = items.where((item) => item.id == itemId).firstOrNull;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      floatingActionButton: CartButton(cart: cart),
      body: item == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Product not found', style: textTheme.titleLarge),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Browse products'),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final image = AspectRatio(
                    aspectRatio: 1,
                    child: ProductImage(item: item),
                  );
                  final details = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(item.name, style: textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Text(
                        formatPrice(item.price),
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      Text('Description', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(item.description, style: textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      AddToCartButton(item: item, cart: cart),
                    ],
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: constraints.maxWidth >= 700
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: image),
                                  const SizedBox(width: 32),
                                  Expanded(child: details),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  image,
                                  const SizedBox(height: 24),
                                  details,
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
