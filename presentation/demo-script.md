# Week 1 Demo Script — presenter notes

Companion to [`week1-demo.html`](week1-demo.html). This script is **not**
shown on the deck — keep it on a second screen or printed. Timings assume a
~10-minute slot plus Q&A.

## Before the session (5 min, not on air)

1. Start everything:
   `C:\Users\<you>\Workspace\hcph\gma-ai-enablement\skills\home-debit\scripts\start-local.ps1`
2. Wait until `http://127.0.0.1:5100/` renders the registration screen
   (first debug load takes ~45–60 s — a blank page then a progress bar is
   normal).
3. Pick today's demo email: `juan.delacruz.<yyyymmdd>@example.test` — a date
   you have NOT used before, so registration succeeds and the duplicate
   scenario is under your control.
4. Keep a terminal ready with:
   `docker exec home-debit-postgres psql -U home_debit -d home_debit -c "SELECT * FROM customer ORDER BY id DESC LIMIT 3;"`
5. Open the deck in a browser tab, press `F` for fullscreen; app in a second
   tab sized to a phone-ish window (or DevTools device toolbar, Pixel preset).

## Slide 1 — Title (30 s)

> "This is Home Debit — our Week 1 Flutter exercise. It looks like a simple
> registration form, but every keystroke you'll see ends up in a real
> PostgreSQL row, through a real Spring Boot API. And it's built with the
> same design rules as self-care-mobile."

## Slide 2 — The brief (45 s)

> "Two user stories: register a customer, then view their profile. The
> training goals are widget fundamentals — the widget tree, stateless versus
> stateful, forms and validators, and passing a typed model through the
> Navigator. We went one step beyond the brief: instead of mocking the
> backend, we built it."

## Slide 3 — Architecture (1 min)

> "Three tiers. The Flutter web app on port 5100 posts to Spring Boot on
> 8080, which validates again and persists via JPA — schema managed by
> Flyway. The key detail: the profile screen renders the backend's
> *response*, including the database-generated ID. If the backend didn't
> really save it, the demo would fail in front of you."

## Slide 4 — Standards (1 min)

> "We deliberately scaled self-care-mobile's rules down instead of ignoring
> them. Where production has Koyal widgets, we have App-prefixed widgets. No
> raw colors or paddings — everything goes through theme tokens. HTTP only in
> the service layer, typed exceptions instead of leaking status codes, and
> dependencies injected through constructors so tests can mock them."

## Slide 5 — Scenarios 1–3 (switch to live app, ~2 min)

Do it live, deck stays on slide 5 as the fallback:

1. Show the app freshly loaded → *"Straight into registration — no splash,
   no login, this is the whole Week 1 surface."*
2. Click **Register** with everything empty → three required-field messages.
   > "Client-side validation — nothing was sent; the Register button never
   > produced a network call."
3. Type `not-an-email` and `abc123`, Register → format errors.
   > "Same story for format — rejected before the backend ever sees it."

## Slide 6 — Scenario 4 (live, ~2 min)

1. Fill: `Juan Dela Cruz` / today's unique email / `09201234567` → Register.
2. Profile appears.
   > "That navigation only happens on HTTP 201. What you see is the
   > backend's response — watch this."
3. Run the psql query in the terminal → point at the new row and its `id`.
   > "There's the row, with the ID Postgres generated. The UI never invented
   > any of this."

## Slide 7 — Scenario 5 (live, ~1 min)

1. Go back, resubmit the **same** email → red error, form intact.
   > "409 Conflict from the backend, translated to a human message. We don't
   > navigate, we don't wipe the form, we don't show 'Error 409'."

## Slide 8 — Verification (45 s)

> "Everything you just watched is also automated: analyzer clean, ten widget
> tests covering validation, mapping, errors and navigation, backend tests,
> and this exact five-scenario smoke test recorded with screenshots in the
> wiki. One honest caveat — the Android APK build has a known Gradle issue;
> web is the verified target this week."

