---
type: Reference
title: Frontend architecture
description: Maps the Flutter app's entry point, screens, reusable widgets, model, theme, and service responsibilities.
resource: workspace:home-debit-ui/lib
tags: [flutter, frontend, architecture, home-debit]
timestamp: 2026-09-28T12:00:00+08:00
okf_version: "0.1"
source: ../../lib/main.dart
---
# Frontend architecture

## Component map

| Area | Files | Responsibility |
|---|---|---|
| App bootstrap | `lib/main.dart` | Calls `runApp`, sets the app theme/title, and selects the registration screen. |
| Screens | `lib/screens/` | Registration form and profile display. |
| Reusable UI | `lib/widgets/` | Shared card, text input, and primary button components. |
| Domain data | `lib/models/customer.dart` | Immutable customer values passed between screens. |
| API configuration | `lib/config/api_config.dart` | Selects a platform-aware local API URL with an optional `API_BASE_URL` override. |
| Service boundary | `lib/services/customer_service.dart` | Posts registrations and maps responses/errors from the Spring API. |
| Theme | `lib/theme/` | Shared colors, spacing, text styles, and Material theme. |
| Tests | `test/` | Mocked HTTP service and widget checks for validation, response mapping, errors, and profile navigation. |

## Runtime flow

1. `main()` mounts `MyApp`.
2. `MaterialApp.home` displays `RegistrationScreen`.
3. The stateful registration screen validates inputs and creates a `Customer`.
4. `CustomerService.register` sends the registration fields to
   `POST /api/customers` and maps the persisted JSON response to a `Customer`
   including its generated ID.
5. The screen displays a success `SnackBar` and pushes `ProfileScreen`,
   passing the returned backend customer. API and network failures are shown
   on the form without navigating away.
6. The profile displays the model fields and can pop back to registration.

## Design decisions

* Screen-specific mutable state (`_isSubmitting`) stays in
  `_RegistrationScreenState`; `setState` rebuilds the button as loading state
  changes.
* The profile screen is stateless because it only renders constructor input.
* The reusable widgets centralize repeated input/button presentation.
* The service class isolates HTTP, backend response mapping, and transport
  errors from the UI.
* `API_BASE_URL` supports environment-specific API hosts; defaults account for
  web and Android emulator networking.
* Controllers are disposed by the owning screen.

## Backend integration boundary

The backend exposes `POST /api/customers` and `GET /api/customers/{id}`. The
registration operation is integrated; profile display still uses the response
passed from the registration screen. The backend allows local Flutter web
origins through configurable CORS patterns. See
[Backend service overview](../backend/backend-service-overview.md) and
[Customer API](../backend/customer-api.md).

# Citations

[1][Flutter entry point](../../lib/main.dart)
[2][Registration screen](../../lib/screens/registration_screen.dart)
[3][Customer service](../../lib/services/customer_service.dart)
