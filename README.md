# Odi Shop — Supabase Price Filter & Pagination

Odi Shop is a Flutter shopping app built for **CS Elective 2 (Mobile App Development)**. This version extends the original **PrelimExam** shopping application with a Supabase-hosted product catalog, server-side price filtering, and paginated product browsing.

> **Assignment branch:** `backend-filter-pagination`  
> **Source branch:** `PrelimExam`

## Features

- **Product catalog from Supabase:** product IDs, names, descriptions, and prices are queried from the `public.products` table.
- **Price range filter:** customers select a minimum and maximum price using a Flutter `RangeSlider` (currently **$0–$1,000**). The product query is sent when they finish dragging the slider.
- **Server-side pagination:** **6 products per page**, using a Supabase `.range(start, end)` query rather than paginating a locally downloaded catalog.
- **Accurate page count:** Supabase's exact matching-row count powers the page indicator and Previous/Next button states.
- **State management:** `ProductController extends ChangeNotifier` coordinates filtering, pagination, loading, errors, and empty results. It ignores stale responses when newer requests finish first.
- **Product details:** tapping a card fetches the selected product by ID from Supabase.
- **Existing shopping flow:** add-to-cart controls, quantity editing, cart totals, local checkout confirmation, light/dark themes, and responsive layouts are retained from `PrelimExam`.

**Scope:** Product listing and details are database-backed; **cart state, checkout, and order confirmation remain local/in-memory**. The demo does not process payments or persist orders. Product images remain bundled Flutter assets; Supabase Storage is not required. Product editing and deletion are not added by this filter/pagination patch.

## Tech stack

| Layer | Technology |
| --- | --- |
| Frontend | Flutter / Dart (Material 3) |
| Routing | `go_router` |
| Product state | `ChangeNotifier` + `AnimatedBuilder` |
| Cart state | Existing `CartController extends ChangeNotifier` |
| Backend | Supabase (PostgreSQL and Flutter client SDK) |
| Images | Bundled `assets/images/product-*.png` |
| Tests | `flutter_test`, with a fake product service |

## Project structure

```text
lib/
  main.dart                       Supabase initialization and app entry point
  models/item.dart                Item model and Supabase JSON parsing
  data/item_data.dart             Original local sample data (test fixtures)
  services/product_service.dart   Database filtering, paging, and item lookup
  state/product_controller.dart   Price range, page number, async UI state
  state/cart_controller.dart      Local cart and checkout state
  pages/home_page.dart            Price slider, product grid, paging controls
  pages/item_detail_page.dart     Database-backed product details
  pages/cart_page.dart            Cart and quantity controls
  pages/checkout_confirmation_page.dart
  router/app_router.dart          App routes
  widgets/                       Product cards, images, and cart controls
test/
  product_controller_test.dart
  support/fake_product_service.dart
  shop_flow_test.dart
  cart_controller_test.dart
assets/images/                     Bundled item artwork
supabase.config.example.json      Safe placeholder configuration
```

## Prerequisites

1. Flutter SDK and Dart compatible with the project's `pubspec.yaml` (Dart SDK `>=3.12.0 <4.0.0`).
2. An existing Supabase project with a populated `public.products` table.
3. The packages from `pubspec.yaml`, including `go_router` and `supabase_flutter`.
4. A browser (Chrome) or supported Flutter device/emulator with network access.

## 1. Set up the Flutter branch

From the repository root, save any current work, then create the assignment branch from `PrelimExam` if it does not exist:

```powershell
git switch PrelimExam
git switch -c backend-filter-pagination
flutter pub add supabase_flutter
flutter pub get
```

If the branch already exists, use `git switch backend-filter-pagination` instead of creating it again.

## 2. Configure the Supabase connection

