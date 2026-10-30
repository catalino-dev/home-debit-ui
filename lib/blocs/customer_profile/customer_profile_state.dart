part of 'customer_profile_bloc.dart';

/// Exactly one of loading, loaded, or failed — the UI renders whichever it
/// receives, so it can never show a spinner and an error at the same time.
sealed class CustomerProfileState {
  const CustomerProfileState();
}

final class CustomerProfileLoading extends CustomerProfileState {
  const CustomerProfileLoading();

  @override
  bool operator ==(Object other) => other is CustomerProfileLoading;

  @override
  int get hashCode => (CustomerProfileLoading).hashCode;
}

final class CustomerProfileLoaded extends CustomerProfileState {
  const CustomerProfileLoaded(this.customer);

  final Customer customer;

  @override
  bool operator ==(Object other) =>
      other is CustomerProfileLoaded && other.customer == customer;

  @override
  int get hashCode => customer.hashCode;
}

final class CustomerProfileLoadFailure extends CustomerProfileState {
  const CustomerProfileLoadFailure(this.message);

  /// User-facing; never a raw exception string.
  final String message;

  @override
  bool operator ==(Object other) =>
      other is CustomerProfileLoadFailure && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
