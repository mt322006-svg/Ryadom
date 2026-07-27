import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ryadom/app/app.dart';
import 'package:ryadom/theme/ryadom_app_theme.dart';
import 'package:ryadom/features/nostr/data/local_nostr_request_store.dart';
import 'package:ryadom/features/nostr/data/we_ryadom_nostr_gateway.dart';

import 'support/ryadom_test_store.dart';

Future<void> _pumpUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _pumpRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _openRequestsTab(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.receipt_long_rounded));
  await _pumpUi(tester);
}

RyadomApp _buildTestApp({LocalNostrRequestStore? requestStore}) {
  return RyadomApp(
    nostrGateway: DisabledWeRyadomNostrGateway(),
    requestStore: requestStore ?? LocalNostrRequestStore.testOnly(),
    initialAppTheme: RyadomAppTheme.night,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows Мы Рядом MVP home screen', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await _pumpUi(tester);

    expect(find.text('Мы Рядом'), findsWidgets);
    expect(find.text('Помощь рядом'), findsOneWidget);
    expect(find.text('Радар'), findsWidgets);
    expect(find.byTooltip('Нужна помощь'), findsOneWidget);
  });

  testWidgets('opens request creation flow', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await _pumpUi(tester);

    await tester.tap(find.byTooltip('Нужна помощь'));
    await _pumpUi(tester);

    expect(
      find.textContaining('Собери короткий понятный сигнал'),
      findsOneWidget,
    );
    expect(find.text('Что нужно'), findsOneWidget);
  });

  testWidgets('publishes a local request to the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await _pumpUi(tester);

    await tester.tap(find.byTooltip('Нужна помощь'));
    await _pumpUi(tester);

    await tester.enterText(
      find.byType(TextField).first,
      'Нужно помочь донести коробки',
    );
    await tester.scrollUntilVisible(
      find.text('Опубликовать запрос'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Опубликовать запрос'));
    await _pumpUi(tester);
    await _openRequestsTab(tester);

    expect(find.text('Нужно помочь донести коробки'), findsWidgets);
  });

  testWidgets('opens request details from activity list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp(requestStore: createWidgetTestStore()));
    await _pumpUi(tester);
    await _openRequestsTab(tester);

    await tester.scrollUntilVisible(
      find.text('Прикурить автомобиль'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Прикурить автомобиль').last);
    await _pumpUi(tester);

    expect(find.text('Откликнуться'), findsOneWidget);
    expect(find.text('Рядом с ТЦ Гринвич'), findsWidgets);
    expect(find.textContaining('Не отправляй деньги заранее'), findsOneWidget);
  });

  testWidgets('responds to a nearby request', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(requestStore: createWidgetTestStore()));
    await _pumpUi(tester);
    await _openRequestsTab(tester);

    await tester.scrollUntilVisible(
      find.text('Прикурить автомобиль'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Прикурить автомобиль').last);
    await _pumpUi(tester);

    await tester.ensureVisible(find.text('Откликнуться'));
    await tester.tap(find.text('Откликнуться'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Автор запроса'), findsWidgets);

    await tester.tap(find.byType(BackButton));
    await tester.pump(const Duration(seconds: 2));

    expect(find.textContaining('ты откликнулся'), findsWidgets);
  });

  testWidgets('opens chat after responding to a request', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp(requestStore: createWidgetTestStore()));
    await _pumpUi(tester);
    await _openRequestsTab(tester);

    await tester.scrollUntilVisible(
      find.text('Прикурить автомобиль'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Прикурить автомобиль').last);
    await _pumpUi(tester);

    await tester.ensureVisible(find.text('Откликнуться'));
    await tester.tap(find.text('Откликнуться'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Автор запроса'), findsWidgets);
    expect(find.text('Я рядом'), findsWidgets);
    expect(find.text('Без предоплаты'), findsOneWidget);
  });

  testWidgets('opens chat from own requests card', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(requestStore: createWidgetTestStore()));
    await _pumpUi(tester);
    await _openRequestsTab(tester);

    await tester.scrollUntilVisible(
      find.text('Помочь заменить лампу'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Помочь заменить лампу'));
    await _pumpRoute(tester);

    expect(find.text('Помощник рядом'), findsWidgets);
    expect(find.text('Я дома'), findsOneWidget);
    expect(find.text('Ещё'), findsOneWidget);
    expect(find.text('Без предоплаты'), findsOneWidget);
  });

  testWidgets('opens settings from header', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await _pumpUi(tester);

    await tester.tap(find.byTooltip('Настройки'));
    await _pumpUi(tester);

    expect(find.text('Оформление'), findsOneWidget);
    expect(find.text('Классическая'), findsOneWidget);
    expect(find.text('Ночная'), findsOneWidget);
    expect(find.text('Светлая'), findsOneWidget);
  });
}