import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'screens/registration_screen.dart';
import 'services/customer_profile_service.dart';
import 'services/customer_service.dart';
import 'services/fake_customer_profile_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

/// Composition root: creates the services once and hands them down.
class MyApp extends StatefulWidget {
  const MyApp({super.key, this.customerService, this.profileService});

  final CustomerService? customerService;

  /// Defaults to [FakeCustomerProfileService] (Week 3), or to the backend
  /// when built with `--dart-define=USE_BACKEND_PROFILE=true`.
  final CustomerProfileService? profileService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final CustomerService _customerService;
  late final CustomerProfileService _profileService;

  // Only a fake created here is disposed here; injected services are owned
  // by whoever injected them.
  FakeCustomerProfileService? _ownedFakeProfileService;

  @override
  void initState() {
    super.initState();
    _customerService = widget.customerService ?? CustomerService();
    _profileService = widget.profileService ?? _defaultProfileService();
  }

  CustomerProfileService _defaultProfileService() {
    if (ApiConfig.useBackendProfile) return _customerService;
    return _ownedFakeProfileService = FakeCustomerProfileService(
      savedCustomers: _customerService.savedCustomers,
    );
  }

  @override
  void dispose() {
    _ownedFakeProfileService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileService = _profileService;
    return MaterialApp(
      title: 'Home Debit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: RegistrationScreen(
        customerService: _customerService,
        profileService: profileService,
        // Debug-only demo switch for US-06; null hides it.
        simulateProfileLoadFailure: profileService is FakeCustomerProfileService
            ? profileService.failNextLoad
            : null,
      ),
    );
  }
}
