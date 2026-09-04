# SGX Partners: app audit and implementation plan

Reviewed: 4 September 2026. Scope: local documentation, generated design references, Flutter `lib/`, dependencies, assets, and native configuration.

## Assessment

This is a substantial UI prototype with a useful shared Flutter foundation. It is not yet a functional end-to-end mock app, and it is not ready for live money or authentication flows. Most principal routes exist, but screen existence hides missing actions, missing states, disconnected repositories, and inconsistent data.

Keep the existing project and component work. Complete the interaction and state architecture before connecting real rewards and withdrawals. Do not estimate completion by counting Dart files or screens.

Verification: `flutter analyze --no-pub` passed with no issues. Findings below come from source inspection; device rendering, camera operation, screen-reader behavior, backend access policies, and live API behavior were not tested. No application code was changed during this audit.

## 1. Product understanding and source precedence

SGX Partners is one Android-first Flutter B2B app with mechanic and wholesaler experiences. Phone OTP resolves a protected profile. Active existing partners enter their role; an unknown verified phone enters mechanic onboarding; customer/staff and inactive accounts are blocked.

Mechanics scan online. A trusted server transaction validates the QR and dispatched invoice, records the scan, and credits both the mechanic and the invoice's wholesaler. Wholesalers receive rewards passively and see aggregate QR progress. Both roles browse a price-free catalog, view campaigns and notifications, and withdraw available rewards.

Use `docs/shared-architecture.md`, then the role PRDs and architecture, then screen specifications/flows and tokens. `docs/modules.md` is older and includes explicitly superseded scope. Do not add offline queues, role selection, wholesaler signup/scanning, invoice inventory, redemption, ordering, or customer checkout to this app.

There is real design drift to reconcile:

- Role specs say Wallet/Profile and branded Home headers.
- `docs/generated-ui/withdrawal-status-home-preview.html` and `mechanic-settings-header-options.html` show Activity/Settings and revised Home composition. The implementation follows parts of this direction.
- The Home preview still includes Latest Scan/History and campaign See All, which are absent from Flutter Home.
- Treat naming and Home-versus-Wallet balance placement as a baseline decision, not an automatic request to undo the later design.
- Several documentation links point to an older `docs/mobile-app-design/...` tree and to backend requirement files not present here. Consolidate the authoritative paths and record accepted design changes.

## 2. What is already useful

- One shared Flutter app with mechanic and wholesaler folders, Riverpod, GoRouter, and Material 3 light/dark theme definitions.
- Role shells, including the mechanic's raised 64 dp scanner action and a wholesaler shell without a scanner.
- Most main route destinations, product search, activity filters, reusable cards, money formatting, and an approved-name SVG asset.
- Browse-only product content and aggregate, non-tappable wholesaler QR progress.
- Shared domain/repository interfaces and reusable loading/empty/error/offline components, although most are not connected to screens.
- Existing detailed PRDs, state inventories, and HTML/JSX design handoffs. A full redesign is unnecessary.

## 3. Confirmed issues to fix first

### P0: invalid OTP can still advance

`lib/shared/auth/presentation/otp_verification_screen.dart`, `_submit`: after `verifyOtp`, navigation checks profile fields without requiring `AuthStatus.signedIn`. An incorrect nonempty code produces `otpSent` with no profile, then navigates to mechanic onboarding. Onboarding Continue then navigates to Home without saving or validation.

Fix: require verified authentication before routing, keep invalid codes on OTP, and centralize route decisions. Add a regression test for invalid OTP followed by an attempted protected route. This is an app-flow bypass in the current mock; it is not evidence of a deployed backend vulnerability.

### P0: role/auth route protection is not installed

`lib/app/router/app_router.dart` creates GoRouter without an auth redirect. `route_guards.dart` is unused. `SgxPartnersShell` defaults to mechanic when there is no role. Protected route paths are not checked for authentication, active status, onboarding completion, or matching role.

Fix: wire reactive guards, validate role on every protected route, and put onboarding outside the authenticated navigation shell. Check blocked role/active status before incomplete-profile routing. Preserve safe notification destinations through login.

