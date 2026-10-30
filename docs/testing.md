---
type: Playbook
title: Test evidence and scenarios
description: Records automated verification and repeatable test scenarios for Flutter registration, optional nickname, profile editing, and Spring Boot persistence.
resource: workspace:home-debit-ui-and-home-debit/tests
tags: [home-debit, testing, flutter, spring-boot, postgresql]
timestamp: 2026-10-30T16:00:00+08:00
okf_version: "0.1"
source: ../test/widget_test.dart
---
# Test evidence and scenarios

This page records the most recent verification of the Flutter UI, Spring Boot
API, and their local database integration. Flutter tests mock HTTP; the
separate browser smoke test exercised the running UI, backend, and PostgreSQL.

## Automated test results

| Project | Command | Result | Coverage |
|---|---|---|---|
| Flutter UI | `flutter analyze` | **PASS** — no issues found. | Static analysis of app and tests. |
| Flutter UI | `flutter test` | **PASS** — all 74 tests passed (Week 4). | HTTP contract (register, update, `loadProfile`), `savedCustomers` stream, fake profile and account-status services, BLoC event → state flows, `intl` formatting, model/utility behavior, form validation, navigation, optional nickname, Edit/Save/Cancel, async profile loading, load errors with Retry, live account status, and visible API/network failures. |
| Spring Boot backend | `.\gradlew.bat test` from `home-debit`, with JDK 25 | **PASS** — `BUILD SUCCESSFUL`; 18 tests, 0 failures (Week 2). | Controller integration tests using PostgreSQL Testcontainers: validation, nickname, persistence/readback, update, duplicate email, not-found, and CORS (incl. `PUT`). |
| Flutter Web | `flutter build web --release --dart-define=API_BASE_URL=http://localhost:8080` | **PASS**. | Release web build configured for the local API. |

The frontend suite verifies client behavior with a mocked HTTP client. Backend
integration tests verify server/database behavior independently. The live
smoke test below verifies those components work together in the local setup.

## Flutter HTTP service scenarios

Tests: `test/customer_service_test.dart`.

| Scenario | Action / input | Expected result |
|---|---|---|
| Send registration | Register a customer model. | Sends JSON `POST /api/customers` with `fullName`, `email`, `mobileNumber`, and `nickname` (may be `null`). |
| Successful response | Backend returns `201` and JSON including `id`. | Returns a `Customer` containing the generated ID and matching profile values. |
| Duplicate email | Backend returns `409`. | Throws a service exception with an actionable duplicate-email message. |
| Backend validation failure | Backend returns `400` with a JSON detail. | Throws a service exception exposing the validation detail. |
| Network failure | HTTP client throws `ClientException`. | Throws a service exception advising the user to check backend connectivity. |
| Send update (Week 2) | Update a customer with an `id`. | Sends JSON `PUT /api/customers/{id}` and returns the `200` response as a `Customer`. |
| Update without ID | Update a customer whose `id` is `null`. | Throws `ArgumentError`; no request is sent. |
| Update not found / duplicate / validation | Backend returns `404`, `409`, or `400`. | Throws service exceptions with re-register, duplicate-email, or validation-detail messages. |

Model and utility tests (`test/customer_test.dart`) cover nullable nickname
JSON mapping, `toRequestJson`, value equality, and `nullIfBlank`.

## Flutter widget scenarios

Tests: `test/widget_test.dart`.

| Scenario | Action / input | Expected result |
|---|---|---|
| Required fields empty | Press Register with all fields blank. | Shows required-field errors; does not navigate. |
| Invalid values | Enter an invalid email and non-digit mobile number, then register. | Shows email/mobile validation messages; stays on registration. |
| Normal registration | Enter valid details; mock API returns `201` with customer data. | Shows success message, navigates to Profile, and displays submitted name, email, and mobile. |
| API validation error | Valid-looking form; API returns `400`. | Shows the API validation error; remains on registration. |
| Duplicate email | Valid-looking form; API returns `409`. | Shows duplicate-email guidance; does not navigate. |
| API unavailable | HTTP client fails. | Shows a network error, remains on registration, and enables retry. |

## Week 2 widget scenarios

Tests: `test/profile_edit_test.dart`.

| Story | Scenario | Expected result |
|---|---|---|
| US-03 | Register without nickname. | Request sends `nickname: null`; profile shows **Not provided**. |
| US-03 | Register with nickname. | Profile shows the nickname. |
| US-03 | Nickname longer than 50 characters. | Validation error; no request sent. |
| US-04 | Open Edit Profile. | All four fields prefilled; empty nickname field when `null`. |
| US-04 | Save valid changes. | `PUT` sent; profile shows new values and **Profile updated**. |
| US-04 | Clear nickname and save. | Profile shows **Not provided** again. |
| US-04 | Cancel after typing. | No request; profile shows the original values. |
| US-04 | Invalid edit. | Field errors shown; no request sent. |
| US-04 | Save fails with `409`. | Error shown on Edit; stays on Edit; profile unchanged after Cancel. |
| US-04 | Back pressed while Save is in progress. | Back is blocked (`PopScope`); the saved result still reaches the profile. |

