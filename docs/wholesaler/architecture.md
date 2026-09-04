# SGX Partners — Wholesaler Module Architecture

**Application:** SGX Partners — one shared B2B Flutter app  
**Module:** Wholesaler role experience  
**Platform:** Flutter, Android first, iOS-compatible  
**State management:** Riverpod 3  
**Backend:** Shared Supabase project  
**Design system:** Material Design 3  
**Document version:** v1.0  
**Last updated:** 22 July 2026  
**Status:** Architecture baseline for design and future implementation

---

## 1. Purpose

This document converts the approved wholesaler PRD, screen specifications, and screen flow into implementation boundaries for the single SGX Partners Flutter app. It defines how a protected wholesaler profile enters the role-aware app shell, how data is separated, and how wallet, QR summary, withdrawal, product, campaign, notification, and profile features should be organized.

This is not a second mobile application. Mechanic and wholesaler modules share one Flutter executable, authentication session, theme, localization system, and selected feature packages. Role-specific routes and permissions determine which experience opens.

## 2. Source of Truth and Precedence

For wholesaler mobile behavior, use this order:

1. `prd.md`, especially Locked Owner Decisions.
2. This architecture document.
3. `screen-specs.md` and `screen-flow.md`.
4. `design-token.json`.
5. Current owner instructions recorded in this package.
6. Older shared requirements and admin module documents as background only.

Older references to wholesaler signup, invoice redemption, invoice inventory, tax numbers, or QR detail are superseded for this module.

## 3. Locked Architecture Decisions

| Area | Decision |
|---|---|
| Application | One B2B Flutter app with mechanic and wholesaler role modules. |
| Product name | `SGX Partners` for both role experiences. |
| Brand icon | Reuse `../../customer/sgx-app-icon.svg` unchanged for both roles. |
| Wholesaler provisioning | Admin panel only. |
| Authentication | Phone plus SMS OTP. |
| Role selection | Not shown; role comes from trusted profile data. |
| Unknown phone | Continues to mechanic onboarding outside this module. |
| Wrong-role phone | Customer/staff profiles are blocked from B2B access. |
| Wholesaler navigation | Home, QR Progress, Wallet, Products, Profile. |
| QR Progress | Aggregate read-only summary; no detail route. |
| Reward source | Passive credit from mechanic scans tied to wholesaler invoice snapshots. |
| Invoice redemption | Removed. |
| Withdrawals | Only supported wallet cash-out mechanism. |
| Product catalog | Shared, browse-only, price-free. |
| Profile | Business identity is read-only. |
| Offline | Read refresh may use cached content; no offline writes or withdrawal queue. |
| Data boundary | Repository contracts; widgets never call Supabase directly. |
| State management | Riverpod 3 as the only global state/DI system. |

## 4. Brand Asset Architecture

- Canonical source: [`../../customer/sgx-app-icon.svg`](../../customer/sgx-app-icon.svg).
- Flutter asset target: `assets/branding/sgx-app-icon.svg` in the future SGX Partners project.
- The asset is bundled locally; the app must not fetch the logo from a remote URL.
- Android and iOS launcher files are generated from this master while respecting platform safe zones.
- Splash, authentication, and Home render the same master asset at the sizes in `screen-specs.md`.
- Preserve the white rounded-square background, navy SGX artwork, aspect ratio, and clear space. Do not tint or create role variants.
- Use semantic label `SGX Partners logo` where the icon conveys identity. When adjacent text already says `SGX Partners`, it may be excluded from accessibility semantics to prevent duplicate announcements.

## 5. Architectural Principles

1. The verified phone establishes identity; trusted server data establishes role.
2. UI visibility is not authorization. Supabase policies and server functions enforce ownership and role.
3. Wholesaler rewards are server-authored ledger credits, never client calculations.
4. QR Progress is an aggregate projection, not a raw QR query.
5. Available, Pending, and Lifetime balances are named projections over immutable financial events.
6. Withdrawal state transitions are server-enforced and idempotent.
7. Shared features remain role-aware and expose only B2B-safe fields.
8. Every asynchronous screen supports loading, content, empty, error, offline, and retry.
9. Local persistence improves continuity but never becomes the source of financial truth.
10. Simplicity is an architecture constraint: avoid duplicate routes and unnecessary intermediate screens.

## 6. System Context

```text
SGX Partners Flutter App
  |- Shared auth, theme, localization, products, campaigns, notifications
  |- Mechanic module
  `- Wholesaler module
       |- Home
       |- QR Progress aggregate
       |- Wallet
       |- Withdrawals
       `- Read-only profile
             |
             v
Shared Supabase Backend
  |- Auth: phone OTP and sessions
  |- Profiles: one protected role per phone identity
  |- PostgreSQL: QR reward projections, wallet ledger, withdrawals, products, campaigns
  |- Storage: campaign/product images and private withdrawal proof
  |- Realtime: reward, withdrawal, and notification update signals
  `- Trusted server operations: reward credit and withdrawal state transitions

