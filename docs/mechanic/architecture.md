# SGX Partners — Mechanic Module Architecture

**Application:** SGX Partners — one shared B2B Flutter app  
**Module:** Mechanic role experience  
**Platform:** Flutter, Android first, iOS-compatible  
**State management:** Riverpod 3  
**Backend:** Shared Supabase project  
**Design system:** Material Design 3  
**Document version:** v1.0  
**Last updated:** 22 July 2026  
**Status:** Architecture baseline for design and future implementation

---

## 1. Purpose

This document converts the approved mechanic PRD, screen specifications, screen flow, and navigation reference into implementation boundaries for the single SGX Partners Flutter app.

Mechanic and wholesaler modules share one executable, authentication session, theme, localization system, and selected feature packages. The protected profile determines the role experience. Unknown verified phone numbers may create mechanic profiles through the trusted onboarding workflow; they can never create wholesaler profiles.

Mechanic scanning is online-only. No scan payload, reward estimate, or mutation is persisted for later synchronization.

## 2. Source of Truth and Precedence

Use this order for mechanic mobile behavior:

1. `prd.md`, especially Locked Owner Decisions.
2. This architecture document.
3. `screen-specs.md` and `screen-flow.md`.
4. `design-token.json`.
5. Current owner instructions recorded in this package.
6. Older shared requirements/admin modules as background only.

Older references to offline scanning, offline queue, mechanic wholesaler assignment, role selection, or tax fields are superseded.

## 3. Locked Architecture Decisions

| Area | Decision |
|---|---|
| Application | One B2B Flutter app with mechanic and wholesaler modules. |
| Product name | `SGX Partners` for both role experiences. |
| Brand icon | Reuse `../../customer/sgx-app-icon.svg` unchanged for both roles. |
| Mechanic registration | Self-registration with verified phone plus minimal profile. |
| Unknown phone | Trusted onboarding creates `role = mechanic`. |
| Role selection | Not shown. |
| Wholesaler relationship | No profile assignment; resolved per QR invoice snapshot. |
| Navigation | Home, Products, center Scan, Wallet, Profile. |
| Scan presentation | Raised center-docked Material 3 action. |
| Scan connectivity | Online-only. |
| Offline behavior | Block scan; no queue, cache, pending state, or sync worker. |
| Reward authority | Trusted server validates and credits atomically. |
| Wallet exit | Withdrawals only; no invoice redemption. |
| Products | Shared B2B-safe, price-free, browse-only. |
| Profile | Basic identity editable; phone and role read-only. |
| Data architecture | Repository contracts and typed domain models. |
| State management | Riverpod 3 only. |

## 4. Brand Asset Architecture

- Canonical source: [`../../customer/sgx-app-icon.svg`](../../customer/sgx-app-icon.svg).
- Flutter asset target: `assets/branding/sgx-app-icon.svg` in the future SGX Partners project.
- The asset is bundled locally; the app must not fetch the logo from a remote URL.
- Android and iOS launcher files are generated from this master while respecting platform safe zones.
- Splash, authentication, onboarding, and Home render the same master asset at the sizes in `screen-specs.md`.
- Preserve the white rounded-square background, navy SGX artwork, aspect ratio, and clear space. Do not tint or create role variants.
- Use semantic label `SGX Partners logo` where the icon conveys identity. When adjacent text already says `SGX Partners`, it may be excluded from accessibility semantics to prevent duplicate announcements.

## 5. Architectural Principles

1. OTP verifies phone ownership; trusted profile data determines role and status.
2. An existing customer/staff/wholesaler profile is never overwritten by mechanic onboarding.
3. Mechanic profiles do not store a permanent wholesaler relationship.
4. Scan validation and both reward credits happen in one trusted server transaction.
5. The mobile client never confirms a reward before the server response.
6. Duplicate scan defense exists on the server even if the UI prevents repeat frames.
7. Scan payloads are ephemeral and are discarded on close/failure; there is no offline persistence.
8. Wallet and withdrawal values are server-authoritative ledger projections.
9. Shared product/campaign/notification features expose only role-safe fields.
10. Every async screen deliberately handles loading, content, empty, error, offline, and retry.

## 6. System Context

