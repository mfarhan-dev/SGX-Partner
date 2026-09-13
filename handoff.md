# SGX Partner — Handoff (2026-09-13)

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
- **QR scan-to-earn (backend only)** — `mechanics.points_balance` / `wholesalers.points_balance` with guard triggers, `scan_qr_code(p_qr_id)` RPC (credits both mechanic and wholesaler instantly, blocks re-scan), verified end-to-end against a real QR code in an earlier session. **The scanner UI itself is still decorative — see Remaining below.**
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

1. **QR camera scanning is fully decorative.** `/mechanic/scan` → `QrScannerScreen` (`lib/roles/mechanic/scanner/presentation/qr_scanner_screen.dart`) is a static gradient UI with a "Mock successful scan" button (`_showSuccess`) — there's no camera package wired in at all, and it never calls the real `scan_qr_code(p_qr_id)` RPC that already exists and was verified working in an earlier session. `mechanic_scan_repository.dart` / `scan_history_screen.dart` exist as scaffolding but the actual scan-and-credit path from camera → RPC isn't connected.

2. **Multi-dispute-cycle history isn't representable yet.** `withdrawals.dispute_reason` / `disputed_at` are single columns — only the *latest* dispute survives. If a withdrawal is ever disputed → re-paid → disputed again, the app has no way to show the first dispute's own reason/timestamp separately. The payment side already got the audit_logs-backed fix this session (`get_withdrawal_payment_events`); the same pattern (a partner-scoped RPC reading `audit_logs` for "Disputed by mechanic/wholesaler" rows) would fix this too, if/when it becomes a real scenario worth handling.

3. **Dead route, low priority:** `/profile/preferences` → `PlaceholderScreen` is defined in `app_routes.dart` but nothing in the app links to it anymore — Settings already has real Language/Theme dialog pickers. Safe to delete whenever someone's cleaning up routes; not urgent.

4. **Home's "Lifetime Earned" is still a copy of "Available", not the real figure.** `available` (reducible) and a true "lifetime earned" (should never reduce) are still the same underlying `points_balance` value on Home. This was flagged as a future gap before withdrawals existed and is still open there — though the new mechanic Activity screen (see above) now shows the *real* lifetime-earned figure via `get_mechanic_wallet_summary()`, so the two screens will visibly disagree for any mechanic whose balance was ever adjusted outside the normal scan/withdraw flow (e.g. a manual test top-up) until Home is switched to the same source.

## How to resume
- For (1) above: the next real user-visible gap. Confirm scope with the user before starting (camera package choice, RPC wiring, UI).
- Same workflow as always: research/demo (HTML mockup via Artifact when it's UI-driven) → user picks → implement in Flutter → `dart format` + `flutter analyze` + real debug build → user verifies on-device → user explicitly says commit.
