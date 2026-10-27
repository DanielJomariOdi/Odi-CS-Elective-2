import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/providers/pokemon_provider.dart';
import 'package:pokedex/screens/pokedex_screen.dart';
import 'package:pokedex/screens/pokemon_details_screen.dart';
import 'package:pokedex/services/pokemon_service.dart';
import 'package:provider/provider.dart';

List<Pokemon> _pokemon({int count = 1, String firstName = 'bulbasaur'}) =>
    List.generate(count, (index) {
      final id = index + 1;
      return Pokemon(
        id: id,
        name: switch (id) {
          1 => firstName,
          30 => 'nidorina',
          _ => 'pokemon-$id',
        },
        imageUrl: 'https://example.com/$id.png',
      );
    });

class _FakePokemonService extends PokemonService {
  _FakePokemonService(this.respond);

  final Future<List<Pokemon>> Function() respond;
  int fetches = 0;

  @override
  Future<List<Pokemon>> fetchPokemon({bool forceRefresh = false}) {
    fetches++;
    return respond();
  }
}

_FakePokemonService _service(Future<List<Pokemon>> Function() respond) {
  final service = _FakePokemonService(respond);
  addTearDown(service.close);
  return service;
}

PokemonProvider _provider(PokemonService service) {
  final provider = PokemonProvider(service: service);
  addTearDown(provider.dispose);
  unawaited(provider.fetchPokemon());
  return provider;
}

Widget _app(
  PokemonProvider provider, {
  NavigatorObserver? observer,
  Widget home = const PokedexScreen(),
  double textScale = 1,
}) => ChangeNotifierProvider<PokemonProvider>.value(
  value: provider,
  child: MaterialApp(
    navigatorObservers: [?observer],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  ),
);

class _NavigationObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}

Finder get _gridScroll => find.descendant(
  of: find.byType(CustomScrollView),
  matching: find.byType(Scrollable),
);

