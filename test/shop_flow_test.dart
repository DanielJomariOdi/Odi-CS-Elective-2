import 'package:act_1/data/item_data.dart';
import 'package:act_1/main.dart';
import 'package:act_1/models/item.dart';
import 'package:act_1/pages/cart_page.dart';
import 'package:act_1/pages/checkout_confirmation_page.dart';
import 'package:act_1/pages/home_page.dart';
import 'package:act_1/pages/item_detail_page.dart';
import 'package:act_1/router/app_router.dart';
import 'package:act_1/state/cart_controller.dart';
import 'package:act_1/theme/app_theme.dart';
import 'package:act_1/utils/format_price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CartController cart;

  setUp(() {
    cart = CartController();
    appThemeMode.value = ThemeMode.light;
  });

  Future<void> openShop(
    WidgetTester tester, {
    String location = '/',
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    final router = createAppRouter(cart, initialLocation: location);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      cart.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await tester.pumpWidget(MyApp(router: router));
    await tester.pumpAndSettle();
  }

  testWidgets('Browse, add, edit quantities, checkout, and continue shopping', (
    tester,
  ) async {
    await openShop(tester);
    await tester.tap(find.byTooltip('Add Placeholder Phone to cart'));
    await tester.pumpAndSettle();
    expect(cart.itemCount, 1);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byTooltip('Cart (1 item)'), findsOneWidget);

    await tester.tap(find.text('Placeholder Phone'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemDetailPage), findsOneWidget);
    expect(find.text(items.first.description), findsOneWidget);
    final addButton = find.widgetWithText(FilledButton, 'Add to cart');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(cart.quantityFor(items.first.id), 2);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    await tester.tap(find.byTooltip('Increase Placeholder Phone quantity'));
    await tester.pump();
    expect(cart.quantityFor(items.first.id), 3);
    await tester.tap(find.byTooltip('Decrease Placeholder Phone quantity'));
    await tester.pump();
    expect(cart.quantityFor(items.first.id), 2);

    await tester.tap(find.widgetWithText(FilledButton, 'Checkout'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutConfirmationPage), findsOneWidget);
    expect(find.text('Order confirmed'), findsOneWidget);
    expect(
      find.text('Qty 2 x ${formatPrice(items.first.price)}'),
      findsOneWidget,
    );
    expect(cart.isEmpty, isTrue);
    expect(cart.completedOrder!.itemCount, 2);
    expect(cart.completedOrder!.total, closeTo(599.98, 0.001));

    final continueButton = find.text('Continue shopping');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byTooltip('Cart (0 items)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Card add button becomes a synced quantity control and resets at zero',
    (tester) async {
      await openShop(tester, size: const Size(320, 568));
      final card = find.ancestor(
        of: find.text('Placeholder Phone'),
        matching: find.byType(ProductCard),
      );
      final originalSize = tester.getSize(card);
      final quantity = find.byKey(const ValueKey('card-quantity-product-1'));
      final add = find.byTooltip('Add Placeholder Phone to cart');
      final increase = find.byTooltip('Increase Placeholder Phone quantity');
      final decrease = find.byTooltip('Decrease Placeholder Phone quantity');

      expect(quantity, findsNothing);
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(add, findsNothing);
      expect(tester.widget<Text>(quantity).data, '1');
      expect(tester.getSize(card), originalSize);

      await tester.tap(increase);
      await tester.pump();
      expect(tester.widget<Text>(quantity).data, '2');
      expect(cart.total, closeTo(599.98, 0.001));
      await tester.tap(decrease);
      await tester.pump();
      expect(tester.widget<Text>(quantity).data, '1');
      await tester.tap(decrease);
      await tester.pumpAndSettle();
      expect(quantity, findsNothing);
      expect(add, findsOneWidget);
      expect(cart.isEmpty, isTrue);
      expect(tester.getSize(card), originalSize);
      expect(find.byType(HomePage), findsOneWidget);

      cart.add(items.first, quantity: 12);
      await tester.pump();
      expect(tester.widget<Text>(quantity).data, '12');
      cart.remove(items.first.id);
      await tester.pump();
      expect(add, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Direct checkout is guarded and empty cart checkout is disabled',
    (tester) async {
      await openShop(tester, location: '/checkout');
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.byType(CheckoutConfirmationPage), findsNothing);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Checkout'))
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Cart totals update on screen and removing the last item empties it',
    (tester) async {
      const pricedItem = Item(
        id: 'product-1',
        name: 'Placeholder Phone',
        description: 'Lorem ipsum',
        price: 12.50,
        icon: Icons.phone_iphone,
      );
      cart.add(pricedItem);
      await openShop(tester, location: '/cart');
      await tester.tap(find.byTooltip('Increase Placeholder Phone quantity'));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('cart-total'))).data,
        '\$25.00',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('subtotal-product-1')))
            .data,
        '\$25.00',
      );
      await tester.tap(find.byTooltip('Remove Placeholder Phone'));
      await tester.pumpAndSettle();
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(cart.isEmpty, isTrue);
    },
  );

  testWidgets('Unknown products have a working route back to the grid', (
    tester,
  ) async {
    await openShop(tester, location: '/item/missing');
    expect(find.text('Product not found'), findsOneWidget);
    await tester.tap(find.text('Browse products'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Theme toggle applies to the home and the next screen', (
    tester,
  ) async {
    await openShop(tester);
    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(HomePage))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('Placeholder Phone'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(ItemDetailPage))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(768, 1024),
    const Size(1024, 768),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Layouts fit $size at text scale $scale', (tester) async {
        cart.add(items.first, quantity: 2);
        cart.add(items[1]);
        await openShop(tester, size: size, textScale: scale);
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(
          delegate.crossAxisCount,
          size.width >= 900
              ? 4
              : size.width >= 600
              ? 3
              : 2,
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Placeholder Phone'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final checkout = find.widgetWithText(FilledButton, 'Checkout');
        await tester.scrollUntilVisible(
          checkout,
          200,
          scrollable: find
              .descendant(
                of: find.byType(CartPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(checkout);
        await tester.pumpAndSettle();
        await tester.tap(checkout);
        await tester.pumpAndSettle();
        expect(find.byType(CheckoutConfirmationPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
