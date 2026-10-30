import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:home_debit_ui/main.dart';
import 'package:home_debit_ui/models/account_status.dart';
import 'package:home_debit_ui/models/customer.dart';
import 'package:home_debit_ui/screens/profile_screen.dart';
import 'package:home_debit_ui/services/account_status_service.dart';
import 'package:home_debit_ui/services/customer_profile_service.dart';
import 'package:home_debit_ui/services/customer_service.dart';
import 'package:home_debit_ui/services/fake_customer_profile_service.dart';

/// Lets a test decide exactly when, and how, each profile load completes.
class _ControlledProfileService implements CustomerProfileService {
  final loads = <Completer<Customer>>[];
  final requestedIds = <int>[];

  @override
  Future<Customer> loadProfile(int customerId) {
    requestedIds.add(customerId);
    final completer = Completer<Customer>();
    loads.add(completer);
    return completer.future;
  }
}

/// Status feed that never emits, so these tests focus on profile loading.
class _SilentStatusService implements AccountStatusService {
  @override
  Stream<AccountStatus> watchStatus(int customerId) => const Stream.empty();
}

/// Week 3 scenarios: US-05 (async load) and US-06 (load errors + Retry).
void main() {
  const juan = Customer(
    id: 7,
    fullName: 'Juan Dela Cruz',
    email: 'juan@example.com',
    mobileNumber: '09201234567',
  );

  final loading = find.text('Loading your profile...');
  final retry = find.widgetWithText(ElevatedButton, 'Retry');

  Future<_ControlledProfileService> pumpProfile(WidgetTester tester) async {
    final service = _ControlledProfileService();
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          customerId: 7,
          profileService: service,
          accountStatusService: _SilentStatusService(),
        ),
      ),
    );
    return service;
  }

  group('US-05 load customer profile', () {
    testWidgets('shows loading while waiting, then the customer', (
      tester,
    ) async {
      final service = await pumpProfile(tester);

      expect(service.requestedIds, [7]);
      expect(loading, findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Juan Dela Cruz'), findsNothing);

      service.loads.single.complete(juan);
      await tester.pump();

      expect(loading, findsNothing);
      expect(find.text('Juan Dela Cruz'), findsOneWidget);
      expect(find.text('juan@example.com'), findsOneWidget);
      expect(find.text('Not provided'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('UI stays interactive while the profile is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      customerId: 7,
                      profileService: _ControlledProfileService(),
                      accountStatusService: _SilentStatusService(),
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(loading, findsOneWidget);

      // The pending Future does not block: Back still works mid-load.
      await tester.tap(find.text('Back to Registration'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('US-06 handle profile loading errors', () {
    testWidgets('a failed load shows the error and Retry, not a crash', (
      tester,
    ) async {
      final service = await pumpProfile(tester);

      service.loads.single.completeError(
        const CustomerServiceException('Profile service unavailable.'),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(loading, findsNothing, reason: 'loading reset after failure');
      expect(find.text('Profile service unavailable.'), findsOneWidget);
      expect(retry, findsOneWidget);
      expect(find.text('Edit Profile'), findsNothing);
    });

    testWidgets('Retry loads again and shows the customer on success', (
      tester,
    ) async {
      final service = await pumpProfile(tester);
      service.loads.single.completeError(
        const CustomerServiceException('Profile service unavailable.'),
      );
      await tester.pump();

      await tester.tap(retry);
      await tester.pump();

      expect(service.requestedIds, [7, 7]);
      expect(loading, findsOneWidget);
      expect(find.text('Profile service unavailable.'), findsNothing);

      service.loads.last.complete(juan);
      await tester.pump();

      expect(loading, findsNothing, reason: 'loading reset after success');
      expect(find.text('Juan Dela Cruz'), findsOneWidget);
      expect(retry, findsNothing);
    });

    testWidgets('Retry after a second failure shows the error again', (
      tester,
    ) async {
      final service = await pumpProfile(tester);
      service.loads.single.completeError(
        const CustomerServiceException('First failure.'),
      );
      await tester.pump();
      await tester.tap(retry);
      await tester.pump();

      service.loads.last.completeError(
        const CustomerServiceException('Second failure.'),
      );
      await tester.pump();

      expect(find.text('Second failure.'), findsOneWidget);
      expect(retry, findsOneWidget);
    });

    testWidgets('an unexpected exception becomes a generic retryable error', (
      tester,
    ) async {
      final service = await pumpProfile(tester);

      service.loads.single.completeError(StateError('boom'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Something went wrong'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);
      expect(retry, findsOneWidget);
    });
  });

  testWidgets('end to end: simulated failure after registration, then Retry', (
    tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response(
        '{"id":7,"fullName":"Juan Dela Cruz","email":"juan@example.com",'
        '"mobileNumber":"09201234567"}',
        201,
      ),
    );
    final customerService = CustomerService(
      client: client,
      baseUri: Uri.parse('http://localhost:8080'),
    );
    final profileService = FakeCustomerProfileService(
      savedCustomers: customerService.savedCustomers,
    );
    addTearDown(profileService.dispose);
    await tester.pumpWidget(
      MyApp(customerService: customerService, profileService: profileService),
    );

    final failureSwitch = find.byKey(
      const ValueKey('simulate-profile-load-failure'),
    );
    await tester.ensureVisible(failureSwitch);
    await tester.tap(failureSwitch);
    await tester.pump();
    expect(profileService.failNextLoad.value, isTrue);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Juan Dela Cruz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'juan@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile Number'),
      '09201234567',
    );
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Customer Profile'), findsOneWidget);
    expect(loading, findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text(FakeCustomerProfileService.loadFailedMessage), findsOne);

    await tester.tap(retry);
    await tester.pump();
    expect(loading, findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(retry, findsNothing);
  });
}
