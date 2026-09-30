# Documentation Update Log

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
