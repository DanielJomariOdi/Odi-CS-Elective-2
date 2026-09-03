import 'package:flutter/material.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Center(
        child: Text(
          'Product detail page for $itemId will be built next.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
