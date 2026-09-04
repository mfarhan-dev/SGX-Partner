# Handoff: SGX Partners — Mechanic Module

## Overview

SGX Partners is a single shared B2B Flutter application with two role-aware experiences: **Mechanic** and **Wholesaler**. This handoff covers the **Mechanic module only** — a 20-screen experience that lets independent motorcycle mechanics self-register, scan SGX product QRs online, earn rupee rewards, view scan history, and withdraw money via EasyPaisa, JazzCash, Bank Transfer, or Cash from SGX.

Primary audience: **independent mechanics in Pakistan with limited literacy and low smartphone experience**. Every design decision assumes: big touch targets, one primary action per screen, icons paired with text, plain-language copy, and large reward/balance numerals.

**Target platform:** Flutter (Android first, iOS-compatible), Material Design 3, Riverpod 3, Supabase backend.

## About the Design Files

The files in this bundle are **design references created in HTML/React** — high-fidelity prototypes that show the intended visual language, layout, spacing, typography, iconography, and interaction shape of every screen. **They are not production code and must not be shipped directly.**

The task is to **recreate these designs in the SGX Partners Flutter codebase** using Material 3 widgets, the established Riverpod state architecture, the shared theme, and the repository/domain contracts documented in `architecture.md`. If the Flutter project does not yet exist, follow the layer/folder structure specified in `docs/architecture.md § 8`.

## Fidelity

**High-fidelity (hifi).** These mockups are pixel-accurate:

- Exact colors from `design-token.json` (OKLCH values, both light and dark schemes).
- Correct Material 3 shape, spacing, elevation, and typography scales.
- Real Material Symbols Rounded icons in their intended fill/weight.
- Realistic content (Pakistani names, PKR amounts, EasyPaisa/JazzCash/Bank Transfer methods, real SGX product families like Shell Advance, NGK, K&N, DID, CEAT, Osaka).
- 390 × 844 dp phone viewport, safe-area aware, with correct Android status bar, gesture home indicator, and 80 dp bottom app bar with the raised 72 dp center Scan FAB.

The developer should **recreate the UI pixel-perfectly** in Flutter, treating the CSS variables in `tokens.css` and the token definitions in `docs/design-token.json` as the single source of truth.

## Screens / Views

There are **20 navigable screens** plus a **6-variant scan-result state family** and a bilingual (Urdu/RTL) sample of the Home screen. Screens are grouped by flow. Every screen ID (MEC-XX) matches `docs/screen-specs.md`.

### Group 1 — Authentication & Onboarding

#### MEC-00 · Splash (`/splash`)
- **Purpose:** boot the app, restore Supabase session, resolve protected profile, route to the correct destination.
- **Layout:** full-bleed primary-navy background. Vertically centered SGX icon (112 dp, white rounded square) with `SGX Partners` (28 px / 700) below it and tagline `Scan · Earn · Withdraw`. Circular loading indicator 40 dp from the bottom.
- **Status bar / home indicator:** white tint on primary background.

#### MEC-01 · Phone Login (`/auth/phone`)
- **Purpose:** collect a Pakistani mobile number and request an SMS OTP.
- **Layout (top → bottom):**
  - Top-right language chip (`English` with `language` icon, 36 dp height, 18 px radius, outline variant border).
  - 72 dp SGX icon centered.
  - Title `Login to SGX Partners` (26 px / 700).
  - Supporting `Enter your mobile number to continue.` (15 px / on-surface-variant).
  - Outlined text field: label `Mobile Number`, prefix `+92`, leading icon `smartphone`, value `0300-1234567`.
  - Filled pill button `Send OTP` (48 dp, full width, primary bg, leading `sms` icon).
  - Helper text under button: `An SMS with a 6-digit code will be sent. Standard SMS charges may apply.`
  - Bottom-center trust line `Secure login by SGX` with 16 px `shield` icon.
- **Validation copy** (exact strings): `Phone number is required.`, `Enter a valid phone number.`, `Could not send OTP. Please try again.`

#### MEC-02 · OTP Verification (`/auth/otp`)
- **Layout:** back arrow app bar (no title). 48 dp SGX icon, `Verify your number` (24/700), masked phone `+92 300-****567`. Six 46 × 56 dp square inputs with 8 px gap and 8 px radius; empty cells use outline-variant border, focused/filled use 2 px primary border. Blinking caret in the focused cell.
- **Below inputs:** `Resend code in 00:24` (24 s countdown, `Resend code` link when 0). Filled `Verify` button (leading `check`). Text button `Change number` (leading `edit`).
- **Validation copy:** `OTP is required.`, `Invalid OTP. Please try again.`, `Too many attempts. Please wait and try again.`