void main() {
  testWidgets('shows loading and prevents a duplicate refresh request', (
    tester,
  ) async {
    final response = Completer<List<Pokemon>>();
    final service = _service(() => response.future);
    final provider = _provider(service);

    await tester.pumpWidget(_app(provider));
    await tester.pump();

    expect(find.text('Finding Pokémon…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('pokemon-grid')), findsNothing);
    expect(service.fetches, 1);

    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();
    expect(service.fetches, 1);

    response.complete(_pokemon());
    await tester.pumpAndSettle();
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows an API error and retries successfully', (tester) async {
    var requests = 0;
    final service = _service(() async {
      if (++requests == 1) {
        throw const PokemonServiceException(
          'PokéAPI is unavailable (HTTP 503).',
        );
      }
      return _pokemon();
    });
    final provider = _provider(service);

    await tester.pumpWidget(_app(provider));
    await tester.pumpAndSettle();

    expect(find.text('Couldn’t load the Pokédex'), findsOneWidget);
    expect(find.byKey(const Key('pokemon-grid')), findsNothing);

    final retry = find.widgetWithText(FilledButton, 'Try again');
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(service.fetches, 2);
    expect(find.text('Couldn’t load the Pokédex'), findsNothing);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('#001'), findsOneWidget);
  });

  testWidgets('shows an empty state with a working retry', (tester) async {
    var requests = 0;
    final service = _service(
      () async => _pokemon(count: ++requests == 1 ? 0 : 1),
    );
    final provider = _provider(service);

    await tester.pumpWidget(_app(provider));
    await tester.pumpAndSettle();
    expect(find.text('No Pokémon found'), findsOneWidget);
    expect(find.byKey(const Key('pokemon-grid')), findsNothing);

    final retry = find.widgetWithText(FilledButton, 'Try again');
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(service.fetches, 2);
    expect(find.text('No Pokémon found'), findsNothing);
    expect(find.byKey(const Key('pokemon-1')), findsOneWidget);
  });

  testWidgets('scrolls through 30 Pokémon, opens details, and returns', (
    tester,
  ) async {
    final service = _service(() async => _pokemon(count: 30));
    final provider = _provider(service);
    final observer = _NavigationObserver();

    await tester.pumpWidget(_app(provider, observer: observer));
    await tester.pumpAndSettle();
    final initialPushes = observer.pushes;

    expect(find.byKey(const Key('pokemon-grid')), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('pokemon-30')),
      350,
      scrollable: _gridScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pokemon-30')));
    await tester.pumpAndSettle();

    expect(observer.pushes, initialPushes + 1);
    expect(find.byType(PokemonDetailsScreen), findsOneWidget);
    expect(find.byKey(const Key('pokemon-grid')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-name'))).data,
      'Nidorina',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-id'))).data,
      '#030',
    );
    final artwork = tester.widget<Image>(find.byKey(const Key('detail-image')));
    expect(
      (artwork.image as NetworkImage).url,
      provider.selectedPokemon!.imageUrl,
    );
    expect(provider.selectedPokemon!.id, 30);
    expect(service.fetches, 1);

    await tester.tap(find.byKey(const Key('back-to-collection')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pokemon-grid')), findsOneWidget);
    expect(find.byType(PokemonDetailsScreen), findsNothing);
    expect(find.text('Nidorina'), findsOneWidget);
    expect(service.fetches, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rebuilding the screen does not fetch again', (tester) async {
    final service = _service(() async => _pokemon());
    final provider = _provider(service);

    await tester.pumpWidget(_app(provider));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app(provider));
    await tester.pumpAndSettle();

    expect(service.fetches, 1);
    expect(find.text('Bulbasaur'), findsOneWidget);
  });

  testWidgets('refresh shows loading until fresh data arrives', (tester) async {
    var requests = 0;
    final response = Completer<List<Pokemon>>();
    final service = _service(
      () => ++requests == 1 ? Future.value(_pokemon()) : response.future,
    );
    final provider = _provider(service);

    await tester.pumpWidget(_app(provider));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();

    expect(service.fetches, 2);
    expect(find.text('Finding Pokémon…'), findsOneWidget);

    response.complete(_pokemon(count: 2));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pokemon-2')), findsOneWidget);
    expect(find.text('Finding Pokémon…'), findsNothing);
  });

  testWidgets('fits a narrow screen with enlarged text without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _service(() async => _pokemon(count: 30));
    final provider = _provider(service);

    await tester.pumpWidget(_app(provider, textScale: 1.4));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('pokemon-1')),
      250,
      scrollable: _gridScroll,
    );
    await tester.pumpAndSettle();

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('pokemon-30')),
      350,
      scrollable: _gridScroll,
    );
    await tester.pumpAndSettle();
    expect(find.text('Nidorina'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('pokemon-30')));
    await tester.pumpAndSettle();
    expect(find.byType(PokemonDetailsScreen), findsOneWidget);
    expect(find.byKey(const Key('detail-name')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details rebuild when the selected record changes', (
    tester,
  ) async {
    var firstName = 'bulbasaur';
    final service = _service(() async => _pokemon(firstName: firstName));
    final provider = _provider(service);

    await tester.pumpWidget(_app(provider));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('pokemon-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pokemon-1')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('detail-name'))).data,
      'Bulbasaur',
    );
    firstName = 'updated-bulbasaur';
    await provider.refresh();
    await tester.pumpAndSettle();

    expect(service.fetches, 2);
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-name'))).data,
      'Updated Bulbasaur',
    );
    expect(provider.selectedPokemon!.name, firstName);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details handle a missing selection gracefully', (tester) async {
    final service = _service(() async => _pokemon());
    final provider = _provider(service);

    await tester.pumpWidget(_app(provider, home: const PokemonDetailsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Pokémon not found'), findsOneWidget);
    expect(find.byKey(const Key('detail-name')), findsNothing);
    expect(find.byKey(const Key('detail-image')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
