# SGX Partners — Shared B2B App Architecture

**Application:** SGX Partners  
**Platform:** Flutter, Android first, iOS-compatible  
**Design system:** Material Design 3  
**State management:** Riverpod 3  
**Backend target:** Shared Supabase project  
**Document purpose:** Prompt and architecture baseline for creating a new empty Flutter project  
**Status:** Shared foundation spec for mechanic and wholesaler modules  
**Last updated:** 22 July 2026  

---

## 1. Purpose

SGX Partners is one Flutter mobile application with two role-aware experiences:

- Mechanic
- Wholesaler

Do not create two Flutter apps. Do not duplicate authentication, theme, products, campaigns, notifications, wallet UI, withdrawal UI, or profile basics. Build one shared app foundation, then add role modules under separate folders.

This document is the starting prompt for implementing the empty Flutter project. It combines the shared decisions from:

- `docs/mobile-app-design/b2b/mechanic/prd.md`
- `docs/mobile-app-design/b2b/mechanic/architecture.md`
- `docs/mobile-app-design/b2b/mechanic/screen-specs.md`
- `docs/mobile-app-design/b2b/wholesaler/prd.md`
- `docs/mobile-app-design/b2b/wholesaler/architecture.md`
- `docs/mobile-app-design/b2b/wholesaler/screen-specs.md`
- `docs/mobile-app-design/b2b/mechanic/design-token.json`
- `docs/mobile-app-design/b2b/wholesaler/design-token.json`

---

## 2. Source of Truth and Precedence

When documents conflict, use this order:

1. This shared architecture file for project structure, shared dependencies, and shared app foundation.
2. Role PRDs, especially Locked Owner Decisions.
3. Role architecture files.
4. Role screen specs and screen flows.
5. Role design tokens.
6. Older shared requirements/admin docs as background only.

The latest B2B mobile docs override older references to:

- Separate B2B apps.
- Role selection.
- Mechanic-to-wholesaler assignment during onboarding.
- Mechanic offline scan queue.
- Cached scan rewards.
- Invoice redemption from the mobile app.
- Wholesaler scanner.
- Wholesaler invoice inventory.
- QR detail screens for wholesalers.

---

## 3. Locked Shared Decisions

| Area | Decision |
|---|---|
| App model | One Flutter app named `SGX Partners`. |
| Roles | Mechanic and wholesaler are role modules inside the same app. |
| Authentication | Phone number + SMS OTP. |
| Role routing | Trusted protected profile decides mechanic or wholesaler experience after OTP. |
| Role selector | Never shown. |
| Unknown verified phone | Goes to mechanic onboarding only. |
| Wholesaler creation | Admin panel only; no mobile wholesaler signup. |
| Mechanic creation | Mobile self-registration allowed after phone verification. |
| Design system | Material Design 3 only. |
| Theme | One shared SGX Partners theme for both roles. |
| App icon | Reuse `docs/mobile-app-design/customer/sgx-app-icon.svg` unchanged. |
| Product catalog | Shared B2B-safe, browse-only, price-free. |
| Wallet exit | Withdrawals only. No invoice redemption. |
| Campaigns | Shared role-filtered campaigns. No user-facing progress bar. |
| Offline writes | No offline writes. No queued scans or queued withdrawals. |
| State management | Riverpod 3. |
| Data access | Repository pattern. Widgets never call Supabase directly. |
| Initial implementation | Mock repositories first, then Supabase repositories later. |

---

## 4. New Flutter Project Cleanup

Start from a clean Flutter project.

After creating the project:

1. Remove the generated counter app from `lib/main.dart`.
2. Remove generated demo comments and sample counter logic.
3. Remove the generated `test/widget_test.dart`.
4. Remove the default `flutter_test` dev dependency if no tests will be written in the first implementation pass.
5. Keep `flutter_lints` or an equivalent lint package.
6. Keep the project free of sample/demo names such as `MyHomePage`, `Counter`, and `Increment`.

If tests are added later, reintroduce `flutter_test` and create real SGX Partners tests. Do not keep the default counter test.

---

## 5. Dependencies

Use a small dependency set. Do not add state-management or UI libraries beyond the approved stack unless the owner explicitly approves.

