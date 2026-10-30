import 'package:intl/intl.dart';

/// US-08: date formatting via `package:intl` instead of hand-built strings.
extension DateTimeFormatting on DateTime {
  static final _syncTimestamp = DateFormat('d MMM y, h:mm:ss a');

  /// e.g. `30 Oct 2026, 2:31:05 PM` (local time).
  String get syncTimestamp => _syncTimestamp.format(toLocal());
}
