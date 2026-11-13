# Odi Shop

Odi Shop is a Flutter shopping application with a Supabase-backed product catalog, server-side price filtering and pagination, a shopping cart, and Google authentication through Supabase Auth.

## Features

- Browse products stored in Supabase PostgreSQL.
- Filter by minimum and maximum price; queries run in Supabase.
- Navigate a paginated product catalog (**6 products per page**).
- View product details, manage cart quantities, and complete a local demo checkout.
- Sign in with a Google account, view the signed-in profile, and sign out.
- Use responsive layouts and light/dark themes.

The product catalog is read from Supabase. Cart contents and checkout confirmation are local demonstration features; payment processing is not included. Customers can browse products without signing in.

## Tech Stack

- **Flutter / Dart** — UI
- **Supabase** — PostgreSQL product catalog and Google OAuth authentication
- **ChangeNotifier** — product, cart, and authentication state
- **go_router** — navigation

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Set up the product catalog

Create a Supabase project and a `public.products` table with `id` (text primary key), `name` (text), `description` (text), and `price` (numeric). Enable Row Level Security and a public read policy for the demo catalog. Insert the nine sample products with IDs `product-1` through `product-9` to use the bundled images.

### 3. Add the Supabase client configuration

Create `supabase.config.json` in the project root:

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_ID.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_YOUR_KEY"
}
```

Use only the publishable key in Flutter. This file is ignored by Git.

### 4. Configure Google OAuth

1. In [Google Cloud Console](https://console.cloud.google.com/), configure the Google Auth Platform consent screen and audience. While in Testing mode, add intended Google accounts as test users.
2. Create an **OAuth client ID** of type **Web application**. Set an authorized JavaScript origin of `http://localhost:3000` for the local web build.
3. Set the **Authorized redirect URI** to the Supabase callback shown in **Supabase Dashboard → Authentication → Sign In / Providers → Google**. For a standard hosted project it is `https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback`.
4. Copy the Google OAuth **Client ID** and **Client Secret** into the Supabase Google provider settings, enable the provider, and save. The Google Client Secret belongs in Supabase only, **never in the Flutter app or Git**.
5. In **Supabase → Authentication → URL Configuration**, use `http://localhost:3000` as the development **Site URL**. Add `http://localhost:3000/**` and `io.odishop.app://login-callback/` to the permitted redirect URLs.
6. Android and iOS callback handling is included in this repository. The mobile redirect URL is defined in `lib/state/auth_controller.dart` and must match the Supabase allow list.

For deployment, replace development origins and callback allow-list entries with the actual application domains.

### 5. Run the app

Flutter Web (fixed port for Google OAuth):

```bash
flutter run -d chrome --web-port 3000 --dart-define-from-file=supabase.config.json
```

Android:

```bash
flutter run -d android --dart-define-from-file=supabase.config.json
```

If needed, run `flutter devices` and specify the ID of your connected device instead of `android`.

To sign in, select the account icon on the shop page and choose **Continue with Google**.

## Project Structure

```text
lib/
  main.dart                    Supabase client and application initialization
  models/item.dart             Product model
  services/product_service.dart Supabase catalog queries
  state/product_controller.dart Price filtering and pagination state
  state/cart_controller.dart    Local cart and checkout state
  state/auth_controller.dart    Google OAuth and auth session state
  pages/                       Catalog, product details, cart, account, checkout
  router/app_router.dart        go_router configuration
assets/images/                  Bundled product images
```

## Testing

```bash
flutter analyze
flutter test
```

Verify Google sign-in manually using a configured test account: open Account, select **Continue with Google**, complete Google consent, confirm the account details appear, and sign out. On mobile, confirm the browser returns to the app after authentication.
