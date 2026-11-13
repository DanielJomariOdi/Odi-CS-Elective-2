import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/item_detail_page.dart';
import '../pages/home_page.dart';
import '../pages/cart_page.dart';
import '../pages/auth_page.dart';
import '../pages/checkout_confirmation_page.dart';
import '../services/product_service.dart';
import '../state/cart_controller.dart';
import '../state/auth_controller.dart';

final GoRouter appRouter = createAppRouter(
  cartController,
  authController: AuthController(),
);

GoRouter createAppRouter(
  CartController cart, {
  String initialLocation = '/',
  ProductService? productService,
  AuthController? authController,
}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          HomePage(
            cart: cart,
            productService: productService,
            authController: authController,
          ),
      routes: [
        if (authController != null)
          GoRoute(
            path: 'account',
            builder: (context, state) =>
                AuthPage(authController: authController),
          ),
        GoRoute(
          path: 'item/:id',
          builder: (context, state) => ItemDetailPage(
            itemId: state.pathParameters['id']!,
            cart: cart,
            productService: productService,
          ),
        ),
        GoRoute(
          path: 'cart',
          builder: (context, state) => CartPage(cart: cart),
        ),
        GoRoute(
          path: 'checkout',
          redirect: (context, state) =>
              cart.completedOrder == null ? '/cart' : null,
          builder: (context, state) =>
              CheckoutConfirmationPage(order: cart.completedOrder!),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
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
    ),
  ),
);