```text
SGX Partners Flutter App
  |- Shared auth, theme, localization, products, campaigns, notifications
  |- Wholesaler module
  `- Mechanic module
       |- Onboarding
       |- Home
       |- Online Scanner
       |- Confirmed Scan History
       |- Wallet
       `- Withdrawals
             |
             v
Shared Supabase Backend
  |- Auth: phone OTP and sessions
  |- Profiles: role and active status
  |- Trusted scan operation
  |- QR/invoice/scheme snapshots
  |- Wallet ledger and withdrawals
  |- Products, campaigns, notifications
  |- Private withdrawal proof
  `- Realtime update signals

Admin Panel
  |- Manages mechanics and wholesalers
  |- Issues/dispatches QR-bearing invoices
  |- Processes withdrawals
  `- Manages campaigns
```

## 7. Flutter Layers

```text
Presentation
  Screens, scanner UI, forms, navigation, Material 3 states
       |
Application
  Riverpod providers, Notifiers, orchestration, duplicate-action guards
       |
Domain
  Typed models, repository interfaces, status/value rules
       |
Data
  Supabase repositories, scan endpoint adapter, DTO mapping, mocks
       |
Infrastructure
  Supabase client, connectivity, camera adapter, secure session, logging
```

### Presentation

- Renders typed state.
- Owns camera preview and permission UI.
- Collects onboarding/withdrawal/profile input.
- Triggers one scan request and renders result.
- Handles navigation, sheets, dialogs, and snackbars.

It must not parse reward snapshots, decide QR validity, assign a wholesaler, or credit wallet entries.

### Application

- Coordinates repositories.
- Prevents duplicate scan/withdrawal submissions.
- Maps failures into plain-language states.
- Invalidates Home, Scan History, Wallet, Withdrawals, and Notifications after success.
- Coordinates route reevaluation after onboarding or deactivation.

### Domain

- Immutable entities and enums.
- Repository contracts.
- Pure UI-safe format/mapping rules.
- No Flutter, camera, Riverpod, or Supabase imports.

### Data/Infrastructure

- Supabase and server-operation calls.
- DTO mapping.
- Camera scanner adapter.
- Connectivity signal.
- Mock repositories and deterministic scan results.
- No local scan database or sync worker.

## 8. Recommended Shared-App Structure

```text
lib/
|- main.dart
|- bootstrap.dart
|- app/
|  |- app.dart
|  |- router/
|  |  |- app-router.dart
|  |  |- route-guards.dart
|  |  `- route-names.dart
|  |- theme/
|  `- localization/
|- core/
|  |- auth/
|  |- camera/
|  |- config/
|  |- errors/
|  |- network/
|  |- storage/
|  `- supabase/
|- shared/
|  |- products/
|  |- campaigns/
|  |- notifications/
|  |- profile/
|  `- widgets/
|- roles/
|  |- wholesaler/
|  `- mechanic/
|     |- onboarding/
|     |- home/
|     |- scanner/
|     |- scan-history/
|     |- wallet/
|     `- withdrawals/
`- test/
```

There must be no mechanic `offline-queue`, `sync-worker`, or local scan database feature.

## 9. Authentication, Registration, and Role Resolution

### Startup

```text
Initialize environment/Supabase
-> Restore session
-> Observe auth state
-> Load protected profile
-> Route by role, active status, and mechanic profile completeness
```

### OTP and Profile Resolution

```text
Phone Login
-> Normalize phone
-> Request OTP
-> Verify OTP
-> Load profile for auth.uid()
   -> active mechanic, complete: Mechanic shell
   -> active mechanic, incomplete: Mechanic onboarding
   -> no profile: Mechanic onboarding
   -> active wholesaler: Wholesaler shell
   -> inactive B2B: Account Unavailable
   -> customer/staff: B2B Access Unavailable
```

### Trusted Mechanic Creation

The app submits onboarding fields after OTP. A trusted server operation:

1. Confirms authenticated phone identity.
2. Confirms no protected profile already exists.
3. Validates Full Name and Area/City.
4. Creates `role = mechanic`, active by default subject to business approval.
5. Returns the protected profile.

The client does not send a selectable role. It cannot create `wholesaler`, `customer`, or `staff` profiles.

## 10. Navigation Architecture

Approved shell:

```text
BottomAppBar
  Home       /mechanic/home
  Products   /products
  [Scan]     /mechanic/scan
  Wallet     /mechanic/wallet
  Profile    /profile
