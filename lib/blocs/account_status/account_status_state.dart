part of 'account_status_bloc.dart';

sealed class AccountStatusState {
  const AccountStatusState();
}

/// Not listening yet / no value received yet.
final class AccountStatusInitial extends AccountStatusState {
  const AccountStatusInitial();

  @override
  bool operator ==(Object other) => other is AccountStatusInitial;

  @override
  int get hashCode => (AccountStatusInitial).hashCode;
}

final class AccountStatusUpdated extends AccountStatusState {
  const AccountStatusUpdated({required this.status, this.lastSynchronizedAt});

  final AccountStatus status;

  /// When the account was last fully synchronized; kept while a new
  /// synchronization is in progress, null until the first one completes.
  final DateTime? lastSynchronizedAt;

  @override
  bool operator ==(Object other) =>
      other is AccountStatusUpdated &&
      other.status == status &&
      other.lastSynchronizedAt == lastSynchronizedAt;

  @override
  int get hashCode => Object.hash(status, lastSynchronizedAt);
}

/// The status feed failed; the profile itself is still usable.
final class AccountStatusUnavailable extends AccountStatusState {
  const AccountStatusUnavailable();

  @override
  bool operator ==(Object other) => other is AccountStatusUnavailable;

  @override
  int get hashCode => (AccountStatusUnavailable).hashCode;
}
