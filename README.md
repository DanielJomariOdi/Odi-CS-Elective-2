<<<<<<< Updated upstream
# act_1

A new Flutter project.
=======
# Pokédex Provider Activity

A Flutter Pokédex showing the first 30 Pokémon, from Bulbasaur (#001) through
Nidorina (#030). Each card shows the Pokémon's name, image, and ID. Select a
card to open its details page, then use **Back to collection** to return.
The grid and details page share their data through Provider.

## Run in VS Code

1. Open the `Odi-CS-Elective-2` folder directly in VS Code. This folder contains
   `pubspec.yaml` and is the Flutter project root.
2. Enable the Flutter and Dart extensions.
3. Open **Run and Debug** and choose **Flutter: Chrome**.
4. Press **F5** to start the app.

An internet connection is needed for PokéAPI requests and Pokémon artwork.
Use **Flutter: Hot Reload** from the Command Palette after editing Dart files.
For another target, select **Flutter: Selected Device** and choose a device
with **Flutter: Select Device**.

From a terminal in the project root:

```powershell
flutter pub get
flutter run -d chrome
```

## How Provider manages the app

`ChangeNotifierProvider<PokemonProvider>` wraps `MaterialApp`, making the same
provider available to both screens. It creates the provider, starts the initial
fetch, and disposes the provider when removed from the widget tree.

`PokemonProvider` extends `ChangeNotifier` and holds the Pokémon list, loading
state, error message, and selected Pokémon ID. It calls `notifyListeners()` when
the state changes. The grid uses `Consumer<PokemonProvider>` and the details
page uses `context.watch<PokemonProvider>()` to rebuild from that shared state.

The details route does not receive a copied Pokémon. Instead, the provider's
`selectedPokemon` resolves the selected ID against the current list. This keeps
the details page in sync when the list is refreshed. A missing selection shows
a Pokémon-not-found message.

| Provider method | Purpose |
| --- | --- |
| `fetchPokemon()` | Load the collection, using the service's cached list when available. |
| `refresh()` | Request a fresh list for refresh and retry actions. |
| `selectPokemon(id)` | Select a Pokémon before opening its details page. |

The UI handles loading, successful results, empty results, and request errors.
Concurrent fetch calls share the pending request. The provider ignores results
after disposal and closes the service it creates. An injected service remains
owned by its caller.

## Future-based API requests

`PokemonService` keeps the HTTP and JSON parsing logic outside the widgets.
Its `fetchPokemon()` returns a `Future<List<Pokemon>>` because a request completes
with one result or an error. The provider awaits that result and updates shared
state; Provider then informs the listening widgets.

The service makes one list request to
[`/api/v2/pokemon?limit=30&offset=0`](https://pokeapi.co/api/v2/pokemon?limit=30&offset=0)
and caps the result at 30 entries. The model contains `id`, `name`, and
`imageUrl`. IDs are read from the API resource URLs and used to construct the
official artwork URLs. Images load separately as the grid and details page
display them.

The successful list is cached in memory for the service's lifetime. Refresh
bypasses that cache. Request failures show a readable message and a retry
action; unavailable artwork has an image fallback.

## Project structure

```text
lib/
  main.dart          App entry point, ChangeNotifierProvider, and theme
  models/            Pokémon data and API parsing
  providers/         PokemonProvider and shared loading/selection state
  services/          HTTP requests and session cache
  widgets/           Reusable Pokémon cards and state components
  screens/           Pokédex grid and individual Pokémon page
```
>>>>>>> Stashed changes
