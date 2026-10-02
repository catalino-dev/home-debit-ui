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

## Week 1 exercises
* [Week 1 index](./week-1/index.md) — exercise guides and concept explanations

## Frontend
* [Frontend index](./frontend/index.md) — UI architecture, state, forms, and service boundary

## Backend
* [Backend index](./backend/index.md) — service, API, persistence, and configuration

## Current integration status

The Flutter registration flow calls the backend's persistent customer
registration endpoint. Successful responses include the database-generated ID;
duplicate email, backend validation, and network failures remain visible on the
registration form.
