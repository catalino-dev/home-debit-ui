---
type: Reference
title: Frontend architecture
description: Maps the Flutter app's entry point, screens, reusable widgets, model, utilities, theme, and service responsibilities, including Week 2 profile editing.
resource: workspace:home-debit-ui/lib
tags: [flutter, frontend, architecture, home-debit]
timestamp: 2026-09-30T17:30:00+08:00
okf_version: "0.1"
source: ../../lib/main.dart
---
# Frontend architecture

## Component map

| Area | Files | Responsibility |
|---|---|---|
| App bootstrap | `lib/main.dart` | Calls `runApp`, sets the app theme/title, and selects the registration screen. |
| Screens | `lib/screens/` | Registration form, profile display, and profile editing (`edit_profile_screen.dart`). |
| Reusable UI | `lib/widgets/` | `AppCard`/`AppLabelValue`, `AppTextField`, `AppPrimaryButton`, `AppSecondaryButton`, `AppErrorMessage`. |
| Domain data | `lib/models/customer.dart` | Immutable customer values (`int? id`, three required strings, `String? nickname`) with JSON mapping and value equality. |
| Utilities | `lib/utils/` | `CustomerValidators` (shared by Registration and Edit) and the `nullIfBlank` string extension. |
| API configuration | `lib/config/api_config.dart` | Selects a platform-aware local API URL with an optional `API_BASE_URL` override. |
| Service boundary | `lib/services/customer_service.dart` | `register` (`POST`) and `update` (`PUT`), mapping responses and errors from the Spring API. |
| Theme | `lib/theme/` | Shared colors, spacing, text styles, and Material theme. |
| Tests | `test/` | Mocked HTTP service tests, model/utility tests, Week 1 widget tests (`widget_test.dart`), Week 2 widget tests (`profile_edit_test.dart`). |

## Runtime flow

1. `main()` mounts `MyApp`.
2. `MaterialApp.home` displays `RegistrationScreen`.
3. The stateful registration screen validates inputs and creates a `Customer`
   (the optional nickname becomes `null` when blank).
4. `CustomerService.register` sends `POST /api/customers` and maps the
   persisted JSON response to a `Customer` including its generated ID.
5. The screen displays a success `SnackBar` and pushes `ProfileScreen`,
   passing the returned backend customer and the same `CustomerService`. API
   and network failures are shown on the form without navigating away.
6. The profile displays the model fields — nickname or `Not provided` — and
   can pop back to registration.
7. **Edit Profile** pushes `EditProfileScreen` with the current customer.
   Save calls `CustomerService.update` (`PUT /api/customers/{id}`) and pops
   with the saved customer; the profile replaces its state with it. Cancel
   pops with no result and the profile is unchanged.

## Design decisions

* Screen-specific mutable state (`_isSubmitting`, `_isSaving`,
  `_errorMessage`) stays in each screen's `State`; `setState` rebuilds as it
  changes.
* `ProfileScreen` became a `StatefulWidget` in Week 2 because it owns the
  **saved** customer and must replace it after an edit. The **unsaved** draft
  lives only in `EditProfileScreen`'s controllers, so Cancel discards it. See
  [Edit customer profile (US-04)](../week-2/edit-customer-profile.md).
* Only genuinely optional data is nullable (`id`, `nickname`); see
  [Optional customer information (US-03)](../week-2/optional-customer-information.md).
* The reusable widgets centralize input/button/error presentation so screens
  don't use raw Material buttons or inline colors.
* The service class isolates HTTP, backend response mapping, and transport
  errors from the UI; `register` and `update` share one transport/error path.
* `API_BASE_URL` supports environment-specific API hosts; defaults account for
  web and Android emulator networking.
* Controllers are created in `initState` (or as fields) and disposed by the
  owning screen.

## Backend integration boundary

The backend exposes `POST /api/customers`, `GET /api/customers/{id}`, and
`PUT /api/customers/{id}`. Registration and profile editing are integrated;
the profile displays the backend response from the latest register/update
call rather than re-fetching with `GET`. The backend allows local Flutter web
origins through configurable CORS patterns. See
[Backend service overview](../backend/backend-service-overview.md) and
[Customer API](../backend/customer-api.md).

# Citations

[1][Flutter entry point](../../lib/main.dart)
[2][Registration screen](../../lib/screens/registration_screen.dart)
[3][Edit profile screen](../../lib/screens/edit_profile_screen.dart)
[4][Customer service](../../lib/services/customer_service.dart)