## Week 3 scenarios

Tests: `test/fake_customer_profile_service_test.dart`,
`test/customer_service_test.dart` (`loadProfile`, `savedCustomers`), and
`test/profile_loading_test.dart`.

| Story | Scenario | Expected result |
|---|---|---|
| US-05 | Fake `loadProfile` before / after the delay. | Not completed before the delay; completes with the customer after it. |
| US-05 | Customer arrives via `savedCustomers` or `save`; saved again after an edit. | Fake returns it; returns the latest version. |
| US-05 | `CustomerService.loadProfile` 200 / 404 / 500 / network. | `Customer` / profile-missing / retryable / backend-not-running messages. |
| US-05 | `savedCustomers` on register + update; on a rejected save. | Emits both confirmed customers; emits nothing for a `409`. |
| US-05 | Open Profile with a pending `Future`. | Spinner + *Loading your profile...*; customer shown after completion. |
| US-05 | Tap Back while loading. | Navigates back; no crash. |
| US-06 | Load throws `CustomerServiceException`. | Message + Retry; loading cleared; no exception escapes. |
| US-06 | Retry then success / Retry then failure. | Loading → customer / the new error with Retry. |
| US-06 | Load throws an unexpected `StateError`. | Generic message; internal text not shown. |
| US-06 | Fake `failNextLoad`. | Exactly one load fails, then the flag resets. |
| US-05/06 | End to end through `MyApp` with the debug switch. | Register → loading → error → Retry → customer. |

## Week 4 scenarios

Tests: `test/blocs/customer_profile_bloc_test.dart`,
`test/blocs/account_status_bloc_test.dart`,
`test/fake_account_status_service_test.dart`,
`test/date_time_extension_test.dart`, and `test/dashboard_test.dart`.

| Story | Scenario | Expected result |
|---|---|---|
| US-10 | `CustomerProfileRequested` with success / service failure / unexpected error. | `Loaded(customer)` / `LoadFailure(message)` / generic `LoadFailure`. |
| US-10 | `CustomerProfileRetryRequested` after a failure; when not failed. | `Loading` → `Loaded`; ignored (no service call). |
| US-10 | `CustomerProfileUpdated`. | `Loaded(updated)` with no reload. |
| US-07 | Status stream emits synchronizing, synchronized, synchronizing. | One `Updated` per value; last sync time kept while re-syncing. |
| US-07 | Status stream error; bloc closed. | `Unavailable`; subscription cancelled. |
| US-07 | Fake status service over time; after cancel. | Alternating values; no more values after cancel. |
| US-08 | `syncTimestamp` for PM / AM times. | `30 Oct 2026, 2:31:05 PM` / `2 Jan 2026, 9:05:00 AM`. |
| US-07 | Dashboard with the fake stream. | Card changes automatically; *Last synchronized* formatted; no refresh control. |
| US-10 | Dashboard with nickname. | `Welcome, <nickname>`; status independent of profile loading. |
| US-07 | Status stream error on the dashboard. | *Status unavailable*; profile still shown. |
| US-07 | Leave the dashboard. | Status subscription cancelled. |

## Backend integration scenarios

Tests:
`home-debit/src/test/java/ph/hcph/homedebit/customer/CustomerControllerTests.java`.
The suite runs against a PostgreSQL Testcontainers database with Flyway
migrations applied.

| Scenario | Request | Expected result |
|---|---|---|
| Blank registration | `POST /api/customers` with blank required fields. | `400 Bad Request`. |
| Create and read | Register valid data, then `GET /api/customers/{id}`. | Creation returns `201`; lookup returns matching profile fields. |
| Unknown customer | `GET /api/customers/999999`. | `404 Not Found`. |
| Persistence | Register, then fetch the returned ID in a separate request. | Stored customer remains available from PostgreSQL. |
| Duplicate email | Submit the same email twice. | First request succeeds; second returns `409 Conflict`. |
| Browser preflight | `OPTIONS /api/customers` from `http://127.0.0.1:5100` requesting a JSON POST. | `200 OK` and CORS headers allow that origin and `POST`. |
| Nickname optional (Week 2) | Register without / with blank / with nickname; 51-char nickname. | Stored as `null` / `null` / trimmed value; 51 chars returns `400`. |
| Update (Week 2) | `PUT /api/customers/{id}` with valid data. | `200`; subsequent `GET` returns new values. |
| Update clears nickname | `PUT` with blank nickname. | Nickname stored as `null`. |
| Update keeps own email | `PUT` with the customer's current email. | `200` (not a conflict). |
| Update to another customer's email | `PUT` with an email owned by a different ID. | `409 Conflict`; record unchanged. |
| Update invalid / unknown | Blank fields; unknown ID. | `400`; `404`. |
| PUT preflight | `OPTIONS /api/customers/{id}` requesting `PUT`. | `200 OK`; allowed methods include `PUT`. |

