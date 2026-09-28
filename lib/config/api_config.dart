import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static Uri get baseUri {
    if (_configuredBaseUrl.trim().isNotEmpty) {
      return Uri.parse(_configuredBaseUrl.trim());
    }
    if (kIsWeb) {
      return Uri.parse('http://localhost:8080');
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Uri.parse('http://10.0.2.2:8080');
    }
    return Uri.parse('http://localhost:8080');
  }
}