#### MEC-03 · Account Unavailable (`/auth/account-unavailable`)
- **Two variants** driven by profile resolution:
  - **Inactive B2B:** 112 dp circle in error-container, `person_off` icon in error color (56 px, filled), title `Account inactive`, message `Your SGX Partners account is currently inactive. Please contact SGX to reactivate it.`, primary filled `Contact SGX` (leading `support_agent`), secondary outlined `Use another number` (leading `refresh`).
  - **Customer / staff blocked:** same skeleton but icon `lock`, title `B2B access unavailable`, message `This account cannot access the B2B app.`, single primary `Use another number`.
- Never expose raw role enum values or Supabase errors.

#### MEC-04 · Complete Mechanic Profile (`/mechanic/onboarding`)
- **Purpose:** minimal onboarding after a verified phone with no existing profile. Backend assigns `role = mechanic` server-side.
- **Layout:** back-arrow app bar `Complete your profile`. 48 dp SGX icon centered with helper `Tell us a little about yourself so we can send your rewards to the right place.`
- **Verified phone card:** success-container background, `verified` icon (success), label `Verified phone`, value `+92 300-1234567` (700), trailing `lock` icon.
- **Fields (in order):**
  - `Full Name *` — required, leading `person`.
  - `Workshop / Shop Name (optional)` — leading `storefront`.
  - `Area / City *` — 56 dp selector row with leading `location_on`, trailing `expand_more`. Opens a bottom sheet of Pakistani cities.
- **Info banner:** surface-container background, primary `info` icon, copy `You do not need to choose a shop or wholesaler. Rewards come from the SGX QR you scan.`
- **Primary CTA:** filled `Continue` (leading `arrow_forward`).
- **Rules:** NO role selector, NO wholesaler selector, NO GST/NTN/CNIC/tax field.

### Group 2 — Home

#### MEC-05 · Home (`/mechanic/home`) — main destination
- **Top app bar:** leading 32 dp SGX icon + title `SGX Partners`. Trailing notifications icon with red badge showing unread count (e.g. `3`).
- **Greeting:** `Assalam-o-Alaikum,` (14 / on-surface-variant), `Muhammad Farhan 👋` (22 / 700).
- **Wallet Hero card** (16 px padding, 20 px radius, primary → dark-primary linear gradient at 135°, white text, e3 shadow):
  - Header row: filled `account_balance_wallet` icon + label `Available Balance`.
  - Amount: `Rs. 4,285` at 40 px / 800 / tabular-nums / -1 letter-spacing.
  - Two-column divider row: `PENDING · Rs. 1,500` and `LIFETIME · Rs. 28,540` (uppercase 11 px labels, 15 px / 700 values).
  - Full-width white pill button `Withdraw Money` (44 dp, `payments` icon, primary text).
- **Big Scan CTA card** (16 px radius, surface-container bg, 2 px dashed primary border at 20% opacity): 64 dp round primary FAB with filled `qr_code_scanner`, title `Scan SGX QR` (17/700), subtitle `Scan a product QR to earn rupees.`, trailing `arrow_forward`.
- **Latest scan row:** section header `Latest scan` with `History` action. Card shows product thumbnail, name, `Today · 10:24 AM`, `+ Rs. 15` (success color, 17/700), `Confirmed` status chip.
- **Withdrawal in progress card:** warning-container bg, filled `schedule` icon in warm brown, title `Withdrawal in progress`, subtitle `Rs. 1,500 · JazzCash · Submitted today`, trailing chevron.
- **Active campaign card:** hero image (16:9), footer with title + date window.
- **Quick actions grid (2 × 2):** Scan History (violet), Products (sky), Wallet (primary navy), Campaigns (green) — each with 36 dp colored square icon, label.
- **Bottom bar** (see Global Components).

### Group 3 — QR Scanner & Result States

#### MEC-06 · QR Scanner (`/mechanic/scan`) — camera
- **Chrome:** transparent status bar with white tint. Top row: 44 dp round semi-transparent `close` (left), centered `Scan SGX QR` label (15/600 white), 44 dp round `flashlight_on` (right).
- **Camera preview:** radial dark gradient placeholder (real Flutter uses `mobile_scanner` or `qr_code_scanner`).
- **Scan frame:** 68 % of viewport width, square, 20 px radius, four white L-shaped corner brackets (36 × 36 px, 4 px stroke). The frame is a cutout in a `rgba(0,0,0,0.55)` overlay. A gradient horizontal blue scanning line sits at the vertical center with a `#60A5FA` glow.
- **Bottom instruction:** `Place the QR inside the frame` (20/700 white), sub `Hold steady until the code is detected.`, a green `Connected` pill (`rgba(34,197,94,0.15)` bg, `#22C55E` dot).

