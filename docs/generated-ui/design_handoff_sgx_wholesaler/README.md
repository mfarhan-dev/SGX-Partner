# Handoff: SGX Partners — Wholesaler Module

**Application:** SGX Partners (shared B2B Flutter app — mechanic + wholesaler modules)
**Module in this handoff:** Wholesaler role only
**Target platform:** Flutter (Android first, iOS-compatible) · Material Design 3 · Riverpod 3 · Supabase backend
**Design fidelity:** High-fidelity (see "Fidelity" section below)
**Package date:** 22 July 2026

---

## 1. Overview

This bundle contains the complete visual/behavioral reference for the **wholesaler role** of SGX Partners, a B2B rewards app for a motorcycle-parts distribution business in Pakistan. Wholesalers are shop owners who buy SGX products from the factory. When a mechanic scans a reward QR tied to one of the wholesaler's dispatched invoices, both parties earn a share — the wholesaler passively accrues rewards, watches QR progress, withdraws money, browses the catalog, and reads campaigns/notifications.

The wholesaler experience is intentionally simple because many users have limited literacy and smartphone experience. Design bias: **one primary action per screen, large numbers, icon + text + color on every status, no jargon.**

**Companion module:** The mechanic role of the same app has been handed off separately. Both modules share one Flutter executable, one auth session, one theme, one Supabase project.

---

## 2. About the Design Files

The files in this bundle are **design references created in HTML/React** — interactive prototypes that show the intended look, layout, spacing, colors, typography, and interactions.

**They are NOT production code to copy directly.** The task is to **recreate these designs in Flutter** using the codebase's target patterns:

- **UI framework:** Flutter with Material 3 (`useMaterial3: true`)
- **State management:** Riverpod 3
- **Backend:** Shared Supabase project (auth, tables, storage, realtime, trusted operations)
- **Architecture:** Clean layered — presentation / application / domain / data / infrastructure
- **Localization:** English + Urdu, RTL-ready

If any part of the layered/architectural setup is not in place yet, follow the boundaries in `docs/architecture.md`.

---

## 3. Fidelity

**High-fidelity.** All screens are pixel-mocked with:

- Final SGX color palette (deep navy-indigo `oklch(0.3582 0.1289 265.52)` ≈ `#1E3A8A`) — see Design Tokens section
- Final Roboto typography scale (Noto Nastaliq Urdu fallback)
- Final spacing (4 px base unit, 16 px screen padding)
- Final iconography (Material Symbols Rounded)
- Final component styles: cards, chips, dialogs, bottom sheets, progress bars, timelines
- Final copywriting (all button labels, empty states, error text, dialog copy)

Recreate the UI **pixel-perfectly**. Colors, spacing, radii, font weights, icon sizes, and copy have been decided.

---

## 4. Screens / Views

**Frame size for all mockups:** 390 × 844 dp (iPhone 14 reference). Layouts must also work at 360 × 800 and 430 × 932.

**Bottom navigation:** 5 destinations, always-visible labels, no scan/FAB (wholesalers never scan).
`Home · QR Progress · Wallet · Products · Profile`

### 4.1 Authentication & Access — WHL-00 → WHL-03

#### WHL-00 · Splash · `/splash`
- **Purpose:** Initialize app, restore session, route by role/active status.
- **Layout:** Full-screen brand surface (`--sgx-primary`). Vertically centered 112 dp SGX icon inside a 6 px translucent white pad (`rgba(255,255,255,0.06)`, radius 28). Below icon: title "SGX Partners" (28 px / 800), tagline "Business rewards, one tap away." (14 px / 500, opacity 0.75). Loading dots + version pin at bottom (40 dp above home indicator).
- **Loading state:** three 8 px dots (opacity 0.35 → 0.55 → 0.75), shown only after 1 s.

#### WHL-01 · Phone Login · `/auth/phone`
- **Purpose:** Enter registered mobile number to receive OTP.
- **Layout:** Top app bar (empty title, trailing `Language` text button "EN"). Body 24 px padding. Center-aligned column: 72 dp SGX icon → 26 px / 700 title "Login to SGX Partners" → 14 px / 400 supporting "Enter your registered mobile number." → single text field (label "Mobile number", prefix "🇵🇰", icon `phone_iphone`, helper "Format: 03XX-XXXXXXX") → filled 48 dp `Send OTP` button (icon `sms`). Below: help card (surface-container, 12 px padding, radius 12, icon `badge` in primary color, title "Wholesaler account required", body "Wholesaler accounts are created by SGX staff. Contact SGX to be added.").
- **Behavior:** No role selector shown. Unknown numbers route to mechanic onboarding outside this module (per PRD §7).

