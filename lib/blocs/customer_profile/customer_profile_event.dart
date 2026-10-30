part of 'customer_profile_bloc.dart';

/// What the UI tells [CustomerProfileBloc] happened.
sealed class CustomerProfileEvent {
  const CustomerProfileEvent();
}

/// The dashboard opened and needs the customer.
final class CustomerProfileRequested extends CustomerProfileEvent {
  const CustomerProfileRequested();
}

/// The customer tapped Retry after a failed load.
final class CustomerProfileRetryRequested extends CustomerProfileEvent {
  const CustomerProfileRetryRequested();
}

/// Edit Profile saved a new version of the customer.
final class CustomerProfileUpdated extends CustomerProfileEvent {
  const CustomerProfileUpdated(this.customer);

  final Customer customer;
}
