import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  final Customer customer;

  const ProfileScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.normal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLabelValue(label: 'Full Name', value: customer.fullName),
                  const SizedBox(height: AppSpacing.normal),
                  AppLabelValue(label: 'Email', value: customer.email),
                  const SizedBox(height: AppSpacing.normal),
                  AppLabelValue(
                    label: 'Mobile Number',
                    value: customer.mobileNumber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColorTheme.brand,
                side: const BorderSide(color: AppColorTheme.brand),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.normal,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
