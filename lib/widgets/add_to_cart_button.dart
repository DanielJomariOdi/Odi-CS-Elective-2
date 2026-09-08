import 'dart:async';

import 'package:flutter/material.dart';

import '../models/item.dart';
import '../state/cart_controller.dart';

class AddToCartButton extends StatefulWidget {
  final Item item;
  final CartController cart;
  final bool compact;

  const AddToCartButton({
    super.key,
    required this.item,
    required this.cart,
    this.compact = false,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool _added = false;
  Timer? _feedbackTimer;

  void _add() {
    widget.cart.add(widget.item);
    setState(() => _added = true);
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _added = false);
    });
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: SizedBox(
            height: 48,
            child: ListenableBuilder(
              listenable: widget.cart,
              builder: (context, child) {
                final quantity = widget.cart.quantityFor(widget.item.id);

                if (quantity == 0) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: IconButton.filled(
                      tooltip: 'Add ${widget.item.name} to cart',
                      onPressed: () => widget.cart.add(widget.item),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  );
                }

                return Row(
                  children: [
                    IconButton.outlined(
                      tooltip: 'Decrease ${widget.item.name} quantity',
                      onPressed: () => widget.cart.decrease(widget.item.id),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    Expanded(
                      child: Semantics(
                        label: '${widget.item.name} quantity',
                        value: '$quantity',
                        liveRegion: true,
                        excludeSemantics: true,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$quantity',
                            key: ValueKey('card-quantity-${widget.item.id}'),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: 'Increase ${widget.item.name} quantity',
                      onPressed: () => widget.cart.add(widget.item),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: _add,
      icon: Icon(
        _added ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
      ),
      label: Text(_added ? 'Added to cart' : 'Add to cart'),
    );
  }
}
