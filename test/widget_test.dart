import 'package:flutter_test/flutter_test.dart';
import 'package:unidentified_dead_body/main.dart';

void main() {
  testWidgets('UDBMS App mounts and switches language', (WidgetTester tester) async {
    await tester.pumpWidget(const UnidentifiedDeadBodyApp());
    await tester.pumpAndSettle();

    expect(find.text('UDBMS'), findsWidgets);
    expect(find.text('বাংলা'), findsWidgets);
    expect(find.text('English'), findsWidgets);

    // Tap English button
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Unidentified Deadbody Management System'), findsWidgets);

    // Tap Bangla button
    await tester.tap(find.text('বাংলা'));
    await tester.pumpAndSettle();

    expect(find.text('অজ্ঞাত মৃতদেহ ব্যবস্থাপনা পদ্ধতি'), findsWidgets);
  });
}