#### MEC-06 · Scanner — offline blocked
- Same chrome, but no scan frame. A centered card (`rgba(15,23,42,0.85)` bg, blur, 20 px radius, max-width 320) with:
  - 80 dp red-tinted circle containing `wifi_off` (48 px, `#FCA5A5`).
  - Title `No internet` (20/700).
  - Body: **exact copy** `Internet is required to scan a QR. Please reconnect and try again.`
  - Two 44 dp buttons: outlined `Close` and white filled `Try Again` (with `refresh` icon).
- **Never** open camera, never store or queue the payload.

#### MEC-07 · Scan Result — 6 variants (rendered as a modal sheet)
All variants share the same shell: dimmed camera behind (`rgba(5,7,13,0.85)`), a bottom sheet occupying ~75 % height with 28 px top corners, 40 × 4 px grabber, then a 96 dp round icon in an accent-container, a title, an optional huge amount, a body, an optional product row, and 1–2 pill actions.

| Variant | Icon | Title | Body | Primary | Secondary |
|---|---|---|---|---|---|
| **Success** | `check_circle` in success | `Reward added!` | `Rs. 15 has been added to your wallet.` | `Scan Another` | `Open Wallet` |
| Success only shows the reward hero: `YOU EARNED` (12/600 uppercase muted) and `Rs. 15` (56/800 in success color) + product row with 48 dp thumbnail. | | | | | |
| **Already scanned** | `block` in error | `Already scanned` | `This QR has already been scanned. Each SGX QR can only be used once.` | `Scan Another` | — |
| **QR not active** | `schedule` in warning | `QR not active` | `This QR is not active yet. It will work after the invoice is dispatched.` | `Scan Another` | — |
| **Invalid QR** | `qr_code_2` in error | `Invalid QR` | `This is not a valid SGX QR. Please try another product.` | `Scan Another` | — |
| **Expired QR** | `event_busy` in error | `QR expired` | `This QR has expired and can no longer be used.` | `Scan Another` | — |
| **Network / server failure** | `wifi_tethering_error` in warning | `Could not check QR` | `Check your internet connection and try again.` | `Try Again` (reuses in-memory payload) | `Close` (discards payload; never queued) |

### Group 4 — Wallet & Withdrawals

#### MEC-08 · Scan History (`/mechanic/scans`)
- **Top bar:** back arrow, title `Scan History`, trailing `filter_list`.
- **Summary card (surface-container, 16 px radius, 16 px padding):** two-column split `Total scans · 124` and `Earned from scans · Rs. 28,540` (24/700, success color for money) with a 1 px outline-variant divider between.
- **Date-grouped rows:** each group has an uppercase `TODAY`, `YESTERDAY`, `20 JUL 2026` header (12/700 muted, surface-low bg). Row: 44 dp thumbnail, product name (14/600), time and shop name inline with `storefront` icon (12/muted), right side shows `+Rs. 15` (16/700 success) and a `Confirmed` micro-chip with filled `check_circle`.
- **Restrictions:** no Pending / Offline / Rejected rows, no raw QR IDs, no invoice prices.

#### MEC-09 · Wallet (`/mechanic/wallet`) — main destination
- **Balance hero:** same gradient card as Home but taller — `Rs. 4,285` at 44/800, then a two-tile grid of translucent white pills for Pending / Lifetime. Decorative filled `account_balance_wallet` at 180 px, 8 % opacity in the top-right corner.
- **Action row:** wide filled `Withdraw Money` + 48 dp outlined round `history` shortcut.
- **Helper:** `Minimum withdrawal is Rs. 500.` with 14 px `info` icon.
- **Section header:** `Recent activity` with `View Withdrawals` action.
- **Transaction list** — each row: 40 dp circle icon (success-container for credits, primary-tint for withdrawals), title (14/600), subtitle (12 / muted), right amount (15/700 tabular; success for positives), and an optional small status chip below the amount. Supported types (exact wording):
  - `QR reward added` / `Withdrawal requested` / `Payment sent` / `Withdrawal confirmed` / `Withdrawal disputed` / `Withdrawal auto-confirmed` / `Money returned to wallet`.
- **No invoice-redemption entry** exists.

