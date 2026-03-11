import 'package:flutter_test/flutter_test.dart';
import 'package:enviora/main.dart';

void main() {
  testWidgets('Welcome page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EnvioraApp());

    // Verify that our welcome text is present.
    expect(find.text('Enviora'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
