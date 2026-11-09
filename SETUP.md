# Odi Shop: Supabase price filtering + pagination

This is an overlay of replacement/new files to apply on top of the **PrelimExam**
branch of https://github.com/DanielJomariOdi/Odi-CS-Elective-2.

The app now loads products from Supabase `public.products`, shows **six products
per page**, filters prices **on the server**, and tracks filtering/page state
with `ProductController extends ChangeNotifier`. Product details use Supabase too.
Cart and checkout remain local, as in the original PrelimExam app.

## Apply

1. Make sure all uncommitted work is saved. In the repo run:
   ```
   git switch PrelimExam
   git switch -c backend-filter-pagination
   ```
   (If your branch already exists, switch to it instead.)
2. Copy this overlay's `lib/` files into the matching paths of your Flutter repo,
   overwriting those files. Copy `test/support/` and `test/product_controller_test.dart`.
   Leave existing `lib/data/item_data.dart` for test fixtures.
3. From the Flutter project root run `flutter pub add supabase_flutter` then
   `flutter pub get`.
4. Copy `supabase.config.example.json` to `supabase.config.json` and fill in
   YOUR Supabase project URL and publishable key. Never use a secret/service-role
   key in a Flutter client. Add `/supabase.config.json` to `.gitignore`.
5. For Android release builds, add
   `<uses-permission android:name="android.permission.INTERNET" />`
   immediately under the root `<manifest>` in
   `android/app/src/main/AndroidManifest.xml`.
6. In `test/shop_flow_test.dart`, add this import:
   `import 'support/fake_product_service.dart';`
   Then change the router construction within `openShop()` from:
   `createAppRouter(cart, initialLocation: location)`
   to:
   `createAppRouter(cart, initialLocation: location, productService: FakeProductService())`
   This keeps widget tests isolated from your live database.
7. Run:
   ```
   dart format lib test
   flutter analyze
   flutter test
   flutter run -d chrome --dart-define-from-file=supabase.config.json
   ```
8. Confirm 6 products on page 1, 3 on page 2. Drag price slider to $100–$400:
   three products should match (phone, watch, console) and pagination resets to 1.
9. After validation, commit and push to `backend-filter-pagination`.

## Database prerequisites

Supabase public.products must have text `id`, text `name`, text `description`,
numeric `price` (the 9 demo records already populated). RLS enabled with
an appropriate public SELECT policy and SELECT grants for the client role.

## Notes

- Product IDs map to bundled images (`assets/images/product-1.png`, etc.).
- Filter bounds in UI are currently $0–$1000; change `lowerBound` and
  `upperBound` in `lib/state/product_controller.dart` if your catalogue
  later contains products outside that range.
- The provider ignores stale responses, preventing out-of-order network
  requests from overwriting a newer filter.
- This overlay has not been Flutter-analyzed in the authoring environment;
  run `flutter analyze` and `flutter test` locally before submission.
