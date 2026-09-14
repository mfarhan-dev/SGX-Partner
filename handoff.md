# SGX Partner — Handoff (2026-09-14)

## What this app is
Flutter B2B app for SGX Partners (auto-parts wholesaler). Two roles — **mechanic** and **wholesaler** — each with their own shell/bottom-nav/screens. Backend is Supabase (Postgres + RLS + `SECURITY DEFINER` RPCs + triggers). Project ref: `ghojtefwuzubqguqcbwc`.

Git is clean as of this handoff — everything below through commit `16a6624` is committed on `main`.

## Standing rules (do not break these)
- **Never `git commit` unless explicitly told to.** The user verifies every change on-device (or via Supabase directly, for DB work) first, then explicitly says "commit."
- Run `dart format` + `flutter analyze` (must be clean) + a real `flutter build apk --debug --target-platform android-arm64` after every Dart change, before reporting done.
- Before any DB/schema change: check `get_advisors` (security) before and after, verify real ownership/RLS behavior with actual impersonated queries (`set local request.jwt.claims`), and for any test data use a fixture that is fully deleted afterward with a verified zero-leftover check. Disclose whenever a real production row is touched (not just a fixture).
- Dark mode: always use `AppColors.xOf(context)` theme-aware helpers, never hardcoded light-only `AppColors.text`/`.mutedText` literals.
- Card taps: use `context.push()` not `context.go()` so back-navigation works.
- Session-cached data (profile, ledger, withdrawals list, payout accounts, etc.) uses plain `FutureProvider` (NOT `.autoDispose`) because tab screens sit under a `ShellRoute` that fully unmounts on tab switch — `.autoDispose` would refetch on every visit. Per-item detail providers (a single withdrawal, a signed proof URL, a payment-history read) correctly ARE `.autoDispose.family` since they're reached by push, not as a persistent tab.
- Mechanic and wholesaler screens are near-exact mirrors; when one is changed, mirror the change to the other (the established pattern is a `sed -e "s/mechanic/wholesaler/g" -e "s/Mechanic/Wholesaler/g"` pass, then a manual re-check).

## What's built and working (by module)