#### MEC-10 · Withdraw Money (`/mechanic/withdrawals/new`)
- **Balance banner:** primary bg, filled `account_balance_wallet` (28 px), `Available Balance` + `Rs. 4,285` (22/800), right side `Min Rs. 500`.
- **Amount input:** custom pad-style input, 2 px primary border, `Rs.` prefix (24/700 muted), value (32/800 tabular), trailing `backspace` icon.
- **Quick chips row:** `Rs. 500`, `Rs. 1,000`, `Rs. 2,000`, `All` — 32 dp pills; selected uses primary border + secondary bg.
- **Method cards:** four cards (EasyPaisa green, JazzCash red, Bank Transfer sky, Cash from SGX violet), each with 40 dp colored icon square, name (15/700), subtitle (12/muted), right radio (22 dp). Selected card gets a 2 px primary border and secondary bg.
- **Conditional destination fields** (below the selected method):
  - EasyPaisa / JazzCash → `Account Title *`, `Mobile Number *` (with `+92` prefix).
  - Bank → `Bank Name *`, `Account Title *`, `Account Number or IBAN *`.
  - Cash from SGX → no account fields; show collection instructions card.
- **Processing-time notice** below the fields.
- **Primary:** `Continue` (opens confirmation bottom sheet).
- **Confirmation bottom sheet** (extraLarge 28 px radius): review of amount, method, masked destination, processing time; buttons `Cancel` and `Confirm Withdrawal`. Submission is always online, never queued.
- **Validation copy** (exact): `Enter a withdrawal amount.`, `Minimum withdrawal is Rs. [X].`, `Amount cannot exceed your available balance.`, `Select a payment method.`, `Account title is required.`, `Enter a valid mobile number.`, `Bank name is required.`, `Account number or IBAN is required.`, `Could not submit withdrawal. Please try again.`

#### MEC-11 · Withdrawals list (`/mechanic/withdrawals`)
- **Chips row:** `All` (selected), `Open`, `Completed` — 32 dp pills.
- **Cards** (outlined, 12 px radius): top row shows amount (20/800) + status chip; supporting line has method and submitted date; a horizontal divider then a short next-step message with `info` icon.

#### MEC-12 · Withdrawal Detail (`/mechanic/withdrawals/:id`)
- **Hero section (centered):** status chip (`Payment Sent` — primary tone with `send` icon), amount (44/800), method + sent date.
- **Confirmation prompt** (16 px padding, secondary → surface-container gradient bg, outline border, 16 px radius): title `Did you receive this payment?`, sub `Please check your EasyPaisa balance and confirm.`, two side-by-side pills — outlined `Not Received` (opens `Payment not received?` dialog) and filled success `Received` (opens `Confirm payment received?` dialog).
- **Details card** (surface-container, 12 px radius): key/value rows with 1 px dividers — `Payment method`, `Sent to` (masked), `Reference`, `Submitted`, `Payment sent`.
- **Timeline:** three-step vertical list with a 2 px outline-variant rail. Steps are 24 dp circles: filled success `check` for completed, filled primary `send` for the active step, empty outline for future steps. Rows: `Withdrawal requested`, `Payment sent by SGX`, `Waiting for your confirmation` (with `Auto-confirms in 2 days`).
- **Bottom:** text button `Contact SGX on WhatsApp` (leading `support_agent`).
- **Other status renderings:**
  - **Pending:** no confirmation prompt, timeline stops at step 1, body `SGX is processing your withdrawal.`
  - **Disputed:** warning container with `SGX is reviewing this payment problem.` and prominent `Contact SGX on WhatsApp` filled button.
  - **Confirmed / Auto-confirmed:** success hero + closed timeline.
  - **Refunded:** `Rs. [X] was returned to your available balance.` + `Open Wallet` action.

### Group 5 — Products & Campaigns

#### MEC-13 · Products (`/products`) — main destination
- **Top bar:** title `Products`, trailing notifications.
- **Search row:** 48 dp pill with `search` icon, placeholder `Search parts, brands…`, trailing `tune` filter icon; surface-container bg.
- **Category chips (horizontal scroll):** `All` (selected — primary bg / white text), `Engine Oil`, `Spark Plugs`, `Filters`, `Tires`, `Chains`, `Battery`. 34 dp height.
- **Grid (2 columns, 12 px gutter):** each card is outlined, 12 px radius. Top: 110 dp image slot with the product illustration for its kind. Body: name (14/700, min-height 36 for two lines), brand + category (11 / muted).
- **Never** show price, stock, cart, order, or add-to-cart controls.