#### WHL-02 · OTP Verification · `/auth/otp`
- **Purpose:** Verify phone ownership via 6-digit OTP.
- **Layout:** Back arrow app bar. Center column: 48 dp SGX icon → 24 px title "Verify your number" → supporting text with masked phone (`+92 300 ••• 4567`, bold). OTP field is 6 square boxes (48 × 56, radius 12, 2 px border, `--sgx-primary` when filled, `--sgx-outline-variant` when empty, filled boxes have `rgba(30,58,138,0.06)` background). Cursor blink animation in current box. Below boxes: "Didn't get the code? Resend in 0:32" (12 px, disabled during countdown). Filled `Verify` button. Text button "Change number" at bottom.
- **Validation copy:** `OTP is required.` · `Invalid OTP. Please try again.` · `Too many attempts. Please wait and try again.`
- **Success routing:** active wholesaler → WHL-04 Home · active mechanic → mechanic Home · customer/staff → WHL-03 wrong-role · inactive wholesaler → WHL-03 inactive · unknown → mechanic onboarding.

#### WHL-03 · Account Unavailable · `/auth/account-unavailable` (3 variants)
Common frame: back arrow → 96 dp circular icon badge → 22 px title → 14 px body (max-width 280) → 1–2 stacked buttons.

| Variant | Icon | Icon color | Icon bg | Title | Body | Primary button | Secondary |
|---|---|---|---|---|---|---|---|
| **Inactive wholesaler** | `person_off` | `--sgx-error` | `--sgx-error-container` | "Account inactive" | "Your account is inactive. Please contact SGX to reactivate your wholesaler account." | Contact SGX (`support_agent`) | Use another number |
| **Wrong role** (customer/staff) | `lock` | `--sgx-primary` | `rgba(30,58,138,0.10)` | "B2B access unavailable" | "This account cannot access the B2B app. Please use your registered wholesaler number." | Use another number (`phone_iphone`) | — |
| **Not found** | `person_search` | `#8A5A00` | `--sgx-warning-container` | "Account unavailable" | "We could not find an active account for this number. Contact SGX if you think this is a mistake." | Back to Login (`arrow_back`) | — |

Never expose technical role names, database errors, or identifiers.

### 4.2 Home & QR Progress — WHL-04 & WHL-05

#### WHL-04 · Home · `/wholesaler/home`
- **Purpose:** Immediate view of money, QR progress, pending actions.
- **App bar:** Leading 32 dp SGX icon + "SGX Partners" title, trailing `notifications` icon with unread badge.
- **Sections (top → bottom, 20 px gap):**
  1. **Greeting** (20 px H-padding): "Assalam-o-Alaikum," (14 px, muted) → owner name "Muhammad Farhan" (22 px / 700) → shop chip "Farhan Motor Parts · Lahore" (13 px / 600, primary color, `storefront` icon).
  2. **Wallet hero card** (16 px H-padding, radius 20, gradient `--sgx-primary → oklch(0.28 0.14 265)`, box-shadow `0 8px 20px rgba(30,58,138,0.25)`, decorative circles at 0.06/0.04 opacity):
     - Header row: `account_balance_wallet` icon + "Available Balance" (13 px)
     - Value: "Rs. 18,420" (42 px / 800, letter-spacing -1, tabular-nums)
     - Divider row with Pending + Lifetime (11 px uppercase labels, 15 px / 700 values)
     - White pill button "Withdraw Money" (44 dp, radius 22, primary-color text, `payments` icon)
  3. **QR Progress summary card** (surface-container, radius 16, 16 px padding): big scanned count "486" (28 px / 800, primary) + "/ 720 scanned" muted; right-aligned "67%"; ProgressBar (10 px height); below, two legend items (blue "Scanned 486 QRs" + gray "Remaining 234 QRs"). Action link `View all` → WHL-05.
  4. **Latest reward card** (success-container background, radius 12, 44 dp success circle with `add_circle` icon): "Rs. 12 added to wallet" (15 px / 700), "Shell Advance AX7 · 2 mins ago" (12 px muted), right-aligned "+12" (18 px / 800, success).
  5. **Active withdrawal card** (warning-container background) — shown only when open request exists: `schedule` icon, "Payment sent — please confirm", "Rs. 5,000 · JazzCash · Today", chevron.
  6. **Campaign banner** (radius 16, elevation 1): 130 dp hero image + 14 px caption block (title 15 px / 700 + date range 12 px muted).
  7. **Quick actions grid** (2×2, 12 px gap): QR Progress · Wallet · Withdraw · Products. Each: 36 dp tinted icon square + 13 px / 600 label on surface-container.
- **Empty variant (`WhlHomeEmpty`):** Wallet shows "Rs. 0", withdraw button disabled with `lock` icon and "rgba(255,255,255,0.15)" background. Replace reward card with empty state (72 dp icon circle + "No rewards yet" + subtext "Rewards will appear when mechanics scan your SGX product QRs.").
- **Simplicity rule:** Max 3 monetary values in hero. No charts.

#### WHL-05 · QR Progress · `/wholesaler/qr-progress`
- **Purpose:** Aggregate scanned vs remaining reward QR progress. **One screen only — no detail route.**
- **App bar:** Title "QR Progress", trailing `notifications`.
- **Aggregate summary card** (surface-container, 18 px padding, radius 16):
  - Small uppercase label "Overall progress"
  - Three-column stats (Total 720 · Scanned 486 (primary) · Remaining 234), separated by 1 px dividers
  - 10 px ProgressBar
  - Footer line "Updated just now · Pull down to refresh" with `refresh` icon
