import '../models/account_status.dart';

/// US-07: a live feed of the customer's account-synchronization status.
///
/// Unlike `CustomerProfileService.loadProfile` (one `Future`, one value),
/// this is a `Stream`: it keeps emitting new values over time until the
/// listener cancels its subscription.
abstract interface class AccountStatusService {
  Stream<AccountStatus> watchStatus(int customerId);
}
