import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/cart_controller.dart';

class CartButton extends StatelessWidget {
  final CartController cart;

  const CartButton({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, child) => FloatingActionButton(
        tooltip:
            'Cart (${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'})',
        onPressed: () => context.push('/cart'),
        child: Badge.count(
          count: cart.itemCount,
          isLabelVisible: !cart.isEmpty,
          child: const Icon(Icons.shopping_cart_sharp),
        ),
      ),
    );
  }
}
