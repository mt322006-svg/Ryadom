import 'package:flutter_test/flutter_test.dart';

import 'package:ryadom_app/app/app.dart';

void main() {
  testWidgets('shows Ryadom MVP home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RyadomApp());

    expect(find.text('Рядом'), findsWidgets);
    expect(find.text('Нужна помощь'), findsOneWidget);
    expect(find.text('Могу помочь'), findsOneWidget);
    expect(find.text('Помощь рядом,\nкогда она нужна сейчас'), findsOneWidget);
  });
}
