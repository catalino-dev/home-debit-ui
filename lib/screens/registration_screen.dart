import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../services/customer_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_text_field.dart';
import 'profile_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, this.customerService});

  final CustomerService? customerService;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  late final _customerService = widget.customerService ?? CustomerService();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final requiredError = _validateRequired(value, 'Email');
    if (requiredError != null) return requiredError;
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    final requiredError = _validateRequired(value, 'Mobile number');
    if (requiredError != null) return requiredError;
    final digitsOnly = RegExp(r'^\d{7,15}$');
    if (!digitsOnly.hasMatch(value!.trim())) {
      return 'Enter a valid mobile number (digits only)';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final customer = Customer(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
    );

    try {
      final registered = await _customerService.register(customer);

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful for ${registered.fullName}'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(customer: registered),
        ),
      );
    } on CustomerServiceException catch (exception) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = exception.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Registration')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.normal),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your details to create your profile',
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: AppSpacing.large),
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                validator: (value) => _validateRequired(value, 'Full name'),
              ),
              const SizedBox(height: AppSpacing.normal),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: AppSpacing.normal),
              AppTextField(
                controller: _mobileController,
                label: 'Mobile Number',
                keyboardType: TextInputType.phone,
                validator: _validateMobile,
              ),
              const SizedBox(height: AppSpacing.large),
              if (_errorMessage != null) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _errorMessage!,
                    key: const ValueKey('registration-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.normal),
              ],
              AppPrimaryButton(
                label: 'Register',
                isLoading: _isSubmitting,
                onPressed: _handleRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