```

The center Scan action is a `FloatingActionButton`-style action docked into or visually integrated with `BottomAppBar`. It is not a selected tab and does not preserve a scanner navigation stack.

Pushed routes:

```text
/mechanic/onboarding
/mechanic/scans
/mechanic/withdrawals
/mechanic/withdrawals/new
/mechanic/withdrawals/:withdrawalId
/products/:productId
/campaigns
/campaigns/:campaignId
/notifications
/profile/edit
/profile/preferences
```

Intentionally absent:

- `/select-role`
- `/select-wholesaler`
- `/mechanic/offline-scans`
- `/mechanic/sync-queue`
- `/mechanic/redemptions`

## 11. Riverpod State Ownership

| State | Owner | Persistence |
|---|---|---|
| Auth session | Auth stream provider | Supabase SDK |
| Protected profile/role | Profile provider | Supabase |
| Onboarding form | Onboarding AsyncNotifier | Memory until success/retry |
| Selected content destination | Router shell | Restoration optional |
| Camera permission | Scanner controller/widget lifecycle | OS + memory |
| Current detected payload | Scanner AsyncNotifier | Memory during active scan only |
| Current scan result | Scanner AsyncNotifier | Memory until close/next scan |
| Scan history | Paginated provider | Server |
| Home summary | Mechanic Home provider | Server + memory |
| Wallet/withdrawals | Role-aware providers/Notifiers | Server |
| Products/campaigns/notifications | Shared providers | Server |
| Profile edit | Profile AsyncNotifier | Memory during edit |
| Language/theme | Preference Notifiers | Local preferences |

Never persist current QR payload or create a local pending-scan state.

## 12. Scanner State Machine

```text
ScannerState
|- checkingConnectivity
|- offlineBlocked
|- requestingPermission
|- permissionDenied
|- ready
|- detected(payload in memory)
|- validating
|- success(result)
|- alreadyScanned
|- notActive
|- invalid
|- expired
`- retryableError
```

Rules:

- Only `ready` accepts camera frames.
- First detected payload moves immediately to `detected/validating`.
- Ignore later frames until state resets.
- Retry may reuse payload only while scanner screen remains open.
- Leaving/closing scanner clears payload and result.
- No state is serialized to disk.

## 13. Trusted Scan Operation

Recommended contract:

```text
validateAndCreditScan(payload, requestId)
```

Server transaction:

1. Authenticate caller.
2. Verify caller profile is active mechanic.
3. Parse versioned payload.
4. Verify HMAC/signature using server-only secret.
5. Load QR and invoice snapshot.
6. Verify QR active, dispatched, unused, and not expired.
7. Enforce unique QR scan.
8. Read snapshotted mechanic/wholesaler rupee values.
9. Insert scan record.
10. Insert mechanic wallet credit.
11. Insert invoice-wholesaler wallet credit.
12. Mark QR scanned.
13. Create notifications/update signals.
14. Return safe product and mechanic-reward result.

All steps must succeed or roll back together.

### Safe Result Shape

```text
ScanResult
  status
  mechanicRewardPkr
  productName
  productImageUrl
  scannedAt
```

Do not return HMAC, raw snapshot JSON, buying/selling prices, profit, or sensitive wholesaler data.

## 14. Domain Models

```text
B2BProfile
  id, role, isActive, isComplete, phone,
  fullName, workshopName, area

MechanicHomeSummary
  availableBalance, pendingWithdrawal, lifetimeEarned,
  totalScans, latestScan, activeWithdrawal

ConfirmedScan
  id, productId, productName, imageUrl,
  rewardPkr, scannedAt, optionalWholesalerName

WalletSummary
  available, pending, lifetimeEarned

WalletTransaction
  id, type, amount, occurredAt, status, withdrawalId

Withdrawal
  id, amount, method, maskedDestination, status,
  submittedAt, paidAt, reference, proofReference, timeline
```

