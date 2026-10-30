# Week 3 demo script — async profile loading and error handling

**Stories:** US-05 Load Customer Profile · US-06 Handle Profile Loading Errors
**Branch:** `feature/week-3-async-profile-loading` (PR #5)
**End-of-week challenge:** demonstrate successful *and* failed profile loading,
including Retry, and explain the complete loading → success/error flow.

## Setup (before the demo)

```powershell
# Postgres + backend
<skills>\home-debit\scripts\start-local.ps1 -SkipUi
# UI (debug build so the demo switch is visible)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

## Demo flow (≈5 min)

| Step | Do | Say |
|---|---|---|
| 1 | Show Registration; point at **Simulate profile load failure** (off). | "Registration still persists to the backend. The Profile now *loads* the customer through a service that returns `Future<Customer>`. This switch is a debug-only control on the fake service so I can show failures on demand." |
| 2 | Register a customer. | "Registration hands the Profile only the **id**. The Profile starts the load in `initState` without awaiting it." |
| 3 | Point at the spinner. | "This is the loading state. `_isLoading` starts `true`, so the first frame already shows it. The fake waits 2 seconds — simulated network delay. The UI isn't frozen: the spinner animates and Back works, because `await` only pauses this function, not the event loop." |
| 4 | Customer appears. | "The `Future` completed; `await` unwrapped the `Customer`; `setState` rebuilt with it; `finally` cleared loading." |
| 5 | Back, fill a second customer, switch **on**, Register. | "Now the next load will throw." |
| 6 | Error + Retry appear. | "The service threw `CustomerServiceException`. The `on … catch` branch stored its user-friendly message; `finally` still cleared loading — so no stuck spinner and no crash. An unexpected error type would hit the generic `catch` and show a generic message instead of internals." |
| 7 | Tap **Retry**. | "Retry resets to loading and calls the *same* `_loadProfile`. The failure was transient — it fails once — so this attempt succeeds." |

## Questions to be ready for

**Why can't `Future<Customer>` be used as a `Customer`?**
It's a placeholder for a value that hasn't arrived. The type system stops
`future.fullName`; you must `await` (or `then`) it, and handle the time
before it completes — that's the loading state.

**What does `async`/`await` actually do?**
`async` makes a function return a `Future` and allows `await` inside.
`await` suspends that function until the `Future` completes, then resumes
with the value or rethrows the error. Dart is single-threaded; while suspended,
the event loop keeps rendering frames and handling input.

**Why `finally`?**
It runs on success, on a caught exception, and even after `return`, so
"stop loading" is written once and can never be skipped.

**Normal result vs exception?**
A result is what the operation exists to produce (`Customer`). An exception
says it couldn't (network, 404, server). It skips the success code, so we
never render half-loaded data.

**Why not `FutureBuilder`?**
It would work for a single load, but Retry needs to start a *new* Future and
the screen also owns the saved customer after Edit (Week 2). Holding
`_isLoading` / `_errorMessage` / `_customer` explicitly keeps one clear
state machine and makes `try`/`catch`/`finally` visible — which is this
week's learning goal. (Week 4 moves this into a BLoC.)

**Why a fake behind an interface?**
Delay and failure can be demonstrated deterministically; the screen code is
the same for the fake and the real `GET /api/customers/{id}`
(`--dart-define=USE_BACKEND_PROFILE=true`); tests inject a `Completer`-based
service to freeze the loading state.

## Evidence

* Automated: `flutter analyze` clean; `flutter test` 54/54
  (18 new — fake service, `loadProfile`, `savedCustomers`, 7 profile-loading
  widget scenarios incl. an end-to-end run through `MyApp`).
* Live: [Week 3 exercise results](../docs/week-3-exercise-results.md).
