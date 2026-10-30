---
okf_version: "0.1"
---
# Home Debit Documentation

Project documentation for the Home Debit Flutter learning app and its sibling
Spring Boot customer API. The Week 1 brief is the source for exercise goals;
code references describe what is currently implemented.

## Getting started
* [Local development](./local-development.md) — prerequisites, commands, ports, and tests
* [Test evidence and scenarios](./testing.md) — automated results, test cases, and live integration smoke checks
* [Exercise results — screenshots and scenarios](./exercise-results.md) — visual walkthrough of US-01/US-02 against the live app
* [Week 2 exercise results](./week-2-exercise-results.md) — visual walkthrough of US-03/US-04 (optional nickname, edit profile) against the live app
* [Week 3 exercise results](./week-3-exercise-results.md) — visual walkthrough of US-05/US-06 (async profile loading, load errors with Retry) against the live app
* [Week 4 exercise results](./week-4-exercise-results.md) — visual walkthrough of the BLoC customer dashboard (US-07/US-08/US-10) against the live app

## Week 1 exercises
* [Week 1 index](./week-1/index.md) — exercise guides and concept explanations

## Week 2 exercises
* [Week 2 index](./week-2/index.md) — null safety (US-03) and state ownership / editing (US-04)

## Week 3 exercises
* [Week 3 index](./week-3/index.md) — asynchronous loading with `Future`/`async`/`await` (US-05) and error handling with `try`/`catch`/`finally` and Retry (US-06)

## Week 4 exercises
* [Week 4 index](./week-4/index.md) — account status `Stream` (US-07), the `intl` package (US-08), Hot Reload vs Hot Restart (US-09), and the final BLoC dashboard (US-10)

## Frontend
* [Frontend index](./frontend/index.md) — UI architecture, state, forms, and service boundary

## Backend
* [Backend index](./backend/index.md) — service, API, persistence, and configuration

## Current integration status

The Flutter registration flow calls the backend's persistent customer
registration endpoint. Successful responses include the database-generated ID;
duplicate email, backend validation, and network failures remain visible on the
registration form. Since Week 2 the customer has an optional `nickname`, and
the profile can be edited and saved through `PUT /api/customers/{id}`.
Since Week 3 the Profile receives only the customer id and loads the customer
asynchronously through `CustomerProfileService` — by default an in-memory fake
with a 2 s delay and a debug-only failure switch; the real
`GET /api/customers/{id}` is opt-in via `--dart-define=USE_BACKEND_PROFILE=true`.
Since Week 4 the Profile is a customer dashboard driven by two BLoCs
(`flutter_bloc`): `CustomerProfileBloc` (load / Retry / edit updates) and
`AccountStatusBloc` (a fake account-status `Stream`), with the last sync time
formatted by `intl`.
