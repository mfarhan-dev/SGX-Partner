# SGX Partners — Wholesaler Module PRD

**Application name:** SGX Partners  
**Module:** Wholesaler role experience  
**Platform:** Flutter, Android first, iOS-compatible  
**Design system:** Material Design 3  
**Approved app icon:** `../../customer/sgx-app-icon.svg`  
**Status:** Approved product/design baseline  
**Last updated:** 22 July 2026

---

## 1. Product Summary

SGX Partners is one Flutter application with separate mechanic and wholesaler experiences. This document defines only the wholesaler experience.

Wholesalers do not create accounts from the mobile app. SGX staff create and manage wholesaler accounts in the admin panel. A wholesaler signs in with the registered phone number and an SMS OTP. After verification, the app reads the protected profile role and opens the wholesaler interface automatically.

The wholesaler app is intentionally simple. A wholesaler can see rewards earned when mechanics scan QRs tied to their dispatched SGX invoices, review total/scanned/remaining QR progress, withdraw wallet money, browse SGX products, view campaigns and notifications, and read their profile. A wholesaler never scans QRs, orders products, manages invoice inventory, or redeems wallet money against an invoice.

## 2. Locked Owner Decisions

These decisions override conflicting or outdated statements in older project documents:

1. This is one B2B app with role-aware mechanic and wholesaler interfaces.
2. Wholesalers are created only from the admin panel; there is no wholesaler signup.
3. Login uses the admin-registered phone number plus OTP.
4. The app never asks a wholesaler to choose a role.
5. Wholesalers never scan QR codes and have no camera/scanner/offline-scan UI.
6. QR Progress is one summary screen only; there is no QR Progress Detail screen.
7. QR Progress is not invoice inventory and exposes no stock or financial invoice details.
8. Invoice wallet redemption has been removed completely.
9. Wallet money leaves the system only through the withdrawal lifecycle.
10. Wholesaler profiles contain no GST, NTN, or other tax-number fields.
11. The B2B product catalog is browse-only and price-free.
12. Campaigns are visible, but user-facing campaign progress is not shown in v1.
13. Business identity is read-only in the app and maintained by SGX staff.
14. The customer app's existing `sgx-app-icon.svg` is the single approved SGX Partners icon for both roles; no wholesaler-specific variant is created.

## 3. Brand Identity and Icon Usage

The approved master asset is [`../../customer/sgx-app-icon.svg`](../../customer/sgx-app-icon.svg). UI designers and developers must reuse it unchanged: preserve its white rounded-square background, navy SGX artwork, aspect ratio, and internal clear space. Do not recolor, crop, stretch, redraw, or add a mechanic/wholesaler badge.

| Placement | Required treatment |
|---|---|
| Android/iOS launcher | Use the SVG as the master source when producing platform launcher assets. Keep the complete rounded-square artwork inside each platform safe zone. |
| Splash | Center a 112 dp icon, then show `SGX Partners` below it using the screen-title style. |
| Phone Login | Center a 72 dp icon above `Login to SGX Partners`. |
| OTP Verification | Center a compact 48 dp icon above `Verify your number`. |
| Home app bar | Show a 32 dp icon immediately before the `SGX Partners` title; keep Notifications on the trailing side. |

Do not place the brand icon in the bottom navigation. Each destination keeps its functional icon so low-literacy users can recognize its purpose quickly.

## 4. Goals

1. Make passive QR rewards obvious and trustworthy.
2. Let wholesalers understand scanned-versus-remaining QR progress without technical detail.
3. Provide a clear wallet and withdrawal experience for users with limited digital literacy.
4. Keep the interface consistent with the SGX customer app while adapting it to B2B needs.
5. Support English and Urdu with RTL-ready layouts.
6. Use short labels, large touch targets, recognizable icons, and one primary action per task.

## 5. Non-Goals

