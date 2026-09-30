import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:home_debit_ui/main.dart';
import 'package:home_debit_ui/services/customer_service.dart';

void main() {
  testWidgets('shows validation errors when required fields are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Customer Registration'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();

    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Mobile number is required'), findsOneWidget);
  });

  testWidgets('rejects invalid email and mobile number', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Jane Doe',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'not-an-email',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile Number'),
      'abc123',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(
      find.text('Enter a valid mobile number (digits only)'),
      findsOneWidget,
    );
    expect(find.text('Customer Registration'), findsOneWidget);
  });

  testWidgets(
    'successful registration navigates to Profile with the submitted data',
    (WidgetTester tester) async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url, Uri.parse('http://localhost:8080/api/customers'));
        return http.Response(
          '{"id":42,"fullName":"Jane Doe","email":"jane.doe@example.com",'
          '"mobileNumber":"09171234567"}',
          201,
        );
      });
      await tester.pumpWidget(
        MyApp(
          customerService: CustomerService(
            client: client,
            baseUri: Uri.parse('http://localhost:8080'),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Jane Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'jane.doe@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile Number'),
        '09171234567',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();

      expect(find.text('Customer Profile'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane.doe@example.com'), findsOneWidget);
      expect(find.text('09171234567'), findsOneWidget);
      expect(find.text('Registration successful for Jane Doe'), findsOneWidget);
    },
  );

  testWidgets(
    'backend validation error stays visible on the registration form',
    (WidgetTester tester) async {
      final client = MockClient(
        (_) async => http.Response('{"detail":"Email is required"}', 400),
      );
      await tester.pumpWidget(
        MyApp(
          customerService: CustomerService(
            client: client,
            baseUri: Uri.parse('http://localhost:8080'),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Jane Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'jane.doe@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile Number'),
        '09171234567',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Customer Registration'), findsOneWidget);
      expect(find.text('Customer Profile'), findsNothing);
    },
  );

  testWidgets('duplicate email error stays visible without navigating', (
    WidgetTester tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response('{"message":"Email already exists"}', 409),
    );
    await tester.pumpWidget(
      MyApp(
        customerService: CustomerService(
          client: client,
          baseUri: Uri.parse('http://localhost:8080'),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Jane Doe',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'jane.doe@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile Number'),
      '09171234567',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'An account with this email already exists. Use a different email.',
      ),
      findsOneWidget,
    );
    expect(find.text('Customer Registration'), findsOneWidget);
    expect(find.text('Customer Profile'), findsNothing);
  });

  testWidgets('network error is shown and registration can be retried', (
    WidgetTester tester,
  ) async {
    final client = MockClient(
      (_) async => throw http.ClientException('connection refused'),
    );
    await tester.pumpWidget(
      MyApp(
        customerService: CustomerService(
          client: client,
          baseUri: Uri.parse('http://localhost:8080'),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Jane Doe',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'jane.doe@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile Number'),
      '09171234567',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Unable to connect to Home Debit. Check that the backend is running and try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Customer Registration'), findsOneWidget);
    expect(find.text('Customer Profile'), findsNothing);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Register'),
          )
          .onPressed,
      isNotNull,
    );
  });
}
