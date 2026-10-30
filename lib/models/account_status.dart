/// US-07: whether the customer's profile data is up to date.
enum AccountSyncState {
  synchronizing('Synchronizing...'),
  synchronized('Synchronized');

  const AccountSyncState(this.label);

  final String label;
}

/// One value emitted by the account-status Stream.
class AccountStatus {
  final AccountSyncState state;

  /// When this status was observed.
  final DateTime updatedAt;

  const AccountStatus({required this.state, required this.updatedAt});

  bool get isSynchronized => state == AccountSyncState.synchronized;

  @override
  bool operator ==(Object other) =>
      other is AccountStatus &&
      other.state == state &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(state, updatedAt);

  @override
  String toString() => 'AccountStatus(${state.name}, $updatedAt)';
}
