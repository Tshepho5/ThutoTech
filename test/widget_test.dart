import 'package:flutter_test/flutter_test.dart';
import 'package:thutotech/main.dart';

void main() {
  testWidgets('ThutoTech smoke test - App renders role switcher and portals', (WidgetTester tester) async {
    await tester.pumpWidget(const ThutoTechApp());
    await tester.pumpAndSettle();

    expect(find.text('ThutoTech'), findsWidgets);
    expect(find.byTooltip('Apply for Admission'), findsOneWidget);
    expect(find.byTooltip('Complete Registration'), findsOneWidget);
  });
}