### Required Initial Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.0
  go_router: ^16.0.0
  flutter_svg: ^2.0.0
  intl: ^0.20.0
```

### Add When Needed

```yaml
dependencies:
  supabase_flutter: ^2.0.0
  mobile_scanner: ^6.0.0
  image_picker: ^1.0.0
  connectivity_plus: ^6.0.0
  shared_preferences: ^2.0.0
  flutter_secure_storage: ^9.0.0
```

Usage:

- `supabase_flutter`: live auth, profile, wallet, withdrawals, campaigns, products, notifications.
- `mobile_scanner`: mechanic online QR scanning only.
- `image_picker`: future withdrawal/payment proof flows if image upload is required.
- `connectivity_plus`: online/offline state checks, especially scanner blocking.
- `shared_preferences`: theme/language preference.
- `flutter_secure_storage`: sensitive local session helpers only if needed.

### Dev Dependencies

```yaml
dev_dependencies:
  flutter_lints: ^5.0.0
```

Do not keep `flutter_test` unless real tests are being added in the current pass.

---

## 6. Asset Directory

Use one asset directory for the shared app.

```text
assets/
  branding/
    sgx-app-icon.svg
  images/
    products/
  images/
    campaigns/
  mock/
```

Copy the approved icon from:

```text
docs/mobile-app-design/customer/sgx-app-icon.svg
```

to:

```text
assets/branding/sgx-app-icon.svg
```

Asset rules:

- Preserve the SVG unchanged.
- Do not recolor, crop, stretch, redraw, or add mechanic/wholesaler badges.
- Use the same icon for both roles.
- Do not use the brand icon inside bottom navigation.
- Do not use the brand icon as the mechanic Scan icon.

Register assets in `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/branding/
    - assets/images/products/
    - assets/images/campaigns/
    - assets/mock/
