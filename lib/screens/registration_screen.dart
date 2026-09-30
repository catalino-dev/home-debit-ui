import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../services/customer_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/customer_validators.dart';
import '../utils/string_extension.dart';
import '../widgets/app_error_message.dart';
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
  final _nicknameController = TextEditingController();

  // `late`: needs `widget`, which is only available once the State is
  // attached, and should be created once on first use.
  late final _customerService = widget.customerService ?? CustomerService();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _nicknameController.dispose();
    super.dispose();
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
      nickname: _nicknameController.text.nullIfBlank,
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
          builder: (context) => ProfileScreen(
            customer: registered,
            customerService: _customerService,
          ),
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
    // Local copy so the null check promotes `String?` to `String` below.
    final errorMessage = _errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Registration')),
      body: SingleChildScrollView(
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
                validator: CustomerValidators.fullName,
              ),
              const SizedBox(height: AppSpacing.normal),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: CustomerValidators.email,
              ),
              const SizedBox(height: AppSpacing.normal),
              AppTextField(
                controller: _mobileController,
                label: 'Mobile Number',
                keyboardType: TextInputType.phone,
                validator: CustomerValidators.mobileNumber,
              ),
              const SizedBox(height: AppSpacing.normal),
              AppTextField(
                controller: _nicknameController,
                label: 'Nickname (optional)',
                validator: CustomerValidators.nickname,
              ),
              const SizedBox(height: AppSpacing.large),
              if (errorMessage != null) ...[
                AppErrorMessage(
                  key: const ValueKey('registration-error'),
                  message: errorMessage,
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
