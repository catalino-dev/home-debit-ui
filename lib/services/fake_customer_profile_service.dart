import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/customer.dart';
import 'customer_profile_service.dart';
import 'customer_service.dart';

/// US-05/US-06: in-memory stand-in for `GET /api/customers/{id}`.
///
/// * Every load waits [delay] to simulate network latency, so the loading
///   state is visible.
/// * Customers become loadable once they arrive on [savedCustomers] (wired
///   to [CustomerService.savedCustomers]) or are passed to [save].
/// * Setting [failNextLoad] makes exactly one load throw, which is how the
///   error + Retry flow is demonstrated: the flag resets itself, so Retry
///   succeeds.
class FakeCustomerProfileService implements CustomerProfileService {
  static const defaultDelay = Duration(seconds: 2);
  static const loadFailedMessage =
      'We could not load your profile right now. Please try again.';
  static const notFoundMessage =
      'This profile no longer exists. Please register again.';

  FakeCustomerProfileService({
    this.delay = defaultDelay,
    Stream<Customer>? savedCustomers,
    Iterable<Customer> initialCustomers = const [],
  }) {
    initialCustomers.forEach(save);
    _subscription = savedCustomers?.listen(save);
  }

  final Duration delay;

  /// Observable so a debug-only switch can bind to it.
  final ValueNotifier<bool> failNextLoad = ValueNotifier(false);

  final Map<int, Customer> _records = {};
  StreamSubscription<Customer>? _subscription;

  /// Stores [customer] so later loads return it. Ignores unsaved customers.
  void save(Customer customer) {
    final id = customer.id;
    if (id != null) _records[id] = customer;
  }

  @override
  Future<Customer> loadProfile(int customerId) async {
    await Future<void>.delayed(delay);

    if (failNextLoad.value) {
      failNextLoad.value = false;
      throw const CustomerServiceException(loadFailedMessage);
    }

    final customer = _records[customerId];
    if (customer == null) {
      throw const CustomerServiceException(notFoundMessage);
    }
    return customer;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    failNextLoad.dispose();
  }
}