#### MEC-14 · Product Detail (`/products/:productId`)
- **No app bar** — image is full-bleed. Floating 44 dp round back button top-left over a 90 % white background with blur.
- **Hero:** 280 dp product image.
- **Body:** category tag (12/600/primary, uppercase, 0.5 letter-spacing) → product name (22/700) → product code line.
- **Specs grid (2 × 1):** two surface-container tiles — `VOLUME · 1 Litre`, `GRADE · 10W-40 · SL`.
- **About:** section title + 14 px body copy in on-surface-variant.
- **Earn callout:** success-container bg, filled `redeem` icon, title `Earn on every scan`, subtitle `Scan the QR on the pack to get your reward.`
- **Never** show prices, stock quantity, purchase action, or scheme configuration.

#### MEC-15 · Campaigns (`/campaigns`)
- **Info banner:** surface-container, filled `campaign` icon (primary), copy explaining SGX promotions.
- **Campaign cards (full width, 16 px radius, outline border, e1 shadow):** 140 dp campaign hero image, then body with title (16/700), date window (12 / muted), and a footer row with green `ACTIVE` pill (with pulse dot) and `View Campaign` chevron link.

#### MEC-16 · Campaign Detail (`/campaigns/:id`)
- **Chrome:** two floating 44 dp round buttons (back and share) over a 260 dp hero image.
- **Body:** green `ACTIVE` pill, title (24/700), date row with `calendar_month` icon.
- **Reward callout:** yellow gradient card (`#FEF3C7 → #FDE68A`), filled `emoji_events` icon (`#B45309`), label `REWARD` and title `Double reward on every Shell product`.
- **About:** section title + 14 px explanation.
- **How to participate:** three numbered steps with 32 dp primary numeric circles — `1. Buy or install any Shell product`, `2. Open the app and tap Scan`, `3. Get double reward instantly`.
- **Never** show user progress bar or promise automatic prize delivery.

### Group 6 — Notifications, Profile & Settings

#### MEC-17 · Notifications (`/notifications`)
- **Top bar:** back arrow, title `Notifications`, trailing text button `Mark all`.
- **Row:** 40 dp round tone icon (success / primary / warning / neutral bg mapping), title (14/700 when unread), one-line sub, timestamp. Unread rows get a 3 % primary tint bg and a 6 px primary dot at the left edge.
- **Type → destination map** (implement as routing):
  - Reward → Wallet or Scan History.
  - Withdrawal (submitted / paid / confirmed / disputed / auto-confirmed / refunded) → Withdrawal Detail.
  - Campaign → Campaign Detail.

#### MEC-18 · Profile (`/profile`) — main destination
- **Identity card:** primary gradient bg, 64 dp initials circle (`MF`), name (18/700), workshop + city, green `ACTIVE MECHANIC` micro-pill.
- **Info list (outlined card):** three rows — `Verified Phone` with `smartphone` icon and trailing `lock`; `Workshop` with `storefront`; `Area / City` with `location_on`.
- **Actions list (outlined card):** `Edit Profile`, `Language & Theme` (`English · Light` subtitle), `Contact SGX` (`WhatsApp: 0300-8880000` subtitle), `Help & FAQs`. Each row: 40 dp surface-container square with primary icon + label + chevron.
- **Logout button:** full width, 48 dp, error border and error text, leading `logout` icon.
- **Footer:** `SGX Partners · v1.0.0`.

#### MEC-19 · Edit Profile (`/profile/edit`)
- **Top bar:** back arrow, title `Edit Profile`, trailing text button `Save`.
- **Avatar:** 96 dp initials circle with a floating 32 dp `photo_camera` edit button.
- **Fields:** read-only `Verified Phone` (with success `check_circle` verified marker, surface-variant bg to signal locked), required `Full Name`, optional `Workshop / Shop Name` with helper `Optional — helps customers recognize your shop.`, required `Area / City` selector.
- **Footer:** two half-width buttons `Cancel` (outlined) and `Save` (filled with `check`).
- **Dirty state:** on back, if fields changed, show a discard confirmation dialog.

#### MEC-20 · Language & Theme (`/profile/preferences`)
- **Language group:** two rows in an outlined card — `English (Pakistan)` (selected) and `اردو / Urdu · دائیں سے بائیں` — each with a 40 dp `Aa` / `ا` glyph tile and a 22 dp radio.
- **Theme group:** 3-column grid — `System` (split card), `Light` (grey card), `Dark` (dark card) — each 12 px radius, selected wraps in 2 px primary border.
- **Preview:** surface-container card that shows the wallet balance + two half-width action buttons using the current tokens.

