---
type: Playbook
title: Local development
description: Runs the Home Debit Flutter UI, Spring Boot backend, and PostgreSQL database locally.
resource: workspace:home-debit-ui-and-home-debit
tags: [home-debit, local-development, flutter, spring-boot, postgresql]
timestamp: 2026-09-28T12:00:00+08:00
okf_version: "0.1"
source: ../README.md
---
# Local development

## Prerequisites

| Tool | Requirement | Used by |
|---|---|---|
| Flutter / Dart | Flutter compatible with Dart `^3.13.3` | UI |
| Java | JDK 25 | Backend |
| Docker with Compose | Available and running | Local PostgreSQL; backend integration tests |

The backend Gradle wrapper downloads the configured Gradle distribution when
needed. The database is defined in the sibling `home-debit/docker-compose.yml`.

## Run the database

In PowerShell, from `home-debit`:

```powershell
docker compose up -d
docker compose ps
```

PostgreSQL is exposed on port `5432`. The compose file configures a local
database named `home_debit`; these credentials are development-only and must
not be reused for a shared or production environment. Flyway applies database
migrations at backend startup.

## Run the backend

From `home-debit`, with JDK 25 selected:

```powershell
.\gradlew.bat bootRun
```

The service listens on `http://localhost:8080`. Customer endpoints are under
`/api/customers`; see [Customer API](./backend/customer-api.md).

## Run the Flutter UI

From `home-debit-ui`:

```powershell
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5100 `
  --dart-define=API_BASE_URL=http://localhost:8080
```

Open `http://127.0.0.1:5100/`. The form submits registrations to
`POST http://localhost:8080/api/customers`; the backend and PostgreSQL
container must be running for registration to succeed.

### API host selection

`API_BASE_URL` is an optional Flutter compile-time setting. Without an
override, the UI uses `http://localhost:8080` on web, desktop, and iOS
simulator targets, and `http://10.0.2.2:8080` on Android emulators. For a
physical Android device, pass the development machine's reachable IP address,
for example `--dart-define=API_BASE_URL=http://192.168.1.20:8080`, and ensure
the machine firewall permits that connection. The Android debug manifest
allows cleartext HTTP for local development; production deployments should use
HTTPS. Physical iOS devices may require an HTTPS endpoint or an explicit
development-only App Transport Security exception.

For a different web development port or host, the backend's
`home-debit.cors.allowed-origin-patterns` setting can be overridden in the
usual Spring configuration to include that origin. The default permits
`localhost` and `127.0.0.1` origins over HTTP on any port; it does not allow
arbitrary remote websites.

## Verify changes

From `home-debit-ui`:

```powershell
flutter analyze
flutter test
```

From `home-debit`:

```powershell
.\gradlew.bat test
```

The backend tests use Testcontainers with `postgres:17-alpine`, so Docker must
be available. Flutter tests mock HTTP and cover the request/response mapping,
successful profile navigation, duplicate email, network and validation
errors, empty required fields, and invalid email/mobile input.

See [Test evidence and scenarios](./testing.md) for recorded results and
step-by-step test scenarios.

## Stop local services

Stop the UI/backend with `Ctrl+C` in their run terminals. To stop the database
container while preserving its named volume:

```powershell
docker compose down
```

## Registration flow

The Flutter form sends the validated customer fields to the backend. The
backend persists them in PostgreSQL and returns the generated customer ID with
the customer data. On success, the UI shows a success message and opens the
profile using the backend response. API, validation, duplicate-email, and
network failures are shown on the registration screen; the form stays open so
the user can correct or retry.
