# SGX Partners — Mechanic Module PRD

**Application name:** SGX Partners  
**Module:** Mechanic role experience  
**Platform:** Flutter, Android first, iOS-compatible  
**Design system:** Material Design 3  
**Approved app icon:** `../../customer/sgx-app-icon.svg`  
**Status:** Approved product/design baseline  
**Last updated:** 22 July 2026

---

## 1. Product Summary

SGX Partners is one Flutter application with separate mechanic and wholesaler experiences. This document defines only the mechanic experience.

Mechanics may self-register with a phone number and SMS OTP. If the verified number has no existing profile, the app creates a mechanic onboarding flow automatically without asking the user to select a role. Existing mechanics and wholesalers are routed to their correct role interfaces. Existing customer or staff profiles cannot enter the B2B app.

The mechanic’s primary task is scanning SGX reward QRs online. A successful server-validated scan credits the mechanic reward to the mechanic wallet and the wholesaler reward to the wholesaler associated with the QR’s dispatched invoice. Mechanics are independent: they are not assigned to one wholesaler at registration.

## 2. Locked Owner Decisions

These decisions override conflicting or outdated statements in older project documents:

1. This is one B2B app with role-aware mechanic and wholesaler interfaces.
2. Mechanics may self-register using phone plus OTP.
3. An unknown verified phone enters mechanic onboarding automatically.
4. There is no role-selection screen.
5. Mechanics are independent and do not select a wholesaler during registration.
6. The QR’s dispatched invoice determines which wholesaler receives the wholesaler reward.
7. Mechanic QR scanning is online-only.
8. There is no offline scan, pending sync, cached reward, or offline queue.
9. Main navigation order is Home, Products, center Scan, Wallet, Profile.
10. Scan is a raised center action modeled on the approved navigation reference.
11. Products are browse-only and price-free.
12. Wallet money leaves through withdrawals; invoice redemption is not part of this module.
13. Campaigns are visible, but user-facing campaign progress is not shown in v1.
14. Mechanic onboarding has no GST, NTN, or tax-number field.
15. The customer app's existing `sgx-app-icon.svg` is the single approved SGX Partners icon for both roles; no mechanic-specific variant is created.

## 3. Brand Identity and Icon Usage

The approved master asset is [`../../customer/sgx-app-icon.svg`](../../customer/sgx-app-icon.svg). UI designers and developers must reuse it unchanged: preserve its white rounded-square background, navy SGX artwork, aspect ratio, and internal clear space. Do not recolor, crop, stretch, redraw, or add a mechanic/wholesaler badge.

| Placement | Required treatment |
|---|---|
| Android/iOS launcher | Use the SVG as the master source when producing platform launcher assets. Keep the complete rounded-square artwork inside each platform safe zone. |
| Splash | Center a 112 dp icon, then show `SGX Partners` below it using the screen-title style. |
| Phone Login | Center a 72 dp icon above `Login to SGX Partners`. |
| OTP Verification | Center a compact 48 dp icon above `Verify your number`. |
| Mechanic onboarding | Show a 48 dp icon beside or above the onboarding title to preserve app identity. |
| Home app bar | Show a 32 dp icon immediately before the `SGX Partners` title; keep Notifications on the trailing side. |

Do not place the brand icon in the bottom navigation or inside the raised Scan action. Those positions keep their functional icons so low-literacy users can recognize actions quickly.

## 4. Goals

1. Make the scan action immediately recognizable and reachable.
2. Give a clear, trustworthy result after every online scan.
3. Make wallet balances and withdrawals understandable for low-literacy users.
4. Let mechanics browse SGX products and promotions without exposing trade prices.
5. Support English and Urdu with RTL-ready layouts.
6. Preserve shared visual and technical foundations with the wholesaler role.

## 5. Non-Goals

- No mechanic role selector.
- No wholesaler assignment during onboarding.
- No offline scanning, offline queue, pending scan sync, or cached reward estimation.
- No QR generation, QR reissue, or raw QR payload display.
- No product prices, cart, ordering, or checkout.
- No invoice redemption.
- No campaign progress bar.
- No profit, buying price, wholesaler price, mechanic price, or admin data.
- No GST, NTN, or tax data.
- No fraud/rate-limit information shown to mechanics.
- No admin controls.

