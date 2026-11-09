import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/item.dart';
import '../services/product_service.dart';
import '../state/cart_controller.dart';
import '../state/product_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format_price.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/cart_button.dart';
import '../widgets/product_image.dart';

class HomePage extends StatefulWidget {
  final CartController cart;
  final ProductService? productService;

  const HomePage({super.key, required this.cart, this.productService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ProductController _products;
  RangeValues _sliderValues = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    _products = ProductController(service: widget.productService);
    _products.load();
  }

  @override
  void dispose() {
    _products.dispose();
    super.dispose();
  }

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
        child: AnimatedBuilder(
          animation: _products,
          builder: (context, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Price filter',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${formatPrice(_sliderValues.start)} – '
                            '${formatPrice(_sliderValues.end)}',
                            key: const Key('selected-price-range'),
                          ),
                        ],
                      ),
                      RangeSlider(
                        key: const Key('price-range-slider'),
                        min: ProductController.lowerBound,
                        max: ProductController.upperBound,
                        divisions: 100,
                        values: _sliderValues,
                        labels: RangeLabels(
                          formatPrice(_sliderValues.start),
                          formatPrice(_sliderValues.end),
                        ),
                        onChanged: (value) =>
                            setState(() => _sliderValues = value),
                        // Query once the user finishes dragging, not on every tick.
                        onChangeEnd: _products.setPriceRange,
                      ),
                      Text(
                        _products.isLoading
                            ? 'Loading products…'
                            : '${_products.totalCount} matching product(s)',
                        key: const Key('product-count'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildResults(context)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      OutlinedButton(
                        key: const Key('previous-page'),
                        onPressed: _products.canGoBack
                            ? _products.previousPage
                            : null,
                        child: const Text('Previous'),
                      ),
                      Text(
                        '${_products.currentPage} / ${_products.totalPages}',
                        key: const Key('page-indicator'),
                      ),
                      OutlinedButton(
                        key: const Key('next-page'),
                        onPressed: _products.canGoNext
                            ? _products.nextPage
                            : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: CartButton(cart: widget.cart),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_products.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_products.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_products.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _products.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_products.items.isEmpty) {
      return const Center(child: Text('No products match this price range.'));
    }
    return _ProductGrid(items: _products.items, cart: widget.cart);
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
          itemBuilder: (context, index) =>
              ProductCard(item: items[index], cart: cart),
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
        onTap: () => context.go('/item/${item.id}'),
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