- **Group cards** (list, 12 px gap, radius 16, `--sgx-outline-variant` border, surface bg):
  - Row 1: 56 dp product image + product name (15 px / 700) + reference "INV-0058" (12 px muted with `receipt_long` icon) + status chip (Active/Complete, `paid`/`confirmed` chip variants)
  - Counts row: "148 scanned" (primary, big number 18 px) · "52 remaining" (right-aligned muted)
  - 8 px ProgressBar (success tone when complete)
  - Divider → "Earned from this batch" label + "Rs. 1,776" (16 px / 800, success)
- **Interaction:** Cards are NON-tappable. No chevron. No ripple. Pull-to-refresh allowed.
- **Data restriction:** Never show mechanic names, individual QR IDs, scan timestamps, invoice totals, inventory, stock, prices, or profit.
- **Empty variant (`WhlQrProgressEmpty`):** Centered 96 dp icon in surface-container circle, "No QR progress yet" (18 px / 700), "Your SGX reward QR progress will appear here once SGX dispatches an invoice to your shop.", `Contact SGX` outlined button.

### 4.3 Wallet & Withdrawals — WHL-06 → WHL-08

#### WHL-06 · Wallet · `/wholesaler/wallet`
- **Balance hero card**: gradient primary, "Available Balance" label (13 px, opacity 0.8), value "Rs. 18,420" (44 px / 800). Two glass-tile stats (Pending Rs. 5,000 · Lifetime Rs. 1,42,340). Decorative large wallet icon at 0.08 opacity in top-right.
- **Action row**: filled `Withdraw Money` button (flex 2) + circular `receipt_long` icon button (48 dp).
- **Helper**: "Minimum withdrawal is Rs. 500." (12 px muted, `info` icon).
- **Recent activity list**: continuous list (no separate history screen). Each row: 40 dp tinted circle (success container for credits, warning for pending/paid, primary tint for other debits) + `mi-fill` icon → title + subtitle → right-aligned amount (green for positive) + status chip when relevant.
- **Row types:** `QR reward added` (+15), `Payment sent` (Confirm now chip), `Withdrawal requested` (Pending chip), `Withdrawal confirmed`, `Money returned to wallet` (Refunded chip). **NO invoice-redemption row exists.**

#### WHL-07 · Withdraw Money · `/wholesaler/withdrawals/new`
- **Balance banner**: primary background, wallet icon + "Available Balance Rs. 18,420" + right-aligned "Minimum Rs. 500".
- **Amount section**: "How much?" label + text field (prefix "Rs.", icon `payments`) + quick-amount chip row: `Rs. 500`, `Rs. 1,000`, `Rs. 5,000` (selected primary bg), `All (Rs. 18,420)`.
- **Payment method cards** (radio-select list, 8 px gap): EasyPaisa (green `phone_android`), JazzCash (red `phone_android`), Bank Transfer (blue `account_balance`), Cash from SGX (purple `store`). Each: 40 dp tinted icon square + name (14 px / 700) + subtitle + radio dot on right. Selected card: 1.5 px `--sgx-primary` border, `rgba(30,58,138,0.05)` background.
- **Conditional destination fields:**
  - EasyPaisa/JazzCash: Account title + Mobile number
  - Bank Transfer: Bank name + Account title + Account number/IBAN
  - Cash from SGX: no fields; show collection instructions
- **Primary button**: `Continue` (arrow_forward). Footer helper about business hours.
- **Validation copy** (from spec §11): `Enter a withdrawal amount.` · `Minimum withdrawal is Rs. [X].` · `Amount cannot exceed your available balance.` · `Select a payment method.` · `Account title is required.` · `Enter a valid mobile number.` · `Bank name is required.` · `Account number or IBAN is required.` · `Could not submit withdrawal. Please try again.`