- **Auth** — real Supabase phone-OTP login for both roles, session restore.
- **Onboarding / Profile** — mechanic + wholesaler onboarding forms, real Supabase-backed profile + edit (photo, name, area, address, CNIC, phone re-verification), Settings with real Language/Theme pickers and a working WhatsApp "Contact SGX" deep link.
- **Home** — real name/photo greeting, real active-campaigns carousel, real points balance, and a real, non-expandable "current withdrawal" activity card.
- **Mechanic Activity tab** — real end to end (this session), replacing the old 100% mocked `MechanicWalletScreen`. Two new RPCs, `get_mechanic_wallet_summary()` and `get_mechanic_wallet_activity()` (neither table existed before — `khata_entries` is wholesaler-only, and `audit_logs` has no QR-scan-reward or "withdrawal requested" events at all), union confirmed QR-scan rewards (`qr_codes`) with withdrawal lifecycle events unpivoted off `withdrawals`' own timestamp columns. The screen is a pure log (title "Activity", matching the bottom-nav label for the first time) — no balance card or Withdraw button here, since Home already owns those. Removed now-dead code this uncovered: `MockTransaction`/`mechanicTransactions`, the `MockTransaction`-based `TransactionRow` in `sgx_cards.dart`, and the entire orphaned `lib/shared/wallet/` directory (pre-existing, unrelated to this session's change).
- **Products** — real Supabase-backed catalog (list + detail), mirrored for both roles.
- **Campaigns** — real active-campaigns carousel + detail screen.
- **QR scan-to-earn — now real end to end (this session).** `mobile_scanner` wired in (camera permission already declared in the manifest/plist from an earlier session); the scanner is a "Ghost Link" layout -- live camera, no bottom card, a quiet underlined "Enter code manually" link (matches Uber/Trust Wallet's own scanners) opening a real `showModalBottomSheet` for the always-available manual fallback. Both paths call the same `MechanicScanRepository.submitScan()` → `scan_qr_code()`. Pushed on the root navigator, outside `MechanicShell` entirely (see its own route comment in `app_routes.dart`) -- the shell's bottom nav/FAB live in an ancestor `Scaffold` and were bleeding through when this route was nested inside the shell, the same bug class already documented for the old Withdrawals routes.
  - A "Verifying with SGX…" spinner overlay covers the gap between capture and the server's answer (real on 2G/3G — see this screen's own comment citing Smashing Magazine's progress-indicator guidance), plus a light haptic the instant a code is read and a stronger one on success.
  - `scan_qr_code()` now also returns who already claimed an already-scanned code (`scanned_by_name`/`scanned_by_workshop`/`scanned_at`/`scanned_by_you`) — name + workshop only, deliberately never a phone number or photo (a Storage policy exposing another mechanic's photo to anyone who scans their used sticker has no way to be scoped narrowly). Shown as a small profile card (colored-initial avatar, not a real photo) with an amber/info tone distinct from a genuine invalid-code error; re-scanning your own claimed code shows a plain message instead of a card of yourself. This was originally built to solve a real support problem: mechanics in Pakistan escalating "SGX never paid me" complaints against a code someone else already legitimately claimed.
  - The result overlay's background is fully opaque, not translucent — a lower-alpha scrim was letting the idle screen's aiming-frame decoration show through it, landing behind the result buttons and reading as a broken dialog.
- **Wholesaler khata ledger** — real Supabase-backed ledger replacing the old mocked Activity tab.
- **Wholesaler QR Progress** — real screen exposing the wholesaler's own QR scan progress.
- **Firebase** — push notifications, Crashlytics, Remote Config wired in (`97923d3`).
- **Withdrawals — the full flow, now real end to end:**
  - Multi-account payout methods with real provider logos, settable from Settings.
  - Request / Confirm-received / Dispute ("not received"), replacing the old mocks.
  - **This session's work** (commits `cf6a305`, `16a6624`):
    - Withdrawal Detail screen fully redesigned (StubHub-style always-expanded timeline, amount → status chip → method/ref header order, Sora display font for the amount, a real WhatsApp FAB replacing a dead no-op button, no per-row actor chip).
    - Home's withdrawal card redesigned into a fixed, non-expandable dot-strip summary (`WithdrawalActivityCard`) reflecting the real last-3 events.
    - Admin's payment-proof screenshot embedded on the "Payment sent" timeline step, tap-to-zoom, backed by a new partner-scoped Storage RLS read policy.
    - **Re-pay handling**: if a payment is disputed and SGX re-pays, the timeline now shows a real, separate "Payment sent again by SGX" step with its own screenshot — backed by a new RPC `get_withdrawal_payment_events()` that reads the partner's own `audit_logs` rows (otherwise staff-only), instead of the `withdrawals` row's single `payment_sent_at`/`proof_storage_path` columns (which only ever hold the *latest* payment and silently lose the earlier one on a re-pay).
    - **Fixed a real Storage RLS gap**: the proof-read policy matched a file only if it equalled the withdrawal's *current* `proof_storage_path` — so once a re-pay overwrote that column, the first payment's own screenshot became unreadable. Now matches by the withdrawal-id folder prefix, so every proof ever uploaded for a partner's own withdrawal is readable.
    - **Fixed a real backend bug**: the `enforce_withdrawal_status_transition()` trigger only set `payment_sent_at` when it was still `null`, so a re-pay silently left it pinned to the *original* payment time. This fed directly into `auto_confirm_stale_withdrawals()`'s 3-day window — a re-paid withdrawal could have auto-confirmed almost immediately, based on stale elapsed time, before the partner ever saw the new payment. Now resets on every transition into `payment_sent`. Verified with a real, fully-cleaned-up test fixture.
  - All of the above verified live in the app by the user against real data (withdrawal WD-0015: disputed then re-paid).

## Remaining / known gaps

1. **Mechanic Scan History (`/mechanic/scans`) is still 100% mock.** Reachable from Home's quick actions, still reads `mockScans` from `sgx_mock_data.dart` (hardcoded "124 scans / Rs. 28,540" summary). Surfaced while building the real scanner this session but deliberately left out of scope. The orphaned `MechanicScanHistoryRepository`/`ScanHistoryItem` scaffolding that predated this (zero implementations, zero providers) was deleted as dead code -- a real implementation would most naturally just filter `get_mechanic_wallet_activity()` (already built, already ordered) down to `qr_reward` rows rather than adding new backend surface.

2. **Multi-dispute-cycle history isn't representable yet.** `withdrawals.dispute_reason` / `disputed_at` are single columns — only the *latest* dispute survives. If a withdrawal is ever disputed → re-paid → disputed again, the app has no way to show the first dispute's own reason/timestamp separately. The payment side already got the audit_logs-backed fix this session (`get_withdrawal_payment_events`); the same pattern (a partner-scoped RPC reading `audit_logs` for "Disputed by mechanic/wholesaler" rows) would fix this too, if/when it becomes a real scenario worth handling.

3. **Dead route, low priority:** `/profile/preferences` → `PlaceholderScreen` is defined in `app_routes.dart` but nothing in the app links to it anymore — Settings already has real Language/Theme dialog pickers. Safe to delete whenever someone's cleaning up routes; not urgent.

4. **Home's "Lifetime Earned" is still a copy of "Available", not the real figure.** `available` (reducible) and a true "lifetime earned" (should never reduce) are still the same underlying `points_balance` value on Home. `get_mechanic_wallet_summary()` (RPC, real, verified) already computes the true lifetime figure from confirmed QR scans, but the mechanic Activity screen doesn't show a balance card at all anymore (removed on request -- Home already owns that), so nothing in the app currently displays it. The corresponding `mechanicWalletSummaryProvider`/`MechanicWalletSummary` Dart wrapper was deleted as dead code this session (zero watchers, only a pointless `ref.invalidate()`); the RPC itself was left in place, unused but harmless, for whenever Home is the one that switches to it.

## How to resume
- For (1) above: the next real user-visible gap. Confirm scope with the user before starting.
- **Always show the demo before touching real code, no exceptions** -- including for a small follow-up tweak to something already implemented. Skipping straight to implementation on a change the user expected to review as a mockup first caused real friction this session.
- Same workflow otherwise: research/demo (HTML mockup via Artifact when it's UI-driven) → user picks → implement in Flutter → `dart format` + `flutter analyze` + real debug build → user verifies on-device → user explicitly says commit.
