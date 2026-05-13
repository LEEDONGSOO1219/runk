import 'package:flutter_test/flutter_test.dart';
import 'package:runk/main.dart';

void main() {
  testWidgets('renders app splash', (tester) async {
    await tester.pumpWidget(const RunkApp());
    expect(find.text('RunK'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1300));
  });
}