There is no `PendingScan`, `OfflineScan`, `SyncQueue`, mechanic `wholesalerId`, or invoice-redemption type.

## 15. Repository Contracts

```text
AuthRepository
  sendOtp(phone)
  verifyOtp(phone, token)
  watchAuthState()
  signOut()

ProfileRepository
  getCurrentB2BProfile()
  createMechanicProfile(input)
  updateMechanicProfile(input)

ScannerRepository
  validateAndCredit(payload, requestId)

ScanHistoryRepository
  getConfirmedScans(page)

MechanicHomeRepository
  getSummary()

WalletRepository
  getSummary()
  getTransactions(page)

WithdrawalRepository
  getWithdrawals(page, filter)
  getWithdrawal(id)
  submitWithdrawal(command, idempotencyKey)
  confirmReceived(id)
  reportNotReceived(id)
  watchWithdrawal(id)

ProductRepository
  getB2BProducts(query, category, brand, page)
  getB2BProduct(id)

CampaignRepository
  getActiveCampaignsForRole(role)
  getCampaign(id)

NotificationRepository
  getNotifications(page)
  watchNotifications()
  markRead(id)
```

No offline scanner repository exists.

## 16. Wallet and Withdrawal Integrity

- Wallet ledger is append-only.
- Server returns authoritative Available, Pending, and Lifetime values.
- Scan credit references trusted scan record.
- No invoice-redemption event exists.
- Withdrawal submissions use idempotency keys.
- Server validates role, active status, minimum, available balance, and destination.
- Paid confirmation/dispute is allowed once from valid state.
- Refund creates a new wallet credit event.
- UI invalidates Home, Wallet, Withdrawals, and Notifications after changes.

## 17. Supabase Access Boundaries

| Resource | Mechanic access |
|---|---|
| Profile | Read/update own allowed fields; phone/role protected |
| QR payload processing | Execute trusted scan operation only |
| Scan history | Read own confirmed scans only |
| Wallet | Read own summary/transactions only |
| Withdrawals | Read own; mutate through trusted operations |
| Products | Read B2B-safe price-free fields |
| Campaigns | Read active mechanic-targeted campaigns |
| Notifications | Read/update own notifications |
| Payment proof | Read own through private signed access |

Requirements:

- RLS on exposed resources.
- Ownership uses `auth.uid()`.
- Role comes from protected server-controlled data.
- No service-role or HMAC secret in app.
- Customer/staff profile cannot call scan or withdrawal B2B operations.
- Rate-limit/security flags are admin-only.

## 18. Connectivity and Local Persistence

Persist:

- Supabase session through SDK.
- Language/theme.
- Optional last successful read-only content cache.

Never persist:

- Detected QR payload.
- Unvalidated scan.
- Pending scan.
- Reward estimate.
- Wallet balance as authority.
- Withdrawal write queue.
- Proof URLs.

Connectivity is checked before activating the scanner and again handled at request time. A failed scan request remains retryable only while the scanner route is open.

## 19. Error Model

