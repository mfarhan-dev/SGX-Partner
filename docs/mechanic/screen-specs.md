# SGX Partners — Mechanic Screen Specifications

**Platform:** Flutter with Material Design 3  
**Navigation:** Four labeled bottom destinations plus raised center Scan action  
**Audience:** Independent mechanics, including self-registered users  
**Design priority:** Fast online scanning and low-literacy-friendly interaction

---

## 1. Screen Index and Routes

| ID | Screen | Type | Route |
|---|---|---|---|
| MEC-00 | Splash | System | `/splash` |
| MEC-01 | Phone Login | Authentication | `/auth/phone` |
| MEC-02 | OTP Verification | Authentication | `/auth/otp` |
| MEC-03 | Account Unavailable | Authentication state | `/auth/account-unavailable` |
| MEC-04 | Complete Mechanic Profile | Onboarding | `/mechanic/onboarding` |
| MEC-05 | Home | Main destination | `/mechanic/home` |
| MEC-06 | QR Scanner | Center action | `/mechanic/scan` |
| MEC-07 | Scan Result | Scanner state/overlay | Not a standalone route |
| MEC-08 | Scan History | List | `/mechanic/scans` |
| MEC-09 | Wallet | Main destination | `/mechanic/wallet` |
| MEC-10 | Withdraw Money | Form | `/mechanic/withdrawals/new` |
| MEC-11 | Withdrawals | List | `/mechanic/withdrawals` |
| MEC-12 | Withdrawal Detail | Detail/state | `/mechanic/withdrawals/:withdrawalId` |
| MEC-13 | Products | Main destination | `/products` |
| MEC-14 | Product Detail | Detail | `/products/:productId` |
| MEC-15 | Campaigns | List | `/campaigns` |
| MEC-16 | Campaign Detail | Detail | `/campaigns/:campaignId` |
| MEC-17 | Notifications | List | `/notifications` |
| MEC-18 | Profile | Main destination | `/profile` |
| MEC-19 | Edit Profile | Form | `/profile/edit` |
| MEC-20 | Language and Theme | Settings | `/profile/preferences` |
| MEC-21 | Reusable States | System components | Not navigable |

There are 20 navigable screens, one scan-result state family, and one reusable-state family.

## 2. Global Screen Rules

- Use `useMaterial3: true` and `design-token.json`.
- Use the shared name `SGX Partners` and approved icon [`../../customer/sgx-app-icon.svg`](../../customer/sgx-app-icon.svg) on both role experiences.
- Use the approved order: Home, Products, raised center Scan, Wallet, Profile.
- The Scan action is larger than destination icons and has a visible semantic label.
- Use a small `AppBar` on main destinations and a back arrow on pushed screens.
- Minimum normal touch target is 48 dp; center Scan is at least 64 dp.
- Use one primary action per task.
- Pair unfamiliar icons with text.
- Avoid hidden gestures, technical copy, and dense tables.
- Use icon + label + color for status.
- Support 360x800, 390x844, and 430x932.
- Support 200 percent text scaling and Urdu RTL.
- Scanning and all writes are online-only.
- Never show offline queue, pending scan sync, tax fields, prices, invoice redemption, or assigned wholesaler.

### Brand Placement Contract

| Surface | Icon size | Placement and copy |
|---|---:|---|
| Platform launcher | Platform-generated | Generate Android/iOS launcher assets from the full SVG; preserve its safe area and colors. |
| Splash | 112 dp | Centered icon with `SGX Partners` immediately below. |
| Phone Login | 72 dp | Centered above `Login to SGX Partners`. |
| OTP Verification | 48 dp | Centered above `Verify your number`. |
| Complete Mechanic Profile | 48 dp | At the top of the onboarding identity block. |
| Home app bar | 32 dp | Leading icon followed by `SGX Partners`; Notifications remains trailing. |

The SVG is the approved artwork and must not be tinted, recolored, cropped, stretched, or redrawn. Do not use it in bottom navigation or as the Scan symbol.

## 3. Approved Bottom Navigation

Use a Material 3 `BottomAppBar` with a centered notch or equivalent safe spacing for a raised scan action.

| Position | Item | Icon | Destination |
|---:|---|---|---|
| 1 | Home | `home` | MEC-05 |
| 2 | Products | `category` | MEC-13 |
| 3 | Scan | `qr_code_scanner` | MEC-06 |
| 4 | Wallet | `account_balance_wallet` | MEC-09 |
| 5 | Profile | `person` | MEC-18 |

### Center Scan Action

- Circular primary-colored container.
- Raised above the bar, modeled on the approved reference.
- Scan icon centered with high contrast.
- Semantic label: `Scan QR`.
- Minimum 64 dp visual and touch size.
- Selected destination styling applies to the four content destinations; Scan does not remain selected.
- Respect safe-area/home-indicator insets.