#### WHL-07 · Withdraw · Confirmation bottom sheet
- Dimmed backdrop (`rgba(15,23,42,0.55)` with 2 px blur).
- Sheet: `--sgx-surface`, top corners 28 px radius, `0 -8px 24px` shadow. 32 × 4 drag handle at top.
- Title "Confirm withdrawal" (13 px muted) → big "Rs. 5,000" (40 px / 800, primary).
- Review rows inside surface-container card: Method · Account title · Mobile number · Processing time (each with icon in method's color).
- Actions: outlined `Cancel` (flex 1) + filled `Confirm Withdrawal` (`check` icon, flex 2). On success → WHL-09 Detail.

#### WHL-08 · Withdrawals · `/wholesaler/withdrawals`
- **Filter chips** (scrollable, 4/16 px padding): `All (6)` (selected primary), `Open (3)`, `Completed (3)`. Chip count uses translucent counter pill.
- **Cards** (radius 12, 1 px outline-variant border): 44 dp method icon square + amount "Rs. 5,000" (18 px / 800) + status chip; method name + date muted; divider → next-step note + chevron. Statuses: `Pending`, `Payment Sent`, `Confirmed`, `Disputed`, `Auto-confirmed`, `Refunded`.

### 4.4 Withdrawal Detail Lifecycle — WHL-09 (all states)

**Shared header (`_WdHeader`):** 4/16 padding. Centered "Withdrawal amount" label → giant "Rs. 10,000" (44 px / 800). StatusChip below (size default). Below: method + destination card (44 dp tinted method icon + name + masked destination + submitted date on right).

**Shared timeline (`_Timeline`):** vertical stepper. 28 dp circular step marker (`--sgx-primary` when done, `--sgx-surface-container-high` when not; 3 px translucent halo on current step). 2 px connecting line (primary when done). Title (14 px / 700) + time + note.

#### WHL-09 · Pending
- Warning-container info banner: `schedule` icon + "SGX is processing your withdrawal" + "Bank transfers usually take 1 working day. You will be notified when the payment is sent."
- Timeline: Submitted ✓ → Being processed ✓ (current) → Payment will be sent (todo) → Payment confirmation (todo).
- **No destructive or duplicate-submit action.**

#### WHL-09 · Payment Sent (awaiting user confirmation)
- **Payment details card** (surface-container): payment date · reference "JC-8827145" · payment proof preview link ("View proof" in primary with `image` icon).
- **Confirmation prompt** (`rgba(30,58,138,0.06)` bg with 1 px primary-15% border): centered "Did you receive Rs. 5,000?" + subtitle. Two buttons:
  - `Not Received` — outlined error, 48 dp, `close` icon
  - `Yes, Received` — filled success, 48 dp, `check_circle` icon (flex 1.4)
- Footer: "If you don't respond within 3 days, this payment will be auto-confirmed."

#### WHL-09 · "Not Received" dialog
- Centered modal (320 × auto, radius 28, `0 20px 40px` shadow).
- 56 dp error-container circle with `error` icon → "Payment not received?" (20 px / 700) → body "This will report a payment problem to SGX. SGX will review and contact you." → Cancel (outlined) + `Report Problem` (error-filled, 1.3 flex).

#### WHL-09 · Disputed
- Error-container warning: `error` icon + "SGX is reviewing this payment problem" (error color) + "We received your report on 03 Jul. Your Rs. 4,200 remains locked until this is resolved."
- WhatsApp button: `#25D366` background, 56 dp height, WhatsApp SVG glyph + "Contact SGX on WhatsApp".
- Timeline includes "You reported not received" + "SGX is reviewing" (current).

#### WHL-09 · Confirmed (and Auto-confirmed via `auto` prop)
- Success-container banner with 56 dp success circle + `check` icon → "Payment confirmed" or "Closed automatically" → body ("Rs. 8,000 was successfully received." or "This payment was closed automatically after the 3-day confirmation period.") + closed date.
- Timeline finishes with "You confirmed receipt" (or "Auto-confirmed after 3 days").

#### WHL-09 · Refunded
- Success-container banner with `currency_exchange` icon → "Rs. 2,500 returned to wallet" → body.
- `Open Wallet` filled button.
- Timeline ends with "Money returned to wallet" + reason note.

### 4.5 Products & Campaigns — WHL-10 → WHL-13

#### WHL-10 · Products · `/products`
- **Search bar** (48 dp, radius 24, surface-container): `search` icon + placeholder "Search products…" + trailing `tune` filter icon.
- **Category chips** (scrollable): All (selected primary), Engine Oil, Spark Plugs, Tires, Batteries, Filters, Chains.
- **Grid** (2 columns, 12 px gap): each card is radius 12, 1 px border-variant border. 110 dp hero image at top, 10 px padded caption: uppercase brand (10.5 px / 700, primary), product name (13 px / 600, 2-line clamp height 34), monospaced code.
- **NO price, stock, Add, Cart, or Order action.**

#### WHL-11 · Product Detail · `/products/:productId`
- 220 dp hero image (radius 16, 16 px H-padding).
- Category+brand uppercase line → product title (22 px / 800) → SKU monospace.
- Attribute grid inside surface-container card: Brand · Category · Volume · Type · Grade (13 px, each row divided by 1 px outline-variant).
- "Description" section + 14 px paragraph.
- Footer info: "For pricing and orders, contact SGX directly." **NO fixed bottom purchase action.**

#### WHL-12 · Campaigns · `/campaigns`
- List of campaign cards (radius 16, elevation 1, 1 px outline-variant border):
  - 130 dp hero image with corner tag (top-left, 4/10 px padding, radius 10) — "ACTIVE" (green) or "ENDING SOON" (amber `#F59E0B`)
  - Caption block: title (16 px / 700) + description + divider → date row (`calendar_month` icon) + "View →" link.

#### WHL-13 · Campaign Detail · `/campaigns/:campaignId`
- 180 dp hero image (radius 16).
- Active-status pill (`bolt` icon + "ACTIVE CAMPAIGN") → title (24 px / 800) → date row.
- **Reward highlight card** (gradient primary, 18 px padding, radius 16): 56 dp glass icon square with `redeem` → "Reward" label + "+10% on filter sales" (20 px / 800) + "On top of regular QR reward".
- "About this campaign" description.
- "How to participate" numbered list (24 dp primary circles with white numbers 1–3).
- Footer info: "Bonus is credited when scans are confirmed by SGX." **NO progress bar. NO guaranteed-prize promise.**

### 4.6 Notifications, Profile & Preferences — WHL-14 → WHL-16

#### WHL-14 · Notifications · `/notifications`
- **Unread summary strip** (top): `rgba(30,58,138,0.06)` background, `notifications_active` icon (primary), "4 unread notifications" (12 px / 600 primary).
- **Notification rows** (14/16 padding, 1 px outline-variant divider, unread rows have `rgba(30,58,138,0.03)` bg):
  - 40 dp tinted circle with type icon (`add_circle` green for rewards, `send` blue for payment sent, `campaign` amber, `edit_document` blue for submitted, `currency_exchange` green for refunded, `task_alt` green for confirmed, `lock_clock` gray for auto)
  - Title (bold 700 when unread, 500 when read) + subtitle + timestamp
  - 10 dp primary dot on right for unread items.
- **Types + destinations** (see PRD §18): QR reward → Wallet · Withdrawal notifications → WHL-09 Detail · Campaign → WHL-13. **No QR Progress Detail destination.**

#### WHL-15 · Profile · `/profile`
- **Identity hero** (gradient primary, radius 20, centered content, large `storefront` icon at 0.08 opacity in top-right):
  - 76 dp white circle avatar with "FM" monogram (32 px / 800, primary text)
  - Shop name (20 px / 800), "Muhammad Farhan · Owner" subtitle
  - Pill "ACTIVE WHOLESALER" with `check_circle` icon on `rgba(255,255,255,0.16)` bg
- **Business information** list (surface): rows for Phone (with `verified` icon), Area/City, Shop address. Each row: `mi-symbol` icon + uppercase key + value.
- **Read-only notice** (surface-container, 10 px radius): `info` icon + "Contact SGX to update your business information."
- **Preferences menu**: Language & Theme · Contact SGX · Help & FAQs · Log out (destructive, error color). Each row: 40 dp tinted icon square + label + subtitle + chevron.
- **Footer:** "SGX Partners · v1.0.0"
- **NO Edit Profile action. NO GST, NTN, tax, wallet redemption, or QR scanner entry.**

#### WHL-16 · Language & Theme · `/profile/preferences`
- **Language** (radio card list): English (default, selected) · اردو (Urdu — Right-to-Left). Each card: 44 dp letter chip (Urdu uses `Noto Nastaliq Urdu`) + name + subtitle + radio.
- **Theme** (3-column grid): System (half-white/half-dark preview), Light (white), Dark (`#0F172A`). Selected has 2 px primary border. Card footer with label + `check_circle` on selected.
- **Preview**: mini balance card showing tokens in current theme + "Withdraw Money" button.
- **Footer:** "Changes apply immediately."

### 4.7 Urdu / RTL sample

`WhlHomeUrdu` proves the theme, components, and layout invert cleanly under `dir="rtl"`. All flex rows flip via `row-reverse`. Monetary numbers stay LTR (`dir="ltr"` on money spans with `text-align: right`) — tabular figures are locale-invariant. Bottom bar order reversed. Font family switches to `Noto Nastaliq Urdu` on Urdu strings.

---

## 5. Interactions & Behavior

### Navigation
- **Bottom nav** (Riverpod-owned stateful shell) preserves each tab's stack where practical.
- **Back button** on every pushed screen. Never hijack the OS back gesture.

### Wallet & Withdrawal Lifecycle
```
Submitted → Pending → Admin marks payment sent → Paid (Awaiting Confirmation)
  → Received → Confirmed
  → Not Received → Disputed
  → No response in configured window → Auto-confirmed

Disputed → Admin re-pays → Paid Awaiting Confirmation → Confirmed
Disputed → Admin refunds → Refunded (amount returns to Available)
```

### Passive Reward Flow (no user action)
```
Mechanic scans active QR tied to wholesaler invoice
→ Server validates + credits both shares
→ Wholesaler wallet + QR Progress refresh
→ Reward notification arrives
→ Tap notification → Wallet
```

### Confirmation UX
- Withdrawal submission → **ModalBottomSheet** ("Confirm withdrawal" with masked destination).
- "Received" → **AlertDialog** ("Confirm payment received?").
- "Not Received" → **AlertDialog** ("Payment not received?" — reports dispute).
- Logout → **AlertDialog** confirmation.

### Animations
- Balance refresh: subtle value crossfade (300 ms, no celebratory motion).
- Progress bar refresh: animate to server value (500 ms).
- Standard enter/exit: 250/200 ms with M3 easing (`cubic-bezier(0, 0, 0, 1)` / `cubic-bezier(0.3, 0, 1, 1)`).

### Loading / Empty / Error / Offline (every network screen must implement)
- **Loading:** skeleton variants for wallet, QR card, product grid, campaign card, withdrawal card.
- **Empty:** recognizable icon + specific title + one short explanation + at most one action.
- **Error:** title "Something went wrong" + plain-language message + `Try Again` action.
- **Offline:** `No internet connection. Please reconnect and try again.` — **NO write is queued offline.** Withdrawal form input is preserved in memory only long enough for retry.

### Accessibility
- 48 dp minimum touch targets everywhere.
- Icon + text + color for every status (never color alone).
- Support text scaling to **200%** without overlap or clipping.
- QR Progress cards must NOT expose button semantics (they are non-interactive).
- Screen-reader labels required on every interactive element.
- RTL correctness: logical reading order preserved at 200% scale.

---

## 6. State Management (Riverpod 3)

| State | Owner | Persistence |
|---|---|---|
| Auth session | Supabase auth stream provider | Supabase SDK |
| Protected profile / role | Profile provider | Supabase |
| Selected main tab | Router shell | Optional restoration |
| Home summary | Wholesaler home provider | Server + memory |
| QR Progress aggregates | QR progress provider | Server + short-lived memory cache |
| Wallet summary | Wallet provider | Server source of truth |
| Wallet transactions | Paginated wallet provider | Server |
| Withdrawal form | Withdrawal Notifier | Memory only until success/retry |
| Withdrawal list | Withdrawals provider | Server |
| Withdrawal detail | Provider family by ID | Server + Realtime/refetch |
| Products/campaigns/notifications | Shared role-aware providers | Server |
| Language/theme | Preference Notifiers | Local prefs |

Provider guidance:
- `Provider<T>` — repositories & services
- `FutureProvider<T>` — read-only summaries & details
- `StreamProvider<T>` — auth + narrowly scoped Realtime signals
- `AsyncNotifierProvider` — withdrawal submission & mutations
- `NotifierProvider` — local synchronous preferences
- Families — product/campaign/withdrawal IDs

**Keep alive:** auth, profile, locale, theme, shell state. **Auto-dispose:** detail/search providers when safe.

### Data Fetching / Backend Requirements

- **Wholesaler reads only own data** (RLS on every table/view; `auth.uid()` ownership checks).
- **QR Progress projection** returns aggregate rows only (no signatures, raw payloads, mechanic identity, prices, invoice totals, stock, profit).
- **Wallet ledger is append-only.** No client-authored balance. Server returns authoritative Available / Pending / Lifetime projections.
- **Withdrawal submission** is a trusted server operation with idempotency key. Locks amount from Available into Pending.
- **`confirmReceived` / `reportNotReceived`** valid only from Paid state. Closed states reject repeat actions.
- **Payment proof** served via private paths + short-lived signed URLs.
- **Realtime** is only a signal — refetch the authoritative record on each event. Subscribe only to the current user's channels; cancel on logout/dispose.

---

## 7. Design Tokens

Source of truth: `docs/design-token.json` (the schema is `SGX Partners Wholesaler Design Tokens v1.0`, inheriting from the customer app). All CSS variables live in `tokens.css`.

### Colors (Light)

| Token | oklch | Hex approx | Usage |
|---|---|---|---|
| `--sgx-primary` | `oklch(0.3582 0.1289 265.52)` | `#1E3A8A` | Primary brand, CTAs, active tab tint, links |
| `--sgx-on-primary` | — | `#FFFFFF` | Text on primary |
| `--sgx-primary-container` | `oklch(0.2316 0.0907 265.52)` | ≈ `#0F1E4A` | Deep container variant |
| `--sgx-secondary` | `oklch(0.9385 0.0285 264.18)` | ≈ `#DDE3F5` | Tonal secondary (nav pill highlight) |
| `--sgx-on-secondary` | `oklch(0.2077 0.0398 265.75)` | ≈ `#1A1F35` | Text on secondary |
| `--sgx-tertiary` / `--sgx-success` | `oklch(0.6235 0.1737 145.94)` | ≈ `#22C55E` | Positive amounts, confirmed |
| `--sgx-error` | `oklch(0.5266 0.2049 27.43)` | ≈ `#DC2626` | Errors, destructive, disputed |
| `--sgx-warning` | `oklch(0.8388 0.1614 84.42)` | ≈ `#EAB308` | Pending states |
| `--sgx-surface` | `oklch(0.9789 0.0042 247.86)` | ≈ `#F5F7FA` | Base screen background |
| `--sgx-surface-container` | `oklch(0.9683 0.0069 248.08)` | ≈ `#EEF1F6` | Cards / tonal surfaces |
| `--sgx-surface-container-high` | `oklch(0.9385 0.0285 264.18)` | ≈ `#DDE3F5` | Track backgrounds |
| `--sgx-outline` | `oklch(0.5510 0.0234 264.37)` | ≈ `#7B8399` | Text field outlines |
| `--sgx-outline-variant` | `oklch(0.9219 0.0098 247.88)` | ≈ `#DDE1EA` | Dividers, subtle borders |

### Colors (Dark) — key overrides
- `--sgx-primary` → `oklch(0.4683 0.1371 265.52)`
- `--sgx-surface` → `oklch(0.145 0 0)`
- `--sgx-surface-container` → `oklch(0.205 0 0)`
- `--sgx-outline-variant` → `rgba(255,255,255,0.10)`

### Status role map (from `design-token.json`)
| Status | Role | Label |
|---|---|---|
| `qrActive` | primary | Active |
| `qrComplete` | success | Complete |
| `withdrawalPending` | warning | Pending |
| `withdrawalPaid` | primary | Payment Sent |
| `withdrawalConfirmed` | success | Confirmed |
| `withdrawalDisputed` | error | Disputed |
| `withdrawalAutoConfirmed` | surfaceVariant | Auto-confirmed |
| `withdrawalRefunded` | success | Refunded |

### Typography
Font: **Roboto** (400/500/600/700/800). Urdu fallback: **Noto Nastaliq Urdu**. Mono: **Roboto Mono**.

| Preset | Size | Line-height | Weight | Notes |
|---|---:|---:|---:|---|
| screenTitle | 24 | 32 | 600 | |
| sectionTitle | 16 | 24 | 600 | |
| balanceHero | 32 | 40 | 700 | tabular-nums; used at 42–44 for hero |
| balanceSupporting | 16 | 24 | 600 | |
| cardTitle | 16 | 24 | 600 | |
| body | 14 | 20 | 400 | |
| supporting | 12 | 16 | 400 | |
| button | 14 | 20 | 600 | |
| badge | 11 | 16 | 600 | |

Rules: max 4 body-style variants per screen · allow wrap · **text scale up to 200%** · financial numbers use tabular figures.

### Shape / Radius
`extraSmall 4` · `small 8` · `medium 12` · `large 16` · `extraLarge 28` · `full 9999`

Component mapping: button/chip/badge → **full pill** · textField → **small (8)** · card → **medium (12)** · walletHero / qrProgressCard → **large (16 or 20)** · bottomSheet / dialog → **extraLarge (28)** · image → **medium (12)**.

### Spacing (4 px unit)
Scale: 0, 4, 8, 12, 16, 20, 24, 32, 40, 48 · Screen padding 16 · Card padding 16 · Section gap 24 · Field gap 16 · List gap 12.

### Sizing
Touch target min **48 dp** · Bottom nav **80** · Top app bar (small) **64** · Button **48** · Text field **56** · Chip **32** · Product image ratio **4:3** · Campaign banner ratio **16:9** · Progress indicator height **8**.

### Elevation
| Level | dp | Usage |
|---|---:|---|
| level0 | 0 | Screen bg, flat progress cards |
| level1 | 1 | Wallet hero, navigation tonal surface |
| level2 | 3 | Menus, scrolled app bar |
| level3 | 6 | Dialogs, bottom sheets, search view |

CSS shadow tokens: `--sgx-e1`, `--sgx-e2`, `--sgx-e3`.

### Motion
- Standard: 300 ms, `cubic-bezier(0.2, 0, 0, 1)`
- Enter: 250 ms, `cubic-bezier(0, 0, 0, 1)`
- Exit: 200 ms, `cubic-bezier(0.3, 0, 1, 1)`
- Balance refresh: 300 ms subtle value crossfade
- Progress refresh: 500 ms determinate animate

### Content Guidelines
- Currency: `Rs. X,XXX` · Phone: `0300-1234567` · Date: `DD MMM YYYY` · Time: `HH:mm`
- Tone: plain, respectful, direct
- Button labels: specific verbs (never "OK" or "Submit")
- Max primary actions per screen: **1**
- Avoid: `inventory`, `redemption`, `payload`, `signature`, `ledger debit`, `conversion rate`

---

## 8. Assets

- **`assets/sgx-app-icon.png`** — approved SGX Partners app icon (also authored as `sgx-app-icon.svg` in the customer module; treat that SVG as the master and generate Android/iOS launcher assets from it, respecting each platform's safe zone). Preserve white rounded-square background + navy SGX artwork. Do NOT recolor, crop, stretch, redraw, or add a wholesaler badge. **Not used in bottom navigation.**

- **Product/campaign imagery** — the HTML uses procedurally-drawn SVG placeholders (`<ImgSlot>`) in 8 variants (oil, spark, tire, filter, chain, battery, part, camp). Production must swap in real product photography and campaign artwork. Recommended: source photos through SGX marketing; store in Supabase Storage (`products/`, `campaigns/`). Serve sized variants; avoid over-fetching.

- **Fonts** — Roboto (Google Fonts) + Noto Nastaliq Urdu (Google Fonts). Bundle locally in Flutter (`pubspec.yaml → fonts:`). Material Symbols Rounded — use the `google_fonts` or `material_symbols_icons` package (or export a subset icon font of the ~40 used symbols).

- **WhatsApp SVG** in `withdrawal_detail.jsx` (Disputed screen) — replace with `flutter_svg` and the official brand mark for release.

---

## 9. Files in this bundle

Copy these into your source tree as reference — they are the ground truth for pixel-level decisions:

### Design references (HTML + React JSX prototypes)
- `SGX Wholesaler Screens.html` — pan/zoom canvas that mounts all 27 artboards
- `tokens.css` — every design token compiled to CSS variables (light + dark)
- `components.jsx` — shared UI kit (Phone shell, TopAppBar, IconBtn, FilledBtn/OutlinedBtn/TextBtn, TextField, StatusChip, SectionHeader, ImgSlot, Scroll, ProgressBar, `WholesalerBottomBar`, plus SgxIcon SVG recreation)
- `screens/auth.jsx` — Splash, Phone Login, OTP, 3 Account Unavailable variants
- `screens/home_qr.jsx` — Home (populated + empty), QR Progress (populated + empty)
- `screens/wallet.jsx` — Wallet, Withdraw Money form, Confirm bottom sheet, Withdrawals list
- `screens/withdrawal_detail.jsx` — all 6 lifecycle states (Pending · Payment Sent · Not-Received dialog · Disputed · Confirmed/Auto-confirmed · Refunded) + shared `_WdHeader` + `_Timeline`
- `screens/products_campaigns.jsx` — Products grid, Product Detail, Campaigns list, Campaign Detail
- `screens/profile.jsx` — Notifications, Profile, Language & Theme, Urdu/RTL Home sample
- `screens_index.jsx` — mounts all artboards into the DesignCanvas
- `design_canvas.jsx` + `android_frame.jsx` — supporting canvas + frame helpers (not needed in production; artboard chrome only)

### Source specifications (read first, then the mockups)
- `docs/prd.md` — Product requirements with **Locked Owner Decisions** (§2 — treat as constitution). Read before any implementation decision.
- `docs/architecture.md` — Flutter layered architecture, Riverpod ownership, Supabase boundaries, RLS + trusted operations, testing strategy.
- `docs/screen-flow.md` — Navigation map, route transition table, error/offline flow.
- `docs/screen-specs.md` — Screen-by-screen visual specs (WHL-00 → WHL-17).
- `docs/screen-stats.md` — Screen inventory, complexity, required state coverage, component inventory, risk register.
- `docs/design-token.json` — Full design-token schema (light + dark, status roles, typography, shape, spacing, sizing, elevation, motion, content guidelines, accessibility rules).

### Assets
- `assets/sgx-app-icon.png` — approved shared brand icon.

---

## 10. Implementation Sequence (suggested)

Follow the phased plan in `docs/architecture.md` §22:

**Phase 1 — Shared B2B foundation:** Flutter project, Material 3 SGX theme, Riverpod scope, localization + RTL, shared router + OTP auth + role guards, shared loading/empty/error/offline components.

**Phase 2 — Wholesaler mock experience:** Domain models + repo interfaces → mock data → build screens in this priority order (from `screen-stats.md` §7):
1. WHL-04 Home
2. WHL-05 QR Progress
3. WHL-06 Wallet
4. WHL-07 Withdraw Money
5. WHL-09 Withdrawal Detail (all states)
6. WHL-01/02 Auth
7. WHL-08 Withdrawals
8. WHL-10 Products
9. WHL-14 Notifications
10. Campaigns / Profile / Preferences
11. Reusable, dark, and Urdu variants

**Phase 3 — Supabase integration:** phone OTP + role resolution → wholesaler-safe profile read → aggregate QR projection + RLS → wallet ledger → trusted withdrawal operations + private proof access → products/campaigns/notifications → scoped Realtime.

**Phase 4 — Release hardening:** cross-role access tests, slow/offline network tests, withdrawal idempotency, Urdu/RTL + dark + 200% text tests, low-literacy usability test on QR Progress and Withdrawal confirmation, production signing.

---

## 11. Definition of Done (from architecture §23)

- One shared B2B app routes active wholesalers into the wholesaler shell.
- Wholesaler signup and role selection do not exist.
- Customer/staff profiles cannot access B2B role routes.
- Wholesaler shell has exactly five approved destinations.
- QR Progress is aggregate-only and has no detail route.
- Wallet and withdrawals contain no invoice redemption.
- Products are price-free and browse-only.
- Profile is read-only and contains no tax fields.
- All sensitive writes are trusted and server-authoritative.
- All screens implement loading / empty / error / offline / retry.
- English, Urdu/RTL, light, dark, accessibility, and large text are verified.

---

## 12. Companion — Mechanic Module

The mechanic module of this same shared Flutter app has been handed off separately. It uses the same brand, tokens, and component vocabulary but with a different bottom navigation (Home · Products · **Scan (FAB)** · Wallet · Profile) and includes camera-based QR scanning + 6 scan-result states. Make sure your `theme/`, `localization/`, `core/`, and `shared/` layers are engineered to serve **both** modules from one executable.
