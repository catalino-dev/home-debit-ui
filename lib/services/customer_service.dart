import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/customer.dart';

class CustomerServiceException implements Exception {
  final String message;

  const CustomerServiceException(this.message);

  @override
  String toString() => message;
}

class CustomerService {
  static const _timeout = Duration(seconds: 15);
  static const _jsonHeaders = {'Content-Type': 'application/json'};
  static const _duplicateEmailMessage =
      'An account with this email already exists. Use a different email.';
  static const _invalidResponseMessage =
      'The server returned an invalid response. Please try again later.';

  final http.Client _client;
  final Uri _baseUri;

  CustomerService({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      _baseUri = baseUri ?? ApiConfig.baseUri;

  /// US-01/US-03: `POST /api/customers`, expecting `201 Created`.
  Future<Customer> register(Customer customer) async {
    final response = await _send(
      () => _client.post(
        _baseUri.resolve('/api/customers'),
        headers: _jsonHeaders,
        body: jsonEncode(customer.toRequestJson()),
      ),
    );

    if (response.statusCode != 201) {
      throw CustomerServiceException(
        _failureMessage(
          response,
          fallback:
              'Registration could not be completed. Please try again later.',
        ),
      );
    }
    return _decodeCustomer(response);
  }

  /// US-04: `PUT /api/customers/{id}`, expecting `200 OK`.
  ///
  /// [customer] must already be persisted, i.e. carry a backend [Customer.id].
  Future<Customer> update(Customer customer) async {
    final id = customer.id;
    if (id == null) {
      throw ArgumentError.value(
        customer,
        'customer',
        'must have an id to be updated',
      );
    }
    // From here Dart has promoted `id` from `int?` to `int` — no `!` needed.
    final response = await _send(
      () => _client.put(
        _baseUri.resolve('/api/customers/$id'),
        headers: _jsonHeaders,
        body: jsonEncode(customer.toRequestJson()),
      ),
    );

    if (response.statusCode == 404) {
      throw const CustomerServiceException(
        'This profile no longer exists. Please register again.',
      );
    }
    if (response.statusCode != 200) {
      throw CustomerServiceException(
        _failureMessage(
          response,
          fallback: 'Your changes could not be saved. Please try again later.',
        ),
      );
    }
    return _decodeCustomer(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      throw const CustomerServiceException(
        'The server took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const CustomerServiceException(
        'Unable to connect to Home Debit. Check that the backend is running and try again.',
      );
    } on FormatException {
      throw const CustomerServiceException(_invalidResponseMessage);
    }
  }

  String _failureMessage(http.Response response, {required String fallback}) {
    return switch (response.statusCode) {
      409 => _duplicateEmailMessage,
      400 => _validationMessage(response.body),
      _ => fallback,
    };
  }

  Customer _decodeCustomer(http.Response response) {
    try {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      return Customer.fromJson(payload);
    } on FormatException {
      throw const CustomerServiceException(_invalidResponseMessage);
    } on TypeError {
      throw const CustomerServiceException(_invalidResponseMessage);
    }
  }

  String _validationMessage(String body) {
    final payload = _tryDecode(body);
    if (payload is Map<String, dynamic>) {
      final detail = payload['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
      final message = payload['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return 'Please check your details and try again.';
  }

  dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }
}