### P0: withdrawal UI does not represent a submitted request

Both withdrawal forms ignore entered values, have nonfunctional amount chips/payment choices, and show mobile-wallet fields for every method. Mechanic confirmation always shows Rs. 1,000 and a fixed recipient. Wholesaler Continue skips review. Both open a fixed `wd-001` route.

Both detail screens ignore `withdrawalId` and display fixed Payment Sent content. Received/Not Received actions are empty callbacks. No request, balance movement, dispute, or confirmation occurs.

Fix: one shared typed form/controller and detail component, method-specific validation, review of actual input, submission lock, repository operation, and server-driven lifecycle states.

### P1: available money is subtracted twice in the Home status card

`lib/shared/widgets/sgx_cards.dart`, `WithdrawalStatusCard`, calculates `availableBalance - withdrawal.amount` for Payment Sent. The specification defines Available as already excluding locked withdrawals. With the wholesaler Home values, the hero says Rs. 18,420 available while the status card says Rs. 13,420 left to withdraw.

Fix: display the same authoritative Available value in both places. Do not derive wallet balance from the status-card amount. Reconcile the older HTML example with the balance definition.

### P1: logout and startup are visual navigation only

Profile Logout buttons navigate to Phone Login without calling `signOut`. Splash always navigates to Phone Login after 1.2 seconds. Session restore is not invoked there and the controller's restore method always finishes signed out.

Fix: restore session/profile on startup, revoke/clear session on logout, invalidate user-scoped providers, and reevaluate routes on auth changes. Implement send/verify failure recovery; `sendOtp` currently has no error handling and verification only catches the mock exception type.

### P1: missing IDs silently show unrelated content

Product and campaign details use `firstWhere(..., orElse: first)`. An invalid/deleted ID displays another item. Withdrawal detail ignores the ID entirely.

Fix: show an explicit unavailable/not-found state and safe return action. Notification/deep-link access must enforce visibility and ownership.

## 4. Screen and interaction gap matrix

| Area | Present | Missing or incomplete |
|---|---|---|
| Phone/OTP | Phone validation, OTP layout, loading indicator | Real SMS, resend timer/action (currently fixed `00:24`), expiry/retry/rate-limit states, empty initial OTP (currently `123456`), correct failure routing |
| Account unavailable | Basic screen | Reason-specific variants and working support/re-login actions |
| Mechanic onboarding | Field layout | Authenticated phone binding, required-field validation, actual area selection, save/error states, backend-created profile; mock auth never returns a new user |
| Mechanic Home | Balance, withdrawal card, campaign | In-content Scan CTA per PRD, latest scan, total scans, History and campaign-list entry points, empty variants, real greeting/unread count |
| Wholesaler Home | Balance, withdrawal card, campaign | Shop context, QR summary, latest reward, shortcuts, empty variants, real greeting/unread count |
| Wallet/Activity | Search-free transaction list with working local filters | Specified wallet summary/Withdraw and withdrawals-list access, or documented Home-only alternative; typed transaction events and detail destinations |
| Withdraw Money | Form shell | Functional quick amounts, payment selection, conditional bank/cash fields, min/balance/destination validation, confirmation for both roles, submitting/error/success states |
| Withdrawals | Static list | Working All/Open/Completed filters, pagination, entry point from normal navigation, empty/error/refresh states |
| Withdrawal Detail | Fixed Payment Sent layout | Record-specific data; Pending, Disputed, Confirmed, Auto-confirmed, Refunded; receipt dialogs, proof/reference, actual deadline, working support/actions |
| Scanner | Frame, guidance, mock success sheet | Camera, torch, permissions/settings recovery, connectivity gate, detection lock, lifecycle handling, real reward/product result, all failure/retry states |
| Scan History | Static rows/summary | Discoverable entry point, confirmed labels/date grouping from data, pagination and async states |
| QR Progress | Aggregate totals and non-tappable cards | Refresh (copy promises pull-down but no RefreshIndicator exists), images, explicit per-group total, loading/empty/error states, safe zero-total progress |
| Products | Grid, text search, detail routes | Working category/brand filters; category callbacks are no-ops and Apply merely closes sheet; real images, normal-grid empty state, pagination and errors |
| Campaigns | Static list/details | Role/date filtering, real artwork, campaign-specific instructions, list entry point/consistent back behavior, unavailable/empty states |
| Notifications | Three sample rows | Tap destinations, typed targets, read/unread persistence, live badge count, pagination, refresh and all lifecycle notification types |
| Mechanic profile/edit | Layout and navigation | Bound/prefilled values, actual save, dirty-form protection, account status, working support/logout |
| Wholesaler profile | Read-only layout | Bound owner/shop data, optional address and active status, working support/logout |
| Preferences | Placeholder route and in-memory controllers | Actual language/theme controls, persistence, Urdu translations, Flutter localization delegates, supported locales and RTL verification |
| Common states | Standalone reusable widgets | Screens do not use AsyncStateView; no real connectivity source; retry/loading/offline cases are largely absent |

