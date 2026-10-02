import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../services/customer_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_secondary_button.dart';
import 'edit_profile_screen.dart';

/// Shows the saved customer and owns it: after a successful edit (US-04)
/// this screen replaces its copy and rebuilds.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.customer,
    this.customerService,
  });

  /// The customer as returned by the backend when the profile was opened.
  final Customer customer;
  final CustomerService? customerService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _notProvided = 'Not provided';

  // `late`: assigned in initState, before the first build reads it.
  late Customer _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  Future<void> _openEditProfile() async {
    // Don't let e.g. "Registration successful" cover the Edit form's buttons.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // Edit returns the saved Customer on Save, or null on Cancel/back.
    final updated = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          customer: _customer,
          customerService: widget.customerService,
        ),
      ),
    );
    if (!mounted || updated == null) return;

    setState(() => _customer = updated);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.normal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLabelValue(label: 'Full Name', value: _customer.fullName),
                  const SizedBox(height: AppSpacing.normal),
                  AppLabelValue(label: 'Email', value: _customer.email),
                  const SizedBox(height: AppSpacing.normal),
                  AppLabelValue(
                    label: 'Mobile Number',
                    value: _customer.mobileNumber,
                  ),
                  const SizedBox(height: AppSpacing.normal),
                  AppLabelValue(
                    label: 'Nickname',
                    // US-03: `??` supplies the fallback when nickname is null.
                    value: _customer.nickname ?? _notProvided,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            AppPrimaryButton(
              label: 'Edit Profile',
              onPressed: _openEditProfile,
            ),
            const SizedBox(height: AppSpacing.normal),
            AppSecondaryButton(
              label: 'Back to Registration',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