### Group 7 — Localization Sample

#### Home · اردو (RTL)
Same MEC-05 Home component wrapped in `dir="rtl"`. Confirms all spacing, alignment, and icons mirror correctly. Currency and phone numbers stay LTR inline; text uses `Noto Nastaliq Urdu` fallback.

## Interactions & Behavior

- **Splash routing:** on mount → check Supabase session → fetch protected profile → route: no session → MEC-01, complete active mechanic → MEC-05, incomplete mechanic → MEC-04, active wholesaler → wholesaler home, inactive/customer/staff → MEC-03.
- **OTP:** 24 s countdown to `Resend code`; on 6 digits entered, auto-submit is optional but must not skip validation feedback.
- **Bottom bar:** four labelled destinations + center-docked Scan FAB (72 dp, primary bg, filled `qr_code_scanner`, semantic label `Scan QR`). Scan is not a persistent tab; it opens the scanner as a pushed route and never remains selected.
- **Scanner state machine** (see `docs/architecture.md § 12`): `checkingConnectivity → offlineBlocked | requestingPermission → permissionDenied | ready → detected → validating → success | alreadyScanned | notActive | invalid | expired | retryableError`. Only `ready` accepts frames; first detection immediately transitions to `detected/validating` and camera pauses. Leaving the route clears the payload; nothing is persisted.
- **Scan Result surface:** enter as bottom sheet (`extraLarge` 28 px top radius), 350 ms scale + crossfade (respect reduced motion → 200 ms opacity only). Success uses one large celebratory scale; failures crossfade only.
- **Withdraw Money confirmation:** `Continue` opens a `ModalBottomSheet` with amount / method / masked destination / processing time. `Confirm Withdrawal` requires internet — on success go to MEC-12; on failure keep form and show retry error.
- **Withdrawal Detail actions:** `Received` opens an `AlertDialog` — `Confirm payment received?` / `Confirm that you received Rs. [X].` / Cancel + `Confirm Received`. `Not Received` opens `Payment not received?` / `This will report a payment problem to SGX.` / Cancel + `Report Problem`.
- **Logout:** confirmation dialog → clears session → routes to MEC-01.
- **Every network-backed screen** implements loading, content, empty, error, and offline states (see `docs/screen-specs.md § 25`).
- **Offline scanner copy (exact):** `Internet is required to scan a QR. Please reconnect and try again.` The scanner must **never** queue a payload.

## State Management

Use **Riverpod 3**. Ownership matrix from `docs/architecture.md § 11`:

| State | Owner | Persistence |
|---|---|---|
| Auth session | Auth stream provider | Supabase SDK |
| Protected profile / role | Profile provider | Supabase |
| Onboarding form | `AsyncNotifier` | Memory until success/retry |
| Selected content destination | Router shell | Restoration optional |
| Camera permission | Scanner controller | OS + memory |
| Current detected payload | Scanner `AsyncNotifier` | **Memory only, during active scan** |
| Current scan result | Scanner `AsyncNotifier` | Memory until close/next scan |
| Scan history | Paginated provider | Server |
| Home summary | Provider | Server + memory |
| Wallet / withdrawals | Role-aware providers | Server |
| Products / campaigns / notifications | Shared providers | Server |
| Profile edit | `AsyncNotifier` | Memory during edit |
| Language / theme | Preference notifiers | Local preferences |

**Never** persist the current QR payload, and **never** create a local pending-scan state.

**Repository contracts** (implement in `data/`, one per aggregate — full signatures in `docs/architecture.md § 15`): `AuthRepository`, `ProfileRepository`, `ScannerRepository.validateAndCredit(payload, requestId)`, `ScanHistoryRepository`, `MechanicHomeRepository`, `WalletRepository`, `WithdrawalRepository`, `ProductRepository`, `CampaignRepository`, `NotificationRepository`. No offline scanner repository exists.

## Design Tokens

Everything below is compiled from `docs/design-token.json` (v1.0). Also available as CSS variables in `tokens.css`.