## 4. MEC-00 Splash

### Purpose

Initialize the shared B2B app and route by session, role, profile completeness, and status.

### Layout

- Full-screen SGX branded surface.
- Centered 112 dp `sgx-app-icon.svg`.
- App name `SGX Partners` below the icon.
- Loading indicator after one second.

### Outcomes

- No session -> MEC-01.
- Active complete mechanic -> MEC-05.
- Active incomplete mechanic -> MEC-04.
- Active wholesaler -> wholesaler Home.
- Inactive/wrong-role -> MEC-03.

### States

- Loading.
- Initialization error with Retry.
- Offline with Retry.

## 5. MEC-01 Phone Login

### Purpose

Start phone-plus-OTP authentication for new or existing B2B users.

### Content

- Centered 72 dp `sgx-app-icon.svg`.
- Title: `Login to SGX Partners`.
- Supporting text: `Enter your mobile number to continue.`
- Phone input.
- Primary button: `Send OTP`.
- Language shortcut.

### Validation

- `Phone number is required.`
- `Enter a valid phone number.`
- `Could not send OTP. Please try again.`

### Behavior

- Accept Pakistani format `03XXXXXXXXX`.
- Do not ask for role.
- Do not reveal whether the phone exists before OTP verification.

## 6. MEC-02 OTP Verification

### Content

- Centered 48 dp `sgx-app-icon.svg`.
- Title: `Verify your number`.
- Masked phone number.
- Six-digit OTP input.
- `Verify` primary button.
- `Resend code` countdown.
- `Change number` action.

### Validation

- `OTP is required.`
- `Invalid OTP. Please try again.`
- `Too many attempts. Please wait and try again.`

### Routing

- Existing mechanic -> MEC-05 or MEC-04 if incomplete.
- Unknown phone -> MEC-04.
- Active wholesaler -> wholesaler Home.
- Inactive mechanic/wholesaler -> MEC-03.
- Customer/staff -> MEC-03.

## 7. MEC-03 Account Unavailable

### Inactive B2B Account

- Icon: `person_off`.
- Title: `Account inactive`.
- Message: `Your account is inactive. Please contact SGX.`
- Primary: `Contact SGX`.
- Secondary: `Use another number`.

### Customer or Staff Account

- Icon: `lock`.
- Title: `B2B access unavailable`.
- Message: `This account cannot access the B2B app.`
- Primary: `Use another number`.

Do not expose role enum values or database errors.

## 8. MEC-04 Complete Mechanic Profile

### Purpose

Collect the minimum identity needed after a new phone is verified.

### Content

- 48 dp `sgx-app-icon.svg` at the top of the identity block.
- Title: `Complete your profile`.
- Verified phone card with check icon; read-only.
- Full Name input — required.
- Workshop/Shop Name input — optional.
- Area/City selector — required.
- Primary button: `Continue`.

### Validation

- `Full name is required.`
- `Select your area or city.`
- `Could not create your profile. Please try again.`

### Rules

- No role selector.
- No wholesaler selector.
- No GST, NTN, CNIC, or tax field.
- Backend assigns `role = mechanic` only after verified OTP.

## 9. MEC-05 Home

### Purpose

Make scanning, balance, and current activity immediately understandable.

### Top App Bar

- Leading 32 dp `sgx-app-icon.svg` followed by title `SGX Partners`.
- Notification icon with unread badge.

### Sections

1. Greeting with mechanic name.
2. Wallet hero card:
   - Available Balance, largest value.
   - Pending Withdrawal.
   - Lifetime Earned.
   - `Withdraw Money` action.
3. Large `Scan QR` action card in content in addition to center navigation action.
4. Latest confirmed scan card with reward amount.
5. Total confirmed scans summary.
6. Active withdrawal card when applicable.
7. Active campaign banner.
8. Quick actions: Scan History, Products, Wallet, Campaigns.

### Empty Variants

- No scans: `Scan your first SGX QR to earn a reward.`
- No wallet activity: Available remains `Rs. 0`.
- No withdrawal/campaign: hide those sections.

## 10. MEC-06 QR Scanner

### Purpose

Capture one QR and receive an authoritative online result.

### Entry Checks

1. Check authenticated active mechanic state.
2. Check internet connection.
3. Request camera permission if needed.
4. Open camera preview only when ready.

### Camera Layout

- Full-screen or near-full-screen dark camera surface.
- Back/close action.
- Title/semantic instruction: `Scan SGX QR`.
- Large centered scan frame.
- Short instruction: `Place the QR inside the frame.`
- Torch toggle when device supports it.
- No gallery/upload action in v1.

