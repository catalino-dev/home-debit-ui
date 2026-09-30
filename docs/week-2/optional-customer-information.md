---
type: Playbook
title: Optional customer information (US-03)
description: Adds an optional nickname end to end and explains Dart null safety — String vs String?, ?, ??, !, and late — using the actual Home Debit code.
resource: workspace:home-debit-ui/week-2/us-03
tags: [flutter, dart, week-2, null-safety, nickname, us-03]
timestamp: 2026-09-30T17:30:00+08:00
okf_version: "0.1"
source: ../../lib/models/customer.dart
---
# Optional customer information (US-03)

> **Business story:** As a customer, I want to optionally provide a nickname
> so that my profile can display it when available.

## What was built

| Layer | Change |
|---|---|
| Database | Flyway `V2__add_customer_nickname.sql` adds a **nullable** `nickname VARCHAR(50)` column. |
| Backend API | `nickname` is an optional field on `POST /api/customers` (and `PUT`, see US-04); blank is stored as `null`; more than 50 characters is `400`. The response always includes `nickname` (a string or `null`). |
| Model | `Customer.nickname` is `String?`. `fromJson` maps a missing key and an explicit `null` to `null`. |
| Registration form | New **Nickname (optional)** field. It has no "required" rule — only a 50-character limit. An empty or whitespace-only value is sent as `null` via the `nullIfBlank` extension. |
| Profile | New **Nickname** row: shows the nickname, or `Not provided` when it is `null`. |

## Acceptance criteria → evidence

| Acceptance criterion | Where it is satisfied | Proof |
|---|---|---|
| Customer model supports nullable data | `final String? nickname;` in `lib/models/customer.dart` | `test/customer_test.dart` — missing key / `null` / value |
| App does not crash when nickname is null | `fromJson` casts with `as String?`; the profile uses `??` | Widget test *registers without nickname and shows the fallback*; live screenshot 02 |
| A non-null nickname is displayed | Profile renders `_customer.nickname ?? …` | Widget test *registers with a nickname and displays it*; live screenshot 09 |
| A null nickname uses a fallback value | `_customer.nickname ?? _notProvided` → `Not provided` | Same tests + screenshot 02 |
| Explain nullable vs non-nullable | See "Null safety in this code" below | — |
| Explain `?`, `??`, `!`, and `late` | See the table below — every operator is pointed at a real line | — |

## Null safety in this code

### `String` vs `String?`

Dart is **sound null safe**: a variable of type `String` can never hold
`null`, and the compiler enforces that. Adding `?` makes the type
**nullable** — `String?` means "a `String` *or* `null`".

```dart
class Customer {
  final int? id;            // null until the backend assigns one
  final String fullName;    // always present — required in the constructor
  final String email;
  final String mobileNumber;
  final String? nickname;   // US-03: optional, null = "not provided"
}
```

`fullName`, `email`, and `mobileNumber` stay non-nullable on purpose: the
business rules say they're mandatory, so the type system guarantees every
`Customer` has them and no screen ever has to null-check them. Only data
that is *genuinely* optional is nullable. Making everything `String?` "to be
safe" would push null checks into every widget and hide real bugs.

### The operators, pointed at real code

| Syntax | Meaning | Where it's used |
|---|---|---|
| `T?` | Nullable type. | `String? nickname`, `int? id` (`customer.dart`); `String? _errorMessage` (screens). |
| `?.` | Null-aware access: evaluate to `null` instead of throwing if the receiver is `null`. | `value?.trim().length` in `CustomerValidators.nickname` — a `null` field doesn't crash the validator. |
| `??` | "If-null": use the right side when the left is `null`. | `_customer.nickname ?? 'Not provided'` (profile fallback); `value?.trim().length ?? 0`; `widget.customerService ?? CustomerService()`; `customer.nickname ?? ''` to seed the Edit field. |
| `!` | Null assertion: "I know this isn't `null`" — throws at runtime if you're wrong. | `_formKey.currentState!` (the `Form` is always mounted when the button is pressed); `value!.trim()` in the email/mobile validators, **after** `_required` has already rejected `null`. |
| `late` | "This non-nullable variable will be assigned before it's read, just not at declaration." | `late final _customerService = …` (needs `widget`, available only after the `State` is attached — also lazily initialised); `late Customer _customer` in `ProfileScreen`, assigned in `initState`; `late final TextEditingController …` in `EditProfileScreen`, created in `initState`. |

### When to use `!` — and when not to

`!` moves a compile-time guarantee to a runtime crash, so use it only where an
invariant makes `null` impossible, and say why in a comment (see
`CustomerValidators.email`). Prefer **type promotion** when you can:

```dart
// CustomerService.update
final id = customer.id;          // int?
if (id == null) {
  throw ArgumentError.value(customer, 'customer', 'must have an id to be updated');
}
_baseUri.resolve('/api/customers/$id');  // id is promoted to int — no `!`
```

Promotion works on **local** variables, not fields — which is why the screens
copy the field first: `final errorMessage = _errorMessage; if (errorMessage
!= null) AppErrorMessage(message: errorMessage)`.

### When to use `late` — and the trap

`late` is a promise, not a default. If code reads a `late` variable before it
is assigned, Dart throws `LateInitializationError`. That's safe here because
`initState` always runs before `build`. Don't reach for `late` just to silence
the compiler — if a value can legitimately be absent, it should be `T?`
instead (that's exactly why `nickname` is `String?` and not `late String`).

## Blank means "not provided"

An untouched text field gives `''`, not `null`. Without normalising, a
customer who skipped the nickname would be stored as `''` and the profile
would show an empty row instead of the fallback. Both sides normalise:

* Flutter: `_nicknameController.text.nullIfBlank` (`lib/utils/string_extension.dart`)
  trims and returns `null` for empty/whitespace.
* Backend: `CustomerService.normalizeNickname` does the same with
  `StringUtils.hasText`, so a client that bypasses the UI can't store `"   "`.

## Tests

* `test/customer_test.dart` — `fromJson` null/missing/present, equality, `nullIfBlank`, nickname validator (0, 50, 51 chars).
* `test/customer_service_test.dart` — registration body always includes `nickname` (`null` or value) and the response maps it.
* `test/profile_edit_test.dart` (`US-03` group) — fallback shown, nickname shown and trimmed, >50 chars blocked client-side.
* `CustomerControllerTests` — nickname absent → `null`, present → persisted, blank → `null`, 51 chars → `400`.

## Sources

* [Customer model](../../lib/models/customer.dart)
* [String extension](../../lib/utils/string_extension.dart)
* [Customer validators](../../lib/utils/customer_validators.dart)
* [Registration screen](../../lib/screens/registration_screen.dart)
* [Profile screen](../../lib/screens/profile_screen.dart)
* [Week 2 exercise results](../week-2-exercise-results.md)

# Citations

[1][Week 2 training brief](../../../home-debit/Flutter_4_Week_Training_Developer_Week_2%201.docx)
[2][Customer model](../../lib/models/customer.dart)
[3][Nickname migration](../../../home-debit/src/main/resources/db/migration/V2__add_customer_nickname.sql)