- No wholesaler signup or role selection.
- No QR scanner, camera permission, scan result, scan history, or offline scan queue.
- No QR-level detail screen or raw QR list.
- No invoice inventory.
- No product stock management.
- No product prices, cart, ordering, or checkout.
- No Khata editing or payment recording from the app.
- No invoice wallet redemption or redemption history.
- No GST, NTN, tax, profit, buying-price, or margin information.
- No individual mechanic identity in QR Progress.
- No user-facing campaign progress bar.
- No admin controls or reports.

## 6. Primary User

### Wholesaler

A local motorcycle-parts shop owner who buys SGX products from the factory. The user may have limited reading or smartphone experience. Rewards are credited passively when mechanics scan active QRs tied to the wholesaler’s dispatched invoices.

### Admin / Counter Staff

Does not use this mobile module. Staff create, edit, activate, and deactivate wholesaler accounts; issue and dispatch invoices; generate reward QRs; process withdrawals; and manage campaigns from the admin panel.

## 7. Account Provisioning and Authentication

Admin creates the wholesaler with:

- Owner name.
- Shop name.
- Phone number.
- Area/city.
- Optional address.
- Active/inactive status.

Authentication flow:

```text
Splash
-> Phone Login
-> OTP Verification
-> Read profile for verified phone
   -> Active wholesaler: Wholesaler Home
   -> Inactive wholesaler: Account Unavailable
   -> Existing mechanic: Mechanic Home
   -> Existing customer/staff: Account Unavailable
   -> Unknown phone: Mechanic onboarding, outside this module
```

The app must not expose a role selector. A phone already assigned to a customer or staff profile must not be silently converted into a mechanic or wholesaler.

## 8. Navigation Model

Use a five-destination Material 3 `NavigationBar`:

1. Home
2. QR Progress
3. Wallet
4. Products
5. Profile

Campaigns and Notifications are opened from Home, notification deep links, and top-app-bar actions. Pushed screens use a back arrow and do not show the bottom navigation unless preserving it improves orientation.

## 9. Home Requirements

Home must prioritize recognition and action over dense reporting.

Show:

- Shop/owner greeting.
- Notification icon with unread badge.
- Available Balance.
- Pending Withdrawal.
- Lifetime Earned.
- Overall scanned and remaining QR counts.
- Latest reward received.
- Current or latest withdrawal status.
- Active campaign banner when available.
- Large shortcuts to QR Progress, Wallet, Withdraw, and Products.

Do not show charts, technical QR identifiers, profit, invoice totals, or long tables.

## 10. Reward and QR Progress Rules

Reward flow:

```text
Staff dispatches an invoice containing reward QRs
-> QRs become active
-> A mechanic scans a valid unused QR
-> Server validates the QR and snapshot
-> Mechanic share is credited to the mechanic
-> Wholesaler share is credited to the invoice wholesaler
-> Wholesaler wallet and QR Progress refresh
-> Wholesaler receives a notification
```

The wholesaler takes no action to claim the reward.

QR Progress is a single scrollable summary screen. Each product/invoice group shows:

- Product image.
- Product name.
- Optional short invoice/reference label.
- Total QRs.
- Scanned QRs.
- Remaining QRs.
- Determinate progress indicator.
- Total wholesaler reward earned from confirmed scans.
- Simple status: Active or Complete.

Cards are not tappable and have no detail route.

## 11. Wallet Requirements

Wallet shows:

- Available Balance: money currently eligible for withdrawal.
- Pending Withdrawal: money locked in open withdrawal requests.
- Lifetime Earned: total confirmed QR rewards earned historically.
- Primary action: Withdraw Money.
- Recent transaction history.

Allowed transaction presentations:

- QR reward credited.
- Withdrawal submitted.
- Payment sent.
- Withdrawal confirmed.
- Withdrawal disputed.
- Withdrawal auto-confirmed.
- Withdrawal refunded.

There is no invoice redemption transaction type.

## 12. Withdrawal Requirements

The Withdraw action is enabled only when Available Balance meets the configured minimum.

Supported design options:

- EasyPaisa.
- JazzCash.
- Bank transfer.
- Cash collection from SGX.

Method-specific details:

