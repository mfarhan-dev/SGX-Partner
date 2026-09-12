# Firebase integration

What Firebase does in this app, what it deliberately does **not** do, and
how to verify each piece.

---

## 1. What we use Firebase for — and what we do not

| Firebase product | Used? | Purpose here |
| --- | --- | --- |
| Crashlytics | **Yes** | Crash and error reporting (section 2) |
| Cloud Messaging (FCM) | **Yes** | Push notifications (section 3) |
| Remote Config | **Yes** | App-wide kill switches (section 4) |
| **Cloud Firestore** | **No** | — |
| **Realtime Database** | **No** | — |
| Firebase Auth | No | Auth is Supabase phone-OTP |
| Cloud Storage | No | Images are Supabase Storage |
| Cloud Functions | No | Server logic is Postgres RPCs |

### The database question, stated plainly

**We are not connected to any Firebase database.** Not Firestore, not
Realtime Database. No `cloud_firestore` or `firebase_database` package is
in `pubspec.yaml`, and no code reads or writes one.

**The database for this app is and remains Supabase Postgres**
(project `ghojtefwuzubqguqcbwc`). Every row the app reads or writes —
profiles, mechanics, wholesalers, qr_codes, withdrawals, payout_accounts,
khata_entries — lives there, behind RLS and `SECURITY DEFINER` RPCs.

Firebase is used here as three side services bolted onto that: a crash
reporter, a push transport, and a remote switchboard. The only Firebase
data that touches our own storage goes **the other way**: the FCM
registration token is written into the existing Supabase column
`profiles.fcm_token` (section 3).

This is a deliberate split, not an oversight. Moving app data into
Firestore would mean maintaining two sources of truth with two different
authorisation models, and every business rule this app depends on
(balance guards, the QR status state machine, withdrawal state
transitions) is enforced by Postgres triggers that Firestore cannot
replicate. If a Firebase database is ever genuinely wanted, it should be
a separate decision with its own reasoning — not something that arrives
as a side effect of adding Crashlytics.

---

## 2. Crash detection (Crashlytics)

`lib/core/firebase/crashlytics_service.dart`

### What gets reported

Flutter has four separate error channels, and catching one does not catch
the others. All four are wired:

| # | Channel | What it catches |
| --- | --- | --- |
| 1 | `FlutterError.onError` | Build, layout, and paint failures; anything thrown inside a widget callback |
| 2 | `PlatformDispatcher.instance.onError` | Errors past the framework's reach — an uncaught `Future` rejection, a platform-channel reply that throws, anything after an async gap |
| 3 | `Isolate.current.addErrorListener` | Crashes on background isolates (e.g. inside `compute()`). Both handlers above are *per-isolate*, so neither sees these |
| 4 | Native | Java/Kotlin and Objective-C/Swift crashes, picked up by the Crashlytics Gradle plugin and SDK with no Dart involvement |

Reports are tagged with the signed-in partner via
`CrashlyticsService.setUser()`: the profile id (`auth.uid()`) and the role
(`mechanic` / `wholesaler`). **Never the phone number or CNIC** — those are
the personal data this app exists to protect, and a crash report is the
wrong place for them. `clearUser()` runs on sign-out so crashes from the
logged-out shell aren't misattributed to whoever used the phone last.

### Debug builds do not report

`setCrashlyticsCollectionEnabled(!kDebugMode)`. Without this, every
hot-reload typo lands in the real dashboard and buries the crashes that
matter.

Consequence: **`flutter run` will never produce a Crashlytics report.**
To verify the wiring you must run a release or profile build on a real
device.

`PlatformDispatcher.onError` returns `!kDebugMode` for the same reason.
That return value means "I handled this" and suppresses Flutter's own
console dump — claiming it in debug, where nothing actually recorded the
error, would make errors vanish with nothing printed anywhere.

### Nothing here is allowed to throw

Every method is internally guarded. Two reasons, both concrete:

- `installErrorHandlers()` runs on the startup path **before the first
  frame**. An escaping exception there is not an error message, it is a
  black screen on launch.
- The installed handlers run *while an error is already being handled*. A
  throw from inside one loses the original error. The isolate listener
  shape-checks its payload instead of destructuring it for exactly this
  reason.

The fire-and-forget Crashlytics calls inside the handlers use `.ignore()`.
An error escaping one of those Futures would route into
`PlatformDispatcher.onError`, which calls Crashlytics again — if
Crashlytics is what's failing, that is a loop.

### Verifying

1. `flutter run --release` on a real device.
2. Trigger a crash — e.g. `throw StateError('crashlytics smoke test');`
   from a button handler.
3. Relaunch the app. Crashlytics uploads on the *next* start, not at crash
   time.
4. Firebase Console → Crashlytics. First report can take a few minutes.

---

## 3. Push notifications (FCM)

`lib/core/notifications/`

| File | Role |
| --- | --- |
| `push_message.dart` | Parses `RemoteMessage`; validates the deep link |
| `push_notifications_service.dart` | Permission, token, channel, the three delivery paths |
| `push_token_repository.dart` | Writes `profiles.fcm_token` in Supabase |
| `push_notifications_coordinator.dart` | Session ↔ token ↔ Crashlytics identity ↔ navigation |

### The three delivery paths

A push reaches the app in one of three states, and each needs its own
handling:

- **Foreground** — Android shows nothing automatically, so
  `_onForegroundMessage` posts an equivalent local notification into our
  own channel. iOS *can* draw its own banner, so
  `setForegroundNotificationPresentationOptions` is enabled there and the
  local-notification path is skipped — doing both would show the same push
  twice.
