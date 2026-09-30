---
type: Playbook
title: Customer model and screen navigation
description: Explains the Customer data object, BuildContext, Navigator routes, and constructor-based profile data passing.
resource: workspace:home-debit-ui/week-1/us-02
tags: [flutter, week-1, customer, navigation, buildcontext]
timestamp: 2026-09-28T12:00:00+08:00
okf_version: "0.1"
source: ../../lib/models/customer.dart
---
# Customer model and screen navigation (US-02)

## Customer model

`Customer` is an immutable Dart class with three required `String` fields:
`fullName`, `email`, and `mobileNumber`. The registration flow creates one
instance and passes it to the profile screen rather than hardcoding display
values there.

## Navigate and pass data

After registration completes, the registration screen creates a route with
`Navigator.push` and supplies `ProfileScreen(customer: registered)` in the
route builder. `ProfileScreen` receives the required object in its
constructor and renders its fields. The Back button calls `Navigator.pop` to
remove that route and return to registration.

The registered `Customer` passed to the profile is the backend's response, so
it carries the database-generated `id`; the profile renders it directly
rather than re-fetching with `GET /api/customers/{id}`.

> **Week 2 update:** `Customer` gained an optional `String? nickname`
> ([US-03](../week-2/optional-customer-information.md)), and the profile
> screen now owns the customer and can edit it, receiving the saved result
> back through `Navigator.pop` ([US-04](../week-2/edit-customer-profile.md)).

## What `BuildContext` does here

`BuildContext` represents a widget's position in the widget tree. APIs such as
`Navigator.of(context)` and `ScaffoldMessenger.of(context)` use it to find the
nearest matching ancestor. The context passed to `Navigator.push` locates the
navigation system for the current screen; the profile screen's context locates
the Navigator used by `Navigator.pop`.

## Acceptance checks

* Successful registration opens the profile.
* The profile displays the exact submitted name, email, and mobile number.
* The route receives one `Customer` object through its required constructor
  argument.
* The profile's Back action returns to registration.

## Sources

* [Customer model](../../lib/models/customer.dart)
* [Registration and navigation](../../lib/screens/registration_screen.dart)
* [Profile screen](../../lib/screens/profile_screen.dart)

# Citations

[1][Week 1 training brief](../../../../../Downloads/Flutter_4_Week_Training_Developer_Week_1.docx)
[2][Customer model](../../lib/models/customer.dart)
