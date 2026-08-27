// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:rehearsal_app/main.dart';

void main() {
  testWidgets('App renders login screen when unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(const RehearsalApp());
    await tester.pumpAndSettle();

    expect(find.text('Rehearsal'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