### Colors — Light theme
| Token | OKLCH | Approx hex |
|---|---|---|
| `primary` | `oklch(0.3582 0.1289 265.52)` | ~`#1E3A8A` (deep SGX navy-indigo) |
| `onPrimary` | `oklch(1 0 0)` | `#FFFFFF` |
| `primaryContainer` | `oklch(0.2316 0.0907 265.52)` | ~`#131E4D` |
| `onPrimaryContainer` | `oklch(0.9385 0.0285 264.18)` | ~`#DDE6FA` |
| `secondary` | `oklch(0.9385 0.0285 264.18)` | ~`#DDE6FA` |
| `onSecondary` | `oklch(0.2077 0.0398 265.75)` | ~`#111A33` |
| `secondaryContainer` | `oklch(0.9683 0.0069 248.08)` | ~`#F1F3F7` |
| `tertiary` / `success` | `oklch(0.6235 0.1737 145.94)` | ~`#22C55E` |
| `error` | `oklch(0.5266 0.2049 27.43)` | ~`#DC2626` |
| `warning` | `oklch(0.8388 0.1614 84.42)` | ~`#FBBF24` |
| `surface` | `oklch(0.9789 0.0042 247.86)` | ~`#F7F9FC` |
| `onSurface` | `oklch(0.2077 0.0398 265.75)` | ~`#111A33` |
| `surfaceVariant` | `oklch(0.9683 0.0069 248.08)` | ~`#F1F3F7` |
| `onSurfaceVariant` | `oklch(0.5510 0.0234 264.37)` | ~`#7B8497` |
| `surfaceContainerLowest` | `oklch(1 0 0)` | `#FFFFFF` |
| `surfaceContainer` | `oklch(0.9683 0.0069 248.08)` | ~`#F1F3F7` |
| `surfaceContainerHigh` | `oklch(0.9385 0.0285 264.18)` | ~`#DDE6FA` |
| `outline` | `oklch(0.5510 0.0234 264.37)` | ~`#7B8497` |
| `outlineVariant` | `oklch(0.9219 0.0098 247.88)` | ~`#E6E9EF` |

### Colors — Dark theme
| Token | OKLCH |
|---|---|
| `primary` | `oklch(0.4683 0.1371 265.52)` |
| `surface` | `oklch(0.145 0 0)` |
| `onSurface` | `oklch(0.985 0 0)` |
| `surfaceContainer` | `oklch(0.205 0 0)` |
| `surfaceContainerHigh` | `oklch(0.235 0 0)` |
| `surfaceContainerHighest` | `oklch(0.269 0 0)` |
| `outline` | `oklch(0.708 0 0)` |
| `outlineVariant` | `rgba(255,255,255,0.10)` |

### Semantic status → role → color map
| Purpose | Role | Label |
|---|---|---|
| Scan success | `success` | `Reward added` |
| Already scanned | `error` | `Already scanned` |
| QR not active | `warning` | `QR not active` |
| Invalid QR | `error` | `Invalid QR` |
| Expired | `error` | `QR expired` |
| Retryable error | `warning` | `Could not check QR` |
| Withdrawal Pending | `warning` | `Pending` |
| Withdrawal Paid | `primary` | `Payment Sent` |
| Withdrawal Confirmed | `success` | `Confirmed` |
| Withdrawal Disputed | `error` | `Disputed` |
| Withdrawal Auto-confirmed | `surfaceVariant` | `Auto-confirmed` |
| Withdrawal Refunded | `success` | `Refunded` |

### Typography — `Roboto` primary, `Noto Nastaliq Urdu` for RTL, `Roboto Mono` for numerics
| Usage | size / line / weight |
|---|---|
| Screen title | 24 / 32 / 600 |
| Section title | 16 / 24 / 600 |
| Balance hero | 32 / 40 / 700 (tabular) |
| Reward result | 40 / 48 / 700 (tabular) |
| Card title | 16 / 24 / 600 |
| Body | 14 / 20 / 400 |
| Supporting | 12 / 16 / 400 |
| Button | 14 / 20 / 600 |
| Badge | 11 / 16 / 600 |

Support **200 % text scale** and text wrapping. Use tabular figures for all financial numbers.

### Shape (radius, dp)
`extraSmall 4`, `small 8`, `medium 12`, `large 16`, `extraLarge 28`, `full 9999`.
Component defaults: button/chip/badge → `full`, text field → `small`, card → `medium`, walletHero → `large`, scanAction → `full`, scanFrame → `large`, bottomSheet/dialog → `extraLarge`, image → `medium`.

### Spacing (unit = 4 dp)
Scale `0/1/2/3/4/5/6/8/10/12`. Screen padding `16`, card padding `16`, section gap `24`, field gap `16`, list gap `12`.

### Sizing (dp)
Minimum touch target `48`, center Scan action `72` (min 64), bottom app bar `80`, top app bar `64`, button `48`, text field `56`, chip `32`. Scan frame width fraction `0.68`. Product image ratio `4:3`, campaign banner `16:9`. Max content width expanded `1040`.

