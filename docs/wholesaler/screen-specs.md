# SGX Partners — Wholesaler Screen Specifications

**Platform:** Flutter with Material Design 3  
**Navigation:** Five-destination bottom navigation plus pushed screens  
**Audience:** Admin-provisioned wholesalers  
**Design priority:** Simple, recognizable, low-literacy-friendly interaction

---

## 1. Screen Index and Routes

| ID | Screen | Type | Route |
|---|---|---|---|
| WHL-00 | Splash | System | `/splash` |
| WHL-01 | Phone Login | Authentication | `/auth/phone` |
| WHL-02 | OTP Verification | Authentication | `/auth/otp` |
| WHL-03 | Account Unavailable | Authentication state | `/auth/account-unavailable` |
| WHL-04 | Home | Main tab | `/wholesaler/home` |
| WHL-05 | QR Progress | Main tab | `/wholesaler/qr-progress` |
| WHL-06 | Wallet | Main tab | `/wholesaler/wallet` |
| WHL-07 | Withdraw Money | Form | `/wholesaler/withdrawals/new` |
| WHL-08 | Withdrawals | List | `/wholesaler/withdrawals` |
| WHL-09 | Withdrawal Detail | Detail/state | `/wholesaler/withdrawals/:withdrawalId` |
| WHL-10 | Products | Main tab | `/products` |
| WHL-11 | Product Detail | Detail | `/products/:productId` |
| WHL-12 | Campaigns | List | `/campaigns` |
| WHL-13 | Campaign Detail | Detail | `/campaigns/:campaignId` |
| WHL-14 | Notifications | List | `/notifications` |
| WHL-15 | Profile | Main tab | `/profile` |
| WHL-16 | Language and Theme | Settings | `/profile/preferences` |
| WHL-17 | Reusable States | System components | Not navigable |

There are 17 navigable screens and one reusable-state family.

## 2. Global Screen Rules

- Use the shared SGX tokens in `design-token.json` and `useMaterial3: true`.
- Use the shared name `SGX Partners` and approved icon [`../../customer/sgx-app-icon.svg`](../../customer/sgx-app-icon.svg) on both role experiences.
- Use `NavigationBar` on Home, QR Progress, Wallet, Products, and Profile.
- Use a small `AppBar` on main tabs and a back arrow on pushed screens.
- Minimum touch target is 48 dp.
- Prefer one primary action per screen.
- Pair every important icon with a text label.
- Avoid hidden swipe-only actions.
- Use plain language and short sentences.
- Use icon + text + semantic color for every status.
- Support 360x800, 390x844, and 430x932 phone layouts.
- Support large text up to 200 percent and future Urdu RTL.
- Use tonal surface containers before shadows for hierarchy.
- Never show scanner, QR payload, invoice inventory, product prices, profit, or invoice redemption.

### Brand Placement Contract

| Surface | Icon size | Placement and copy |
|---|---:|---|
| Platform launcher | Platform-generated | Generate Android/iOS launcher assets from the full SVG; preserve its safe area and colors. |
| Splash | 112 dp | Centered icon with `SGX Partners` immediately below. |
| Phone Login | 72 dp | Centered above `Login to SGX Partners`. |
| OTP Verification | 48 dp | Centered above `Verify your number`. |
| Home app bar | 32 dp | Leading icon followed by `SGX Partners`; Notifications remains trailing. |

The SVG is the approved artwork and must not be tinted, recolored, cropped, stretched, or redrawn. Do not use it in bottom navigation.

## 3. Shared Navigation Shell

### Bottom Navigation

| Destination | Icon | Route |
|---|---|---|
| Home | `home` | `/wholesaler/home` |
| QR Progress | `qr_code_2` | `/wholesaler/qr-progress` |
| Wallet | `account_balance_wallet` | `/wholesaler/wallet` |
| Products | `category` | `/products` |
| Profile | `person` | `/profile` |

Always show labels. Wallet may show a small indicator when a payment needs confirmation. Do not put Campaigns in the bottom bar.

### Top App Bar

- Main tabs: screen title plus Notifications action.
- Home uses the 32 dp approved icon followed by `SGX Partners`; the shop name remains in the greeting/content area.
- Pushed screens: back arrow, short title, no unnecessary actions.

## 4. WHL-00 Splash

### Purpose

