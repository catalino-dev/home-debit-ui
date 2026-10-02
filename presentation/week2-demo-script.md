# Week 2 Exercise — Demo Script (speaker only, not shown on the deck)

Target length: **10–12 minutes** + Q&A. Deck: `index.html` (arrow keys or
click the right edge to advance). If doing the live demo, start the stack
beforehand (`scripts/start-local.ps1` from the home-debit skill, or the wiki's
Local Development page) and open `http://127.0.0.1:5100/` in a separate
browser window. The deck screenshots are the fallback if anything misbehaves.

**Live-demo prep:** refresh the browser before each registration, so you start
with an empty form. Pick a fresh email suffix (e.g. `.demo1@example.test`) and
keep a second registered customer's email ready for the 409 scene.

---

## Slide 1 — Title (30s)

> "Week 1 got a customer registered end to end. Week 2 asks two questions
> every real app has to answer: *what if some information is missing?* and
> *who owns data that's being changed?* We answer them with an optional
> nickname and an Edit Profile screen. Both are persisted to PostgreSQL, not
> just held in memory."

- Point at the chips: US-03, US-04, the new Flyway V2 migration and `PUT`
  endpoint, verified this week.

## Slide 2 — The brief (1.5 min)

> "Two user stories again. Each one carries a Dart or Flutter lesson."

**US-03 — Optional Customer Information (what the brief asked for):**
> "US-03 says: *as a customer, I can optionally give a nickname.* The
> requirement is small. There's a nickname field that is **not** required,
> the model stores it as a nullable `String?`, and when there is no nickname
> the profile says **Not provided**. It shouldn't be blank, crash, or print
> the word 'null'. The real lesson is Dart null safety: the difference
> between `String` and `String?`, and the operators `?`, `??`, `!` and
> `late`. The type system makes you decide, in the model itself, which data
> may be missing. The compiler then makes every screen handle that case."
- Why it matters to the demo: scene 1 shows the same Profile screen twice,
  once without a nickname (fallback) and once with one.
- Acceptance criteria to tick off: nickname optional ✔, nullable in the model
  ✔, fallback shown when null ✔.

**US-04 — Edit Customer Profile (what the brief asked for):**
> "US-04 says: *as a customer, I can edit my profile.* There's an Edit
> action on the Profile. It opens a form pre-filled with the current values:
> name, email, mobile, and nickname. **Save** updates the Profile. **Cancel**
> discards the changes. The lesson is state ownership. Who owns the saved
> customer? Who owns the half-typed draft? That decides which widgets must be
> Stateful, where `setState` is called, where `TextEditingController`s live,
> and how data comes back through navigation."
- Why it matters to the demo: scenes 2–4 cover Save, Cancel, and a failed
  save.
- Acceptance criteria to tick off: Edit from Profile ✔, pre-filled ✔, all four
  fields editable ✔, Save updates Profile ✔, Cancel leaves Profile unchanged ✔.

**End-of-week challenge (third card):**
> "The challenge asks us to show a profile with and without a nickname, edit
> and save one, and explain what happens to unsaved changes. Slide 7 answers
> that last part directly."
- Beyond the brief: edits are persisted with `PUT /api/customers/{id}`, and
  the backend refuses to let you take another customer's email (409).

## Slide 3 — Null safety (2 min)

> "Start with the model. `fullName`, `email`, and `mobileNumber` are plain
> `String`. They can never be null, and the compiler guarantees it. `id` and
> `nickname` are `String?` / `int?`. The ID is null until the backend saves
> the record. The nickname is null because the customer chose not to give one."

Walk the four operators (right card), each with where it appears in our code:
- **`?`** on a type: "this value may be missing". We only use it where
  missing is a real, valid state. We didn't add `?` everywhere to silence
  the compiler.
- **`??`**: "if null, use this instead". `nickname ?? 'Not provided'` on
  Profile is US-03's fallback. `nickname ?? ''` seeds the empty edit field.
- **`!`**: "I promise this isn't null". It throws if you're wrong. We use
  it only on `_formKey.currentState!`, where Flutter guarantees the form is
  mounted. Everywhere else we rely on type promotion: check for null once,
  and Dart treats the variable as non-null after that.
- **`late`**: "I'll assign this before anyone reads it". Profile's
  `late Customer _customer` is set in `initState`. The edit controllers are
  `late final`, assigned once and then never reassigned.

> "One more detail: a blank nickname becomes `null` on **both** sides.
> In Dart it's `nullIfBlank`, in Java it's `normalizeNickname`. So 'no
> nickname' has exactly one representation, and we never store spaces."

## Slide 4 — State ownership (2 min)

> "This is the most important slide of Week 2. There are two kinds of
> customer data on screen. The **saved** customer is owned by
> `ProfileScreen`. The **draft** being typed is owned by `EditProfileScreen`."

- **ProfileScreen became Stateful.** "In Week 1 it only displayed what it
  was given, so Stateless was right. Now what it displays changes after it's
  built, and that is the definition of state. Stateless is the default. A
  widget becomes Stateful only when *it* holds data that changes."
- **The arrows are the data flow.** "Profile pushes Edit with the current
  customer. Edit returns one of two things: `pop(saved)` with the server's
  answer, or `pop()` with nothing on Cancel. `Navigator.push<Customer>`
  returns `Customer?`. Null safety forces Profile to handle the Cancel case,
  so it can't be forgotten."
- **`setState`** (bottom-left card): only the owner calls it. Profile calls it
  once after a successful edit. Edit calls it for the loading flag and the
  error message. Typing does *not* go through `setState`, because the
  controller already notifies its text field.
