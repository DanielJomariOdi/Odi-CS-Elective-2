import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/fruit_detail_page.dart';
import '../screens/fruit_list_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const FruitListPage();
      },

      routes: [
        GoRoute(
          path: 'fruit/:name',
          builder: (context, state) {
            final String fruitName =
                state.pathParameters['name']!;

            return FruitDetailPage(
              fruitName: fruitName,
            );
          },
        ),
      ],
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Text(
          '404 - Page Not Found',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  },
);