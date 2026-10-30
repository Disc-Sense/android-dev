import 'package:flutter_test/flutter_test.dart';

import 'package:disc_sense/main.dart';

void main() {
  testWidgets('navigates between the app pages', (WidgetTester tester) async {
    await tester.pumpWidget(const DiscSenseApp());

    expect(find.text('Disc Sense'), findsOneWidget);
    expect(find.text('Record game stats'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Game statistics'), findsOneWidget);
    expect(find.text('Points'), findsOneWidget);

    await tester.tap(find.text('Record'));
    await tester.pumpAndSettle();
    expect(find.text('Record video'), findsOneWidget);
    expect(find.text('Start recording'), findsOneWidget);
  });
}
