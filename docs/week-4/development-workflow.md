---
type: Playbook
title: Practice development workflow (US-09)
description: Explains when Hot Reload, Hot Restart, or a full restart/rebuild was used while building Week 4, what state each preserves, and why native, plugin, dependency, and initState changes need more than Hot Reload.
resource: workspace:home-debit-ui/week-4/us-09
tags: [flutter, week-4, hot-reload, hot-restart, workflow, us-09]
timestamp: 2026-10-30T16:00:00+08:00
okf_version: "0.1"
source: ../local-development.md
---
# Practice development workflow (US-09)

> **Business story:** As a developer, I want to use Flutter's development
> workflow effectively so that I can iterate quickly while building
> features.

## The three levels

| Action | Key (`flutter run`) | What happens | State |
|---|---|---|---|
| **Hot Reload** | `r` (or save in the IDE) | Injects changed Dart code into the running VM and rebuilds the widget tree. | **Preserved** — `State` objects, blocs, navigation stack, form text, the running stream subscription. |
| **Hot Restart** | `R` | Restarts the Dart app from `main()` with the new code. | **Reset** — all Dart state is discarded; back to Registration, new fake services. The native host and plugins keep running. |
| **Full restart / rebuild** | `q` then `flutter run` | Rebuilds and relaunches the whole app (native shell included). | Everything reset. |

This story is a practice/explanation story — there is no app code for it.
The evidence is being able to choose and justify the right action during the
demo (see the [Week 4 demo script](../../presentation/week4-demo-script.md)).

## Which one to use for each Week 4 change

Use this as the practice plan while building or demoing Week 4 (run the app
with `flutter run -d chrome` or `-d windows`, register, and stay on the
dashboard):

| Change while the dashboard is open | Use | Why / what you should observe |
|---|---|---|
| Status card spacing, icon, colors (`_AccountStatusCard`, `AppStatusRow`) | **Hot Reload** | Pure `build()` changes. The logged-in dashboard and the running status stream stay in place, so the tweak appears in about a second without re-registering. |
| Greeting text or card layout in `_CustomerDetails` | **Hot Reload** | Also `build()`-only; the loaded customer in `CustomerProfileBloc` is preserved. |
| `DateFormat` pattern in `date_time_extension.dart` | **Hot Restart** | The formatter is a `static final` that is already initialized; Hot Reload keeps existing static values, so the old pattern stays until a restart. |
| Composition changes in `MyApp.initState` (e.g. a new service) | **Hot Restart** | `initState` already ran for the live `State`; Hot Reload does not run it again. |
| Fake stream interval / generator logic | **Hot Restart** | The live subscription was created from the old generator; a restart creates a fresh one. |
| `flutter pub add flutter_bloc intl` (and `bloc_test`) | **Full restart** | New packages change the compiled dependency set; the running app can't load them. Plugins with native code additionally need a native rebuild. |
| A new `--dart-define` (e.g. `USE_BACKEND_PROFILE`) | **Full restart** | Compile-time constants are fixed when the app is built. |

## Rules of thumb

* **Hot Reload** for UI and logic changes inside `build()` and methods
  called later — keeps you where you are (great for deep screens like the
  dashboard).
* **Hot Restart** when you change **initialization**: `main()`,
  `initState`, constructors of long-lived objects, `static`/global
  initializers, enum/class shape changes, or when the current state is just
  wrong and you want a clean start.
* **Full restart / rebuild** for `pubspec.yaml` dependency changes, native
  code (`android/`, `ios/`), plugin additions, assets, or
  `--dart-define` changes (compile-time constants).

## Acceptance criteria → evidence

| Acceptance criterion | Evidence |
|---|---|
| Use Hot Reload for normal changes | Practice plan above (status card / dashboard UI tweaks); demonstrate live. |
| Understand Hot Reload generally preserves state | The dashboard, its blocs, and the stream subscription survive a reload. |
| Use Hot Restart to reset Dart state | Formatter, `initState`, and generator changes. |
| Know native/plugin changes need a full rebuild/restart | Package additions and `--dart-define` require a fresh `flutter run`. |
| Explain why each was selected | "Why" column above. |

## Related

* [Local development](../local-development.md) — commands and ports
* [Add an external package (US-08)](./external-package.md)

# Citations

[1][Local development](../local-development.md)
