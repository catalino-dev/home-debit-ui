import '../models/account_status.dart';
import 'account_status_service.dart';

/// US-07: simulated account-status feed.
///
/// Emits `Synchronizing...` immediately, then alternates
/// `Synchronized` / `Synchronizing...` every [interval], forever, until the
/// subscriber cancels.
class FakeAccountStatusService implements AccountStatusService {
  static const defaultInterval = Duration(seconds: 3);

  FakeAccountStatusService({
    this.interval = defaultInterval,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration interval;
  final DateTime Function() _clock;

  @override
  Stream<AccountStatus> watchStatus(int customerId) async* {
    // `async*` makes this a Stream generator: `yield` emits one value,
    // `yield*` forwards every value of another Stream.
    yield _status(AccountSyncState.synchronizing);

    // `yield*` (rather than `Future.delayed` in a loop) forwards cancellation
    // straight to the periodic timer, so nothing keeps running after the
    // dashboard is closed.
    yield* Stream<int>.periodic(interval, (tick) => tick).map(
      (tick) => _status(
        tick.isEven
            ? AccountSyncState.synchronized
            : AccountSyncState.synchronizing,
      ),
    );
  }

  AccountStatus _status(AccountSyncState state) =>
      AccountStatus(state: state, updatedAt: _clock());
}