- EasyPaisa/JazzCash: account title and mobile number.
- Bank transfer: bank name, account title, and account/IBAN.
- Cash collection: no account field; show SGX collection instructions.

Submission flow:

1. Enter a valid amount.
2. Choose payment method.
3. Enter required destination details.
4. Review a short confirmation sheet.
5. Confirm request.
6. Move amount immediately from Available to Pending.
7. Notify admin.

New QR rewards earned while a withdrawal is open remain available separately.

After admin sends payment, the wholesaler can select:

- Received: close as confirmed.
- Not Received: open a dispute and show SGX WhatsApp contact.

If the user does nothing within the configured window, the system auto-confirms. If payment failed, admin can refund the locked amount to Available Balance.

## 13. Product Catalog Requirements

Show only:

- Product image.
- Product name.
- Brand.
- Category.
- Optional product code.
- Short description on Product Detail.

Never show prices, stock controls, ordering, cart, buying price, profit, or supplier information.

## 14. Campaign Requirements

Show active campaigns targeting wholesalers through:

- Home banner/card.
- Campaigns list.
- Campaign Detail.
- Campaign notification deep link.

Campaign Detail shows artwork, title, simple description, date window, reward/prize note, and participation instructions. Do not show a progress bar or promise automatic prize delivery.

## 15. Notifications Requirements

Supported types:

- QR reward credited.
- Withdrawal submitted.
- Payment sent.
- Withdrawal confirmed.
- Withdrawal disputed.
- Withdrawal auto-confirmed.
- Withdrawal refunded.
- Campaign started.

Notifications use short, direct language and typed deep links to Wallet, Withdrawal Detail, or Campaign Detail. There is no QR Progress Detail target.

## 16. Profile and Preferences

Read-only business identity:

- Owner name.
- Shop name.
- Phone number.
- Area/city.
- Address, when present.
- Account status.

Actions:

- Language: English or Urdu.
- Theme: System, Light, or Dark.
- Contact SGX/help.
- Logout.

Business information changes are handled by admin staff.

## 17. Simplicity and Accessibility Rules

- Use familiar icons with visible text labels.
- Minimum touch target: 48 dp.
- Use one obvious primary action per screen.
- Avoid technical vocabulary, dense tables, and hidden gestures.
- Use large balance numerals and short supporting labels.
- Show status with icon, text, and color; never color alone.
- Support text scaling up to 200 percent without overlap.
- Keep confirmation messages short and specific.
- Make Urdu layouts RTL-ready and allow labels to wrap.

## 18. Loading, Empty, Error, and Offline States

Every network-backed screen must deliberately show loading, content, empty, error, and retry states.

Global offline copy:

```text
No internet connection. Please reconnect and try again.
```

The wholesaler experience is online-only. Do not queue withdrawals or other writes offline.

## 19. Security and Privacy

- A wholesaler reads only their own profile, wallet, withdrawals, notifications, and QR summaries.
- Role and active status are read from trusted server-controlled data.
- QR Progress exposes aggregate counts only, not raw QR payloads or signatures.
- Individual mechanic identity is hidden from wholesaler progress.
- Wallet amounts and reward credits are server-authoritative.
- Withdrawal state changes are server-enforced and auditable.
- OTPs, tokens, complete account details, and signed proof URLs must not be logged.

## 20. Success Metrics

- OTP completion rate.
- Home-to-Wallet visits.
- Home-to-QR-Progress visits.
- Withdrawal completion and dispute rates.
- Time taken to understand scanned versus remaining QRs in usability testing.
- Campaign opens.
- Notification opens.
- Support contacts caused by unclear balance or payment status.

## 21. Required Design Handoff Files

- `prd.md`
- `design-token.json`
- `screen-flow.md`
- `screen-specs.md`
- `screen-stats.md`
- `architecture.md`

## 22. Remaining Owner Inputs

1. Final supported withdrawal methods at launch.
2. Cash-collection instructions and whether cash requires a receipt image.
3. Final SGX WhatsApp/help number.
4. Whether a short invoice/reference label should appear on QR Progress cards.
5. Final Urdu translations.
