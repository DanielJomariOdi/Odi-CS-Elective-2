import 'package:act_1/models/item.dart';
import 'package:act_1/state/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const phone = Item(
  id: 'phone',
  name: 'Test phone',
  description: 'Lorem ipsum',
  price: 12.50,
  icon: Icons.phone_iphone,
);
const tablet = Item(
  id: 'tablet',
  name: 'Test tablet',
  description: 'Lorem ipsum',
  price: 30,
  icon: Icons.tablet_mac,
);

void main() {
  late CartController cart;

  setUp(() => cart = CartController());
  tearDown(() => cart.dispose());

  test(
    'Repeated adds merge quantities and recalculate subtotals and total',
    () {
      cart.add(phone);
      cart.add(phone, quantity: 2);
      cart.add(tablet);

      expect(cart.lines.length, 2);
      expect(cart.quantityFor(phone.id), 3);
      expect(cart.itemCount, 4);
      expect(cart.lines.first.subtotal, 37.50);
      expect(cart.total, 67.50);

      cart.decrease(phone.id);
      expect(cart.total, 55);
      cart.remove(tablet.id);
      expect(cart.total, 25);
    },
  );

  test(
    'Decreasing the last unit removes the line without negative quantities',
    () {
      cart.add(phone);
      cart.decrease(phone.id);
      cart.decrease(phone.id);

      expect(cart.isEmpty, isTrue);
      expect(cart.quantityFor(phone.id), 0);
      expect(cart.itemCount, 0);
      expect(cart.total, 0);
    },
  );

  test('Empty checkout is rejected and quantities must be positive', () {
    expect(cart.checkout(), isFalse);
    expect(cart.completedOrder, isNull);
    expect(() => cart.add(phone, quantity: 0), throwsArgumentError);
    expect(() => cart.add(phone, quantity: -1), throwsArgumentError);
  });

  test(
    'Checkout preserves an immutable receipt and clears the active cart',
    () {
      cart.add(phone, quantity: 2);
      cart.add(tablet);

      expect(cart.checkout(), isTrue);
      final order = cart.completedOrder!;
      expect(cart.isEmpty, isTrue);
      expect(order.itemCount, 3);
      expect(order.total, 55);
      expect(() => order.lines.clear(), throwsUnsupportedError);
      expect(cart.checkout(), isFalse);
      expect(cart.completedOrder, same(order));

      cart.add(tablet, quantity: 5);
      expect(order.itemCount, 3);
      expect(order.total, 55);
    },
  );
}
