---
type: Playbook
title: Display account status (US-07)
description: Shows a live account-synchronization status on the dashboard from a fake Stream built with async*/yield, consumed through AccountStatusBloc and BlocBuilder, with the subscription cancelled automatically when the dashboard closes; explains Future vs Stream.
resource: workspace:home-debit-ui/week-4/us-07
tags: [flutter, dart, week-4, stream, async-star, yield, bloc, us-07]
timestamp: 2026-10-30T16:00:00+08:00
okf_version: "0.1"
source: ../../lib/services/fake_account_status_service.dart
---
# Display account status (US-07)

> **Business story:** As a customer, I want to see my account
> synchronization status in real time so that I know whether my profile
> information is up to date.

## What was built

| Layer | Change |
|---|---|
| Model | `AccountStatus` (`state`, `updatedAt`) and `AccountSyncState` (`synchronizing` → *Synchronizing...*, `synchronized` → *Synchronized*). |
| Service | `AccountStatusService.watchStatus(customerId)` returns `Stream<AccountStatus>`. `FakeAccountStatusService` emits *Synchronizing...* immediately, then alternates *Synchronized* / *Synchronizing...* every 3 s — forever, until the listener cancels. Its clock is injectable for tests. |
| BLoC | `AccountStatusBloc`: `AccountStatusSubscriptionRequested` → `emit.forEach` over the stream → `AccountStatusUpdated(status, lastSynchronizedAt)`; stream errors → `AccountStatusUnavailable`. |
| UI | Account Status card at the top of the dashboard: a `BlocBuilder` maps each state to an `AppStatusRow` (icon, color, label, *Last synchronized* caption). No refresh button. |

## Acceptance criteria → evidence

| Acceptance criterion | Where it is satisfied | Proof |
|---|---|---|
| Status comes from a Stream | `watchStatus` returns `Stream<AccountStatus>` | `fake_account_status_service_test.dart` |
| Multiple values are emitted over time | `async*` generator: `yield` + `yield*` over `Stream.periodic` | Test *emits multiple alternating values over time* (5 values) |
| The UI updates automatically | `BlocBuilder<AccountStatusBloc, …>` rebuilds per state | Widget test *status updates automatically from the Stream*; screenshots 02→03 |
| No manual refresh | Subscription starts when the dashboard's bloc is created | Same widget test asserts no *Refresh* control |
| Explain Future vs Stream | See below | — |
| Explain `async*`, `yield`, listen/StreamBuilder, safe subscriptions | See below | Tests *stops emitting once the subscription is cancelled*, *closing the bloc cancels the Stream subscription*, *leaving the dashboard cancels the status subscription* |

## The generator

```dart
@override
Stream<AccountStatus> watchStatus(int customerId) async* {
  yield _status(AccountSyncState.synchronizing);            // one value now
  yield* Stream<int>.periodic(interval, (tick) => tick).map( // then one per tick
    (tick) => _status(tick.isEven
        ? AccountSyncState.synchronized
        : AccountSyncState.synchronizing),
  );
}
```

## Concepts

### Future vs Stream

| | `Future<T>` | `Stream<T>` |
|---|---|---|
| Values | exactly **one** value (or one error) | **zero or more** values (and errors) over time, then optionally *done* |
| Consume with | `await`, `then`, `FutureBuilder` | `await for`, `listen`, `StreamBuilder`, `emit.forEach` |
| In this app | `loadProfile` — the customer, once | `watchStatus` — the sync status, continuously |

The profile is a one-shot question ("who is this customer?"), so it is a
`Future`. The sync status keeps changing, so it is a `Stream`.

### `async*`, `yield`, `yield*`

* `async*` turns a function into a **stream generator**: calling it returns a
  `Stream` immediately; the body only runs once someone listens.
* `yield value` emits one value to the listener.
* `yield* otherStream` forwards every value of another stream.
* When the listener **cancels**, the generator stops. With `yield*` the
  cancellation is forwarded straight to the inner stream, so the periodic
  timer is cancelled at once. (An earlier draft used `await for` +
  `Future.delayed`; that kept a timer alive until its next tick after the
  dashboard closed — the widget tests' pending-timer check caught it.)

### listen / StreamBuilder / `emit.forEach`

`stream.listen(onData)` returns a `StreamSubscription` that **you** must
`cancel()` (typically in `dispose`). `StreamBuilder` does the listen/cancel
for you inside the widget tree. Here the stream is consumed in the BLoC
instead, with `emit.forEach`, which:

* emits a new state for every value (`onData`) and maps errors (`onError`),
* lives as long as the bloc, and
* **cancels the subscription automatically when the bloc is closed** —
  `BlocProvider` closes the bloc when the dashboard route is popped.

So there is no manual subscription to forget — that is the "safe
subscription handling" the story asks for.

### Keeping the last sync time

The bloc (not the widget) decides what *Last synchronized* means: on a
*Synchronized* value it records `updatedAt`; on *Synchronizing...* it keeps
the previous time, so the caption doesn't disappear during a re-sync.

## Edge cases tested

* Stream error → *Status unavailable*; the profile part keeps working.
* Status streams even while the profile is still loading (independent blocs).
* Leaving the dashboard cancels the subscription (`onCancel` observed).

## Related

* [Final customer dashboard (US-10)](./customer-dashboard-bloc.md)
* [Add an external package (US-08)](./external-package.md)

# Citations

[1][Fake account status service](../../lib/services/fake_account_status_service.dart)
[2][Account status bloc](../../lib/blocs/account_status/account_status_bloc.dart)
[3][Dashboard widget tests](../../test/dashboard_test.dart)