### Elevation
`level0` for camera overlay, `level1` (1 dp) for wallet hero and bottom app bar tonal surface, `level2` (3 dp) for menus and scrolled top app bar, `level3` (6 dp) for scan FAB, result surfaces, dialogs and sheets.

### Motion
Standard 300 ms `cubic-bezier(0.2, 0, 0, 1)`, enter 250 ms `cubic-bezier(0, 0, 0, 1)`, exit 200 ms `cubic-bezier(0.3, 0, 1, 1)`. `scanDetected` pauses camera and highlights the frame once (200 ms). `scanSuccess` single 350 ms scale/crossfade (respect reduced motion).

### Content guidelines
- Currency `Rs. X,XXX`.
- Phone `0300-1234567`.
- Date `DD MMM YYYY`. Time `HH:mm`.
- Tone: plain, respectful, direct.
- Button labels: specific verbs, **never** `OK` or `Submit`.
- Max one primary action per screen.
- Scanner instruction: `Place the QR inside the frame.`
- Offline scanner: `Internet is required to scan a QR. Please reconnect and try again.`
- Avoid these terms in copy: `sync queue`, `pending scan`, `payload`, `signature`, `conversion rate`, `invoice redemption`.

### Accessibility
- Min touch target 48 dp; Scan action min 64 dp.
- Normal text 4.5:1 contrast; large text 3:1.
- Status uses icon + text + color (never color-only).
- Screen-reader labels required. Scan FAB semantic label `Scan QR`.
- Support 200 % text scaling without overlap.
- Camera screen provides spoken accessibility labels and non-camera error guidance.
- Reduced motion: result animations become crossfades.

## Assets

- **Brand icon:** the approved master is `../../customer/sgx-app-icon.svg` (see `docs/architecture.md § 4`). It is a white rounded-square with navy SGX artwork. It must never be recolored, cropped, or given a mechanic-specific variant. Placements:
  - Splash 112 dp · Phone Login 72 dp · OTP 48 dp · Onboarding 48 dp · Home app bar 32 dp.
  - **Do not** place in bottom navigation or inside the Scan FAB.
- **Icons:** Material Symbols Rounded (via Google Fonts CDN in the mockups; use the `material_symbols_icons` Flutter package or `flutter_launcher_icons` in the real app). Full mapping in `docs/design-token.json § icons`.
- **Fonts:** Roboto (all weights 400–800), Noto Nastaliq Urdu, Roboto Mono. Bundle via `pubspec.yaml`.
- **Illustrations for products (Shell oil, NGK plug, K&N filter, DID chain, CEAT tire, Osaka battery):** the mockup uses inline SVG placeholders. Production should replace them with server-provided product images (sized per `sizing.productCardImageAspectRatio = 4:3`).
- **Campaign artwork:** admin-uploaded per campaign; render at 16:9 hero.

## Files

Reference these files in the bundle (all are HTML/CSS/JSX design references, not production code):

- `SGX Mechanic Screens.html` — main pan/zoom canvas that hosts every artboard.
- `tokens.css` — every design token compiled to CSS variables (light + dark).
- `components.jsx` — shared UI primitives (`Phone` shell, `TopAppBar`, `BottomBar` with the raised Scan FAB, `TextField`, `FilledBtn` / `OutlinedBtn` / `TextBtn`, `StatusChip`, `SectionHeader`, `ImgSlot`, `Scroll`, `SgxIcon`).
- `screens/auth.jsx` — MEC-00 → MEC-04.
- `screens/home_scan.jsx` — MEC-05, MEC-06 (ready + offline), MEC-07 (6 result variants).
- `screens/wallet.jsx` — MEC-08 → MEC-12.
- `screens/products_more.jsx` — MEC-13 → MEC-17.
- `screens/profile.jsx` — MEC-18 → MEC-20 + Urdu/RTL home sample.
- `screens_index.jsx` — mounts every screen into the DesignCanvas.

### Source documents (single source of truth — read these too)

- `docs/prd.md` — locked owner decisions, scope, non-goals, success metrics.
- `docs/architecture.md` — layer boundaries, Riverpod state ownership, scanner state machine, trusted scan operation contract, Supabase RLS boundaries, testing strategy.
- `docs/screen-flow.md` — navigation graph and route transition map.
- `docs/screen-specs.md` — per-screen content, validation copy, and state coverage.
- `docs/screen-stats.md` — screen inventory, complexity, and 77-frame design workload.
- `docs/design-token.json` — machine-readable tokens (this is the source; `tokens.css` is a derived view).
