import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/item_detail_page.dart';
import '../pages/home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const HomePage();
      },

      routes: [
        GoRoute(
          path: 'item/:id',
          builder: (context, state) {
            final String itemId = state.pathParameters['id']!;
            return ItemDetailPage(itemId: itemId);
          },
        ),
      ],
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text(
          '404 - Page Not Found',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  },
);
