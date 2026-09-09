# SGX Partner — Handoff (2026-09-09)

## What this app is
Flutter B2B app for SGX Partners (auto-parts wholesaler). Two roles: **mechanic** and **wholesaler**, each with their own shell/tabs. Backend is Supabase (Postgres + RLS + `SECURITY DEFINER` RPCs + triggers). Project ref: `ghojtefwuzubqguqcbwc`.

## Standing rules (do not break these)
- **Never `git commit` unless explicitly told to.** The user reviews every change on-device first, then says "commit" explicitly.
- Run `dart format` + `flutter analyze` after every Dart edit — must be clean before reporting done.
- Never do blind ADB/device interaction.
- Before any DB/schema change: check via Supabase advisors (`get_advisors`) and `information_schema.routine_privileges`.
- User wants tasks narrated one at a time — "what are you going to do, how are you going to do it" — before/while doing them. Don't batch multiple unrelated tasks silently.
- Dark mode: always use `AppColors.xOf(context)` theme-aware helpers, never hardcoded light-only `AppColors.text`/`.mutedText` literals.
- Card taps: use `context.push()` not `context.go()` so back-navigation works.
- Session-cached data (profile, ledger, etc.) uses plain `FutureProvider` (NOT `.autoDispose`) because tab screens sit under a `ShellRoute` that fully unmounts on tab switch — autoDispose would refetch every visit.

## Current git status (uncommitted, not yet reviewed by user)
```
M lib/roles/mechanic/home/presentation/mechanic_home_screen.dart
M lib/roles/mechanic/profile/data/mechanic_profile_providers.dart
M lib/roles/mechanic/profile/domain/mechanic_profile_data.dart
M lib/roles/wholesaler/home/presentation/wholesaler_home_screen.dart
M lib/roles/wholesaler/profile/data/wholesaler_profile_providers.dart
M lib/roles/wholesaler/profile/domain/wholesaler_profile_data.dart
```
`dart format` + `flutter analyze` both clean on these 6 files.

## What was just completed: QR scan-to-earn (backend + Home balance)

### Business rules confirmed by user
- Reward "points" (`schemes.mechanic_points`/`wholesaler_points`, `qr_codes.mechanic_reward_snapshot`/`wholesaler_reward_snapshot`) are **whole rupees, 1:1** — no conversion factor. Verified against real `schemes` row "Brake Batay" (mechanic_points: 5, wholesaler_points: 5).
- Credit is **instant** on scan — no staff approval step.
- A QR code can be **scanned exactly once** (already enforced by the pre-existing `qr_codes` status state machine: `generated → active|void`, `active → scanned`).
- Balance must be a **stored running total**, never summed from history — mirrors the existing `khata_balance` guarded pattern.

### DB changes (already applied live via Supabase MCP `apply_migration` — NOT reverted, this is real production schema now)
1. **`add_mechanic_points_balance_and_guards`** — added `mechanics.points_balance` (int, default 0, check >= 0) + `guard_mechanic_points_balance()`/`guard_wholesaler_points_balance()` trigger functions + triggers on both tables. Pattern: `BEFORE UPDATE` trigger raises an exception unless `current_setting('sgx.points_sync', true) = 'on'` — blocks any direct edit outside the trusted path.
2. **`credit_points_balance_on_qr_scan`** — `private.credit_points_on_qr_scan()` trigger function: on `qr_codes` status transitioning TO `'scanned'`, flips `sgx.points_sync` on, adds `mechanic_reward_snapshot`/`wholesaler_reward_snapshot` to the respective balances, flips it back off. `AFTER UPDATE` trigger `qr_codes_credit_points_on_scan`.
3. **`scan_qr_code_function`** — `public.scan_qr_code(p_qr_id text)` `SECURITY DEFINER` RPC: looks up the calling mechanic via `auth.uid()`, locks the `qr_codes` row `for update`, returns `('not_found'|'already_scanned'|'not_active'|'success', reward, new_balance)`. Granted to `authenticated` only (no `anon`).

**Verified end-to-end** with a real test scan (impersonated a real mechanic via `set local request.jwt.claims`) against real QR code `QR-0022-01-0001` — success, correct balances credited to both mechanic and wholesaler, re-scan correctly returned `already_scanned` with no double-credit. **This touched real production data** (disclosed to user at the time).

### Flutter changes (this session, the 6 files above)
- `mechanic_profile_data.dart` / `mechanic_profile_providers.dart`: added `pointsBalance` (int, rupees) field + `points_balance` to the Supabase select + parse into the returned object.
- `wholesaler_profile_data.dart` / `wholesaler_profile_providers.dart`: same treatment, mirrored exactly.
- `mechanic_home_screen.dart` / `wholesaler_home_screen.dart`: removed hardcoded `_availableBalance` mock constant. Now:
  - `available = MoneyAmount(cents: pointsBalance * 100)` from the real profile provider
  - `pending = MoneyAmount(cents: 0)` (genuinely true — no withdrawal system exists yet)
  - `lifetime = available` (mathematically true today since nothing has ever reduced `points_balance`) — **flagged with a code comment** that once withdrawals exist, `lifetime` needs its own separate never-decreasing column.
  - The `WithdrawalStatusCard` mock ("Payment sent by SGX" / "Confirm received") itself was **left untouched** — out of scope for this task, still fully mocked.

## Immediate next step (what the user just asked for, not yet started)
User confirmed the balance wiring is "task 1" of 2 presented options. **Task 2 remains, not started**, and the user has not yet said which to do next — ask them, or resume with:

1. **Real camera-based QR scanning** for `/mechanic/scan` — currently **100% decorative**, no camera integration at all. Needs to call the now-built `scan_qr_code(p_qr_id)` RPC and handle its 4 result states (`success`/`already_scanned`/`not_active`/`not_found`) with appropriate UI feedback.
2. **QR Progress screen for wholesaler** — needs a **new, not-yet-built** narrow RPC to safely expose the wholesaler's own `qr_codes` aggregate progress, since `qr_codes` remains staff-only `SELECT` (no direct wholesaler read access currently).

## Known future gap (flagged, not to be solved yet)
Once a withdrawal system is built (no DB table exists for it at all yet), `available` (reducible) and `lifetime earned` (should never reduce) must become two separate stored values — right now they're identical because nothing has ever decremented `points_balance`.

## How to resume
1. Ask the user to review the 6 modified files on-device (Home screens for both roles should now show their real, live rupee balance instead of the old mock numbers).
2. Once approved, they will explicitly say to commit — do it only then, with:
   ```
   Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
   ```
3. Ask which of the two "next step" items above to do first (mirrors how this feature's kickoff was handled — always confirm before starting new DB/UI work).