Admin Panel
  |- Creates and manages wholesaler profiles
  |- Issues/dispatches invoices and activates reward QRs
  |- Processes withdrawals
  `- Creates campaigns and notifications
```

## 7. Flutter Layers

```text
Presentation
  Screens, widgets, forms, navigation, Material 3 state rendering
       |
Application
  Riverpod providers, Notifiers, feature coordination
       |
Domain
  Typed entities, value objects, repository interfaces, status rules
       |
Data
  Supabase repositories, DTO mapping, mock repositories, local preferences
       |
Infrastructure
  Supabase client, connectivity, secure session, logging, environment config
```

### Presentation

- Renders typed state.
- Collects withdrawal input.
- Shows localized messages.
- Triggers Notifier methods.
- Owns focus, confirmation sheets, snackbars, and navigation effects.

It must not calculate wallet credit, infer role from navigation, query raw QR records, or mutate withdrawals directly.

### Application

- Coordinates repositories.
- Prevents duplicate submissions.
- Maps failures into safe UI states.
- Invalidates Wallet, Withdrawals, Home, and Notifications after mutations.
- Handles role-aware route refresh.

### Domain

- Contains immutable typed models.
- Defines money and status values.
- Contains repository interfaces.
- Has no Flutter widget, Supabase, or Riverpod imports.

### Data

- Builds authorized Supabase queries.
- Maps DTOs to domain models.
- Implements aggregate QR Progress reads.
- Uploads/reads withdrawal proof only through private paths.
- Provides mock implementations for deterministic design/testing.

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
|  |- mechanic/
|  `- wholesaler/
|     |- home/
|     |- qr-progress/
|     |- wallet/
|     `- withdrawals/
`- test/
```

Each wholesaler feature adds only the folders it needs:

```text
roles/wholesaler/qr-progress/
|- domain/
|  |- entities/
|  `- repositories/
|- data/
|  |- dto/
|  |- mappers/
|  `- repositories/
`- presentation/
   |- providers/
   |- screens/
   `- widgets/
```

Do not create a `qr-progress-detail` feature or route.

## 9. Authentication and Role Resolution

### 8.1 Startup

```text
Initialize environment and Supabase
-> Restore Supabase session
-> Observe auth state
-> Load protected profile
-> Evaluate active status and role
-> Route to wholesaler, mechanic, or access-unavailable state
```

### 8.2 OTP Login

```text
Phone Login
-> Normalize Pakistani number
-> Request OTP
-> Verify OTP
-> Load profile for auth.uid()
   -> role=wholesaler, active=true: Wholesaler shell
   -> role=mechanic, active=true: Mechanic shell
   -> role=customer/staff: block B2B access
   -> role=wholesaler/mechanic, active=false: account inactive
   -> no profile: mechanic onboarding flow
```

The mobile client must not set `role=wholesaler`. Only admin/trusted backend provisioning can create that role.

### 8.3 Role Guard Rules

- Wholesaler routes require an authenticated, active wholesaler profile.
- Mechanic routes require an authenticated, active mechanic profile.
- Shared routes render only fields allowed for the active B2B role.
- Role changes during a session force a profile refresh and route reevaluation.
- Logout clears protected provider state and navigation history.
- A customer/staff profile must not be auto-converted or duplicated.

## 10. Route Architecture

```text
/splash
/auth/phone
/auth/otp
/auth/account-unavailable

/wholesaler/home
/wholesaler/qr-progress
/wholesaler/wallet
/wholesaler/withdrawals
/wholesaler/withdrawals/new
/wholesaler/withdrawals/:withdrawalId

/products
/products/:productId
/campaigns
/campaigns/:campaignId
/notifications
/profile
/profile/preferences
```

There is intentionally no:

- `/wholesaler/signup`
- `/select-role`
- `/wholesaler/scan`
- `/wholesaler/qr-progress/:id`
- `/wholesaler/inventory`
- `/wholesaler/redemptions`
- `/profile/edit`

The five main destinations should live in a stateful shell that preserves each tab’s navigation state where practical.

## 11. Riverpod State Ownership

| State | Owner | Persistence |
|---|---|---|
| Auth session | Supabase auth stream provider | Supabase SDK |
| Protected profile/role | Profile provider | Supabase |
| Selected main tab | Router shell | Restoration optional |
| Home summary | Wholesaler home provider | Server + memory |
| QR Progress aggregates | QR progress provider | Server + short-lived memory cache |
| Wallet summary | Wallet provider | Server source of truth |
| Wallet transactions | Paginated wallet provider | Server |
| Withdrawal form | Withdrawal Notifier | Memory until success/retry |
| Withdrawal list | Withdrawals provider | Server |
| Withdrawal detail | Provider family by ID | Server + Realtime/refetch |
| Products/campaigns/notifications | Shared role-aware providers | Server |
| Language/theme | Preference Notifiers | Local preferences |

