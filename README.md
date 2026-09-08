# Odi Shop

A Flutter shopping app for Android and iOS, with responsive phone and tablet
layouts and a browser preview. Products use bundled placeholder images, lorem
ipsum descriptions, and sample dollar prices.

## Run

```sh
flutter pub get
flutter run
```

For a browser preview, use `flutter run -d chrome`. Android builds use
`flutter build apk --debug`. Building for iOS requires macOS and Xcode.

## Shopping Flow

Home grid -> Product detail -> Add to cart -> Cart -> Checkout confirmation.

Each product card starts with an add button. Adding an item replaces it with
minus/quantity/plus controls; removing the last unit restores the add button.
These controls stay in sync with changes on the detail and cart screens.
The floating cart button shows the current item count. Cart quantities, line
subtotals, and the total update immediately. Decreasing a quantity from one
removes that item. Checkout requires a nonempty cart, saves an immutable order
summary, and clears the active cart. Cart and order data are kept in memory and
reset when the app restarts or the browser reloads. Checkout is a local demo;
it does not process payments or send orders to a server.

## Structure

- `lib/theme/app_theme.dart`: shared theme builder and light/dark toggle.
- `lib/router/app_router.dart`: go_router routes and checkout guard.
- `lib/state/cart_controller.dart`: shared cart state and checkout logic.
- `lib/pages/`: home, product detail, cart, and confirmation screens.
- `lib/widgets/`: reusable product image, floating cart, and add-to-cart button.

Product cards, images, details, and receipts are stateless displays. `CartPage`
is stateful and listens for cart changes; `AddToCartButton` is stateful for its
temporary added feedback. Shared cart data uses `ChangeNotifier`, while the
existing app theme uses `ValueNotifier`.

## Verify

```sh
flutter analyze
flutter test
```

Tests cover quantities and totals using nonzero test prices, checkout protection,
receipt snapshots, navigation, theme changes, and phone/tablet layouts with
enlarged text. To regenerate the bundled placeholder images after changing the
catalog icons, run `flutter test tool/generate_product_images.dart`.
