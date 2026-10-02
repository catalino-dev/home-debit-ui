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

  late final _customerService = widget.customerService ?? CustomerService();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    _nameController = TextEditingController(text: customer.fullName);
    _emailController = TextEditingController(text: customer.email);
    _mobileController = TextEditingController(text: customer.mobileNumber);
    _nicknameController = TextEditingController(text: customer.nickname ?? '');
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.normal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Update your details, then save',
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
                    key: const ValueKey('edit-profile-error'),
                    message: errorMessage,
                  ),
                  const SizedBox(height: AppSpacing.normal),
                ],
                AppPrimaryButton(
                  label: 'Save',
                  isLoading: _isSaving,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: AppSpacing.normal),
                AppSecondaryButton(
                  label: 'Cancel',
                  onPressed: _isSaving ? null : _handleCancel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
