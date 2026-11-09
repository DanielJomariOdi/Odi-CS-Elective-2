import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/item.dart';
import '../services/product_service.dart';
import '../state/cart_controller.dart';
import '../utils/format_price.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/cart_button.dart';
import '../widgets/product_image.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemId;
  final CartController cart;
  final ProductService? productService;

  const ItemDetailPage({
    super.key,
    required this.itemId,
    required this.cart,
    this.productService,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Future<Item?> _itemRequest;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _itemRequest = (widget.productService ?? ProductService()).fetchById(
      widget.itemId,
    );
  }

  @override
  void didUpdateWidget(covariant ItemDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemId != widget.itemId ||
        oldWidget.productService != widget.productService) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      floatingActionButton: CartButton(cart: widget.cart),
      body: FutureBuilder<Item?>(
        future: _itemRequest,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load product.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(_reload),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final item = snapshot.data;
          if (item == null) {
            return Center(
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
            );
          }
          return SafeArea(
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
                    Text(formatPrice(item.price), style: textTheme.titleMedium),
                    const SizedBox(height: 24),
                    Text('Description', style: textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(item.description, style: textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    AddToCartButton(item: item, cart: widget.cart),
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
          );
        },
      ),
    );
  }
}
