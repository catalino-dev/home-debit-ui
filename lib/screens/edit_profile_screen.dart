import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../services/customer_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/customer_validators.dart';
import '../utils/string_extension.dart';
import '../widgets/app_error_message.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_secondary_button.dart';
import '../widgets/app_text_field.dart';

/// US-04: edits a copy of the profile.
///
/// The text controllers hold the *unsaved draft*. Save persists it and pops
/// with the saved [Customer]; Cancel (or system back) pops with `null`, so
/// the draft is discarded and [ProfileScreen] keeps what it already had.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.customer,
    this.customerService,
  });

  final Customer customer;
  final CustomerService? customerService;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _nicknameController;

  // `late`: needs `widget`, which is only available once the State is
  // attached, and should be created once on first use.
  late CustomerService _customerService;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _customerService = widget.customerService ?? CustomerService();
    final customer = widget.customer;
    _nameController = TextEditingController(text: customer.fullName);
    _emailController = TextEditingController(text: customer.email);
    _mobileController = TextEditingController(text: customer.mobileNumber);
    _nicknameController = TextEditingController(text: customer.nickname ?? '');
  }

  @override
  void didUpdateWidget(covariant EditProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customerService != oldWidget.customerService) {
      _customerService = widget.customerService ?? CustomerService();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final edited = Customer(
      id: widget.customer.id,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      nickname: _nicknameController.text.nullIfBlank,
    );

    try {
      final saved = await _customerService.update(edited);
      if (!mounted) return;
      Navigator.pop(context, saved);
    } on CustomerServiceException catch (exception) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = exception.message;
      });
    } catch (_) {
      // Fallback for uncaught exceptions so the loading state always clears.
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  void _handleCancel() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final errorMessage = _errorMessage;

    // Blocks back navigation mid-save so the saved result can't be dropped.
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          automaticallyImplyLeading: !_isSaving,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.normal),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.normal,
                children: [
                  const Text(
                    'Update your details, then save',
                    style: AppTextStyles.body1,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  AppTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    validator: CustomerValidators.fullName,
                  ),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: CustomerValidators.email,
                  ),
                  AppTextField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    keyboardType: TextInputType.phone,
                    validator: CustomerValidators.mobileNumber,
                  ),
                  AppTextField(
                    controller: _nicknameController,
                    label: 'Nickname (optional)',
                    validator: CustomerValidators.nickname,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  if (errorMessage != null) ...[
                    AppErrorMessage(
                      key: const ValueKey('edit-profile-error'),
                      message: errorMessage,
                    ),
                  ],
                  AppPrimaryButton(
                    label: 'Save',
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                  ),
                  AppSecondaryButton(
                    label: 'Cancel',
                    onPressed: _isSaving ? null : _handleCancel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