```

---

## 7. Theme and Design System

Both roles use the same Material 3 theme. Do not create separate mechanic and wholesaler themes.

Use:

- `useMaterial3: true`
- Shared SGX primary color from the design tokens.
- Shared light and dark schemes.
- Shared shape, spacing, typography, status colors, and motion behavior.

Core color source:

```text
Primary: oklch(0.3582 0.1289 265.52)
Background: oklch(0.9789 0.0042 247.86)
Surface: oklch(1 0 0)
Text: oklch(0.2077 0.0398 265.75)
Muted text: oklch(0.5510 0.0234 264.37)
Border/outline: oklch(0.9219 0.0098 247.88)
Success: oklch(0.6235 0.1737 145.94)
Warning: oklch(0.8388 0.1614 84.42)
Error: oklch(0.5266 0.2049 27.43)
```

If Flutter cannot consume OKLCH directly, convert tokens once in the theme layer and keep all app screens using semantic theme roles. Do not scatter raw colors across widgets.

Status color meaning:

- Success: reward credited, delivered, confirmed, received, refunded.
- Warning: pending, processing, awaiting confirmation, network retry.
- Error: invalid, already scanned, disputed, failed, rejected.
- Primary: active state, payment sent, selected navigation.

---

## 8. Recommended Project Structure

Use feature-first structure with shared foundations and role modules.

```text
lib/
  main.dart
  bootstrap.dart

  app/
    app.dart
    router/
      app_router.dart
      route_guards.dart
      route_names.dart
      app_routes.dart
    theme/
      app_theme.dart
      app_colors.dart
      app_spacing.dart
      app_typography.dart
      theme_controller.dart
    localization/
      app_localizations.dart
      locale_controller.dart
    shell/
      sgx_partners_shell.dart
      mechanic_shell.dart
      wholesaler_shell.dart

  core/
    auth/
      auth_controller.dart
      auth_repository.dart
      mock_auth_repository.dart
      auth_state.dart
    config/
      app_environment.dart
      environment_provider.dart
    errors/
      app_failure.dart
      failure_mapper.dart
    network/
      connectivity_controller.dart
      network_status.dart
    storage/
      local_preferences.dart
      secure_session_store.dart
    supabase/
      supabase_client_provider.dart
      supabase_initializer.dart
    utils/
      money_formatter.dart
      date_formatter.dart
      phone_formatter.dart

  shared/
    models/
      app_role.dart
      profile_summary.dart
      money_amount.dart
      status_presentation.dart
    widgets/
      sgx_app_bar.dart
      sgx_logo.dart
      async_state_view.dart
      empty_state.dart
      error_state.dart
      offline_state.dart
      status_chip.dart
      money_text.dart
      section_header.dart
      primary_action_card.dart
    auth/
      presentation/
        splash_screen.dart
        phone_login_screen.dart
        otp_verification_screen.dart
        account_unavailable_screen.dart
    products/
      domain/
      data/
      presentation/
        products_screen.dart
        product_detail_screen.dart
        widgets/
          b2b_product_card.dart
    campaigns/
      domain/
      data/
      presentation/
        campaigns_screen.dart
        campaign_detail_screen.dart
        widgets/
          campaign_card.dart
    notifications/
      domain/
      data/
      presentation/
        notifications_screen.dart
        widgets/
          notification_row.dart
    wallet/
      domain/
        wallet_summary.dart
        wallet_transaction.dart
      presentation/
        widgets/
          wallet_balance_card.dart
          transaction_row.dart
    withdrawals/
      domain/
        withdrawal.dart
        withdrawal_method.dart
        withdrawal_status.dart
      data/
      presentation/
        widgets/
          withdrawal_card.dart
          payment_method_card.dart
          withdrawal_confirmation_sheet.dart
          withdrawal_status_panel.dart
    profile/
      domain/
      data/
      presentation/
        widgets/
          profile_identity_card.dart

  roles/
    mechanic/
      onboarding/
        domain/
        data/
        presentation/
          complete_mechanic_profile_screen.dart
      home/
        domain/
        data/
        presentation/
          mechanic_home_screen.dart
      scanner/
        domain/
        data/
        presentation/
          qr_scanner_screen.dart
          widgets/
            scan_result_surface.dart
            scanner_permission_view.dart
      scan_history/
        domain/
        data/
        presentation/
          scan_history_screen.dart
      wallet/
        presentation/
          mechanic_wallet_screen.dart
      withdrawals/
        presentation/
          mechanic_withdraw_money_screen.dart
          mechanic_withdrawals_screen.dart
          mechanic_withdrawal_detail_screen.dart
      profile/
        presentation/
          mechanic_profile_screen.dart
          edit_mechanic_profile_screen.dart

    wholesaler/
      home/
        domain/
        data/
        presentation/
          wholesaler_home_screen.dart
      qr_progress/
        domain/
        data/
        presentation/
          qr_progress_screen.dart
          widgets/
            qr_progress_card.dart
      wallet/
        presentation/
          wholesaler_wallet_screen.dart
      withdrawals/
        presentation/
          wholesaler_withdraw_money_screen.dart
          wholesaler_withdrawals_screen.dart
          wholesaler_withdrawal_detail_screen.dart
      profile/
        presentation/
          wholesaler_profile_screen.dart
```

Do not create:

```text
roles/mechanic/offline_queue/
roles/mechanic/sync_worker/
roles/mechanic/redemptions/
roles/wholesaler/scanner/
roles/wholesaler/qr_detail/
roles/wholesaler/inventory/
roles/wholesaler/redemptions/
shared/role_selection/
```

---

## 9. Application Startup Flow

```text
main.dart
-> bootstrap.dart
-> initialize environment
-> initialize local preferences
-> initialize ProviderScope
-> run SGXPartnersApp
-> restore auth session
-> load protected profile
-> route by profile role and active status
```

Routing outcomes:

```text
No session
-> Splash
-> Phone Login

Verified phone with active mechanic profile
-> Mechanic shell

Verified phone with incomplete mechanic profile
-> Complete Mechanic Profile

Verified phone with active wholesaler profile
-> Wholesaler shell

Verified phone with inactive mechanic/wholesaler profile
-> Account Unavailable

Verified phone with customer/staff profile
-> Account Unavailable

