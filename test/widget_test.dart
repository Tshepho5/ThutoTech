import 'package:flutter_test/flutter_test.dart';
import 'package:thutotech/main.dart';

void main() {
  testWidgets('ThutoTech smoke test - Renders Portal Sign In and Action Buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const ThutoTechApp());
    await tester.pumpAndSettle();

    expect(find.text('ThutoTech'), findsWidgets);
    expect(find.text('Portal Sign In'), findsOneWidget);
    expect(find.text('Apply for Admission'), findsOneWidget);
    expect(find.text('Complete Registration'), findsOneWidget);
  });
}
