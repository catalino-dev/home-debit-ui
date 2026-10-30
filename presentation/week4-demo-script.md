# Week 4 demo script — Stream, package, workflow, BLoC dashboard

**Stories:** US-07 Account Status · US-08 External Package · US-09 Development
Workflow · US-10 Final Customer Dashboard (BLoC mandatory)
**Branch:** `feature/week-4-dashboard-bloc` (PR #6)

## Setup

```powershell
<skills>\home-debit\scripts\start-local.ps1 -SkipUi
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

Use a device with Hot Reload (Chrome/Windows/Android) so US-09 can be shown
live.

## Demo flow (≈8 min)

| Step | Do | Say |
|---|---|---|
| 1 | Register a customer **with** a nickname. | "The dashboard route creates two blocs: one loads the profile (a `Future`), one listens to the account status (a `Stream`). They're independent — notice status is already *Synchronizing...* while the profile is still loading." |
| 2 | Wait for *Synchronized* and the timestamp. | "The fake service is an `async*` generator: `yield` the first value, then `yield*` a periodic stream. Every value becomes a state via `emit.forEach`, and `BlocBuilder` rebuilds just the card. The time is formatted with `intl`'s `DateFormat` — US-08." |
| 3 | Wait for *Synchronizing...* again. | "No refresh button — the UI updates whenever the stream emits. The bloc keeps the last completed sync time while re-syncing." |
| 4 | **Hot Reload**: change the status icon size or card spacing, press `r`. | "Hot Reload injected the new `build()` code; I'm still on the dashboard and the stream is still running — state preserved." |
| 5 | **Hot Restart**: change the `DateFormat` pattern, press `r` (no change), then `R`. | "The formatter is a `static final` — already initialized — so Hot Reload keeps the old value. Hot Restart re-runs `main()`: Dart state is reset, I'm back on Registration, and the new pattern applies." |
| 6 | Turn on **Simulate profile load failure**, register another customer. | "Profile bloc: `Requested` → `LoadFailure(message)`. Status keeps streaming — failures are isolated per bloc." |
| 7 | Tap **Retry**. | "The view only adds `CustomerProfileRetryRequested`; the bloc decides: `Loading` → `Loaded`. It ignores Retry unless the last load failed." |
| 8 | Edit Profile → change nickname → Save. | "Edit persists with `PUT` and pops with the saved customer; the dashboard adds `CustomerProfileUpdated` — no reload. The greeting uses `nickname ?? fullName`." |
| 9 | Back to Registration. | "Popping the route closes both blocs; closing `AccountStatusBloc` cancels the stream subscription, which cancels the periodic timer — verified by tests." |

## Questions to be ready for

**Future vs Stream?** One value later vs many values over time. Profile =
`Future<Customer>`; status = `Stream<AccountStatus>`.

**`async*` / `yield` / `yield*`?** `async*` returns a `Stream` lazily; `yield`
emits one value; `yield*` forwards another stream and forwards cancellation
to it.

**Safe subscription handling?** `emit.forEach` ties the subscription to the
bloc; `BlocProvider` closes the bloc with the route. Nothing to cancel by hand.
(With raw `listen`, you'd store the `StreamSubscription` and cancel it in
`dispose`.)

**Events vs states? Responsibilities?** Events are *what happened* (user
intent: Retry tapped, Edit saved). States are *what to show* (Loading /
Loaded / LoadFailure). The bloc owns calls, error mapping, and decisions;
widgets only add events and render states.

**Why two blocs?** Different lifecycles and failure modes: a one-shot load
with Retry vs a continuous feed. One bloc would couple them (a status tick
would rebuild the profile; a profile error could hide the status).

**Why are Registration/Edit still `StatefulWidget`?** Their state is
form-local and short-lived (controllers, submit flag). No shared or
business logic would move into a bloc.

**Widget tree and `BuildContext`?** `context` is the widget's position;
`context.read<Bloc>()` searches upward, so the provider must be an ancestor —
`ProfileScreen` provides, `_ProfileView` reads. Don't use `context` after an
`await` without checking it's still mounted; the dashboard reads the bloc and
messenger before navigating to Edit.

**Why `intl`?** Official Dart team package for date/number formatting,
pure Dart, works on web/mobile, ready for localization. Only one file
imports it.

**Production improvements?** Real GET/push status with auth; DI container;
typed failures (`Either`/sealed results); freezed/equatable states and
`bloc_concurrency`; offline cache; go_router; observability; localization.

## Evidence

* Automated: `flutter analyze` clean; `flutter test` 74/74 (20 new — blocs,
  stream, formatter, dashboard).
* Live: [Week 4 exercise results](../docs/week-4-exercise-results.md).
