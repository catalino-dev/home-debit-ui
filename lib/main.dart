import 'package:flutter/material.dart';

import 'services/customer_service.dart';
import 'screens/registration_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.customerService});

  final CustomerService? customerService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Debit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: RegistrationScreen(customerService: customerService),
    );
  }
}