### Provider Guidance

- `Provider<T>` for repositories and services.
- `FutureProvider<T>` for read-only summaries and details.
- `StreamProvider<T>` for auth and narrowly scoped Realtime signals.
- `NotifierProvider` for local synchronous preferences.
- `AsyncNotifierProvider` for withdrawal submission and mutation state.
- Provider families for product, campaign, and withdrawal IDs.

Keep auth, profile, locale, theme, and shell state alive. Auto-dispose detail/search providers when safe.

## 12. Domain Models

Recommended typed models:

```text
B2BProfile
  id, role, isActive, phone, ownerName, shopName, area, address

WholesalerHomeSummary
  availableBalance, pendingWithdrawal, lifetimeEarned,
  totalQr, scannedQr, remainingQr, latestReward, activeWithdrawal

QrProgressGroup
  groupId, productId, productName, imageUrl, shortReference,
  totalQr, scannedQr, remainingQr, earnedPkr, status

WalletSummary
  available, pending, lifetimeEarned

WalletTransaction
  id, type, amount, occurredAt, status, withdrawalId

Withdrawal
  id, amount, method, maskedDestination, status,
  submittedAt, paidAt, reference, proofReference, timeline
```

`WalletTransactionType` must not include invoice redemption.

## 13. Repository Contracts

```text
AuthRepository
  sendOtp(phone)
  verifyOtp(phone, token)
  watchAuthState()
  signOut()

ProfileRepository
  getCurrentB2BProfile()

WholesalerHomeRepository
  getSummary()

QrProgressRepository
  getProgressGroups()

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

There is no raw QR, inventory, redemption, or profile-edit repository in this module.

## 14. QR Progress Data Boundary

The app should read an authorized server projection that returns aggregate rows already scoped to the current wholesaler.

Required projection fields:

- Group/product identity.
- Optional short invoice reference.
- Total QR count.
- Scanned QR count.
- Remaining QR count.
- Confirmed wholesaler reward total.
- Aggregate status.

The client may calculate the visual progress fraction from validated counts:

```text
progress = totalQr == 0 ? 0 : scannedQr / totalQr
```

Financial totals remain server-authored. The projection must not include signatures, raw payloads, mechanic identity, prices, invoice totals, stock, profit, or admin-only fields.

## 15. Wallet and Withdrawal Integrity

### Wallet

- Use an append-only ledger.
- Do not store or update a client-authored balance.
- Server returns authoritative Available, Pending, and Lifetime projections.
- Reward credits reference trusted scan events.
- No invoice-redemption event exists.

### Withdrawal Submission

```text
Withdrawal Notifier validates input
-> Generate idempotency key
-> Trusted server operation validates:
   active wholesaler role
   minimum amount
   amount <= available
   destination by method
   no duplicate idempotency key
-> Create Pending withdrawal
-> Lock amount from Available into Pending
-> Return authoritative withdrawal
-> Invalidate Home, Wallet, Withdrawals
```

Do not clear form input on recoverable failure.

### Withdrawal Confirmation

- `confirmReceived` is valid only from Paid.
- `reportNotReceived` is valid only from Paid.
- Closed states reject repeat actions.
- Admin re-pay updates the existing withdrawal.
- Refund returns locked amount through a new ledger event.
- Realtime is an update signal; refetch the authoritative record after an event.

## 16. Supabase Access Boundaries

| Resource | Wholesaler access |
|---|---|
| Profile | Read own allowed fields only |
| QR progress projection | Read own aggregates only |
| Wallet summary/transactions | Read own only |
| Withdrawals | Read own; submit/confirm/dispute through trusted operations |
| Products | Read B2B-safe fields only |
| Campaigns | Read active wholesaler-targeted campaigns |
| Notifications | Read/update own notifications only |
| Withdrawal proof | Read own proof through private signed access |

Requirements:

- RLS on every exposed table/view.
- Role authorization from server-controlled profile/app metadata.
- Ownership checks based on `auth.uid()`.
- No service-role key in the app.
- Do not expose full product rows or full settings rows.
- Private proof paths and expiring signed URLs.

## 17. Local Persistence and Offline Behavior

Persist:

- Supabase session through the SDK.
- Language and theme.
- Optional last successful read-only summaries for continuity.

Do not persist as authoritative:

- Wallet balance.
- Withdrawal status.
- QR counts or reward totals.
- Payment proof URLs.

No wholesaler writes are queued offline. If offline during withdrawal submission, preserve the form in memory and show the approved reconnect message.

## 18. Error Model

Use typed failures:

```text
AppFailure
|- OfflineFailure
|- AuthenticationFailure
|- AuthorizationFailure
|- InactiveAccountFailure
|- ValidationFailure
|- InsufficientBalanceFailure
|- DuplicateSubmissionFailure
|- NotFoundFailure
|- StorageFailure
|- ServerFailure
`- UnknownFailure
```

