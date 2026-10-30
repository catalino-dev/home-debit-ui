import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/account_status/account_status_bloc.dart';
import '../blocs/customer_profile/customer_profile_bloc.dart';
import '../models/customer.dart';
import '../services/account_status_service.dart';
import '../services/customer_profile_service.dart';
import '../services/customer_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_time_extension.dart';
import '../widgets/app_card.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_secondary_button.dart';
import '../widgets/app_status_row.dart';
import 'edit_profile_screen.dart';

/// US-10 customer dashboard: the profile (loaded with retry, US-05/06) and
/// the live account status (US-07).
///
/// This widget only creates the blocs for this route; [_ProfileView] renders
/// their states. Each bloc is closed automatically when the route is popped,
/// which also cancels the status Stream subscription.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.customerId,
    required this.profileService,
    required this.accountStatusService,
    this.customerService,
  });

  final int customerId;
  final CustomerProfileService profileService;
  final AccountStatusService accountStatusService;

  /// Used by Edit Profile to save changes.
  final CustomerService? customerService;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CustomerProfileBloc(
            profileService: profileService,
            customerId: customerId,
          )..add(const CustomerProfileRequested()),
        ),
        BlocProvider(
          create: (_) => AccountStatusBloc(
            statusService: accountStatusService,
            customerId: customerId,
          )..add(const AccountStatusSubscriptionRequested()),
        ),
      ],
      child: _ProfileView(customerService: customerService),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({this.customerService});

  final CustomerService? customerService;

  Future<void> _openEditProfile(BuildContext context, Customer customer) async {
    final bloc = context.read<CustomerProfileBloc>();
    final messenger = ScaffoldMessenger.of(context);
    // Don't let e.g. "Registration successful" cover the Edit form's buttons.
    messenger.hideCurrentSnackBar();
    // Edit returns the saved Customer on Save, or null on Cancel/back.
    final updated = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          customer: customer,
          customerService: customerService,
        ),
      ),
    );
    if (updated == null || bloc.isClosed) return;

    bloc.add(CustomerProfileUpdated(updated));
    messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
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
              const _AccountStatusCard(),
              BlocBuilder<CustomerProfileBloc, CustomerProfileState>(
                builder: (context, state) => switch (state) {
                  CustomerProfileLoading() => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
                    child: AppLoadingView(message: 'Loading your profile...'),
                  ),
                  CustomerProfileLoadFailure(:final message) => AppErrorView(
                    key: const ValueKey('profile-load-error'),
                    message: message,
                    onRetry: () => context.read<CustomerProfileBloc>().add(
                      const CustomerProfileRetryRequested(),
                    ),
                  ),
                  CustomerProfileLoaded(:final customer) => _CustomerDetails(
                    customer: customer,
                    onEdit: () => _openEditProfile(context, customer),
                  ),
                },
              ),
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
}

class _CustomerDetails extends StatelessWidget {
  const _CustomerDetails({required this.customer, required this.onEdit});

  static const _notProvided = 'Not provided';

  final Customer customer;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    // US-03 null safety: `??` picks a fallback whenever nickname is null.
    final greetingName = customer.nickname ?? customer.fullName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.large,
      children: [
        Text('Welcome, $greetingName', style: AppTextStyles.subheadline),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.normal,
            children: [
              AppLabelValue(label: 'Full Name', value: customer.fullName),
              AppLabelValue(label: 'Email', value: customer.email),
              AppLabelValue(
                label: 'Mobile Number',
                value: customer.mobileNumber,
              ),
              AppLabelValue(
                label: 'Nickname',
                value: customer.nickname ?? _notProvided,
              ),
            ],
          ),
        ),
        AppPrimaryButton(label: 'Edit Profile', onPressed: onEdit),
      ],
    );
  }
}

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: const ValueKey('account-status'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.small,
        children: [
          const Text('Account Status', style: AppTextStyles.caption),
          // Rebuilds automatically for every value the Stream emits.
          BlocBuilder<AccountStatusBloc, AccountStatusState>(
            builder: (context, state) => switch (state) {
              AccountStatusInitial() => const AppStatusRow(
                icon: Icons.sync,
                color: AppColorTheme.secondaryText,
                label: 'Checking status...',
              ),
              AccountStatusUnavailable() => const AppStatusRow(
                icon: Icons.sync_problem,
                color: AppColorTheme.errorText,
                label: 'Status unavailable',
              ),
              AccountStatusUpdated(:final status, :final lastSynchronizedAt) =>
                AppStatusRow(
                  icon: status.isSynchronized ? Icons.cloud_done : Icons.sync,
                  color: status.isSynchronized
                      ? AppColorTheme.successText
                      : AppColorTheme.info,
                  label: status.state.label,
                  caption: lastSynchronizedAt == null
                      ? null
                      : 'Last synchronized: '
                            '${lastSynchronizedAt.syncTimestamp}',
                ),
            },
          ),
        ],
      ),
    );
  }
}