Initialize the app, restore session, and route by protected role and active status.

### Layout

- Full-screen SGX branded surface.
- Centered 112 dp `sgx-app-icon.svg`.
- App name `SGX Partners` below the icon.
- Loading indicator only when initialization exceeds one second.

### Outcomes

- No/expired session -> WHL-01.
- Active wholesaler -> WHL-04.
- Inactive or wrong-role session -> WHL-03.

### States

- Loading.
- Initialization error with Retry.
- Offline with Retry.

## 5. WHL-01 Phone Login

### Purpose

Start phone-plus-OTP authentication for the shared B2B app.

### Content

- Centered 72 dp `sgx-app-icon.svg`.
- Title: `Login to SGX Partners`.
- Supporting text: `Enter your registered mobile number.`
- Phone input.
- Primary button: `Send OTP`.
- Language shortcut.
- Help text: `Wholesaler accounts are created by SGX staff.`

### Input

- Pakistani mobile number in `03XXXXXXXXX` format.

### Validation Copy

- `Phone number is required.`
- `Enter a valid phone number.`
- `Could not send OTP. Please try again.`

### Important Behavior

Do not show a role selector. Do not reveal the profile role before OTP verification. An unknown number proceeds through the shared flow and becomes mechanic onboarding outside this module.

## 6. WHL-02 OTP Verification

### Purpose

Verify ownership of the entered phone number.

### Content

- Centered 48 dp `sgx-app-icon.svg`.
- Title: `Verify your number`.
- Masked phone number.
- Six-digit OTP input.
- Primary button: `Verify`.
- `Resend code` with countdown.
- `Change number` action.

### Validation Copy

- `OTP is required.`
- `Invalid OTP. Please try again.`
- `Too many attempts. Please wait and try again.`

### Success Routing

- Active wholesaler -> WHL-04.
- Existing mechanic -> mechanic Home.
- Existing customer/staff -> WHL-03 wrong-role state.
- Inactive wholesaler -> WHL-03 inactive state.
- Unknown phone -> mechanic onboarding outside this module.

## 7. WHL-03 Account Unavailable

### Purpose

Explain why the verified account cannot enter the wholesaler experience.

### Variants

#### Inactive Wholesaler

- Icon: `person_off`.
- Title: `Account inactive`.
- Message: `Your account is inactive. Please contact SGX.`
- Primary action: `Contact SGX`.
- Secondary action: `Use another number`.

#### Customer or Staff Profile

- Icon: `lock`.
- Title: `B2B access unavailable`.
- Message: `This account cannot access the B2B app.`
- Primary action: `Use another number`.

#### Missing/Deleted Account After Session Restore

- Icon: `person_search`.
- Title: `Account unavailable`.
- Message: `We could not find an active account for this number.`
- Primary action: `Back to Login`.

Do not show technical role names, database errors, or identifiers.

## 8. WHL-04 Home

### Purpose

Give the wholesaler an immediate understanding of money, QR progress, and pending actions.

### Top App Bar

- Leading 32 dp `sgx-app-icon.svg` followed by title `SGX Partners`.
- Notifications icon with unread badge.

### Sections

1. Greeting: `Assalam-o-Alaikum, [Owner Name]` with shop name below.
2. Wallet hero card:
   - Available Balance as the largest value.
   - `Withdraw Money` filled button.
   - Pending and Lifetime values as supporting rows.
3. QR Progress summary card:
   - Scanned count.
   - Remaining count.
   - Determinate progress bar.
   - `View QR Progress` action.
4. Latest reward card, only when reward activity exists.
5. Active withdrawal card, only when an open/paid/disputed request exists.
6. Campaign banner carousel or single active banner.
7. Quick actions: Products, Wallet, QR Progress, Campaigns.

### Empty Variants

- No rewards: show `Rewards will appear when mechanics scan your SGX product QRs.`
- No active withdrawal: hide the withdrawal card.
- No campaigns: hide campaign section.
- No QR groups: show a compact QR empty-state card with contact SGX guidance.

### Simplicity Rule

Do not place more than three monetary values in the hero card or introduce charts.

## 9. WHL-05 QR Progress

### Purpose

Show aggregate scanned-versus-remaining reward QR progress in one simple screen.

### Top App Bar

- Title: `QR Progress`.
- Notifications action.

### Summary