```text
AppFailure
|- OfflineFailure
|- AuthenticationFailure
|- AuthorizationFailure
|- InactiveAccountFailure
|- CameraPermissionFailure
|- InvalidQrFailure
|- AlreadyScannedFailure
|- QrNotActiveFailure
|- QrExpiredFailure
|- ValidationFailure
|- InsufficientBalanceFailure
|- DuplicateSubmissionFailure
|- NotFoundFailure
|- StorageFailure
|- ServerFailure
`- UnknownFailure
```

Repositories map technical errors. Notifiers map them to safe localized result states. Widgets do not inspect raw Supabase or camera exceptions.

## 20. Camera and Lifecycle Rules

- Request only camera permission required for live scanning.
- No gallery/media-library permission.
- Pause camera when app backgrounds, route loses focus, or payload is detected.
- Resume only in `ready` state.
- Dispose camera controller when leaving scanner.
- Do not record video or store frames.
- Provide semantic labels and non-camera permission guidance.
- Handle rotation and safe-area insets without moving the scan frame off-screen.

## 21. Localization and Accessibility

- All copy comes from localization resources.
- English and Urdu are required; Urdu is RTL-ready.
- Center scan action has `Scan QR` semantics independent of icon.
- Scanner instructions are announced to screen readers.
- Status uses icon, text, and color.
- Support 200 percent text scaling outside camera overlay; camera result actions may stack.
- Touch targets: 48 dp minimum; Scan: at least 64 dp.
- Use locale-aware currency, date, time, and phone formatting.

## 22. Performance

- Keep scanner preview isolated from unrelated provider rebuilds.
- Debounce QR detection at the scanner layer.
- Send one request per detected payload/requestId.
- Paginate Scan History, Wallet, Withdrawals, Products, Campaigns, Notifications.
- Debounce product search.
- Request sized images.
- Realtime only for scoped notifications/withdrawal signals; refetch authority after events.
- Cancel subscriptions and camera on logout/dispose.

## 23. Testing Strategy

### Unit

- Phone normalization.
- Auth routing matrix.
- Mechanic onboarding validation.
- Scanner state transitions.
- Duplicate-frame suppression.
- Scan-result mapping.
- Withdrawal validation/idempotency.
- Profile edit validation.

### Backend/Security

- Customer/staff/wholesaler cannot call mechanic scan operation.
- Inactive mechanic scan rejected.
- Invalid signature rejected.
- Generated/not-dispatched QR rejected.
- Duplicate QR credits once.
- Successful scan credits both correct wallet shares atomically.
- Wholesaler derived from invoice snapshot, not mechanic profile.
- Cross-mechanic scan history access denied.
- Invoice redemption operation absent.

### Widget

- Bottom order exactly Home, Products, Scan, Wallet, Profile.
- Center Scan semantics and 64 dp target.
- Scanner permission/offline/processing/result states.
- No offline queue/pending scan UI.
- All async screen states.
- No price/tax/wholesaler selector.
- Profile phone/role read-only.

### Integration

1. Unknown phone OTP to mechanic onboarding/Home.
2. Existing mechanic OTP to Home.
3. Active wholesaler routes to wholesaler shell.
4. Customer/staff blocked.
5. Online valid scan credits reward and opens Wallet.
6. Duplicate/invalid/not-active scan states.
7. Scanner offline blocks without saving.
8. Withdrawal submit/payment confirmation/dispute/refund.
9. Profile edit and logout cleanup.
10. Products/campaigns remain price/progress-free.

## 24. Implementation Sequence

### Phase 1 — Shared B2B Foundation

1. Flutter, environments, Material 3 theme.
2. Riverpod, localization, shared router.
3. Phone OTP and role/profile guards.
4. Shared error/loading/empty/offline components.
5. BottomAppBar plus center Scan shell.

### Phase 2 — Mechanic Mock Experience

1. Domain models and repository contracts.
2. Mock onboarding and role routes.
3. Home and approved navigation.
4. Scanner UI with deterministic mocked results.
5. Confirmed Scan History.
6. Wallet and withdrawal lifecycle.
7. Shared Products, Campaigns, Notifications, Profile.

### Phase 3 — Live Integration

1. Auth/profile creation and RLS.
2. Camera/QR reader adapter.
3. Trusted atomic scan operation.
4. Confirmed scan history and wallet.
5. Withdrawal operations.
6. Shared data and notifications.

### Phase 4 — Hardening

1. QR security and duplicate concurrency tests.
2. Slow/interrupted network and app-lifecycle tests.
3. Camera permission/device tests.
4. Cross-role access tests.
5. Urdu/RTL, dark, 200 percent text, screen-reader tests.
6. Low-literacy usability testing.

## 25. Definition of Done

- Unknown verified phones can create mechanic profiles without role selection.
- Existing roles are preserved and routed safely.
- Mechanics are independent; no wholesaler assignment exists.
- Navigation matches Home, Products, center Scan, Wallet, Profile.
- Scan action is prominent, accessible, and safe-area aware.
- Scanning is online-only with no persisted/queued payload.
- Scan credit is atomic, idempotent, and server-authoritative.
- Scan History contains confirmed server records only.
- Wallet/withdrawals contain no invoice redemption.
- Products are price-free.
- Profile has no tax fields and protects phone/role.
- All async, accessibility, localization, and security tests pass.