## Live UI-to-database smoke scenario

**Result: PASS** against the local Flutter web app at
`http://127.0.0.1:5100`, backend at `http://localhost:8080`, and PostgreSQL on
port `5432`.

| Step | Action | Observed result |
|---|---|---|
| 1 | Entered valid synthetic customer details in the browser UI and selected Register. | Browser issued `POST /api/customers`. |
| 2 | Checked the registration response. | **HTTP 201**, with generated ID and submitted profile values. |
| 3 | Checked the UI. | Navigated to Customer Profile and displayed the submitted name, email, and mobile. |
| 4 | Requested `GET /api/customers/{id}` for the returned ID. | **HTTP 200**, with values matching the UI submission. |
| 5 | Repeated registration using the same email. | **HTTP 409 Conflict**. |
| 6 | Sent the browser CORS preflight from the UI origin. | **HTTP 200**, matching allowed origin; Week 2 run returns `GET,POST,PUT,OPTIONS`. |

### Week 2 live smoke

**Result: PASS** (2026-09-30) against the same local stack after Flyway `V2`
added the nullable `nickname` column. Screenshots are in
[Week 2 exercise results](./week-2-exercise-results.md).

| Step | Action | Observed result |
|---|---|---|
| 1 | Registered a customer without a nickname. | Profile shows **Not provided**; DB `nickname` is `NULL`. |
| 2 | Opened Edit Profile, typed a draft, selected Cancel. | Profile unchanged; no `PUT` issued; DB unchanged. |
| 3 | Edited mobile + nickname and selected Save. | `PUT` returned **200**; profile updated with **Profile updated** SnackBar; DB updated. |
| 4 | Edited email to another customer's email and saved. | **HTTP 409**; error shown on Edit; DB unchanged. |
| 5 | Registered a customer with a nickname. | Profile shows the nickname; DB stores it. |

### Week 3 live smoke

**Result: PASS** (2026-10-30). Screenshots are in
[Week 3 exercise results](./week-3-exercise-results.md).

| Step | Action | Observed result |
|---|---|---|
| 1 | Registered a customer with the failure switch off. | `POST` **201** (`id=21`); Profile showed the loading state, then the customer. |
| 2 | Turned the switch on and registered a second customer. | `POST` **201** (`id=22`); Profile showed the load error and Retry. |
| 3 | Selected Retry. | Loading again, then the customer; DB rows match. |

### Week 4 live smoke

**Result: PASS** (2026-10-30). Screenshots are in
[Week 4 exercise results](./week-4-exercise-results.md).

| Step | Action | Observed result |
|---|---|---|
| 1 | Registered a customer with a nickname. | `POST` **201** (`id=24`); status streaming while the profile loaded; then *Synchronized* with a formatted time and `Welcome, Annie`. |
| 2 | Waited without interacting. | Status changed to *Synchronizing...* automatically. |
| 3 | Failure switch on; registered another customer; Retry. | `POST` **201** (`id=25`); error + Retry; then the profile. |
| 4 | Edit Profile → nickname → Save. | `PUT /api/customers/25` **200**; `Welcome, Juanito`; DB row updated. |

The smoke-test customers used synthetic example data and remains in the local
development database until that record or database volume is removed.

## Known platform build limitation

`flutter build apk --debug` did **not** complete during the recorded
verification. Gradle stopped at `android/settings.gradle.kts:20` because of a
settings-repository and `mavenLocal` conflict. The Web target is verified;
Android APK output is not.

## References

* [Flutter HTTP service tests](../test/customer_service_test.dart)
* [Flutter widget tests](../test/widget_test.dart)
* [Week 2 widget tests](../test/profile_edit_test.dart)
* [Week 3 profile loading tests](../test/profile_loading_test.dart)
* [Week 4 dashboard tests](../test/dashboard_test.dart)
* [Backend controller integration tests](../../home-debit/src/test/java/ph/hcph/homedebit/customer/CustomerControllerTests.java)
* [Customer API](./backend/customer-api.md)
* [Local development](./local-development.md)

# Citations

[1][Flutter HTTP service tests](../test/customer_service_test.dart)
[2][Flutter widget tests](../test/widget_test.dart)
[3][Backend integration tests](../../home-debit/src/test/java/ph/hcph/homedebit/customer/CustomerControllerTests.java)
[4][Week 2 widget tests](../test/profile_edit_test.dart)
