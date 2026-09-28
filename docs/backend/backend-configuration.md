---
type: Configuration
title: Backend configuration
description: Lists the Spring Boot runtime settings and PostgreSQL defaults used by the local Home Debit backend.
resource: workspace:home-debit/src/main/resources/application.yml
tags: [home-debit, configuration, local-development, postgresql]
timestamp: 2026-09-28T12:00:00+08:00
okf_version: "0.1"
source: ../../../home-debit/src/main/resources/application.yml
---
# Backend configuration

## Application properties

| Key | Current value | Purpose |
|---|---|---|
| `spring.application.name` | `home-debit` | Spring application name. |
| `spring.datasource.url` | `jdbc:postgresql://localhost:5432/home_debit` | Local PostgreSQL connection. |
| `spring.datasource.username` | `home_debit` | Local database user. |
| `spring.datasource.password` | Configured in the local YAML and Compose file | Local-only database password; do not reuse outside development. |
| `spring.jpa.hibernate.ddl-auto` | `validate` | Checks the entity mapping against the migrated database schema. |
| `spring.jpa.open-in-view` | `false` | Disables the Open EntityManager in View pattern. |
| `spring.flyway.enabled` | `true` | Applies database migrations at startup. |
| `server.port` | `8080` | HTTP server port. |
| `home-debit.cors.allowed-origin-patterns` | `http://localhost:*`, `http://127.0.0.1:*` | Allows local Flutter web origins to call `/api/**`. |

## Local PostgreSQL

`home-debit/docker-compose.yml` starts `postgres:17-alpine`, creates the
`home_debit` database/user, publishes port `5432`, and stores database files
in the named `postgres-data` volume. A health check runs `pg_isready`.

The checked-in settings are local-development defaults, not production
secrets. Use environment-specific secret management and configuration for
shared environments.

## Runtime requirements

The Gradle Java toolchain targets Java 25. Backend tests use a PostgreSQL
Testcontainers image and therefore require Docker.

Flutter web uses JSON POST requests, which trigger a browser CORS preflight.
The backend permits `GET`, `POST`, and `OPTIONS` with configured origin
patterns and headers on `/api/**`. Restrict or override these patterns for
non-local deployments.

# Citations

[1][Spring Boot configuration](../../../home-debit/src/main/resources/application.yml)
[2][Local database Compose definition](../../../home-debit/docker-compose.yml)
[3][Gradle Java toolchain and dependencies](../../../home-debit/build.gradle)
[4][CORS origin configuration](../../../home-debit/src/main/java/ph/hcph/homedebit/config/CorsProperties.java)