- Total QRs.
- Scanned.
- Remaining.
- One overall determinate progress indicator.

### QR Progress Card

- Product thumbnail.
- Product name.
- Optional short reference such as `INV-0058`; hide if owner rejects references.
- Text: `[X] scanned`.
- Text: `[Y] remaining`.
- Determinate progress bar.
- Reward line: `Earned: Rs. X`.
- Status chip: `Active` or `Complete`.

### Interaction

- Cards are not tappable.
- No chevron, View Details, QR list, or detail route.
- Pull-to-refresh is allowed.

### States

- Loading skeleton cards.
- Empty: `No QR progress yet` / `Your SGX reward QR progress will appear here.`
- Error with Retry.
- Offline with Retry.

### Data Restrictions

Never show mechanic names, individual QR IDs, scan timestamps, invoice totals, inventory quantity, stock, prices, or profit.

## 10. WHL-06 Wallet

### Purpose

Show balances, recent money movement, and the entry point to withdrawals.

### Top Balance Card

- Available Balance, largest value.
- Pending Withdrawal.
- Lifetime Earned.
- Primary button: `Withdraw Money`.
- Disabled state with minimum-withdrawal helper when balance is too low.

### Transaction History

Use one continuous list below the balance card; do not require a separate wallet-history screen.

Each row contains:

- Recognizable status icon.
- Plain-language title.
- Date.
- Amount aligned at the end.
- Status label when relevant.

Examples:

- `QR reward added` / `+ Rs. 2`.
- `Withdrawal requested` / `Rs. 500`.
- `Payment sent` / `Waiting for confirmation`.
- `Withdrawal confirmed`.
- `Withdrawal disputed`.
- `Money returned to wallet` / `+ Rs. 500`.

No invoice-redemption row exists.

### Secondary Action

- `View Withdrawals` -> WHL-08.

### States

- Loading.
- Empty: `No wallet activity yet`.
- Error.
- Offline.

## 11. WHL-07 Withdraw Money

### Purpose

Submit a withdrawal with the least possible form complexity.

### Content

- Available Balance summary.
- Minimum withdrawal helper.
- Amount input with `Rs.` prefix.
- Quick amount chips when useful: `Rs. 500`, `Rs. 1,000`, `All`.
- Payment-method cards with icon and label:
  - EasyPaisa.
  - JazzCash.
  - Bank Transfer.
  - Cash from SGX.
- Conditional destination fields.
- Processing-time notice from Settings.
- Primary button: `Continue`.

### Conditional Fields

#### EasyPaisa / JazzCash

- Account title.
- Mobile number.

#### Bank Transfer

- Bank name.
- Account title.
- Account number or IBAN.

#### Cash from SGX

- No account input.
- Show collection instructions.

### Validation Copy

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

Show:

- Amount.
- Method.
- Masked destination or `Cash from SGX`.
- Processing-time promise.
- `Cancel` and `Confirm Withdrawal` actions.

On success, navigate to WHL-09.

## 12. WHL-08 Withdrawals

### Purpose

Show all withdrawal requests and their current status.

### Content

- Optional simple filter chips: All, Open, Completed.
- Withdrawal cards.

### Withdrawal Card

- Amount.
- Submitted date.
- Payment method.
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

- Title: `No withdrawals yet`.
- Supporting text: `Your withdrawal requests will appear here.`
- Action: `Open Wallet`.

### Exit

- Tap card -> WHL-09.

## 13. WHL-09 Withdrawal Detail

### Purpose

Show one withdrawal’s status and the next action, including payment confirmation and disputes.

### Common Content

- Amount as prominent value.
- Status icon and text.
- Payment method.
- Masked destination.
- Submitted date.
- Processing-time message.
- Simple vertical timeline.

### Pending State

- Message: `SGX is processing your withdrawal.`
- No destructive or duplicate-submit action.

### Payment Sent State

- Payment date.
- Reference number when available.
- Payment proof preview/link when applicable.
- Question: `Did you receive this payment?`
- Primary action: `Received`.
- Secondary/destructive action: `Not Received`.

### Received Confirmation Dialog

- Title: `Confirm payment received?`
- Body: `Confirm that you received Rs. [X].`
- Actions: Cancel, Confirm Received.

### Not Received Dialog

- Title: `Payment not received?`
- Body: `This will report a payment problem to SGX.`
- Actions: Cancel, Report Problem.

