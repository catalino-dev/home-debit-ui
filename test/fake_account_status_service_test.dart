import 'package:flutter_test/flutter_test.dart';

import 'package:home_debit_ui/models/account_status.dart';
import 'package:home_debit_ui/services/fake_account_status_service.dart';

/// US-07: the fake account-status Stream.
void main() {
  final fixedTime = DateTime(2026, 10, 30, 14, 31, 5);

  FakeAccountStatusService service() => FakeAccountStatusService(
    interval: const Duration(milliseconds: 10),
    clock: () => fixedTime,
  );

  test('watchStatus_emits multiple alternating values over time', () async {
    final states = await service()
        .watchStatus(7)
        .take(5)
        .map((status) => status.state)
        .toList();

    expect(states, [
      AccountSyncState.synchronizing,
      AccountSyncState.synchronized,
      AccountSyncState.synchronizing,
      AccountSyncState.synchronized,
      AccountSyncState.synchronizing,
    ]);
  });

  test('watchStatus_stamps each value with the clock', () async {
    final first = await service().watchStatus(7).first;

    expect(
      first,
      AccountStatus(
        state: AccountSyncState.synchronizing,
        updatedAt: fixedTime,
      ),
    );
  });

  test(
    'watchStatus_stops emitting once the subscription is cancelled',
    () async {
      final received = <AccountStatus>[];
      final subscription = service().watchStatus(7).listen(received.add);

      await Future<void>.delayed(const Duration(milliseconds: 25));
      await subscription.cancel();
      final countAtCancel = received.length;
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(countAtCancel, greaterThan(1));
      expect(received.length, countAtCancel);
    },
  );
}
