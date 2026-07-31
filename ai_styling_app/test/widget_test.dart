import 'package:flutter_test/flutter_test.dart';
import 'package:ai_styling_app/main.dart';

void main() {
  testWidgets('AI Styling App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AIStylingApp());

    expect(find.text('AI Styling Agent'), findsOneWidget);
    expect(find.text('Upload User Image'), findsOneWidget);
    expect(find.text('Generate Outfit'), findsOneWidget);
  });
}