### Detection Behavior

- Accept first supported QR detected inside frame.
- Pause camera immediately after detection.
- Show blocking processing state: `Checking QR...`.
- Send payload once with an idempotency identifier.
- Ignore repeated camera frames while request is active.

### Offline State

- Do not open an active scan request.
- Message: `Internet is required to scan a QR. Please reconnect and try again.`
- Actions: `Try Again`, `Close`.
- Never store or queue the payload.

### Camera Permission States

- First request: explain why camera is needed.
- Denied: `Camera permission is required to scan a QR.`
- Permanently denied: `Open Settings` action.

## 11. MEC-07 Scan Result

Render as a full-screen result surface or large modal overlay above the paused scanner. It is not a route in the persistent navigation shell.

### Success

- Large success icon.
- Title: `Reward added!`.
- Reward amount, largest text: `Rs. X`.
- Supporting text: `Added to your wallet.`
- Product name and optional image.
- Primary: `Scan Another`.
- Secondary: `Open Wallet`.

### Already Scanned

- Warning/error icon.
- Title: `Already scanned`.
- Message: `This QR has already been scanned.`
- Primary: `Scan Another`.

### Not Active

- Title: `QR not active`.
- Message: `This QR is not active yet.`
- Primary: `Scan Another`.

### Invalid

- Title: `Invalid QR`.
- Message: `This is not a valid SGX QR.`
- Primary: `Scan Another`.

### Expired

- Title: `QR expired`.
- Message: `This QR has expired.`
- Primary: `Scan Another`.

### Network/Server Failure

- Title: `Could not check QR`.
- Message: `Check your internet connection and try again.`
- Primary: `Try Again` using the still-in-memory payload during the open screen only.
- Secondary: `Close`.
- Closing discards the payload; it is never queued.

## 12. MEC-08 Scan History

### Purpose

Show confirmed mechanic rewards from successful server scans.

### Content

- Summary: Total Scans and Total Earned from scans.
- Confirmed scan rows ordered newest first.

### Scan Row

- Product image/icon.
- Product name.
- Date and time.
- Reward amount with positive sign.
- `Confirmed` success label.
- Optional wholesaler/shop name as supporting context.

### Restrictions

- No Pending, Offline, Syncing, or Rejected offline rows.
- No raw QR ID or signature.
- No admin fraud/rate-limit flag.
- No invoice price or profit.

### States

- Loading skeleton.
- Empty: `No scans yet` / `Your successful SGX QR scans will appear here.`
- Error with Retry.
- Offline with Retry.

## 13. MEC-09 Wallet

### Purpose

Show balances, recent money movement, and withdrawal entry points.

### Balance Card

- Available Balance.
- Pending Withdrawal.
- Lifetime Earned.
- Primary button: `Withdraw Money`.
- Minimum-withdrawal helper when disabled.

### Transaction List

- `QR reward added` / positive amount.
- `Withdrawal requested`.
- `Payment sent`.
- `Withdrawal confirmed`.
- `Withdrawal disputed`.
- `Withdrawal auto-confirmed`.
- `Money returned to wallet` / positive refund.

No invoice redemption entry.

### Secondary Action

- `View Withdrawals` -> MEC-11.

## 14. MEC-10 Withdraw Money

### Content

- Available Balance.
- Minimum withdrawal helper.
- Amount input with `Rs.` prefix.
- Optional quick chips: `Rs. 500`, `Rs. 1,000`, `All`.
- Payment method cards:
  - EasyPaisa.
  - JazzCash.
  - Bank Transfer.
  - Cash from SGX.
- Conditional destination fields.
- Processing-time notice.
- Primary button: `Continue`.

### Method Fields

- EasyPaisa/JazzCash: account title and mobile number.
- Bank: bank name, account title, account/IBAN.
- Cash: no account fields; show collection instructions.

### Validation

- `Enter a withdrawal amount.`
- `Minimum withdrawal is Rs. [X].`
- `Amount cannot exceed your available balance.`
- `Select a payment method.`
- `Account title is required.`
- `Enter a valid mobile number.`
- `Bank name is required.`
- `Account number or IBAN is required.`
- `Could not submit withdrawal. Please try again.`

### Confirmation Bottom Sheet

- Amount.
- Method.
- Masked destination or Cash from SGX.
- Processing time.
- Cancel and `Confirm Withdrawal`.

Submission requires internet and is never queued.

## 15. MEC-11 Withdrawals

### Content

- Optional filter chips: All, Open, Completed.
- Withdrawal cards.

### Card

- Amount.
- Submitted date.
- Method.
- Status icon and text.
- Short next-step message.

### Statuses

