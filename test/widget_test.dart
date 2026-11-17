import 'package:flutter_test/flutter_test.dart';
import 'package:unidentified_dead_body/main.dart';

void main() {
  testWidgets('CID UDB App mounts smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UnidentifiedDeadBodyApp());
    await tester.pumpAndSettle();

    expect(find.text('CID BANGLADESH'), findsWidgets);
  });
}