- **`TextEditingController`** (middle card): create it once in `initState`
  with the current value and dispose it in `dispose()`. "If you create it in
  `build`, every rebuild wipes what the user typed. That's a classic Flutter
  bug."
- Backend (right box): Flyway `V2` adds a nullable `nickname VARCHAR(50)`
  column. Existing rows simply get `NULL`, so no data migration is needed.

## Slide 5 — Demo 1 of 4 · US-03 (1.5 min)

Live: register **without** a nickname, then refresh and register another
customer **with** one.

> "The nickname field says *optional*, and I'm leaving it empty. Register
> still succeeds, because no validator requires it. The backend returned
> `"nickname": null`, and the Profile shows **Not provided**. That's `??` at
> work."
> "Now a customer with the nickname 'Annie'. It's the same screen and the
> same line of code. The value is present, so the fallback is never used."

- Optional validation: a nickname over 50 characters shows a field error, and
  nothing is sent.

## Slide 6 — Demo 2 of 4 · Edit and Save (1.5 min)

Live: from the no-nickname profile, click **Edit Profile**, change the mobile
number, add a nickname, and click **Save**.

> "Edit opens pre-filled. The controllers were seeded in `initState`, and the
> null nickname became an empty field. I change the mobile number and add the
> nickname 'Juanito', then Save."
> "Save sent `PUT /api/customers/17`. The backend validated and persisted
> it, then returned the updated record. Edit popped with that record, and
> Profile called `setState` with it. You see the **Profile updated**
> SnackBar."

- Land the key line: **"Profile shows what the server saved, not what I typed."**
  It's the same ID, so this is an update, not a second registration.

## Slide 7 — Demo 3 of 4 · What happens to unsaved changes? (2 min)

This slide answers the challenge question. Say it clearly.

Live: open Edit, type "Juan Draft" and a nickname "Unsaved", then click
**Cancel**.

> "Those two values exist in exactly one place: the edit screen's
> controllers. When I click Cancel, or press back, `Navigator.pop` runs with
> **no result**."
> "Three things happen. First, the edit screen's `State` is disposed, its
> controllers are disposed with it, and the draft is gone. Second, Profile
> receives `null`, returns early, and keeps its `_customer` unchanged.
> Third, no request was ever sent, so the database is untouched."
> "If I open Edit again, it starts from the **saved** profile, not the draft.
> We have a widget test for exactly that."

- The one-sentence answer: **"Unsaved changes are discarded, because the
  draft and the saved data have different owners. Throwing one away can't
  corrupt the other."**
- If asked "should we warn before discarding?": that's a sensible Week 3
  enhancement (a "Discard changes?" dialog via `PopScope`). The brief asks
  Cancel to discard.

## Slide 8 — Demo 4 of 4 · Save fails (1.5 min)

Live: Edit, set the email to the *other* customer's email, and Save.

> "The backend rejects this with 409, because that email belongs to someone
> else. We stay on Edit, the draft is kept so I can fix it, and the message
> tells me what to do. Profile has not changed."

- Backend rules: keeping **your own** email is fine (200). Another
  customer's email is 409. Invalid input is 400. An unknown ID is 404, with
  "please register again".
- **Code-review finding.** Tell this story, because it's a state-ownership
  lesson:
  > "Review found a real bug. You could press back *while* a Save was in
  > flight. The screen popped with `null`, but the PUT still committed. The
  > Profile then showed stale data, and the next Save sent those stale
  > values and silently reverted the change. The fix was
  > `PopScope(canPop: !_isSaving)` plus hiding the back arrow while saving,
  > and we added a regression test."

## Slide 9 — Evidence (1 min)

> "Same approach as Week 1: each layer is verified alone, then together."

- 36 Flutter tests, including 3 for US-03 and 8 for US-04. Week 1's tests
  still pass unchanged.
- 18 backend integration tests on real PostgreSQL (Testcontainers), covering
  nickname, PUT 200/400/404/409, and the CORS preflight for `PUT`.
- The live run is documented with 9 screenshots, and the DB rows were checked
  directly.

## Slide 10 — Status and next (1 min)

- Done: both stories end to end, shared validators and widgets, and the wiki
  (Week 2 guides plus exercise evidence).
- Limitations to state plainly: the Android APK build still fails, so web is
  the verified target. Profile doesn't re-fetch on open. The Week 1 and
  Week 2 branches are not merged to `main` yet.
- Week 3 candidates: a "Discard changes?" prompt, moving state into
  Bloc/Provider once several screens share it, fetch-by-ID, and the Android
  fix.

## Slide 11 — Close

> "Everything shown can be reproduced from the wiki. Start at *Week 2:
> Overview*. Questions?"

---

## Likely questions (and short answers)

| Question | Answer |
|---|---|
| Why not make every field nullable to be safe? | That hides mistakes. Non-null types make the compiler catch missing values. Only genuinely optional data gets `?`. |
| When is `!` acceptable? | Only when you can prove non-null and the language can't see it (e.g. `currentState!` after the form is built). Otherwise prefer `??`, `?.`, or a null check that promotes the type. |
| Why not keep Profile Stateless and let a parent own the customer? | You could. But no parent needs the customer yet, so that would push state higher than necessary. Lift it when two screens share it (Week 3). |
| Why dispose controllers? | They hold listeners and resources. Not disposing them leaks memory. |
| Why PUT and not PATCH? | The edit form always sends all four fields, so a full replacement is simpler. A blank nickname clears it. |
| What if the record was deleted while editing? | Save gets a 404 and the user sees "This profile no longer exists. Please register again." |