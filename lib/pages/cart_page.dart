import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cart_line.dart';
import '../state/cart_controller.dart';
import '../utils/format_price.dart';
import '../widgets/product_image.dart';

class CartPage extends StatefulWidget {
  final CartController cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    widget.cart.addListener(_refreshCart);
  }

  @override
  void didUpdateWidget(CartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cart != widget.cart) {
      oldWidget.cart.removeListener(_refreshCart);
      widget.cart.addListener(_refreshCart);
    }
  }

  void _refreshCart() => setState(() {});

  @override
  void dispose() {
    widget.cart.removeListener(_refreshCart);
    super.dispose();
  }

  void _checkout() {
    if (widget.cart.checkout()) context.go('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final lines = cart.lines;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final summary = _CartSummary(cart: cart, onCheckout: _checkout);
                final list = cart.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your cart is empty',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
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
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: lines.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => _CartLineCard(
                          key: ValueKey(lines[index].item.id),
                          line: lines[index],
                          cart: cart,
                        ),
                      );

                if (constraints.maxHeight < 450) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (cart.isEmpty)
                        Text(
                          'Your cart is empty',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      for (final line in lines)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CartLineCard(
                            key: ValueKey(line.item.id),
                            line: line,
                            cart: cart,
                          ),
                        ),
                      summary,
                    ],
                  );
                }

                if (constraints.maxWidth >= 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: list),
                      SizedBox(width: 320, child: summary),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(child: list),
                    summary,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  final CartLine line;
  final CartController cart;

  const _CartLineCard({super.key, required this.line, required this.cart});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = line.item;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox.square(dimension: 64, child: ProductImage(item: item)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        '${formatPrice(item.price)} each',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove ${item.name}',
                  onPressed: () => cart.remove(item.id),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.outlined(
                      tooltip: 'Decrease ${item.name} quantity',
                      onPressed: () => cart.decrease(item.id),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Semantics(
                        label: '${item.name} quantity',
                        value: '${line.quantity}',
                        excludeSemantics: true,
                        child: Text(
                          '${line.quantity}',
                          key: ValueKey('quantity-${item.id}'),
                          textAlign: TextAlign.center,
                          style: textTheme.titleSmall,
                        ),
                      ),
                    ),
                    IconButton.outlined(
                      tooltip: 'Increase ${item.name} quantity',
                      onPressed: () => cart.add(item),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Subtotal', style: textTheme.bodySmall),
                    Text(
                      formatPrice(line.subtotal),
                      key: ValueKey('subtotal-${item.id}'),
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartController cart;
  final VoidCallback onCheckout;

  const _CartSummary({required this.cart, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            children: [
              Text('Total', style: textTheme.titleLarge),
              Text(
                formatPrice(cart.total),
                key: const ValueKey('cart-total'),
                style: textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: cart.isEmpty ? null : onCheckout,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}
