import 'item.dart';

class CartLine {
  final Item item;
  final int quantity;

  const CartLine({required this.item, required this.quantity});

  double get subtotal => item.price * quantity;
}

class OrderSummary {
  final List<CartLine> lines;

  OrderSummary(Iterable<CartLine> lines) : lines = List.unmodifiable(lines);

  int get itemCount => lines.fold(0, (count, line) => count + line.quantity);

  double get total => lines.fold(0, (sum, line) => sum + line.subtotal);
}