Source locations: corresponding screens under `lib/shared/*/presentation/` and `lib/roles/{mechanic,wholesaler}/*/presentation/`; see the priority findings above for the highest-risk paths.

## 5. Architecture work before live integration

Most screens import `shared/mock/sgx_mock_data.dart` or embed constants directly. The repository pattern exists mainly as interfaces. Introduce real in-memory mock implementations behind providers, so a scan, profile edit, or withdrawal changes all affected screens consistently.

Complete domain contracts:

- Scan success needs authoritative amount, safe product identity and scan reference; distinguish inactive QR from inactive account; include a request identifier in the scan operation.
- Withdrawal needs destination input, typed timeline, payment reference, proof reference, paid/deadline timestamps, and idempotency. Repository needs confirm/dispute operations and filtered/paginated reads.
- Wallet transactions need event type/status/reference, not just title and amount. Current Activity filtering classifies positive amounts as rewards, which would incorrectly include refunds.
- Notifications need typed destination, read timestamp/state, mark-read and pagination operations.
- Profile needs update operations and auth/session watching. Home summaries need actual provider/repository ownership.

Consolidate duplicated wallet/withdrawal/profile basics through shared implementations with role-specific data and routes. `shared/widgets/sgx_cards.dart` contains mock-bound versions of widgets also represented in feature folders. Choose one production component per purpose rather than maintaining both.

Live backend wiring is absent locally: `supabaseClientProvider` returns null, the initializer does nothing, environment is fixed to mock, and `pubspec.yaml` has no Supabase SDK. There are no local backend migrations or scan/payment operations to review. This does not establish that the shared SGX backend is missing elsewhere.

Before integration, inspect that existing backend and agree exact contracts for protected profiles, OTP, trusted mechanic creation, atomic dual reward credit, aggregate wholesaler QR reads, append-only wallet history, withdrawal transitions/idempotency, configuration, private proof access, and notification refresh. Verify ownership/role restrictions on the server; client guards alone are insufficient. Do not build a second schema from assumptions.

## 6. Visual quality and native readiness

These are source-based findings and validation targets, not a completed screenshot comparison:

- Fixed OTP boxes consume 324 dp inside 48 dp horizontal padding: a 360 dp viewport leaves only 312 dp. Make the layout responsive.
- Several important controls use 44 dp height despite the 48 dp requirement. Fixed-height navigation, two-column product tiles and horizontal money rows need 200% text-scale checks.
- Many screens use light-specific `AppColors` directly. A dark ThemeData alone does not guarantee readable dark UI. Move surface/text/status colors to semantic theme roles and check contrast.
- Urdu is not implemented: only the app name exists in `AppLocalizations`, no delegates/supported locales are configured, and most text/spacing is hardcoded for English/LTR.
- Product/campaign image folders contain no actual imagery in the tracked file inventory; screens render icons. Add approved artwork and image loading/failure behavior.
- Remove prototype copy from customer-facing screens, including “Progress bars are not shown in v1” and “Prices, stock, cart, and ordering are intentionally hidden.”
- Many detail transitions use `context.go`; audit `push`/back behavior. `SgxAppBar` falls back to mechanic Home even for wholesalers. Scanner and onboarding currently sit inside the navigation shell.
- Android main manifest lacks Internet/camera declarations; inspect the final merged manifest when integrating plugins. iOS has no camera usage description. Native display names remain Partner/partner, and Android release uses debug signing. Complete branding, permissions, and production signing before distribution.
- `test/` is empty and there is no Flutter test dependency. Add meaningful auth/navigation, domain/state, and critical journey tests during implementation.

