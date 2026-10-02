---
type: Playbook
title: Customer registration exercise
description: Describes the registration form, input validation, loading state, and Week 1 acceptance checks.
resource: workspace:home-debit-ui/week-1/us-01
tags: [flutter, week-1, customer, registration, validation]
timestamp: 2026-09-28T12:00:00+08:00
okf_version: "0.1"
source: ../../lib/screens/registration_screen.dart
---
# Customer registration exercise (US-01)

## Story and expected behavior

A customer enters a full name, email address, and mobile number to create a
profile. The registration screen is shown at startup; pressing **Register**
validates the form, creates one `Customer` object, shows a success message,
and proceeds to the profile screen.

## Form structure

`RegistrationScreen` owns a `GlobalKey<FormState>` and one
`TextEditingController` for each field. It composes reusable
`AppTextField` and `AppPrimaryButton` widgets inside a `Form` and `Column`.
The controllers are disposed when the screen is removed.

## Validation rules

| Field | Rule | Current error text |
|---|---|---|
| Full Name | Required; whitespace-only values are rejected. | `Full name is required` |
| Email | Required and must match a basic `local@domain.tld` pattern. | `Email is required` / `Enter a valid email address` |
| Mobile Number | Required and must contain 7–15 digits. | `Mobile number is required` / `Enter a valid mobile number (digits only)` |

These are client-side training-app checks, not a complete email or phone
verification system. The backend also validates registration requests; see
[Customer API](../backend/customer-api.md).

## State and submission

If validation fails, `_handleRegister` returns without creating or submitting
a customer. For valid input, it sets `_isSubmitting` with `setState`, creates
the model from trimmed controller values, and calls `CustomerService.register`.
The primary button disables and shows a spinner while the operation is pending.
After completion, the screen shows a `SnackBar` that includes the customer's
name and navigates to the profile.

`CustomerService` posts valid form data to the backend. The profile receives
the persisted customer returned by the API. Duplicate-email, backend
validation, and network failures are shown on the registration form, which
remains available for correction or retry.

## Acceptance criteria and test coverage

| Acceptance criterion | Implementation / verification |
|---|---|
| Registration screen appears on startup. | `MyApp` uses `RegistrationScreen` as `MaterialApp.home`; widget tests assert the screen title. |
| Fields accept input. | `TextFormField` controllers capture the entered values. |
| Empty/invalid values are handled. | Validators cover required fields, email format, and mobile digits/length; tests cover empty fields and malformed email/mobile. |
| Successful registration identifies the customer. | `_handleRegister` shows a success `SnackBar` containing the returned customer's name. |
| Success navigates to profile with submitted values. | The `Customer` is passed into `ProfileScreen`; widget test checks the displayed name, email, and mobile. |
| Registration is persisted by the backend. | The service posts the three API fields; the backend integration suite verifies persistence and the Flutter service test verifies the request/response contract. |
| API failures remain visible without navigation. | Widget tests cover duplicate email, backend validation, and network errors. |

Run `flutter test` from `home-debit-ui` to exercise the HTTP contract, normal
flow, validation, and API failure cases. See [Test evidence and scenarios](../testing.md)
for the recorded results and detailed scenarios.

## Sources

* [Registration screen](../../lib/screens/registration_screen.dart)
* [Customer service](../../lib/services/customer_service.dart)
* [Widget tests](../../test/widget_test.dart)

# Citations

[1][Week 1 training brief](../../../../../Downloads/Flutter_4_Week_Training_Developer_Week_1.docx)
[2][Registration implementation](../../lib/screens/registration_screen.dart)
