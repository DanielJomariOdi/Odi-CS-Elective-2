# Odi Shop

Odi Shop is a Flutter shopping app with a Supabase-backed product catalog. It supports price filtering, paginated browsing, product details, and a shopping cart.

## Features

- Browse products stored in Supabase PostgreSQL.
- Filter products using a minimum–maximum price slider.
- View **6 products per page**, with Previous and Next navigation.
- Open product details and add items to a cart.
- Update cart quantities and view a checkout summary.
- Use responsive layouts and light/dark themes.

Price filtering and pagination are performed through **Supabase queries**, with `ChangeNotifier` managing the selected range, current page, and loading state.

## Tech Stack

- **Flutter / Dart** — user interface
- **Supabase** — product database
- **ChangeNotifier** — state management
- **go_router** — navigation

## Setup

1. Install Flutter and fetch dependencies:

   ```bash
   flutter pub get
   ```

2. Create a Supabase project and a `public.products` table with the following columns:

   | Column | Type |
   | --- | --- |
   | `id` | `text` (primary key) |
   | `name` | `text` |
   | `description` | `text` |
   | `price` | `numeric(10,2)` |

   Enable Row Level Security (RLS) and configure a public read policy. Add the nine sample products with IDs `product-1` through `product-9` to match the bundled images.

3. Create `supabase.config.json` in the project root:

   ```json
   {
     "SUPABASE_URL": "https://YOUR_PROJECT_ID.supabase.co",
     "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_YOUR_KEY"
   }
   ```

   Use your Supabase **publishable key**, not a secret or service-role key. Keep this local configuration file out of Git.

4. Run the app:

   ```bash
   flutter run -d chrome --dart-define-from-file=supabase.config.json
   ```

## Project Structure

```text
lib/
  main.dart                    App setup and Supabase initialization
  models/item.dart             Product model
  services/product_service.dart Supabase queries
  state/product_controller.dart Price filtering and pagination state
  state/cart_controller.dart    Shopping cart state
  pages/                       Shop, product details, cart, checkout
  router/app_router.dart        Navigation
assets/images/                  Product images
```

## Testing

```bash
flutter analyze
flutter test
```

**Note:** The product catalog is stored in Supabase. The cart and checkout confirmation remain local demonstration features; no payments are processed.
