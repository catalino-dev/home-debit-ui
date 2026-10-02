import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:home_debit_ui/main.dart';
import 'package:home_debit_ui/services/customer_service.dart';

/// Week 2 screen scenarios: US-03 (optional nickname) and US-04 (edit profile).
void main() {
  final baseUri = Uri.parse('http://localhost:8080');

  String customerJson({
    int id = 7,
    String fullName = 'Juan Dela Cruz',
    String email = 'juan@example.com',
    String mobileNumber = '09201234567',
    String? nickname,
  }) => jsonEncode({
    'id': id,
    'fullName': fullName,
    'email': email,
    'mobileNumber': mobileNumber,
    'nickname': nickname,
  });

  Future<void> pumpApp(WidgetTester tester, MockClient client) {
    return tester.pumpWidget(
      MyApp(
        customerService: CustomerService(client: client, baseUri: baseUri),
      ),
    );
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder button(String label) => find.ancestor(
    of: find.text(label),
    matching: find.bySubtype<ButtonStyleButton>(),
  );

  Future<void> tapButton(WidgetTester tester, String label) async {
    await tester.ensureVisible(button(label));
    await tester.tap(button(label));
  }

  Future<void> register(WidgetTester tester, {String nickname = ''}) async {
    await tester.enterText(field('Full Name'), 'Juan Dela Cruz');
    await tester.enterText(field('Email'), 'juan@example.com');
    await tester.enterText(field('Mobile Number'), '09201234567');
    await tester.enterText(field('Nickname (optional)'), nickname);
    await tapButton(tester, 'Register');
    await tester.pumpAndSettle();
  }

  Future<void> openEdit(WidgetTester tester) async {
    await tapButton(tester, 'Edit Profile');
    await tester.pumpAndSettle();
  }

  String fieldText(WidgetTester tester, String label) =>
      tester.widget<TextFormField>(field(label)).controller!.text;

  group('US-03 optional nickname', () {
    testWidgets('registers without nickname and shows the fallback', (
      tester,
    ) async {
      late Map<String, dynamic> sentBody;
      final client = MockClient((request) async {
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(customerJson(), 201);
      });
      await pumpApp(tester, client);

      await register(tester);

      expect(sentBody.containsKey('nickname'), isTrue);
      expect(sentBody['nickname'], isNull);
      expect(find.text('Customer Profile'), findsOneWidget);
      expect(find.text('Nickname'), findsOneWidget);
      expect(find.text('Not provided'), findsOneWidget);
    });

    testWidgets('registers with a nickname and displays it', (tester) async {
      late Map<String, dynamic> sentBody;
      final client = MockClient((request) async {
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(customerJson(nickname: 'Juanito'), 201);
      });
      await pumpApp(tester, client);

      await register(tester, nickname: '  Juanito  ');

      expect(sentBody['nickname'], 'Juanito');
      expect(find.text('Juanito'), findsOneWidget);
      expect(find.text('Not provided'), findsNothing);
    });

    testWidgets('rejects a nickname longer than 50 characters', (tester) async {
      var requests = 0;
      final client = MockClient((_) async {
        requests++;
        return http.Response(customerJson(), 201);
      });
      await pumpApp(tester, client);

      await register(tester, nickname: 'x' * 51);

      expect(
        find.text('Nickname must be 50 characters or fewer'),
        findsOneWidget,
      );
      expect(requests, 0);
    });
  });

  group('US-04 edit profile', () {
    testWidgets('Edit opens with the existing values', (tester) async {
      final client = MockClient(
        (_) async => http.Response(customerJson(nickname: 'Juanito'), 201),
      );
      await pumpApp(tester, client);
      await register(tester, nickname: 'Juanito');

      await openEdit(tester);

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(fieldText(tester, 'Full Name'), 'Juan Dela Cruz');
      expect(fieldText(tester, 'Email'), 'juan@example.com');
      expect(fieldText(tester, 'Mobile Number'), '09201234567');
      expect(fieldText(tester, 'Nickname (optional)'), 'Juanito');
    });

    testWidgets('Edit shows an empty nickname field when nickname is null', (
      tester,
    ) async {
      final client = MockClient(
        (_) async => http.Response(customerJson(), 201),
      );
      await pumpApp(tester, client);
      await register(tester);

      await openEdit(tester);

      expect(fieldText(tester, 'Nickname (optional)'), isEmpty);
    });

    testWidgets('Save sends PUT and the Profile shows the updated values', (
      tester,
    ) async {
      http.Request? putRequest;
      final client = MockClient((request) async {
        if (request.method == 'PUT') {
          putRequest = request;
          return http.Response(
            customerJson(
              fullName: 'Juan P. Dela Cruz',
              email: 'juan.p@example.com',
              mobileNumber: '09179998888',
              nickname: 'JP',
            ),
            200,
          );
        }
        return http.Response(customerJson(), 201);
      });
      await pumpApp(tester, client);
      await register(tester);
      await openEdit(tester);

      await tester.enterText(field('Full Name'), 'Juan P. Dela Cruz');
      await tester.enterText(field('Email'), 'juan.p@example.com');
      await tester.enterText(field('Mobile Number'), '09179998888');
      await tester.enterText(field('Nickname (optional)'), 'JP');
      await tapButton(tester, 'Save');
      await tester.pumpAndSettle();

      expect(putRequest, isNotNull);
      expect(
        putRequest!.url,
        Uri.parse('http://localhost:8080/api/customers/7'),
      );
      expect(jsonDecode(putRequest!.body), {
        'fullName': 'Juan P. Dela Cruz',
        'email': 'juan.p@example.com',
        'mobileNumber': '09179998888',
        'nickname': 'JP',
      });
      expect(find.text('Customer Profile'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget); // the button
      expect(find.byType(TextFormField), findsNothing);
      expect(find.text('Juan P. Dela Cruz'), findsOneWidget);
      expect(find.text('juan.p@example.com'), findsOneWidget);
      expect(find.text('09179998888'), findsOneWidget);
      expect(find.text('JP'), findsOneWidget);
      expect(find.text('Profile updated'), findsOneWidget);
    });

    testWidgets('clearing the nickname on Save shows the fallback again', (
      tester,
    ) async {
      final client = MockClient((request) async {
        if (request.method == 'PUT') {
          return http.Response(customerJson(), 200);
        }
        return http.Response(customerJson(nickname: 'Juanito'), 201);
      });
      await pumpApp(tester, client);
      await register(tester, nickname: 'Juanito');
      await openEdit(tester);

      await tester.enterText(field('Nickname (optional)'), '   ');
      await tapButton(tester, 'Save');
      await tester.pumpAndSettle();

      expect(find.text('Not provided'), findsOneWidget);
      expect(find.text('Juanito'), findsNothing);
    });

    testWidgets('Cancel discards unsaved changes and sends nothing', (
      tester,
    ) async {
      var putCount = 0;
      final client = MockClient((request) async {
        if (request.method == 'PUT') putCount++;
        return http.Response(customerJson(nickname: 'Juanito'), 201);
      });
      await pumpApp(tester, client);
      await register(tester, nickname: 'Juanito');
      await openEdit(tester);

      await tester.enterText(field('Full Name'), 'Unsaved Name');
      await tester.enterText(field('Nickname (optional)'), 'Unsaved');
      await tapButton(tester, 'Cancel');
      await tester.pumpAndSettle();

      expect(putCount, 0);
      expect(find.text('Customer Profile'), findsOneWidget);
      expect(find.text('Juan Dela Cruz'), findsOneWidget);
      expect(find.text('Juanito'), findsOneWidget);
      expect(find.text('Unsaved Name'), findsNothing);

      // Re-opening starts from the saved profile, not the discarded draft.
      await openEdit(tester);
      expect(fieldText(tester, 'Full Name'), 'Juan Dela Cruz');
      expect(fieldText(tester, 'Nickname (optional)'), 'Juanito');
    });

    testWidgets('invalid edits show validation errors and do not save', (
      tester,
    ) async {
      var putCount = 0;
      final client = MockClient((request) async {
        if (request.method == 'PUT') putCount++;
        return http.Response(customerJson(), 201);
      });
      await pumpApp(tester, client);
      await register(tester);
      await openEdit(tester);

      await tester.enterText(field('Full Name'), '');
      await tester.enterText(field('Email'), 'not-an-email');
      await tapButton(tester, 'Save');
      await tester.pump();

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(putCount, 0);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('duplicate email on Save stays on Edit with the error', (
      tester,
    ) async {
      final client = MockClient((request) async {
        if (request.method == 'PUT') return http.Response('{}', 409);
        return http.Response(customerJson(), 201);
      });
      await pumpApp(tester, client);
      await register(tester);
      await openEdit(tester);

      await tester.enterText(field('Email'), 'taken@example.com');
      await tapButton(tester, 'Save');
      await tester.pumpAndSettle();

      expect(
        find.text(
          'An account with this email already exists. Use a different email.',
        ),
        findsOneWidget,
      );
      expect(fieldText(tester, 'Email'), 'taken@example.com');

      await tapButton(tester, 'Cancel');
      await tester.pumpAndSettle();

      expect(find.text('juan@example.com'), findsOneWidget);
      expect(find.text('taken@example.com'), findsNothing);
    });

    testWidgets('back navigation is blocked while Save is in progress', (
      tester,
    ) async {
      final pendingSave = Completer<http.Response>();
      final client = MockClient((request) async {
        if (request.method == 'PUT') return pendingSave.future;
        return http.Response(customerJson(), 201);
      });
      await pumpApp(tester, client);
      await register(tester);
      await openEdit(tester);

      await tester.enterText(field('Full Name'), 'Juan Updated');
      await tapButton(tester, 'Save');
      await tester.pump();

      expect(find.byType(BackButton), findsNothing);
      await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
      await tester.pump();
      expect(find.text('Edit Profile'), findsOneWidget);

      pendingSave.complete(
        http.Response(customerJson(fullName: 'Juan Updated'), 200),
      );
      await tester.pumpAndSettle();

      expect(find.text('Customer Profile'), findsOneWidget);
      expect(find.text('Juan Updated'), findsOneWidget);
    });
  });
}
