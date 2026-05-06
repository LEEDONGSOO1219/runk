import 'package:flutter_test/flutter_test.dart';

import 'package:runk/main.dart';

void main() {
  testWidgets('shows auth screen first', (WidgetTester tester) async {
    await tester.pumpWidget(const RunkApp());

    expect(find.text('런크'), findsOneWidget);
    expect(find.text('러닝 시작하기'), findsOneWidget);
  });
}