## 6. Primary User

### Mechanic

An independent motorcycle mechanic who installs or sells spare parts and scans SGX product QRs to earn rupee rewards. The same mechanic may scan products originating from different wholesalers over time.

The user may have limited reading or smartphone experience. Primary actions therefore use familiar icons, visible labels, short Urdu/English copy, and large touch targets.

### Admin / Counter Staff

Does not use this mobile module. Staff can view and manage mechanic profiles, review scan activity, process withdrawals, manage campaigns, and deactivate accounts from the admin panel.

## 7. Authentication and Registration

```text
Splash
-> Phone Login
-> OTP Verification
-> Resolve protected profile
   -> Active mechanic: Mechanic Home
   -> No profile: Complete Mechanic Profile
   -> Active wholesaler: Wholesaler Home
   -> Inactive mechanic/wholesaler: Account Unavailable
   -> Existing customer/staff: Account Unavailable
```

New mechanic profile fields:

- Full Name — required.
- Workshop/Shop Name — optional.
- Area/City — required.
- Verified Phone — read-only and not re-entered.

After saving, the trusted backend creates the profile with `role = mechanic`. The client must never allow selection of `role = wholesaler`.

## 8. Navigation Model

Use a Material 3 `BottomAppBar` with four labeled destinations and one raised center scan action:

```text
Home | Products | [Scan] | Wallet | Profile
```

- Home: left-most destination.
- Products: second destination.
- Scan: center-docked large circular action raised above the bar.
- Wallet: fourth destination.
- Profile: right-most destination.

The scan action opens the QR Scanner but is not treated as a persistent content tab. Campaigns, Notifications, Scan History, Withdrawals, and Preferences use pushed routes.

## 9. Home Requirements

Show:

- Mechanic greeting.
- Notification icon with unread badge.
- Available Balance.
- Pending Withdrawal.
- Lifetime Earned.
- Large `Scan QR` action.
- Latest successful scan and reward.
- Total confirmed scans.
- Current withdrawal status.
- Active mechanic-targeted campaign banner.
- Shortcuts to Scan History, Wallet, Products, and Campaigns.

Do not show technical QR data, charts, assigned wholesaler, or admin flags.

## 10. Online QR Scan Requirements

Scanning requires an active internet connection.

```text
Open Scanner
-> Check camera permission and connectivity
-> Detect QR
-> Send signed payload to trusted scan endpoint
-> Server validates and processes atomically
-> Return authoritative result
-> Show success or failure
```

Server checks:

- Authenticated profile is an active mechanic.
- QR format/signature are valid.
- QR exists and belongs to an SGX product.
- Associated invoice is dispatched and QR is active.
- QR has not already been scanned.
- QR has not expired when expiry applies.
- Reward snapshot is valid.

The first valid server transaction wins. Duplicate scans never credit money twice.

## 11. Scan Result Requirements

### Success

Show:

- Large success icon.
- `Reward added!`
- Large `Rs. X` amount.
- Product name.
- Actions: `Scan Another` and `Open Wallet`.

The server atomically:

- Marks QR scanned.
- Credits mechanic reward.
- Credits invoice wholesaler reward.
- Creates scan and wallet records.
- Triggers notifications.

### Failure Outcomes

- Already scanned.
- QR not active.
- Invalid SGX QR.
- Expired QR.
- Account inactive.
- Network/server failure.

No failed result credits money. Network failure offers Retry or Close; it never queues the scan.

## 12. Scan History

Show confirmed server scan records only:

- Product image/icon.
- Product name.
- Date and time.
- Reward amount.
- `Confirmed` status.
- Optional wholesaler/shop name as supporting context.

Do not show raw QR IDs, signatures, technical errors, rate-limit flags, or pending/offline statuses.

## 13. Wallet Requirements

Wallet shows:

- Available Balance.
- Pending Withdrawal.
- Lifetime Earned.
- Primary `Withdraw Money` action.
- Recent transaction list.

Supported transaction presentations:

- QR reward credited.
- Withdrawal submitted.
- Payment sent.
- Withdrawal confirmed.
- Withdrawal disputed.
- Withdrawal auto-confirmed.
- Withdrawal refunded.

