part of 'account_status_bloc.dart';

sealed class AccountStatusEvent {
  const AccountStatusEvent();
}

/// The dashboard opened: start listening to the status Stream.
final class AccountStatusSubscriptionRequested extends AccountStatusEvent {
  const AccountStatusSubscriptionRequested();
}
