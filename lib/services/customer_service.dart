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
  final http.Client _client;
  final Uri _baseUri;

  CustomerService({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      _baseUri = baseUri ?? ApiConfig.baseUri;

  Future<Customer> register(Customer customer) async {
    final uri = _baseUri.resolve('/api/customers');
    late final http.Response response;

    try {
      response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(customer.toRegistrationJson()),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const CustomerServiceException(
        'The server took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const CustomerServiceException(
        'Unable to connect to Home Debit. Check that the backend is running and try again.',
      );
    } on FormatException {
      throw const CustomerServiceException(
        'The server returned an invalid response. Please try again later.',
      );
    }

    if (response.statusCode == 409) {
      throw const CustomerServiceException(
        'An account with this email already exists. Use a different email.',
      );
    }
    if (response.statusCode == 400) {
      throw CustomerServiceException(_validationMessage(response.body));
    }
    if (response.statusCode != 201) {
      throw const CustomerServiceException(
        'Registration could not be completed. Please try again later.',
      );
    }

    try {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      return Customer.fromJson(payload);
    } on FormatException {
      throw const CustomerServiceException(
        'The server returned an invalid response. Please try again later.',
      );
    } on TypeError {
      throw const CustomerServiceException(
        'The server returned an invalid response. Please try again later.',
      );
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