Verified phone with no profile
-> Complete Mechanic Profile
```

The app must not reveal profile role before OTP verification.

---

## 10. Shared Routing

Use declarative routing.

Shared routes:

```text
/splash
/auth/phone
/auth/otp
/auth/account-unavailable
/products
/products/:productId
/campaigns
/campaigns/:campaignId
/notifications
/profile/preferences
```

Mechanic routes:

```text
/mechanic/onboarding
/mechanic/home
/mechanic/scan
/mechanic/scans
/mechanic/wallet
/mechanic/withdrawals
/mechanic/withdrawals/new
/mechanic/withdrawals/:withdrawalId
/mechanic/profile
/mechanic/profile/edit
```

Wholesaler routes:

```text
/wholesaler/home
/wholesaler/qr-progress
/wholesaler/wallet
/wholesaler/withdrawals
/wholesaler/withdrawals/new
/wholesaler/withdrawals/:withdrawalId
/wholesaler/profile
```

Forbidden routes:

```text
/select-role
/signup/wholesaler
/mechanic/select-wholesaler
/mechanic/offline-scans
/mechanic/redemptions
/wholesaler/scan
/wholesaler/qr-progress/:id
/wholesaler/inventory
/wholesaler/redemptions
```

---

## 11. Navigation Shells

### Mechanic Shell

Use the approved Material 3 `BottomAppBar` with four labeled destinations and one raised center scan action:

```text
Home | Products | [Scan] | Wallet | Profile
```

Rules:

- Scan is a raised center action.
- Scan opens `/mechanic/scan`.
- Scan is not a persistent selected tab.
- Scan action minimum visual/touch size is 64 dp.
- Respect bottom safe area.

### Wholesaler Shell

Use Material 3 `NavigationBar` with five destinations:

```text
Home | QR Progress | Wallet | Products | Profile
```

Rules:

- Always show labels.
- QR Progress cards are not tappable.
- Wallet can show a small indicator when payment awaits confirmation.
- No scanner action anywhere.

---

## 12. Shared Features

### Auth

Shared screens:

- Splash
- Phone Login
- OTP Verification
- Account Unavailable

Shared validation copy:

- `Phone number is required.`
- `Enter a valid phone number.`
- `Could not send OTP. Please try again.`
- `OTP is required.`
- `Invalid OTP. Please try again.`
- `Too many attempts. Please wait and try again.`

Phone format:

```text
03XXXXXXXXX
```

### Products

Shared B2B catalog for both roles.

Show:

- Product image.
- Product name.
- Brand.
- Category.
- Optional product code.
- Short description on detail.

Never show:

- Prices.
- Stock quantity.
- Cart.
- Ordering.
- Buying price.
- Mechanic price.
- Wholesaler price.
- Profit.
- Supplier information.

### Campaigns

Shared role-aware campaigns.

Show active campaigns for the current role only.

Do not show:

- Progress bar.
- Automatic prize promise.
- Admin-only progress metrics.

### Notifications

Shared notification list with role-safe deep links.

Mechanic notification targets:

- Wallet
- Scan History
- Withdrawal Detail
- Campaign Detail

Wholesaler notification targets:

- Wallet
- Withdrawal Detail
- Campaign Detail

### Wallet and Withdrawals

Use shared domain concepts and reusable widgets.

Both roles show:

- Available Balance.
- Pending Withdrawal.
- Lifetime Earned.
- Transaction history.
- Withdraw Money action when eligible.
- Withdrawal status lifecycle.

Allowed withdrawal statuses:

- Pending.
- Payment Sent.
- Confirmed.
- Disputed.
- Auto-confirmed.
- Refunded.

Allowed payment methods:

- EasyPaisa.
- JazzCash.
- Bank transfer.
- Cash collection from SGX.

Final supported launch methods are owner input and may be reduced before release.

No invoice redemption exists.

---

## 13. Role Modules

### Mechanic Module

Mechanic-only responsibilities:

- Complete Mechanic Profile for unknown verified phones.
- Mechanic Home.
- Online QR Scanner.
- Scan Result states.
- Confirmed Scan History.
- Mechanic Wallet screen.
- Mechanic Withdrawal screens.
- Mechanic Profile and Edit Profile.

Mechanic locked rules:

- No role selector.
- No wholesaler selector.
- No offline queue.
- No pending scan sync.
- No cached reward estimate.
- No invoice redemption.
- No tax fields.
- Phone and role are read-only.
- Server validates and credits scans atomically.

### Wholesaler Module

Wholesaler-only responsibilities:

- Wholesaler Home.
- QR Progress aggregate screen.
- Wholesaler Wallet screen.
- Wholesaler Withdrawal screens.
- Read-only Wholesaler Profile.

Wholesaler locked rules:

- No signup.
- No role selector.
- No scanner.
- No QR detail.
- No invoice inventory.
- No invoice redemption.
- No tax fields.
- Business identity is read-only.
- QR Progress means reward QR progress, not physical stock.

---

## 14. Domain Model Baseline

Create typed models before wiring UI to data.

Shared models:

```text
AppRole
ProfileSummary
MoneyAmount
ProductSummary
ProductDetail
CampaignSummary
CampaignDetail
AppNotification
WalletSummary
WalletTransaction
Withdrawal
WithdrawalMethod
WithdrawalStatus
StatusPresentation
```

Mechanic models:

```text
MechanicProfile
MechanicHomeSummary
ScanResult
ScanFailureReason
ScanHistoryItem
MechanicOnboardingDraft
```

Wholesaler models:

```text
WholesalerProfile
WholesalerHomeSummary
QrProgressSummary
QrProgressItem
```

Do not create:

```text
PendingScan
OfflineScan
SyncQueue
MechanicWholesalerAssignment
InvoiceRedemption
WholesalerInventoryItem
QrDetail
```

---

## 15. Repository Pattern

Widgets must never call Supabase directly.

Use repository contracts:

```text
AuthRepository
ProfileRepository
ProductsRepository
CampaignsRepository
NotificationsRepository
WalletRepository
WithdrawalsRepository
MechanicOnboardingRepository
MechanicScanRepository
MechanicScanHistoryRepository
WholesalerQrProgressRepository
```

Initial implementation:

- Create mock repositories first.
- Use deterministic mock data.
- Keep mock and live repositories behind the same interface.

Later implementation:

- Add Supabase repositories.
- Keep server-side security authoritative.
- Do not move role checks, wallet calculations, scan validation, or withdrawal state transitions into widgets.

---

## 16. Async State Rules

Every network-backed screen must intentionally handle:

- Loading.
- Content.
- Empty.
- Error.
- Offline.
- Retry.

Use shared components:

```text
AsyncStateView
EmptyState
ErrorState
OfflineState
```

Mechanic scanner has a more specific offline message:

```text
Internet is required to scan a QR. Please reconnect and try again.
```

No write action is queued offline.

---

## 17. Security and Data Boundaries

The mobile app is not the source of truth.

Server/Supabase must enforce:

- Profile role and active status.
- RLS for role-safe data.
- Mechanic scan validation.
- QR duplicate prevention.
- Wallet credit/debit rules.
- Withdrawal state transitions.
- Private storage access.

The app must never contain:

- Service-role key.
- QR HMAC secret.
- Admin-only fields.
- Raw QR signature display.
- Buying price, profit, or role-forbidden prices.

Mechanic scan operation:

```text
Scanner detects QR
-> app sends payload to trusted endpoint
-> server validates active mechanic, QR signature, QR existence, invoice dispatched, unused status, expiry, and reward snapshot
-> server credits mechanic and invoice wholesaler in one atomic operation
-> app displays authoritative result
```

No reward is shown as confirmed before the server response.

---

## 18. Localization and Accessibility

Support from the beginning:

- English.
- Urdu.
- RTL-ready layout.
- Light and dark theme.
- Text scale up to 200 percent.
- Screen reader labels for important actions.
- Minimum 48 dp touch targets.
- Mechanic Scan action minimum 64 dp.

Low-literacy rules:

- Use short labels.
- Pair important icons with text.
- Avoid hidden gestures.
- Avoid technical terms like payload, signature, conversion rate, RLS, ledger debit, sync queue.
- Keep one primary action per task when possible.

---

## 19. Implementation Phases

### Phase 1 — Shared Foundation

1. Clean Flutter scaffold.
2. Add dependencies.
3. Add asset directory and SGX icon.
4. Add Material 3 theme.
5. Add Riverpod `ProviderScope`.
6. Add router.
7. Add shared auth skeleton.
8. Add role resolver skeleton.
9. Add shared async state components.
10. Add shared shell components.

### Phase 2 — Shared Mock Features

1. Products list/detail with price-free mock data.
2. Campaigns list/detail with role filtering.
3. Notifications list with typed mock deep links.
4. Shared wallet summary widgets.
5. Shared withdrawal widgets and status components.
6. Shared profile identity widgets.

### Phase 3 — Mechanic Mock Module

1. Mechanic onboarding.
2. Mechanic shell with center Scan action.
3. Mechanic Home.
4. Online scanner UI with mocked deterministic results.
5. Scan Result states.
6. Scan History.
7. Mechanic Wallet and Withdrawals.
8. Mechanic Profile and Edit Profile.

### Phase 4 — Wholesaler Mock Module

1. Wholesaler shell.
2. Wholesaler Home.
3. QR Progress aggregate screen.
4. Wholesaler Wallet and Withdrawals.
5. Read-only Wholesaler Profile.

### Phase 5 — UI Integration From Generated Designs

1. Paste generated UI into a temporary review area.
2. Identify duplicated widgets.
3. Move shared UI into `shared/widgets` or shared feature folders.
4. Move mechanic-only UI into `roles/mechanic`.
5. Move wholesaler-only UI into `roles/wholesaler`.
6. Replace raw colors with shared theme tokens.
7. Replace duplicated navigation with shared shells.
8. Remove any forbidden screens or concepts from generated UI.

### Phase 6 — Supabase Integration

1. Phone OTP auth.
2. Protected profile and role resolver.
3. Mechanic onboarding creation.
4. Products, campaigns, notifications.
5. Mechanic trusted scan endpoint.
6. Wallet summaries and transaction history.
7. Withdrawal operations.
8. Wholesaler QR Progress aggregate.
9. Scoped realtime refresh signals.

### Phase 7 — Hardening

1. Cross-role route tests.
2. Scanner permission tests.
3. Slow network and offline handling.
4. Duplicate scan prevention behavior.
5. Withdrawal double-submit behavior.
6. Large text, dark theme, Urdu/RTL review.
7. Low-literacy usability review.

---

## 20. Generated UI Integration Rules

When generated UI is provided:

1. Do not paste everything directly into `lib/`.
2. First classify every screen as shared, mechanic-only, or wholesaler-only.
3. Extract common cards, buttons, chips, app bars, list rows, product cards, campaign cards, wallet cards, and withdrawal components.
4. Keep only one version of theme, typography, spacing, and status colors.
5. Keep only one phone login and OTP flow.
6. Keep only one products feature.
7. Keep only one campaigns feature.
8. Keep only one notifications feature.
9. Keep shared withdrawal widgets, but allow role-specific screen composition.
10. Delete any generated role selector, offline scan queue, invoice redemption, wholesaler scanner, QR detail, or invoice inventory UI.

---

## 21. Definition of Done for Shared Foundation

- App launches as `SGX Partners`.
- Generated counter app is removed.
- Default counter test is removed.
- Shared SGX icon is registered and renders.
- Material 3 light/dark theme is centralized.
- Riverpod is configured.
- Router is configured.
- Auth skeleton exists.
- Role resolver skeleton exists.
- Mechanic and wholesaler route branches exist.
- Shared products/campaigns/notifications placeholders exist.
- Shared wallet/withdrawal widgets exist.
- Mechanic shell and wholesaler shell are separate but use shared app foundations.
- No duplicated theme systems.
- No role selector.
- No forbidden B2B screens.
- App runs with mock data before Supabase integration.

---

## 22. Remaining Owner Inputs

Before final launch, confirm:

1. Final supported withdrawal methods.
2. Final SGX WhatsApp/help number.
3. Final Urdu translations.
4. Whether mechanic Workshop/Shop Name remains optional.
5. Whether mechanic Scan History should show wholesaler/shop name.
6. Whether wholesaler QR Progress cards show a short invoice/reference label.
7. Cash collection instructions and whether cash collection needs a receipt image.

