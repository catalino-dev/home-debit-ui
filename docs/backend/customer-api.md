---
type: API Group
title: Customer API
description: Registers customers, retrieves a customer profile by its database ID, and updates a profile, including the optional nickname.
resource: /api/customers
tags: [home-debit, customer, rest]
timestamp: 2026-09-30T17:30:00+08:00
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
| `PUT` | `/api/customers/{id}` | `200 OK` | Replace the editable profile fields (US-04); returns the updated customer. |

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
  "mobileNumber": "09171234567",
  "nickname": "Janie"
}
```

`fullName`, `email`, and `mobileNumber` are required. `email` must be a valid
email according to Jakarta Validation. `mobileNumber` must contain 7–15
digits. `nickname` is **optional** (US-03): it may be omitted, `null`, or
blank — all are stored as `null` — and must be 50 characters or fewer.

### Response

Successful registration returns `201 Created` with a JSON object. `nickname`
is always present, either as a string or `null`:

```json
{
  "id": 1,
  "fullName": "Jane Doe",
  "email": "jane.doe@example.com",
  "mobileNumber": "09171234567",
  "nickname": null
}
```

### Failure cases

| Status | Condition |
|---|---|
| `400 Bad Request` | Request fields fail `@NotBlank`, `@Email`, `@Pattern`, or `@Size` validation, or the request body cannot be parsed. |
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

## Update customer profile

### Request

```http
PUT /api/customers/1
Content-Type: application/json
```

```json
{
  "fullName": "Jane Smith",
  "email": "jane.smith@example.com",
  "mobileNumber": "09998887777",
  "nickname": "JS"
}
```

A full replacement of the editable fields, validated exactly like
registration (`CustomerUpdateRequest`). Sending a blank or missing
`nickname` clears it.

### Success

`200 OK` returns the updated customer in the registration response shape.
The `id` never changes.

### Failure cases

| Status | Condition |
|---|---|
| `400 Bad Request` | A field fails validation, or the body cannot be parsed. |
| `404 Not Found` | No customer has that ID. |
| `409 Conflict` | The email belongs to a **different** customer. Keeping the customer's own email is not a conflict. |

## Persistence and caller boundary

The API writes through the JPA repository to PostgreSQL. The Flutter app calls
`POST /api/customers` to register and `PUT /api/customers/{id}` to save profile
edits; the profile screen renders what those calls return. Local browser
origins on `localhost` and `127.0.0.1` are permitted by configurable CORS
patterns for `GET`, `POST`, `PUT`, and `OPTIONS`; see
[Local development](../local-development.md).

Automated API/persistence and CORS coverage, together with the live
UI-to-database checks, is documented in [Test evidence and scenarios](../testing.md).

# Citations

[1][Customer controller](../../../home-debit/src/main/java/ph/hcph/homedebit/customer/CustomerController.java)
[2][Registration request validation](../../../home-debit/src/main/java/ph/hcph/homedebit/customer/CustomerRegistrationRequest.java)
[3][Update request validation](../../../home-debit/src/main/java/ph/hcph/homedebit/customer/CustomerUpdateRequest.java)
[4][Customer service behavior](../../../home-debit/src/main/java/ph/hcph/homedebit/customer/CustomerService.java)