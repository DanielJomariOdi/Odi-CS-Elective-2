import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cart_line.dart';
import '../utils/format_price.dart';
import '../widgets/product_image.dart';

class CheckoutConfirmationPage extends StatelessWidget {
  final OrderSummary order;

  const CheckoutConfirmationPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Confirmation'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Order confirmed',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thank you for shopping with Odi Shop!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text('Order summary', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
                ),
                const SizedBox(height: 16),
                for (final line in order.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox.square(
                              dimension: 56,
                              child: ProductImage(item: line.item),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.item.name,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty ${line.quantity} x ${formatPrice(line.item.price)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Subtotal ${formatPrice(line.subtotal)}',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const Divider(),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  children: [
                    Text('Total', style: theme.textTheme.titleLarge),
                    Text(
                      formatPrice(order.total),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text('Continue shopping'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