## 7. Recommended delivery order and acceptance gates

### Phase 1 — Reconcile baseline and repair authentication/navigation

Record Activity/Settings versus Wallet/Profile, balance placement, and approved Home header direction. Fix invalid OTP advancement, centralize guards, make logout/restore real within mocks, and add new/inactive/wrong-role mock profiles. Correct the balance subtraction and missing-ID fallbacks.

Done when: invalid OTP never advances; direct protected routes and wrong-role routes are blocked; verified unknown users reach onboarding; existing roles route correctly; logout removes user state; Home shows consistent Available amounts.

### Phase 2 — Make one coherent mock app

Implement repository-backed fixtures and provider state. Complete forms and methods, six withdrawal statuses, dialogs, scanner result states, and profile saves. Route changes through shared operations and refresh dependent Home/Activity/history/notifications. No widgets should claim success without an operation result.

Done when: both roles can complete a withdrawal journey using actual entered values; mechanic scan success changes the same wallet/history data shown elsewhere; failed operations leave balances unchanged; all states can be selected deterministically for review.

### Phase 3 — Finish UI coverage

Complete Home sections and navigation entry points, preferences, filtering, notifications, imagery, empty/loading/error/offline/retry states, English/Urdu and light/dark themes. Review the generated design frames against device screenshots at narrow widths and 200% text scale.

Done when: every visible control has a purpose and works; each required state can be reviewed; no unreachable main flow or placeholder preferences remains; both languages and themes are usable.

### Phase 4 — Integrate the existing backend in vertical slices

First verify the shared backend contracts. Then integrate OTP/profile, read-only catalog/campaigns, wallets/history/QR summaries, mechanic scan, withdrawals, and notifications/private proof access. Add actual connectivity and camera lifecycle behavior. Keep mock/staging/production explicit and prevent mock OTP/data in production.

Done when: a staging mechanic scan credits the correct two accounts once; duplicate/concurrent requests cannot double-credit or overdraw; withdrawals lock and refund money correctly; confirm/dispute transitions are authorized; users cannot read another user's records; new earnings stay available during an open withdrawal.

### Phase 5 — Device and release verification

Test camera denial/permanent denial, background/resume, slow and dropped networks, retry after uncertain submission, notification entry while signed out, blocked accounts, Urdu/RTL, TalkBack/VoiceOver, dark mode, keyboard visibility and large text. Finish release permissions, icons/name, signing and environment configuration.

Done when: critical journeys pass on target Android devices, iOS compatibility is verified if launching there, and a staging-to-release checklist has no unresolved auth/payment blockers.

## 8. Inputs needed before final launch

These do not block Phase 1 or mock completion:

- Approved Activity/Settings versus Wallet/Profile information architecture and Home header direction.
- Existing backend repository/project and API contract ownership.
- Launch payment methods, minimum amount, auto-confirm duration, cash collection instructions, and cash-proof requirements.
- Final SGX WhatsApp/help contact; current screen numbers are sample content.
- Approved Urdu translations, product photos and campaign artwork.
- Whether workshop stays optional, whether scan history shows wholesaler/shop context, and whether QR cards retain invoice references.

Recommended first implementation batch: auth/route correctness, consistent balance semantics, shared repository-backed mock state, and a complete withdrawal flow for both roles. These changes remove the largest correctness risks and make subsequent UI work testable.
