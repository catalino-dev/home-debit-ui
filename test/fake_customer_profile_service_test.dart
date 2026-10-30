import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:home_debit_ui/models/customer.dart';
import 'package:home_debit_ui/services/customer_service.dart';
import 'package:home_debit_ui/services/fake_customer_profile_service.dart';

/// US-05/US-06: the in-memory fake that stands in for the profile backend.
void main() {
  const juan = Customer(
    id: 7,
    fullName: 'Juan Dela Cruz',
    email: 'juan@example.com',
    mobileNumber: '09201234567',
  );

  test('loadProfile_completes only after the simulated delay', () async {
    final service = FakeCustomerProfileService(
      delay: const Duration(milliseconds: 100),
      initialCustomers: [juan],
    );
    Customer? loaded;
    final pending = service.loadProfile(7).then((c) => loaded = c);

    await pumpEventQueue();
    expect(loaded, isNull, reason: 'still waiting on the "network"');

    await pending;
    expect(loaded, juan);
  });

  test('loadProfile_returns customers received on savedCustomers', () async {
    final saved = StreamController<Customer>();
    final service = FakeCustomerProfileService(
      delay: Duration.zero,
      savedCustomers: saved.stream,
    );

    saved.add(juan);
    await pumpEventQueue();

    expect(await service.loadProfile(7), juan);
    await service.dispose();
    await saved.close();
  });

  test('loadProfile_returns the latest saved version of a customer', () async {
    final service = FakeCustomerProfileService(
      delay: Duration.zero,
      initialCustomers: [juan],
    );
    const renamed = Customer(
      id: 7,
      fullName: 'Juan D. Cruz',
      email: 'juan@example.com',
      mobileNumber: '09201234567',
      nickname: 'Juanito',
    );

    service.save(renamed);

    expect(await service.loadProfile(7), renamed);
  });

  test('loadProfile_throws not-found for an unknown id', () {
    final service = FakeCustomerProfileService(delay: Duration.zero);

    expect(
      service.loadProfile(99),
      throwsA(
        isA<CustomerServiceException>().having(
          (e) => e.message,
          'message',
          FakeCustomerProfileService.notFoundMessage,
        ),
      ),
    );
  });

  test('failNextLoad_fails exactly one load, then resets', () async {
    final service = FakeCustomerProfileService(
      delay: Duration.zero,
      initialCustomers: [juan],
    );
    service.failNextLoad.value = true;

    await expectLater(
      service.loadProfile(7),
      throwsA(
        isA<CustomerServiceException>().having(
          (e) => e.message,
          'message',
          FakeCustomerProfileService.loadFailedMessage,
        ),
      ),
    );
    expect(service.failNextLoad.value, isFalse);
    expect(await service.loadProfile(7), juan, reason: 'Retry succeeds');
  });
}