## Slide 9 — Wrap-up (30 s)

> "So Week 1 leaves us with a verified full-stack slice, a mini design
> system that can grow into the self-care-mobile patterns, and documentation
> that answers 'is this integrated yet' with evidence. Questions?"

## Appendix: explaining each user story (for Q&A / deep dives)

The training brief requires being able to explain *why*, not just show *that*
it works — US-01 asks you to explain the Widget Tree and state ownership;
US-02 asks you to explain `BuildContext` in navigation. Use this section if
a reviewer stops you mid-demo and asks "why did you build it that way?"

### US-01 — Create Customer Registration

> *Business story: As a customer, I want to enter my basic information so
> that I can create my profile.*

* **Widget tree** (point at `registration_screen.dart` while explaining):
  `MaterialApp` → `RegistrationScreen` (`Scaffold`) → `Form` → `Column` →
  three `AppTextField`s → `AppPrimaryButton`. Draw it on a whiteboard if
  asked — this is the literal nesting in the `build()` method.
* **Why `StatefulWidget`, not `StatelessWidget`**: the screen owns mutable
  state that must survive rebuilds — the three `TextEditingController`s, the
  `_isSubmitting` flag, and whatever validation errors are currently shown.
  A `StatelessWidget` has no `setState` and can't redraw itself when any of
  that changes; it would need a parent to own and pass all of this down.
* **State and `setState`**: pressing **Register** calls
  `_formKey.currentState!.validate()` first — each `AppTextField`'s
  validator runs, and if any returns non-null, Flutter shows that message
  and stops right there (no network call — this is scenarios 2 and 3 in the
  live demo). On success, `setState(() => _isSubmitting = true)` disables
  the button and shows a spinner while `CustomerService.register()` is in
  flight.
* **Acceptance criteria this demo already proves**: fresh project runs
  (slide 1 narration), registration screen on startup + input fields accept
  input + required fields validated (slide 5), successful registration shows
  the entered customer name via a `SnackBar` before navigating (slide 6).

### US-02 — View Customer Profile

> *Business story: As a customer, I want to view my registered information
> so that I can verify that my profile is correct.*

* **One logical `Customer` object**: `lib/models/customer.dart` is the
  single source of truth for customer data moving between screens.
  `Customer.fromJson` builds an instance from the backend's response
  (including the server-generated `id` — this is why slide 6 can point at a
  real database row). The Profile screen never hardcodes a value; every
  field it shows came from this object.
* **`BuildContext` in navigation** — this is the one acceptance criterion
  people most often fumble explaining live, so rehearse it:
  `Navigator.push(context, ...)` uses `context` to walk *up* the widget tree
  from `RegistrationScreen`'s position to find the nearest `Navigator`
  ancestor (the one `MaterialApp` created), then pushes `ProfileScreen` as a
  new route on top of it, passing the `Customer` returned by the backend.
  The **Back to Registration** button on Profile calls
  `Navigator.pop(context)` — same mechanism, same `Navigator`, just removing
  the top route instead of adding one.
* **Why `StatelessWidget`**: in the Week 1 implementation, `ProfileScreen`
  only renders the `Customer` handed to it via a required constructor field
  — it has no mutable state of its own to manage, so there's nothing a
  `StatefulWidget` would buy you. (Week 2 changes this once editing is
  introduced — don't volunteer that unless asked, it's out of scope for
  this demo.)
* **Acceptance criteria this demo already proves**: successful registration
  navigates to Profile + the exact submitted information is displayed
  (slide 6), and the backend-confirmation JSON on the same slide proves the
  data passed to Profile is real, not hardcoded.

## Recovery notes (if something breaks live)

* App won't load → the framed screenshots on slides 5–7 tell the whole
  story; narrate over them, don't debug on air.
* Registration fails unexpectedly → check the backend terminal; a 409 means
  the email was already used — add a suffix and retry.
* Postgres query errors → the table is `customer` (singular).
