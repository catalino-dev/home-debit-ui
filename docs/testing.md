---
type: Playbook
title: Test evidence and scenarios
description: Records automated verification and repeatable test scenarios for Flutter registration and Spring Boot persistence.
resource: workspace:home-debit-ui-and-home-debit/tests
tags: [home-debit, testing, flutter, spring-boot, postgresql]
timestamp: 2026-09-28T13:00:00+08:00
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
| Flutter UI | `flutter test` | **PASS** — all 10 tests passed. | HTTP contract, form validation, success navigation, and visible API/network failures. |
| Spring Boot backend | `.\gradlew.bat test` from `home-debit`, with JDK 25 | **PASS** — `BUILD SUCCESSFUL`; last recorded run reported `:test UP-TO-DATE`. | Controller integration tests using PostgreSQL Testcontainers, validation, persistence/readback, duplicate email, not-found, and CORS. |
| Flutter Web | `flutter build web --release --dart-define=API_BASE_URL=http://localhost:8080` | **PASS**. | Release web build configured for the local API. |

The frontend suite verifies client behavior with a mocked HTTP client. Backend
integration tests verify server/database behavior independently. The live
smoke test below verifies those components work together in the local setup.

## Flutter HTTP service scenarios

Tests: `test/customer_service_test.dart`.

| Scenario | Action / input | Expected result |
|---|---|---|
| Send registration | Register a customer model. | Sends JSON `POST /api/customers` with `fullName`, `email`, and `mobileNumber`. |
| Successful response | Backend returns `201` and JSON including `id`. | Returns a `Customer` containing the generated ID and matching profile values. |
| Duplicate email | Backend returns `409`. | Throws a service exception with an actionable duplicate-email message. |
| Backend validation failure | Backend returns `400` with a JSON detail. | Throws a service exception exposing the validation detail. |
| Network failure | HTTP client throws `ClientException`. | Throws a service exception advising the user to check backend connectivity. |

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
| 6 | Sent the browser CORS preflight from the UI origin. | **HTTP 200**, matching allowed origin and `GET,POST,OPTIONS` methods. |

The smoke-test customer used synthetic example data and remains in the local
development database until that record or database volume is removed.

## Known platform build limitation

`flutter build apk --debug` did **not** complete during the recorded
verification. Gradle stopped at `android/settings.gradle.kts:20` because of a
settings-repository and `mavenLocal` conflict. The Web target is verified;
Android APK output is not.

## References

* [Flutter HTTP service tests](../test/customer_service_test.dart)
* [Flutter widget tests](../test/widget_test.dart)
* [Backend controller integration tests](../../home-debit/src/test/java/ph/hcph/homedebit/customer/CustomerControllerTests.java)
* [Customer API](./backend/customer-api.md)
* [Local development](./local-development.md)

# Citations

[1][Flutter HTTP service tests](../test/customer_service_test.dart)
[2][Flutter widget tests](../test/widget_test.dart)
[3][Backend integration tests](../../home-debit/src/test/java/ph/hcph/homedebit/customer/CustomerControllerTests.java)
