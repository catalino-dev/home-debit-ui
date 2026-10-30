---
type: Playbook
title: Add an external package (US-08)
description: Adds the intl package to format the dashboard's Last synchronized timestamp, covering pubspec.yaml, flutter pub add/get, imports, and why intl (and flutter_bloc) were selected without unnecessary dependencies.
resource: workspace:home-debit-ui/week-4/us-08
tags: [flutter, dart, week-4, packages, pubspec, intl, us-08]
timestamp: 2026-10-30T16:00:00+08:00
okf_version: "0.1"
source: ../../lib/utils/date_time_extension.dart
---
# Add an external package (US-08)

> **Business story:** As a business owner, I want the customer profile to
> display a formatted value using an existing Dart/Flutter package so that
> common functionality does not need to be built from scratch.

## What was built

* `intl: ^0.20.3` added to `dependencies` in `pubspec.yaml` (via
  `flutter pub add intl`, which edits `pubspec.yaml` and runs `pub get`;
  `pubspec.lock` pins the resolved version).
* `lib/utils/date_time_extension.dart`:

  ```dart
  import 'package:intl/intl.dart';

  extension DateTimeFormatting on DateTime {
    static final _syncTimestamp = DateFormat('d MMM y, h:mm:ss a');
    String get syncTimestamp => _syncTimestamp.format(toLocal());
  }
  ```

* The Account Status card shows
  `Last synchronized: ${lastSynchronizedAt.syncTimestamp}` →
  **`Last synchronized: 30 Oct 2026, 3:17:05 PM`**.

## Acceptance criteria → evidence

| Acceptance criterion | Proof |
|---|---|
| Dependency is added correctly | `pubspec.yaml` `dependencies: intl: ^0.20.3`; `pubspec.lock` entry |
| `flutter pub get` succeeds | `flutter pub add` output *Changed N dependencies!*; CI-style `flutter analyze` + `flutter test` pass |
| Import works | `package:intl/intl.dart` in `date_time_extension.dart` |
| Package functionality is actually used | `DateFormat.format` renders the caption — `date_time_extension_test.dart` (`30 Oct 2026, 2:31:05 PM`, `2 Jan 2026, 9:05:00 AM`); screenshots 02/03/06 |
| Explain what the package provides | See below |
| No unnecessary package is added | See "Dependency audit" |

## What `intl` provides

`intl` is the Dart team's internationalization package: locale-aware date
and number formatting (`DateFormat`, `NumberFormat`), plurals/genders, and
message translation. We use `DateFormat` with an explicit pattern:

| Pattern | Meaning | Example |
|---|---|---|
| `d` | day of month, no padding | `30` |
| `MMM` | short month name | `Oct` |
| `y` | year | `2026` |
| `h:mm:ss` | 12-hour clock with minutes/seconds | `3:17:05` |
| `a` | AM/PM marker | `PM` |

Doing this by hand means month-name tables, 12-hour conversion, zero
padding, and eventually locale rules — exactly the "common functionality"
the story says not to rebuild.

## Why this package

* **Official and maintained** (published by the Dart team), widely used, and
  the same package `flutter_localizations` relies on — so it is the natural
  choice if the app is localized later.
* **Small and focused** for what we need; pure Dart, no native code, works
  on web and mobile without platform setup.
* **Isolated**: only `date_time_extension.dart` imports it, so swapping or
  localizing the format is a one-file change.

## Dependency audit

| Package | Type | Why it is needed |
|---|---|---|
| `intl` | runtime | US-08 formatting (above). |
| `flutter_bloc` | runtime | US-10 requires the BLoC pattern; provides `Bloc`, `BlocProvider`, `BlocBuilder` (and depends on `bloc`). |
| `bloc_test` | **dev** only | `blocTest` for event → state assertions; not shipped in the app. |

Considered and **not** added: `equatable` (states implement `==` by hand —
only five small state classes), `bloc_concurrency` (Retry is ignored unless
the last load failed, so no transformer is needed), `rxdart` (the fake
stream needs only `Stream.periodic`).

## Related

* [Display account status (US-07)](./account-status-stream.md)
* [Practice development workflow (US-09)](./development-workflow.md)

# Citations

[1][Date/time extension](../../lib/utils/date_time_extension.dart)
[2][Formatter tests](../../test/date_time_extension_test.dart)
[3][pubspec.yaml](../../pubspec.yaml)
