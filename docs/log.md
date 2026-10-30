# Documentation Update Log

## 2026-10-30 (Week 4)
* **US-07 account status**: `AccountStatusService` / `FakeAccountStatusService`
  (`async*` + `yield*` over `Stream.periodic`), `AccountStatusBloc` with
  `emit.forEach`, auto-updating Account Status card.
* **US-08 package**: `intl` `DateFormat` via `DateTime.syncTimestamp`
  (`Last synchronized: 30 Oct 2026, 3:17:05 PM`).
* **US-10 dashboard**: `flutter_bloc`; `CustomerProfileBloc`
  (Requested/RetryRequested/Updated → Loading/Loaded/LoadFailure);
  `ProfileScreen` is stateless and provides both blocs per route; null-safe
  greeting; `bloc_test` dev dependency.
* **Docs**: added `week-4/` (US-07..US-10 guides incl. Hot Reload/Restart),
  `week-4-exercise-results.md` with six live screenshots (`id=24..25`, stamp
  `202610301550`), and `presentation/week4-demo-script.md`; updated frontend
  architecture and test evidence (Flutter 74 tests).

## 2026-10-30 (Week 3)
* **US-05 async profile loading**: `CustomerProfileService`
  (`Future<Customer> loadProfile(id)`); default `FakeCustomerProfileService`
  (in-memory, 2 s delay, fed by `CustomerService.savedCustomers`);
  `CustomerService.loadProfile` (`GET`) opt-in via `USE_BACKEND_PROFILE`; the
  Profile now loads by id with a loading state; `MyApp` is the composition root.
* **US-06 load errors**: `try`/`catch`/`finally` in `_loadProfile`,
  `AppErrorView` with Retry, debug-only *Simulate profile load failure* switch
  (fails exactly one load).
* **Docs**: added `week-3/` (US-05, US-06 guides), `week-3-exercise-results.md`
  with seven live screenshots (`id=21..22`, stamp `202610301525`), and
  `presentation/week3-demo-script.md`; updated frontend architecture, local
  development, and test evidence (Flutter 54 tests).

## 2026-09-30 (Week 2)
* **US-03 optional nickname**: Flyway `V2__add_customer_nickname.sql`
  (nullable `VARCHAR(50)`); `nickname` on the register/update requests and the
  response; `Customer.nickname` is `String?`; Registration has an optional
  field; Profile shows `Not provided` for `null`.
* **US-04 edit profile**: new `PUT /api/customers/{id}` (400/404/409, CORS
  `PUT`); `CustomerService.update`; `ProfileScreen` is now Stateful and owns
  the saved customer; new `EditProfileScreen` with Save/Cancel.
* **Docs**: added `week-2/` (US-03, US-04 guides with null-safety and
  state-ownership explanations) and `week-2-exercise-results.md` with nine
  live screenshots (`id=16..18`, stamp `202609301720`); updated Customer API,
  persistence, frontend architecture, and test evidence (Flutter 36 tests,
  backend 18 tests).

## 2026-09-30
* **Screenshot refresh**: Re-captured all five exercise screenshots against
  the live stack at a Pixel-class phone viewport and composed them into an
  Android device frame (2× resolution); `debugShowCheckedModeBanner: false`
  was set in `lib/main.dart` so captures carry no DEBUG banner. Updated
  `exercise-results.md` evidence to the new verification run (`id=7` and
  `id=8`, `*.20260930@example.test`).

## 2026-09-28
* **Creation**: Generated from the Week 1 training brief, the Flutter UI workspace, and the sibling `home-debit` Spring Boot workspace.
* **Extraction**: Added 9 topic documents across 3 groups, plus the root and group indexes.
* **Integration update**: The Flutter registration service now calls the
  Spring Boot API; documentation records platform URL configuration, local
  web CORS, response/error handling, and the active system boundary.
* **Test evidence**: Added automated test results, repeatable test scenarios,
  live UI-to-database smoke results, and the Android APK build limitation.
