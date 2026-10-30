import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:disc_sense/main.dart';
import 'package:disc_sense/stats_page.dart';

void main() {
  testWidgets('navigates between the app pages', (WidgetTester tester) async {
    await tester.pumpWidget(const DiscSenseApp());

    expect(find.text('Disc Sense'), findsOneWidget);
    expect(find.text('Record game stats'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Game statistics'), findsOneWidget);
    expect(find.text('Points'), findsOneWidget);

    await tester.tap(find.text('Record'));
    await tester.pumpAndSettle();
    expect(find.text('Record video'), findsOneWidget);
    expect(find.text('Start recording'), findsOneWidget);
  });

  testWidgets('adds players and saves a game', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: StatsPage()));

    await tester.tap(find.text('Add player to game'));
    await tester.pump();
    expect(find.bySemanticsLabel('Player name'), findsOneWidget);

    await tester.enterText(find.bySemanticsLabel('Player name'), 'Alex');
    await tester.enterText(find.bySemanticsLabel('Team or opponent'), 'Rivals');
    await tester.tap(find.text('Add player'));
    await tester.pump();

    expect(find.text('Players in game (1)'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);

    final saveGameButton = find.text('Save game');
    await tester.scrollUntilVisible(
      saveGameButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveGameButton);
    await tester.pump();

    expect(find.text('Saved games'), findsOneWidget);
    expect(find.text('vs. Rivals'), findsOneWidget);
  });

  testWidgets('rejects duplicate names and edits selected player stats', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: StatsPage()));

    Future<void> addPlayer(String name) async {
      await tester.tap(find.text('Add player to game'));
      await tester.pump();
      await tester.enterText(find.bySemanticsLabel('Player name'), name);
      await tester.tap(find.text('Add player'));
      await tester.pump();
    }

    await addPlayer('Alex');
    await addPlayer('alex');

    expect(find.text('Players in game (1)'), findsOneWidget);
    expect(
      find.text('A player with that name already exists.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Alex'));
    await tester.pump();
    final pointsAddButton = find.byIcon(Icons.add_circle_outline).first;
    await tester.tap(pointsAddButton);
    await tester.pump();

    expect(find.textContaining('Pts - 1'), findsOneWidget);
  });
}