### Disputed State

- Clear warning container.
- Message: `SGX is reviewing this payment problem.`
- `Contact SGX on WhatsApp` action.
- Pending amount remains locked.

### Confirmed / Auto-confirmed State

- Success state.
- Closed date.
- For auto-confirmed: explain `This payment was closed automatically after the confirmation period.`

### Refunded State

- Message: `Rs. [X] was returned to your available balance.`
- Action: `Open Wallet`.

## 14. WHL-10 Products

### Purpose

Browse the shared price-free B2B product catalog.

### Content

- Search bar.
- Category chips.
- Optional brand filter.
- Product grid or comfortable one-column list at large text sizes.

### Product Card

- Image.
- Product name.
- Brand/category.

No price, stock, Add, Cart, or Order action.

### States

- Loading skeletons.
- Empty catalog.
- Filtered empty.
- Error.
- Offline.

### Exit

- Product tap -> WHL-11.

## 15. WHL-11 Product Detail

### Purpose

Show simple read-only product information.

### Content

- Product image.
- Product name.
- Brand.
- Category.
- Optional product code.
- Short description.

No fixed bottom purchase action. No prices, stock quantity, cart, order, or reward-scheme configuration.

## 16. WHL-12 Campaigns

### Purpose

List active campaigns targeting wholesalers.

### Campaign Card

- Campaign image.
- Title.
- Short description.
- Date window.
- `View Campaign` action or whole-card tap.

### Empty State

- Title: `No campaigns right now`.
- Supporting text: `New SGX offers will appear here.`

### Exit

- Select campaign -> WHL-13.

## 17. WHL-13 Campaign Detail

### Purpose

Explain one active campaign in simple language.

### Content

- Campaign image hero.
- Title.
- Date window.
- Description.
- Prize/reward note.
- Simple participation instructions.

Do not show campaign progress, qualified-user calculations, or automatic-prize promises.

## 18. WHL-14 Notifications

### Purpose

Show reward, withdrawal, and campaign updates.

### Notification Row

- Type icon.
- Short title.
- One-line supporting text.
- Timestamp.
- Unread indicator.

### Types and Destinations

| Type | Example | Destination |
|---|---|---|
| QR reward | `Rs. 2 added to your wallet.` | WHL-06 Wallet |
| Withdrawal submitted | `Your withdrawal request was submitted.` | WHL-09 Detail |
| Payment sent | `Your payment has been sent.` | WHL-09 Detail |
| Confirmed | `Your withdrawal was confirmed.` | WHL-09 Detail |
| Disputed | `SGX is reviewing your payment problem.` | WHL-09 Detail |
| Auto-confirmed | `Your withdrawal was closed automatically.` | WHL-09 Detail |
| Refunded | `Money was returned to your wallet.` | WHL-06 Wallet |
| Campaign | `A new SGX campaign has started.` | WHL-13 Campaign Detail |

There is no QR Progress Detail destination.

### Empty State

- Title: `No notifications`.
- Supporting text: `Rewards, payments, and campaigns will appear here.`

## 19. WHL-15 Profile

### Purpose

Show read-only business identity and app-level settings.

### Identity Card

- Owner name.
- Shop name.
- Verified phone.
- Area/city.
- Address when present.
- Active status.

### Menu

- Language and Theme -> WHL-16.
- Contact SGX.
- Help.
- Logout.

### Rules

- No Edit Profile action.
- No GST, NTN, tax, wallet redemption, or QR scanner entry.
- Explain: `Contact SGX to update your business information.`

## 20. WHL-16 Language and Theme

### Purpose

Change presentation preferences without changing business data.

### Language

- English.
- Urdu.

### Theme

- System default.
- Light.
- Dark.

Preferences may apply immediately. Include enough Urdu preview text to catch wrapping and direction problems.

## 21. WHL-17 Reusable States

### Loading

- Wallet skeleton.
- QR Progress card skeleton.
- Product grid skeleton.
- Campaign card skeleton.
- Withdrawal card skeleton.

### Empty

- Recognizable icon.
- Specific title.
- One short explanation.
- At most one action.

### Error

- Title: `Something went wrong`.
- Plain-language message.
- `Try Again` action.

### Offline

```text
No internet connection. Please reconnect and try again.
```

No wholesaler action is queued offline.