- Pending.
- Payment Sent.
- Confirmed.
- Disputed.
- Auto-confirmed.
- Refunded.

### Empty State

- `No withdrawals yet`.
- `Your withdrawal requests will appear here.`
- Action: `Open Wallet`.

## 16. MEC-12 Withdrawal Detail

### Common Content

- Amount.
- Status.
- Payment method.
- Masked destination.
- Submitted date.
- Processing-time message.
- Simple timeline.

### Pending

- `SGX is processing your withdrawal.`

### Payment Sent

- Payment date.
- Reference/proof when available.
- Question: `Did you receive this payment?`
- Primary: `Received`.
- Secondary: `Not Received`.

### Received Dialog

- `Confirm payment received?`
- `Confirm that you received Rs. [X].`
- Cancel and `Confirm Received`.

### Not Received Dialog

- `Payment not received?`
- `This will report a payment problem to SGX.`
- Cancel and `Report Problem`.

### Disputed

- Warning container.
- `SGX is reviewing this payment problem.`
- `Contact SGX on WhatsApp`.

### Confirmed / Auto-confirmed

- Success/closed state and date.
- Auto-confirmed includes a short explanation.

### Refunded

- `Rs. [X] was returned to your available balance.`
- `Open Wallet` action.

## 17. MEC-13 Products

### Content

- Search bar.
- Category chips.
- Optional brand filter.
- Product cards.

### Product Card

- Image.
- Product name.
- Brand/category.

No price, stock, Add, Cart, or Order action.

### States

- Loading.
- Populated.
- Empty/filtered empty.
- Error.
- Offline.

## 18. MEC-14 Product Detail

### Content

- Product image.
- Product name.
- Brand.
- Category.
- Optional product code.
- Short description.

No prices, stock quantity, purchase action, or scheme configuration.

## 19. MEC-15 Campaigns

### Campaign Card

- Image.
- Title.
- Short description.
- Date window.
- Whole-card tap or `View Campaign`.

### Empty State

- `No campaigns right now`.
- `New SGX offers will appear here.`

## 20. MEC-16 Campaign Detail

### Content

- Campaign hero image.
- Title.
- Date window.
- Description.
- Prize/reward note.
- Simple participation instructions.

No mechanic progress bar or qualified-user calculation.

## 21. MEC-17 Notifications

### Row

- Type icon.
- Short title.
- One-line text.
- Timestamp.
- Unread indicator.

### Types and Destinations

| Type | Example | Destination |
|---|---|---|
| Reward | `Rs. 3 added to your wallet.` | MEC-09 Wallet or MEC-08 History |
| Withdrawal submitted | `Your withdrawal request was submitted.` | MEC-12 Detail |
| Payment sent | `Your payment has been sent.` | MEC-12 Detail |
| Confirmed | `Your withdrawal was confirmed.` | MEC-12 Detail |
| Disputed | `SGX is reviewing your payment problem.` | MEC-12 Detail |
| Auto-confirmed | `Your withdrawal was closed automatically.` | MEC-12 Detail |
| Refunded | `Money was returned to your wallet.` | MEC-09 Wallet |
| Campaign | `A new SGX campaign has started.` | MEC-16 Campaign Detail |

There are no offline-scan notifications.

## 22. MEC-18 Profile

### Identity

- Full name.
- Workshop/shop name when present.
- Verified phone.
- Area/city.
- Active status.

### Actions

- Edit Profile -> MEC-19.
- Language and Theme -> MEC-20.
- Contact SGX.
- Help.
- Logout.

No role, wholesaler assignment, GST, NTN, or tax controls.

## 23. MEC-19 Edit Profile

### Editable

- Full Name — required.
- Workshop/Shop Name — optional.
- Area/City — required.

### Read-only

- Verified Phone.
- Role.

### Validation

- `Full name is required.`
- `Select your area or city.`
- `Could not save changes. Please try again.`

### Actions

- `Save Changes`.
- Cancel with discard confirmation when dirty.

## 24. MEC-20 Language and Theme

### Language

- English.
- Urdu.

### Theme

- System default.
- Light.
- Dark.

Show enough Urdu preview copy to verify wrapping and RTL.

## 25. MEC-21 Reusable States

### Loading

- Home/wallet skeleton.
- Scan processing indicator.
- Scan history skeleton.
- Product/campaign/notification cards.
- Withdrawal cards.

### Empty

- Recognizable icon.
- Specific title.
- One short explanation.
- At most one action.

### Error

- `Something went wrong`.
- Plain-language message.
- `Try Again`.

### Offline

```text
No internet connection. Please reconnect and try again.
```

Scanner uses the more specific message from MEC-06. No mechanic write is queued offline.
