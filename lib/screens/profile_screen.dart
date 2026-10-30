import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../services/customer_profile_service.dart';
import '../services/customer_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_secondary_button.dart';
import 'edit_profile_screen.dart';

/// Loads the customer asynchronously (US-05), shows a recoverable error with
/// Retry when that fails (US-06), and owns the loaded customer so a
/// successful edit (US-04) can replace it.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.customerId,
    required this.profileService,
    this.customerService,
  });

  final int customerId;
  final CustomerProfileService profileService;

  /// Used by Edit Profile to save changes.
  final CustomerService? customerService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _notProvided = 'Not provided';
  static const _unexpectedErrorMessage =
      'Something went wrong while loading your profile. Please try again.';

  // Exactly one of these drives the body: loading, error, or the customer.
  // Starts loading because the load begins as soon as the screen opens.
  bool _isLoading = true;
  String? _errorMessage;
  Customer? _customer;
  int _loadGeneration = 0;
  @override
  void initState() {
    super.initState();
    // Not awaited: initState must return synchronously, and the UI must
    // stay responsive (showing the loading state) while the Future runs.
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customerId != oldWidget.customerId ||
        widget.profileService != oldWidget.profileService) {
      _retry();
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadProfile();
  }

  /// US-05/US-06: the whole loading -> success/error flow.
  Future<void> _loadProfile() async {
    // A newer load (e.g. after the customer id changed) supersedes this one.
    final generation = ++_loadGeneration;
    bool isCurrent() => mounted && generation == _loadGeneration;

    try {
      // A `Future<Customer>` is only a promise; `await` suspends here until
      // it completes and unwraps the actual `Customer` (or rethrows).
      final customer = await widget.profileService.loadProfile(
        widget.customerId,
      );
      if (!isCurrent()) return;
      setState(() => _customer = customer);
    } on CustomerServiceException catch (exception) {
      if (!isCurrent()) return;
      setState(() => _errorMessage = exception.message);
    } catch (_) {
      // Anything unexpected still becomes a visible, retryable error.
      if (!isCurrent()) return;
      setState(() => _errorMessage = _unexpectedErrorMessage);
    } finally {
      // Runs after success *and* failure, so loading can never get stuck.
      if (isCurrent()) setState(() => _isLoading = false);
    }
  }

  Future<void> _openEditProfile(Customer customer) async {
    // Don't let e.g. "Registration successful" cover the Edit form's buttons.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // Edit returns the saved Customer on Save, or null on Cancel/back.
    final updated = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          customer: customer,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.normal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.large,
            children: [
              ..._buildContent(),
              AppSecondaryButton(
                label: 'Back to Registration',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    // Local copies so the null checks promote to non-nullable types.
    final errorMessage = _errorMessage;
    final customer = _customer;

    if (_isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
          child: AppLoadingView(message: 'Loading your profile...'),
        ),
      ];
    }
    if (errorMessage != null) {
      return [
        AppErrorView(
          key: const ValueKey('profile-load-error'),
          message: errorMessage,
          onRetry: _retry,
        ),
      ];
    }
    if (customer == null) return const [];

    return [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.normal,
          children: [
            AppLabelValue(label: 'Full Name', value: customer.fullName),
            AppLabelValue(label: 'Email', value: customer.email),
            AppLabelValue(label: 'Mobile Number', value: customer.mobileNumber),
            AppLabelValue(
              label: 'Nickname',
              // US-03: `??` supplies the fallback when nickname is null.
              value: customer.nickname ?? _notProvided,
            ),
          ],
        ),
      ),
      AppPrimaryButton(
        label: 'Edit Profile',
        onPressed: () => _openEditProfile(customer),
      ),
    ];
  }
}
