---
type: Service
title: Home Debit customer backend
description: Provides customer registration and profile lookup over REST, persisting customer records in PostgreSQL.
resource: workspace:home-debit
tags: [home-debit, customer, java, spring-boot, postgresql]
timestamp: 2026-09-28T12:00:00+08:00
okf_version: "0.1"
source: ../../../home-debit/build.gradle
---
# Home Debit customer backend

## Overview

The `home-debit` Spring Boot application serves customer registration and
profile lookup endpoints. It validates registration payloads, checks email
uniqueness, persists customer records through Spring Data JPA, and maps the
entity to a response record.

The REST controller is rooted at `/api/customers`. PostgreSQL is the
persistence store; Flyway manages the schema and Hibernate validates the
mapped schema at startup. There is no configured external service or
messaging integration in the current backend source.

The Flutter frontend is a separate sibling project. Its registration service
calls `POST /api/customers` and passes the persisted API response to the
profile screen.

## Key responsibilities

* Validate and register a customer.
* Reject duplicate email addresses with HTTP `409 Conflict`.
* Retrieve a customer by numeric ID.
* Persist customer data in PostgreSQL.
* Apply schema migrations using Flyway.

## Technology stack

| Layer | Technology |
|---|---|
| Language/runtime | Java 25 |
| Framework | Spring Boot 4.0.0 |
| Web | Spring MVC |
| Persistence | Spring Data JPA / Hibernate |
| Database | PostgreSQL 17 in local Compose and integration tests |
| Schema migrations | Flyway |
| Build | Gradle wrapper |
| Tests | JUnit, Spring MockMvc, Testcontainers |

## Entry points

* [Customer API](./customer-api.md) — `POST /api/customers`, `GET /api/customers/{id}`
* [Customer data and persistence](./customer-data-and-persistence.md) — API records and database mapping
* [Backend configuration](./backend-configuration.md) — local datasource and runtime settings

## Local run

See [Local development](../local-development.md). The app listens on port
`8080` and expects PostgreSQL at `localhost:5432` by default.

# Citations

[1][Backend build configuration](../../../home-debit/build.gradle)
[2][Customer controller](../../../home-debit/src/main/java/ph/hcph/homedebit/customer/CustomerController.java)
[3][Backend runtime configuration](../../../home-debit/src/main/resources/application.yml)