Create `supabase.config.json` **next to `pubspec.yaml`**, using this example:

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_ID.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_YOUR_KEY"
}
```

Replace both placeholders with the **Project URL** and **publishable key** from your Supabase project's API/Connect settings. These values are passed as Dart compile-time defines and read by `lib/main.dart` before `Supabase.initialize(...)` runs.

Add this entry to the root `.gitignore`:

```gitignore
/supabase.config.json
```

**Security:** Use only the client-side *publishable* key. Never put your database password, Supabase secret key, or `service_role` key in the Flutter app or Git. Client-side access depends on properly configured PostgreSQL permissions and Row Level Security (RLS).

To verify that the local config file exists:

```powershell
Test-Path .\supabase.config.json
```

It should print `True`.

## 3. Database requirements

The application reads a Supabase table named `public.products` with the following fields:

| Column | SQL type | Notes |
| --- | --- | --- |
| `id` | `text` | Primary key, e.g. `product-1` |
| `name` | `text` | Product display name |
| `description` | `text` | Product description |
| `price` | `numeric(10,2)` | Nonnegative product price |

The table must have **RLS enabled**, an appropriate policy for public `SELECT`, and `SELECT` granted to the client role. The app currently only reads records; do not grant anonymous write permissions to meet the filtering/pagination activity.

The demonstration catalogue contains **9 products** matching the `PrelimExam` product IDs and bundled images: Phone, Tablet, Laptop, Headset, Watch, Camera, Console, Speaker, and a ninth placeholder item. Seed these records in Supabase before running the app.

## 4. Run the application

From the Flutter project root:

```powershell
flutter pub get
flutter run -d chrome --dart-define-from-file=supabase.config.json
```

For other supported Flutter devices, change the `-d` target. Android release builds require the INTERNET permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Place the permission directly inside the `<manifest>` element, outside `<application>`.

## How the filter and pagination work

`ProductService.fetchPage` sends an ordered, price-filtered query directly to Supabase:

```dart
final start = (page - 1) * pageSize;
final end = start + pageSize - 1;

final response = await _db
    .from('products')
    .select('id, name, description, price')
    .gte('price', minPrice)
    .lte('price', maxPrice)
    .order('id', ascending: true)
    .range(start, end)
    .count(CountOption.exact);
```

- `.gte` and `.lte` enforce the inclusive price range **in the database**.
- `.order('id')` makes page boundaries deterministic for a static catalogue.
- `.range(start, end)` requests only the current page, with an **inclusive** end index.
- `.count(CountOption.exact)` returns the total number of products matching the same price filter, for page controls.

`ProductController` stores the selected range, current page, matching count, loading state, and any error. Moving the slider resets pagination to page 1. Previous/Next are disabled when the requested page is unavailable. A retry option is displayed for failed requests, and an empty-state message is displayed if no products match.

For 9 records and **6 products per page**:

| Page | Supabase range | Expected products |
| --- | --- | --- |
| 1 | `.range(0, 5)` | 6 |
| 2 | `.range(6, 11)` | 3 |

Example price range **$100–$400**: the Phone ($299.99), Watch ($129.99), and Console ($399.99) match, leaving a single page of three products.

## Verification and tests

Run these from the repository root:

```powershell
dart format lib test
flutter analyze
flutter test
flutter run -d chrome --dart-define-from-file=supabase.config.json
```

Manual acceptance checks:

- [ ] Six products appear on page 1; three appear on page 2.
- [ ] Previous/Next buttons navigate correctly and stop at page boundaries.
- [ ] Selecting $100–$400 displays only Phone, Watch, and Console.
- [ ] Changing the price filter while on page 2 resets to page 1.
- [ ] An empty price range shows a readable empty state.
- [ ] Product details open, and cart quantity changes still work.
- [ ] Dark/light mode, cart summary, and local checkout continue to work.
- [ ] No analyzer errors or failing tests remain before submission.

Unit/widget tests inject `FakeProductService` so test runs **do not contact the live Supabase project**. The original local `lib/data/item_data.dart` remains as test data. Existing shopping-flow tests must pass the fake to `createAppRouter(...)` and, if a smaller viewport hides a product card, scroll the target into view before tapping it.

**Validation status:** A prior local run reported analyzer diagnostics and one widget-test failure caused by an off-screen tap; a later correction patch was provided, but a fully passing run has **not yet been confirmed**. Re-run the commands above and resolve any remaining issues before submitting.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| `Did not find the file passed to --dart-define-from-file` | Ensure `supabase.config.json` exists beside `pubspec.yaml`, and run the command from that directory. |
| `Missing Supabase configuration` | Check both JSON keys, their values, and the run command's `--dart-define-from-file` flag. |
| Empty product list | Confirm the nine rows are in `public.products` and RLS permits the client role to select them. |
| Supabase permission/authorization errors | Check public SELECT policy and grants, but do not disable RLS to hide the problem. |
| Test tap misses a product | Use `tester.ensureVisible(...)` or `tester.scrollUntilVisible(...)` before `tester.tap(...)`. |
| Test requires a real Supabase connection | Inject `FakeProductService` into `createAppRouter` in the widget-test setup. |

## Submission

When local verification succeeds, push the **new** assignment branch:

```powershell
git status
git add .
git commit -m "Implement Supabase price filtering and pagination"
git push -u origin backend-filter-pagination
```

Submit this branch URL to the activity's Daigler submission bin:

https://github.com/DanielJomariOdi/Odi-CS-Elective-2/tree/backend-filter-pagination

The URL will resolve after the branch is pushed. Keep `supabase.config.json` untracked and do not push any secret keys.
