import 'package:flutter/foundation.dart';

import '../models/cart_line.dart';
import '../models/item.dart';

final cartController = CartController();

class CartController extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};
  OrderSummary? _completedOrder;

  List<CartLine> get lines => List.unmodifiable(_lines.values);
  bool get isEmpty => _lines.isEmpty;
  OrderSummary? get completedOrder => _completedOrder;

  int get itemCount =>
      _lines.values.fold(0, (count, line) => count + line.quantity);

  double get total => _lines.values.fold(0, (sum, line) => sum + line.subtotal);

  int quantityFor(String itemId) => _lines[itemId]?.quantity ?? 0;

  void add(Item item, {int quantity = 1}) {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be positive');
    }
    _lines[item.id] = CartLine(
      item: item,
      quantity: quantityFor(item.id) + quantity,
    );
    notifyListeners();
  }

  void decrease(String itemId) {
    final line = _lines[itemId];
    if (line == null) return;

    if (line.quantity == 1) {
      _lines.remove(itemId);
    } else {
      _lines[itemId] = CartLine(item: line.item, quantity: line.quantity - 1);
    }
    notifyListeners();
  }

  void remove(String itemId) {
    if (_lines.remove(itemId) != null) notifyListeners();
  }

  bool checkout() {
    if (isEmpty) return false;

    // Keep an immutable receipt so clearing the cart cannot change the order.
    _completedOrder = OrderSummary(_lines.values);
    _lines.clear();
    notifyListeners();
    return true;
  }
}
