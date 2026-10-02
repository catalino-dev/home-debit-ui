import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_debit_ui/models/customer.dart';
import 'package:home_debit_ui/services/customer_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const customer = Customer(
    fullName: 'Jane Doe',
    email: 'jane.doe@example.com',
    mobileNumber: '09171234567',
  );
  final baseUri = Uri.parse('http://localhost:8080');

  test('register_posts backend fields and maps persisted response', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        '{"id":12,"fullName":"Jane Doe","email":"jane.doe@example.com",'
        '"mobileNumber":"09171234567"}',
        201,
      );
    });
    final service = CustomerService(client: client, baseUri: baseUri);

    final registered = await service.register(customer);

    expect(capturedRequest.method, 'POST');
    expect(
      capturedRequest.url,
      Uri.parse('http://localhost:8080/api/customers'),
    );
    expect(capturedRequest.headers['content-type'], 'application/json');
    expect(jsonDecode(capturedRequest.body), {
      'fullName': 'Jane Doe',
      'email': 'jane.doe@example.com',
      'mobileNumber': '09171234567',
      'nickname': null,
    });
    expect(registered.id, 12);
    expect(registered.fullName, customer.fullName);
    expect(registered.email, customer.email);
    expect(registered.mobileNumber, customer.mobileNumber);
    expect(registered.nickname, isNull);
  });

  test('register_sends and maps an optional nickname', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        '{"id":13,"fullName":"Jane Doe","email":"jane.doe@example.com",'
        '"mobileNumber":"09171234567","nickname":"Janie"}',
        201,
      );
    });
    final service = CustomerService(client: client, baseUri: baseUri);

    final registered = await service.register(
      const Customer(
        fullName: 'Jane Doe',
        email: 'jane.doe@example.com',
        mobileNumber: '09171234567',
        nickname: 'Janie',
      ),
    );

    expect(jsonDecode(capturedRequest.body)['nickname'], 'Janie');
    expect(registered.nickname, 'Janie');
  });

  test('register_maps conflict to duplicate-email message', () async {
    final service = CustomerService(
      client: MockClient(
        (_) async => http.Response('{"message":"Email already exists"}', 409),
      ),
      baseUri: baseUri,
    );

    await expectLater(
      service.register(customer),
      throwsA(
        isA<CustomerServiceException>().having(
          (exception) => exception.message,
          'message',
          contains('already exists'),
        ),
      ),
    );
  });

  test('register_surfaces validation response detail', () async {
    final service = CustomerService(
      client: MockClient(
        (_) async => http.Response('{"detail":"Email is required"}', 400),
      ),
      baseUri: baseUri,
    );

    await expectLater(
      service.register(customer),
      throwsA(
        isA<CustomerServiceException>().having(
          (exception) => exception.message,
          'message',
          'Email is required',
        ),
      ),
    );
  });

  test('register_maps client failure to actionable network error', () async {
    final service = CustomerService(
      client: MockClient(
        (_) async => throw http.ClientException('connection refused'),
      ),
      baseUri: baseUri,
    );

    await expectLater(
      service.register(customer),
      throwsA(
        isA<CustomerServiceException>().having(
          (exception) => exception.message,
          'message',
          contains('backend is running'),
        ),
      ),
    );
  });

  group('update', () {
    const saved = Customer(
      id: 12,
      fullName: 'Jane Doe',
      email: 'jane.doe@example.com',
      mobileNumber: '09171234567',
    );

    test('update_puts edited fields to the customer id and maps 200', () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          '{"id":12,"fullName":"Jane Smith","email":"jane.smith@example.com",'
          '"mobileNumber":"09998887777","nickname":"JS"}',
          200,
        );
      });
      final service = CustomerService(client: client, baseUri: baseUri);

      final updated = await service.update(
        const Customer(
          id: 12,
          fullName: 'Jane Smith',
          email: 'jane.smith@example.com',
          mobileNumber: '09998887777',
          nickname: 'JS',
        ),
      );

      expect(capturedRequest.method, 'PUT');
      expect(
        capturedRequest.url,
        Uri.parse('http://localhost:8080/api/customers/12'),
      );
      expect(capturedRequest.headers['content-type'], 'application/json');
      expect(jsonDecode(capturedRequest.body), {
        'fullName': 'Jane Smith',
        'email': 'jane.smith@example.com',
        'mobileNumber': '09998887777',
        'nickname': 'JS',
      });
      expect(
        updated,
        const Customer(
          id: 12,
          fullName: 'Jane Smith',
          email: 'jane.smith@example.com',
          mobileNumber: '09998887777',
          nickname: 'JS',
        ),
      );
    });

    test('update_rejects a customer without an id', () async {
      final service = CustomerService(
        client: MockClient((_) async => fail('must not send a request')),
        baseUri: baseUri,
      );

      expect(() => service.update(customer), throwsArgumentError);
    });

    test('update_maps conflict to duplicate-email message', () async {
      final service = CustomerService(
        client: MockClient((_) async => http.Response('{}', 409)),
        baseUri: baseUri,
      );

      await expectLater(
        service.update(saved),
        throwsA(
          isA<CustomerServiceException>().having(
            (exception) => exception.message,
            'message',
            contains('already exists'),
          ),
        ),
      );
    });

    test('update_maps not found to a profile-missing message', () async {
      final service = CustomerService(
        client: MockClient((_) async => http.Response('{}', 404)),
        baseUri: baseUri,
      );

      await expectLater(
        service.update(saved),
        throwsA(
          isA<CustomerServiceException>().having(
            (exception) => exception.message,
            'message',
            contains('no longer exists'),
          ),
        ),
      );
    });

    test('update_surfaces validation response detail', () async {
      final service = CustomerService(
        client: MockClient(
          (_) async =>
              http.Response('{"detail":"Enter a valid email address"}', 400),
        ),
        baseUri: baseUri,
      );

      await expectLater(
        service.update(saved),
        throwsA(
          isA<CustomerServiceException>().having(
            (exception) => exception.message,
            'message',
            'Enter a valid email address',
          ),
        ),
      );
    });

    test('update_maps client failure to actionable network error', () async {
      final service = CustomerService(
        client: MockClient(
          (_) async => throw http.ClientException('connection refused'),
        ),
        baseUri: baseUri,
      );

      await expectLater(
        service.update(saved),
        throwsA(
          isA<CustomerServiceException>().having(
            (exception) => exception.message,
            'message',
            contains('backend is running'),
          ),
        ),
      );
    });
  });
}
