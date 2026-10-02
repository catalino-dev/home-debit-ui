---
type: API Group
title: Customer API
description: Registers customers and retrieves a customer profile by its database ID.
resource: /api/customers
tags: [home-debit, customer, rest]
timestamp: 2026-09-28T12:00:00+08:00
okf_version: "0.1"
source: ../../../home-debit/src/main/java/ph/hcph/homedebit/customer/CustomerController.java
---
# Customer API

## Base path

`/api/customers`

No authentication mechanism is configured in the current service source.
Requests and responses use JSON where a body is present.

## Endpoints

| Method | Path | Success | Purpose |
|---|---|---|---|
| `POST` | `/api/customers` | `201 Created` | Validate and persist a customer; returns its response including generated ID. |
| `GET` | `/api/customers/{id}` | `200 OK` | Return the customer with the supplied numeric ID. |

## Register customer

### Request

```http
POST /api/customers
Content-Type: application/json
```

```json
{
  "fullName": "Jane Doe",
  "email": "jane.doe@example.com",
  "mobileNumber": "09171234567"
}
```

All fields are required. `email` must be a valid email according to Jakarta
Validation. `mobileNumber` must contain 7–15 digits.

### Response

Successful registration returns `201 Created` with a JSON object:

```json
{
  "id": 1,
  "fullName": "Jane Doe",
  "email": "jane.doe@example.com",
  "mobileNumber": "09171234567"
}
```

### Failure cases

| Status | Condition |
|---|---|
| `400 Bad Request` | Request fields fail `@NotBlank`, `@Email`, or `@Pattern` validation, or the request body cannot be parsed. |
| `409 Conflict` | A customer with the same email already exists. |

## Get customer profile

### Request

```http
GET /api/customers/1
```

### Success

`200 OK` returns the same response shape as registration.

### Failure case

`404 Not Found` is returned when the requested ID does not exist.

## Persistence and caller boundary

The API writes through the JPA repository to PostgreSQL. The Flutter app calls
`POST /api/customers` to persist registration. Local browser origins on
`localhost` and `127.0.0.1` are permitted by configurable CORS patterns; see
[Local development](../local-development.md).

Automated API/persistence and CORS coverage, together with the live
UI-to-database check, is documented in [Test evidence and scenarios](../testing.md).

# Citations

[1][Customer controller](../../../home-debit/src/main/java/ph/hcph/homedebit/customer/CustomerController.java)
[2][Registration request validation](../../../home-debit/src/main/java/ph/hcph/homedebit/customer/CustomerRegistrationRequest.java)
[3][Customer service behavior](../../../home-debit/src/main/java/ph/hcph/homedebit/customer/CustomerService.java)
