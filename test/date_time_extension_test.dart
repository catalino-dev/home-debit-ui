import 'package:flutter_test/flutter_test.dart';

import 'package:home_debit_ui/utils/date_time_extension.dart';

/// US-08: `package:intl` formatting.
void main() {
  test('syncTimestamp_formats day, month, year and 12-hour time', () {
    expect(
      DateTime(2026, 10, 30, 14, 31, 5).syncTimestamp,
      '30 Oct 2026, 2:31:05 PM',
    );
  });

  test('syncTimestamp_formats morning times with AM', () {
    expect(
      DateTime(2026, 1, 2, 9, 5, 0).syncTimestamp,
      '2 Jan 2026, 9:05:00 AM',
    );
  });
}
