import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/account_status.dart';
import '../../services/account_status_service.dart';

part 'account_status_event.dart';
part 'account_status_state.dart';

/// US-07/US-10: turns the account-status Stream into UI states.
class AccountStatusBloc extends Bloc<AccountStatusEvent, AccountStatusState> {
  AccountStatusBloc({required this._statusService, required this._customerId})
    : super(const AccountStatusInitial()) {
    on<AccountStatusSubscriptionRequested>(_onSubscriptionRequested);
  }

  final AccountStatusService _statusService;
  final int _customerId;

  Future<void> _onSubscriptionRequested(
    AccountStatusSubscriptionRequested event,
    Emitter<AccountStatusState> emit,
  ) {
    // `emit.forEach` listens for the bloc's lifetime and cancels the
    // subscription automatically when the bloc is closed.
    return emit.forEach<AccountStatus>(
      _statusService.watchStatus(_customerId),
      onData: (status) => AccountStatusUpdated(
        status: status,
        lastSynchronizedAt: status.isSynchronized
            ? status.updatedAt
            : _lastSynchronizedAt,
      ),
      onError: (_, _) => const AccountStatusUnavailable(),
    );
  }

  DateTime? get _lastSynchronizedAt => switch (state) {
    AccountStatusUpdated(:final lastSynchronizedAt) => lastSynchronizedAt,
    _ => null,
  };
}