- **Background tap** — `onMessageOpenedApp`.
- **Cold-start tap** — `getInitialMessage()`, via `takeLaunchMessage()`.
  Asked for exactly once; FCM keeps returning the same message until the
  app is killed, so a second caller would navigate twice.

### Token storage

The FCM token is written to `profiles.fcm_token`, a column that already
existed. The `profiles_update` RLS policy scopes the write to
`auth.uid() = id`, so a partner can only ever register their own token. No
schema change was needed.

**Known limitation:** one token per profile, not a `device_tokens` table.
A partner signed in on two phones only receives pushes on whichever
registered last. Multi-device needs its own table and a migration.

Sign-out clears the token **inside `AuthController.signOut()`**, before
`supabase.auth.signOut()` runs. This ordering is load-bearing: clearing
the column is an authenticated UPDATE, so once the JWT is gone the write
would be rejected and a live token would be left on a row nobody is using
— meaning the next partner to log in on that phone would have their
notifications delivered to the previous partner's registration.

### Deep links

`data.deep_link` (or `data.route`) navigates on tap. The path is validated
in `PushMessage`: it must start with a single `/`. Absolute URLs and
protocol-relative `//host` forms are rejected — without that check,
anything able to send this project's FCM messages could aim the app at an
arbitrary URL.

Navigation is *queued*, not immediate. `SplashScreen` ends with its own
`context.go(...)` once the session is restored; navigating before that
happens looks like it worked and is then silently discarded, because the
splash's redirect runs later. So the link is held until the partner is
signed in **and** off the splash/auth screens.

### Notification icon

`android/app/src/main/res/drawable-*/ic_stat_sgx.png`, generated from the
launcher foreground.

Android draws a notification's small icon from its **alpha channel only**,
tinted flat. Both launcher PNGs are RGB with no alpha, so using them would
make every notification show as a solid white square.

### Nothing here is allowed to block launch either

`PushNotificationsService.initialize()` is awaited in `bootstrap()` before
`runApp()`, and `requestPermission()` and the local-notification plugin
both fail outright on an Android handset with **no Google Play Services**
— a real share of the low-cost phones this app's partners use. Letting
that propagate would cost the partner the entire app because notifications
weren't available. It is caught. Failing there costs notifications and
nothing else.

### Verifying

1. Run on a **real device** (emulators need Play Services; the iOS
   simulator cannot receive push at all).
2. Accept the permission prompt.
3. Sign in, then check the token landed:
   `select id, fcm_token is not null from profiles where id = '<uid>';`
4. Firebase Console → Cloud Messaging → send a test message to that token.
5. Test all three states: app open, app backgrounded, app swiped away.

---

## 4. Remote Config

`lib/core/firebase/remote_config_keys.dart`, `remote_config_service.dart`

| Key | Default | Meaning |
| --- | --- | --- |
| `maintenance_mode` | `false` | Hard stop; show `maintenance_message` instead of letting the partner in |
| `maintenance_message` | *(see file)* | Text shown while maintenance mode is on |
| `qr_scanning_enabled` | `true` | Kill switch for the QR scan flow |
| `withdrawals_enabled` | `true` | Kill switch for the withdrawal flow |

Rules for adding a key:

1. **The default must describe today's shipped behaviour.** A fresh
   install on a dead network uses these values, and a partner in a
   workshop with no signal must get a working app, not a disabled one.
2. **Don't duplicate Supabase.** Row-shaped, per-partner, or
   already-behind-an-RPC data (the support WhatsApp number, withdrawal
   minimums, campaign content) belongs in Postgres.
3. **Only add a key the app can act on.** A `min_supported_build`
   force-update key was dropped for this reason: enforcing it means
   reading the running build number, which needs a dependency this project
   doesn't have. A key nobody can honour is worse than no key — someone
   will eventually set it and expect something to happen.

Values refresh in real time via `onConfigUpdated`, so a switch flipped in
the console takes effect mid-session rather than on the next cold start.

### ⚠️ Not yet consumed

`remoteConfigProvider` is wired and live, but **no screen reads it yet**.
Flipping `qr_scanning_enabled` to `false` in the console right now changes
nothing in the UI. Gating the scanner and withdrawal flows is a separate,
deliberate change — it means deciding what the blocked screen says.

---

## 5. Manual setup still outstanding

- **iOS push capability.** Xcode → Runner → Signing & Capabilities → add
  **Push Notifications**, then upload an APNs auth key in Firebase Console
  → Project Settings → Cloud Messaging. `project.pbxproj` was left
  untouched on purpose: adding the `aps-environment` entitlement without
  the matching capability in the Apple Developer portal makes the iOS
  build fail outright. Until this is done, iOS gets no token — handled
  gracefully, `currentToken()` returns null.
- **Remote Config parameters** do not exist in the Firebase Console yet.
  The app runs on its local defaults until they're published.
- **Firebase CLI active project is `studioops-app-dev`, not
  `sgx-partner`.** The app code is correct — `firebase_options.dart` and
  `google-services.json` both point at `sgx-partner` — but any `firebase`
  CLI command run from this directory targets the wrong project.
- **Billing is not enabled** on the Firebase project. Crashlytics, FCM,
  and Remote Config are all free-tier, so this is fine as-is.

---

## 6. Related known gap

The in-app Notifications screen
(`lib/shared/notifications/presentation/notifications_screen.dart`) is
still entirely hardcoded, and the `user_notifications` Supabase table has
0 rows. A push arrives and deep-links correctly, but does not appear in
that list. Wiring the screen to `user_notifications` is a separate task.
