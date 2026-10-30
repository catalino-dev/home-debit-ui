import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:home_debit_ui/models/account_status.dart';
import 'package:home_debit_ui/models/customer.dart';
import 'package:home_debit_ui/screens/profile_screen.dart';
import 'package:home_debit_ui/services/account_status_service.dart';
import 'package:home_debit_ui/services/customer_profile_service.dart';
import 'package:home_debit_ui/services/fake_account_status_service.dart';
import 'package:home_debit_ui/services/fake_customer_profile_service.dart';

class _ControlledStatusService implements AccountStatusService {
  final controller = StreamController<AccountStatus>();

  @override
  Stream<AccountStatus> watchStatus(int customerId) => controller.stream;
}

class _PendingProfileService implements CustomerProfileService {
  @override
  Future<Customer> loadProfile(int customerId) => Completer<Customer>().future;
}

/// Week 4 scenarios: US-07 live status and US-10 dashboard.
void main() {
  const juan = Customer(
    id: 7,
    fullName: 'Juan Dela Cruz',
    email: 'juan@example.com',
    mobileNumber: '09201234567',
    nickname: 'Juanito',
  );
  final fixedTime = DateTime(2026, 10, 30, 14, 31, 5);

  Widget dashboard({
    required AccountStatusService statusService,
    CustomerProfileService? profileService,
  }) => MaterialApp(
    home: ProfileScreen(
      customerId: 7,
      profileService:
          profileService ??
          FakeCustomerProfileService(
            delay: Duration.zero,
            initialCustomers: [juan],
          ),
      accountStatusService: statusService,
    ),
  );

  testWidgets('status updates automatically from the Stream (US-07)', (
    tester,
  ) async {
    await tester.pumpWidget(
      dashboard(
        statusService: FakeAccountStatusService(
          interval: const Duration(seconds: 3),
          clock: () => fixedTime,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Synchronizing...'), findsOneWidget);
    expect(find.textContaining('Last synchronized'), findsNothing);
    expect(find.textContaining('Refresh'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Synchronized'), findsOneWidget);
    expect(
      find.text('Last synchronized: 30 Oct 2026, 2:31:05 PM'),
      findsOneWidget,
      reason: 'US-08: formatted with package:intl',
    );

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Synchronizing...'), findsOneWidget);
    expect(
      find.text('Last synchronized: 30 Oct 2026, 2:31:05 PM'),
      findsOneWidget,
      reason: 'the last completed sync stays visible while re-syncing',
    );
  });

  testWidgets('shows the customer and handles the null-safe greeting (US-10)', (
    tester,
  ) async {
    final status = _ControlledStatusService();
    await tester.pumpWidget(dashboard(statusService: status));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Juanito'), findsOneWidget);
    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('Checking status...'), findsOneWidget);
  });

  testWidgets('status streams while the profile is still loading', (
    tester,
  ) async {
    final status = _ControlledStatusService();
    await tester.pumpWidget(
      dashboard(
        statusService: status,
        profileService: _PendingProfileService(),
      ),
    );
    await tester.pump();

    status.controller.add(
      AccountStatus(state: AccountSyncState.synchronized, updatedAt: fixedTime),
    );
    await tester.pump();

    expect(find.text('Loading your profile...'), findsOneWidget);
    expect(find.text('Synchronized'), findsOneWidget);
  });

  testWidgets(
    'a failing status Stream shows unavailable, profile still works',
    (tester) async {
      final status = _ControlledStatusService();
      await tester.pumpWidget(dashboard(statusService: status));
      await tester.pumpAndSettle();

      status.controller.addError(Exception('feed down'));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Status unavailable'), findsOneWidget);
      expect(find.text('Juan Dela Cruz'), findsOneWidget);
    },
  );

  testWidgets('leaving the dashboard cancels the status subscription', (
    tester,
  ) async {
    final status = _ControlledStatusService();
    var cancelled = false;
    status.controller.onCancel = () => cancelled = true;
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
                    profileService: FakeCustomerProfileService(
                      delay: Duration.zero,
                      initialCustomers: [juan],
                    ),
                    accountStatusService: status,
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
    await tester.pumpAndSettle();
    expect(status.controller.hasListener, isTrue);

    await tester.ensureVisible(find.text('Back to Registration'));
    await tester.tap(find.text('Back to Registration'));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(cancelled, isTrue);
  });
}
