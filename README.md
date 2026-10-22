# Pokédex Midterm

A Flutter Pokédex for the first 30 Pokémon, from Bulbasaur (#001) through
Nidorina (#030). The grid and individual Pokémon pages share immutable app
state through Riverpod.

## Midterm features

- **Pokémon List Management:** load the first 30 Pokémon, select one for its
  individual page, and request fresh list data with the notifier's `fetch()`
  method. The UI handles loading, success, empty results, and errors.
- **Pokémon Nickname Editor:** give a Pokémon a nickname, change it, or remove
  it. Names are trimmed and limited to 24 characters. Saving an empty nickname
  restores the Pokémon's original display name.
- **Favorite Pokémon/s:** expand or collapse the favorites panel on either
  page. It shows favorites from the full loaded collection, independent of
  the grid filter.
- **Favorite Indicator:** use a card's heart to toggle its favorite status.
  Every view uses the same set of favorite IDs.
- **Pokémon Type Filter:** show Pokémon matching a selected type, or choose
  all types. A Pokémon with two types matches either type. Filter options
  come from the loaded API data.

Nicknames, favorites, the selected type, the panel's expanded state, and the
selected Pokémon stay intact during a refresh, including a failed refresh.
They are kept for the current app session; they are not saved to device storage.

## Run in VS Code

1. Open `Flutter Exam Project.code-workspace` in the parent directory, or open
   this `pokedex` folder directly in VS Code.
2. Enable the Flutter and Dart extensions.
3. Open **Run and Debug** and choose **Flutter: Chrome**.
4. Press **F5** to start the app.

An internet connection is needed for PokéAPI requests and Pokémon artwork.
Use **Flutter: Hot Reload** from the Command Palette after editing Dart files.
For another target, select **Flutter: Selected Device** and choose a device
with **Flutter: Select Device**.

From a terminal in the `pokedex` folder:

```powershell
flutter pub get
flutter run -d chrome
```

## How Riverpod manages the app

`ProviderScope` at the app entry point makes the shared providers available to
the screens. `pokedexProvider` is a
`NotifierProvider<PokedexNotifier, PokedexState>`. Widgets watch it to display
the latest state and read its notifier to perform actions.

`PokedexState` holds the Pokémon list, request status, error message, nicknames,
favorite IDs, selected Pokémon ID, selected type, and favorites panel state.
Its collections are unmodifiable. Each change creates a new state snapshot,
so widgets react to the update without manually calling `notifyListeners()`.

Derived values such as the filtered grid, favorites collection, type options,
and selected Pokémon are calculated from that shared state. The details page
resolves the selected ID against the current Pokémon list; a missing selection
shows a Pokémon-not-found state. The route does not carry a copied Pokémon.

| Notifier method | Purpose |
| --- | --- |
| `fetch()` | Load fresh API data, including refresh and retry. |
| `selectPokemon(id)` | Select a Pokémon for the details page. |
| `setNickname(id, nickname)` | Save a trimmed nickname of up to 24 characters; an empty value removes it. |
| `removeNickname(id)` | Restore the original Pokémon name. |
| `toggleFavorite(id)` | Add or remove the Pokémon's ID from favorites. |
| `setTypeFilter(type)` | Filter the grid by type; `null` shows all types. |
| `toggleFavoritesPanel()` | Expand or collapse the favorites panel. |

The notifier schedules one initial fetch after installing its initial state.
Concurrent fetch calls share the same pending request. Every new fetch calls
`PokemonService.fetchPokemon(forceRefresh: true)`, so refresh repeats the list
API request instead of returning the cached list. The notifier applies results
only while its Riverpod reference is mounted. `pokemonServiceProvider` owns
the service and closes its HTTP client when disposed.

Riverpod separates UI rendering, app state changes, and API access. All shared
app-state mutations go through the notifier; widgets do not directly alter
maps, sets, or API data. A `Future` represents each request because it completes
with a single result, while Riverpod distributes the resulting state to all
interested widgets.

## Pokémon data and types

The service first requests
[`/api/v2/pokemon?limit=30&offset=0`](https://pokeapi.co/api/v2/pokemon?limit=30&offset=0)
and caps the result at 30 entries. It then fetches uncached Pokémon detail data
in batches of at most six requests. Those detail responses provide the actual
`types` values; types are not guessed from the Pokémon's name or hardcoded by ID.

The `Pokemon` model contains `id`, `name`, `imageUrl`, and `types`. Artwork
loads separately from the official artwork path in the PokéAPI sprites
repository. Loading errors produce a readable message and retry action;
unavailable images have a fallback in the UI.

The service caches successful lists and detail responses in memory for its
lifetime. The notifier's `fetch()` bypasses the list cache, while successful
detail responses can be reused to avoid fetching the same types again. Neither
cache is saved across app restarts.

## Project structure

```text
lib/
  main.dart          App entry point, ProviderScope, and theme
  models/            Pokémon data and API parsing
  providers/         Immutable PokedexState and Riverpod notifier
  services/          HTTP requests, type details, and session cache
  widgets/           Reusable Pokémon cards and state components
  screens/           Pokédex grid and individual Pokémon page
```

## Validation scope

Formatting and static analysis are the lightweight checks planned for this
update. Full automated tests, browser verification, and release builds are
deferred until requested. No passing test or build result is claimed for this
midterm version.
