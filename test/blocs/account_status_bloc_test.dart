import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:home_debit_ui/blocs/account_status/account_status_bloc.dart';
import 'package:home_debit_ui/models/account_status.dart';
import 'package:home_debit_ui/services/account_status_service.dart';

/// Hands the test the StreamController behind each subscription.
class _ControlledStatusService implements AccountStatusService {
  final controller = StreamController<AccountStatus>();
  final requestedIds = <int>[];

  @override
  Stream<AccountStatus> watchStatus(int customerId) {
    requestedIds.add(customerId);
    return controller.stream;
  }
}

/// US-07/US-10: AccountStatusBloc turns Stream values into states.
void main() {
  final t1 = DateTime(2026, 10, 30, 14, 31, 0);
  final t2 = DateTime(2026, 10, 30, 14, 31, 3);
  final t3 = DateTime(2026, 10, 30, 14, 31, 6);

  AccountStatus syncing(DateTime at) =>
      AccountStatus(state: AccountSyncState.synchronizing, updatedAt: at);
  AccountStatus synced(DateTime at) =>
      AccountStatus(state: AccountSyncState.synchronized, updatedAt: at);

  late _ControlledStatusService service;

  blocTest<AccountStatusBloc, AccountStatusState>(
    'emits one state per Stream value and remembers the last sync time',
    setUp: () => service = _ControlledStatusService(),
    build: () => AccountStatusBloc(statusService: service, customerId: 7),
    act: (bloc) async {
      bloc.add(const AccountStatusSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);
      service.controller
        ..add(syncing(t1))
        ..add(synced(t2))
        ..add(syncing(t3));
    },
    expect: () => [
      AccountStatusUpdated(status: syncing(t1)),
      AccountStatusUpdated(status: synced(t2), lastSynchronizedAt: t2),
      AccountStatusUpdated(status: syncing(t3), lastSynchronizedAt: t2),
    ],
    verify: (_) => expect(service.requestedIds, [7]),
  );

  blocTest<AccountStatusBloc, AccountStatusState>(
    'a Stream error becomes unavailable',
    setUp: () => service = _ControlledStatusService(),
    build: () => AccountStatusBloc(statusService: service, customerId: 7),
    act: (bloc) async {
      bloc.add(const AccountStatusSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);
      service.controller.addError(Exception('feed down'));
    },
    expect: () => [const AccountStatusUnavailable()],
  );

  test('closing the bloc cancels the Stream subscription', () async {
    final service = _ControlledStatusService();
    var cancelled = false;
    service.controller.onCancel = () => cancelled = true;
    final bloc = AccountStatusBloc(statusService: service, customerId: 7)
      ..add(const AccountStatusSubscriptionRequested());
    await Future<void>.delayed(Duration.zero);
    expect(service.controller.hasListener, isTrue);

    await bloc.close();

    expect(cancelled, isTrue);
  });
}