Widgets render localized, plain-language messages and never inspect raw Supabase exceptions.

## 19. Localization and Accessibility

- All text comes from localization resources.
- English and Urdu are required; Urdu is RTL-ready.
- Use locale-aware currency, dates, and phone display.
- Status never depends on color alone.
- All interactive elements expose semantic labels.
- Preserve logical reading order at 200 percent text scaling.
- QR Progress cards must not expose button semantics because they are non-interactive.
- Use 48 dp minimum touch targets.

## 20. Performance

- Fetch Home summary as one compact projection where practical.
- Paginate Wallet, Withdrawals, Products, Campaigns, and Notifications.
- Debounce product search.
- Request sized product/campaign images.
- Avoid Realtime channels for QR Progress lists; refresh on notification, app resume, or pull-to-refresh.
- Subscribe only to the current user’s withdrawal/notification events.
- Cancel subscriptions on logout/dispose.

## 21. Testing Strategy

### Unit Tests

- Phone normalization.
- Role-routing matrix.
- QR progress fraction and zero-total behavior.
- Withdrawal amount and destination validation.
- Status mapping.
- Failure mapping.
- Duplicate-submit prevention.

### Repository/Security Tests

- Wholesaler reads only own QR aggregates, wallet, withdrawals, and notifications.
- Raw QR and mechanic identity are not exposed.
- Customer/staff cannot enter B2B routes.
- Unknown profile cannot create a wholesaler role.
- Invoice redemption operation does not exist.
- Withdrawal transitions and idempotency are enforced.

### Widget Tests

Every network-backed screen:

- Loading.
- Content.
- Empty.
- Error.
- Offline.
- Retry.

Critical widget tests:

- QR cards have no tap/chevron/detail semantics.
- Wallet contains no redemption entry.
- Profile contains no edit/tax fields.
- Wholesaler navigation contains no scanner.

### Integration Journeys

1. Admin-provisioned wholesaler OTP login to Home.
2. Inactive wholesaler blocked.
3. Customer/staff phone blocked from B2B.
4. Reward notification updates Wallet and QR Progress.
5. EasyPaisa withdrawal submission to Pending.
6. Payment Sent to Received confirmation.
7. Not Received to dispute/contact flow.
8. Refunded withdrawal updates Wallet.
9. Products and campaigns remain price/progress-free.
10. Logout clears protected state.

## 22. Implementation Sequence

### Phase 1 — Shared B2B Foundation

1. Flutter project, pinned versions, environments.
2. Material 3 SGX light/dark theme.
3. Riverpod ProviderScope.
4. Localization and RTL scaffolding.
5. Shared router, OTP auth, profile role guards.
6. Shared loading, empty, error, and offline components.

### Phase 2 — Wholesaler Mock Experience

1. Domain models and repository contracts.
2. Mock profile, Home, QR Progress, Wallet, and withdrawal data.
3. Home and main shell.
4. QR Progress single screen.
5. Wallet and withdrawal lifecycle screens.
6. Shared Products, Campaigns, Notifications, Profile, Preferences.
7. Full deterministic prototype flow.

### Phase 3 — Supabase Integration

1. Phone OTP and role resolution.
2. Wholesaler-safe profile read.
3. Aggregate QR Progress projection and RLS.
4. Wallet summary/ledger.
5. Trusted withdrawal operations and private proof access.
6. Products, campaigns, and notifications.
7. Scoped Realtime signals.

### Phase 4 — Release Hardening

1. Cross-role access tests.
2. Slow/offline network tests.
3. Withdrawal idempotency and double-action tests.
4. Urdu/RTL, dark theme, and 200 percent text tests.
5. Low-literacy usability test of QR Progress and withdrawal confirmation.
6. Production signing and environment review.

## 23. Definition of Done

- One shared B2B app routes active wholesalers into the wholesaler shell.
- Wholesaler signup and role selection do not exist.
- Customer/staff profiles cannot access B2B role routes.
- The wholesaler shell has exactly five approved destinations.
- QR Progress is aggregate-only and has no detail route.
- Wallet and withdrawals contain no invoice redemption.
- Products are price-free and browse-only.
- Profile is read-only and contains no tax fields.
- All sensitive writes are trusted and server-authoritative.
- All screens implement loading, empty, error, offline, and retry behavior.
- English, Urdu/RTL, light, dark, accessibility, and large text are verified.