There is no invoice-redemption transaction.

## 14. Withdrawal Requirements

The withdrawal flow matches the wholesaler module:

1. Enter amount.
2. Choose EasyPaisa, JazzCash, Bank Transfer, or Cash from SGX.
3. Enter method-specific destination details.
4. Review a short confirmation bottom sheet.
5. Confirm request.
6. Move amount from Available to Pending.
7. Notify admin.

New scan rewards remain available while an earlier withdrawal is pending.

After payment is sent:

- Received -> Confirmed.
- Not Received -> Disputed and show SGX WhatsApp contact.
- No action -> Auto-confirmed after configured period.
- Admin refund -> amount returns to Available Balance.

## 15. Product Catalog Requirements

Show only:

- Product image.
- Product name.
- Brand.
- Category.
- Optional product code.
- Short description on Product Detail.

Never show prices, stock controls, cart, ordering, profit, or scheme configuration.

## 16. Campaign Requirements

Show active campaigns targeting mechanics through:

- Home banner/card.
- Campaign list.
- Campaign Detail.
- Campaign-start notification.

Campaign Detail shows artwork, title, simple description, date window, prize/reward note, and participation instructions. Do not show user progress or promise automatic prize delivery.

## 17. Notifications

Supported types:

- QR reward credited.
- Withdrawal submitted.
- Payment sent.
- Withdrawal confirmed.
- Withdrawal disputed.
- Withdrawal auto-confirmed.
- Withdrawal refunded.
- Campaign started.

Reward notifications open Wallet or Scan History. Withdrawal notifications open Withdrawal Detail. Campaign notifications open Campaign Detail.

## 18. Profile and Preferences

Profile shows:

- Full name.
- Workshop/shop name when present.
- Verified phone, read-only.
- Area/city.
- Active status.

Mechanic may edit Full Name, Workshop/Shop Name, and Area/City. Phone and role remain read-only.

Preferences:

- English or Urdu.
- System, Light, or Dark theme.
- Contact SGX/help.
- Logout.

## 19. Simplicity and Accessibility

- Minimum touch target: 48 dp.
- Raised center Scan action is at least 64 dp and has a clear scan icon plus semantic label.
- Use one primary action per task.
- Pair important icons with text.
- Use large reward/balance numerals.
- Avoid hidden gestures and dense tables.
- Status uses icon, text, and color.
- Support 200 percent text scaling.
- Support Urdu RTL and wrapping.
- Camera screen provides spoken accessibility labels and non-camera error guidance.

## 20. Loading, Empty, Error, and Offline States

Every network-backed screen has loading, content, empty, error, and Retry states.

Scanner offline message:

```text
Internet is required to scan a QR. Please reconnect and try again.
```

The app never queues a scan. Wallet and withdrawal writes are also online-only.

## 21. Security and Privacy

- Mechanic reads only their own profile, scans, wallet, withdrawals, and notifications.
- Role and active status come from trusted server-controlled data.
- QR payload is sent only to the trusted scan operation.
- Reward values are server-authoritative snapshots.
- Duplicate scan prevention is enforced by database uniqueness and transaction logic.
- The QR secret never enters the app.
- Withdrawal changes are server-enforced and auditable.
- OTPs, tokens, full account details, and proof URLs are not logged.

## 22. Success Metrics

- New-mechanic onboarding completion.
- OTP success rate.
- Scanner open-to-result time.
- Successful versus invalid/duplicate scan rate.
- Scan Result to Scan Another rate.
- Scan Result to Wallet rate.
- Withdrawal completion and dispute rate.
- Product/campaign opens.
- Support contacts caused by unclear scan or payment status.

## 23. Required Design Handoff Files

- `prd.md`
- `design-token.json`
- `screen-flow.md`
- `screen-specs.md`
- `screen-stats.md`
- `architecture.md`

## 24. Remaining Owner Inputs

1. Final launch withdrawal methods.
2. Final SGX WhatsApp/help number.
3. Final Urdu translations.
4. Whether Workshop/Shop Name remains optional or becomes required.
5. Whether the confirmed Scan History row should show wholesaler/shop name.
