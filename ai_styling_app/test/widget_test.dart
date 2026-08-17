import 'package:flutter_test/flutter_test.dart';

import 'package:ai_styling_app/main.dart';

void main() {
  testWidgets(
    'AI Personal Styling Consultant loads',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const AIStylingApp(),
      );

      expect(
        find.text(
          'AI Personal\nStyling Consultant',
        ),
        findsOneWidget,
      );

      expect(
        find.text('Continue'),
        findsOneWidget,
      );

      expect(
        find.text('Personal Wardrobe'),
        findsOneWidget,
      );
    },
  );
}