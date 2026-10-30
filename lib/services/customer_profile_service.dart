import '../models/customer.dart';

/// US-05: read side of the customer profile.
///
/// The Profile screen depends on this abstraction rather than on HTTP, so it
/// can be backed by the real backend (`CustomerService`) or by the in-memory
/// `FakeCustomerProfileService` used for the Week 3 async exercise.
///
/// Implementations throw `CustomerServiceException` with a user-facing
/// message when the profile cannot be loaded.
abstract interface class CustomerProfileService {
  /// Completes *later* with the customer — callers must `await` it before
  /// they can read any field.
  Future<Customer> loadProfile(int customerId);
}
