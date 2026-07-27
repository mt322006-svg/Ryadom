import 'package:flutter_test/flutter_test.dart';
import 'package:ryadom/features/trust/data/report_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('stores safety reports locally', () async {
    const store = ReportStore();

    final reports = await store.addReport(
      reportedPubkey: 'bad-actor',
      requestId: 'req-1',
      reason: 'Подозрительный чат',
    );

    expect(reports, isNotEmpty);
    expect(reports.first.reportedPubkey, 'bad-actor');
    expect(reports.first.requestId, 'req-1');

    final loaded = await store.loadReports();
    expect(loaded.any((item) => item.reportedPubkey == 'bad-actor'), isTrue);
  });
}