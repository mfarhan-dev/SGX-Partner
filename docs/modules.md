# SGX Mobile App Design Modules

**Project:** SGX Auto Parts Mobile Apps  
**Document Type:** Design-agent module map  
**Last Updated:** 22 May 2026  
**Target:** Flutter mobile app design only  

This file is for a mobile design agent. It defines the theme direction and the screen/module list only. It does not define field-level logic, backend rules, validation, or implementation details.

---

## 1. Material Theme

Use **Material Design 3** for both mobile apps.

Platform target:

- Flutter.
- Android first.
- iOS-compatible layouts.
- `useMaterial3: true`.

Recommended Flutter theme base:

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: sgxPrimary,
  ),
)
```

Dynamic color can be considered later, but the SGX brand colors below must remain the design base.

---

## 2. SGX Theme Colors

Use these colors first. They come from the existing SGX admin panel theme.

### Light Theme

| Token | Value | Use |
|---|---|---|
| Primary | `oklch(0.3582 0.1289 265.52)` | Main brand actions, active navigation, important highlights. |
| On Primary | `oklch(1 0 0)` | Text/icons on primary. |
| Primary Container | `oklch(0.2316 0.0907 265.52)` | Strong branded containers. |
| On Primary Container | `oklch(0.9385 0.0285 264.18)` | Text/icons on primary container. |
| Background | `oklch(0.9789 0.0042 247.86)` | App background. |
| Foreground | `oklch(0.2077 0.0398 265.75)` | Main text. |
| Surface/Card | `oklch(1 0 0)` | Cards, sheets, app surfaces. |
| Secondary | `oklch(0.9385 0.0285 264.18)` | Soft selected states and low-emphasis fills. |
| Muted | `oklch(0.9683 0.0069 248.08)` | Quiet surface sections. |
| Muted Foreground | `oklch(0.5510 0.0234 264.37)` | Secondary text. |
| Border / Outline | `oklch(0.9219 0.0098 247.88)` | Dividers, outlines. |
| Success | `oklch(0.6235 0.1737 145.94)` | Earned, received, delivered, success states. |
| Warning | `oklch(0.8388 0.1614 84.42)` | Pending, waiting, attention states. |
| Warning Foreground | `oklch(0.3 0.08 80)` | Text/icons on warning surfaces. |
| Destructive | `oklch(0.5266 0.2049 27.43)` | Failed, disputed, rejected, destructive states. |

### Dark Theme

| Token | Value |
|---|---|
| Background | `oklch(0.145 0 0)` |
| Foreground | `oklch(0.985 0 0)` |
| Surface/Card | `oklch(0.205 0 0)` |
| Primary | `oklch(0.4683 0.1371 265.52)` |
| On Primary | `oklch(1 0 0)` |
| Secondary | `oklch(0.269 0 0)` |
| Muted Foreground | `oklch(0.708 0 0)` |
| Border / Outline | `oklch(1 0 0 / 10%)` |
| Success | `oklch(0.6235 0.1737 145.94)` |
| Warning | `oklch(0.8388 0.1614 84.42)` |
| Destructive | `oklch(0.5266 0.2049 27.43)` |

### Theme Notes

- Use Material 3 semantic color roles instead of random custom colors.
- Keep status colors consistent:
  - Success: earned, confirmed, delivered.
  - Warning: pending, awaiting confirmation, campaign scheduled.
  - Destructive: failed, rejected, disputed.
- Use Material 3 surfaces, cards, bottom sheets, navigation bars, tabs, chips, badges, and dialogs.
- Do not copy the admin-panel desktop layout. Mobile should feel native and touch-first.

---

## 3. Apps To Design

There are two mobile products.

### B2B Mobile App

Used by:

- Wholesalers.
- Mechanics.

One app, two role-based experiences after login.

### Customer Mobile App

Used by:

- Retail customers buying products directly.

Separate customer experience.

---

## 4. Shared Mobile Modules

These modules apply to both apps where relevant.

### 4.1 Splash / Launch

Initial branded loading screen.

### 4.2 Login

Phone number based login entry.

### 4.3 OTP Verification

Code verification screen.

### 4.4 Signup / Role Selection

Used where account creation is available.

### 4.5 Area Selection

Area/town selection during onboarding where required.

### 4.6 Home / Dashboard

Default screen after login. Must adapt by user role.

### 4.7 Campaigns

Mobile-facing campaign area showing active promotional campaigns.

### 4.8 Campaign Detail

Detailed view of a selected campaign.

### 4.9 Notifications

List of app notifications.

### 4.10 Profile

User profile and basic account identity area.

### 4.11 Language

Language selection or language-aware presentation.

### 4.12 Empty / Loading / Error States

Reusable mobile states across lists, cards, and offline/online transitions.

---

## 5. B2B App Modules

### 5.1 B2B Dashboard

Role-aware dashboard for wholesalers and mechanics.

### 5.2 Wallet

Shows reward balance, pending withdrawal, and lifetime earning context.

### 5.3 Wallet History

Transaction history for earned rewards, withdrawals, confirmations, disputes, and redemptions.

### 5.4 Withdraw

Withdrawal request entry point.

### 5.5 Withdrawal Detail

Current withdrawal status and payment confirmation area.

### 5.6 Withdrawal Paid Confirmation

Screen where user can confirm received or report not received.

### 5.7 Product Catalog

Browse-only catalog for wholesalers and mechanics.

### 5.8 Product Detail

Read-only product detail screen.

### 5.9 QR Scanner

Mechanic primary scan screen.

### 5.10 Scan Result

Success, already scanned, inactive, offline queued, or failed result presentation.

### 5.11 Offline Scan Queue

Mechanic-only offline scan queue/status area.

### 5.12 My Inventory

Wholesaler invoice inventory and scan-progress overview.

### 5.13 Invoice Inventory Detail

Per-invoice product and QR scan progress context for wholesalers.

### 5.14 Redemption History

Wholesaler view of reward redemptions against invoices.

### 5.15 B2B Campaigns

Campaign list for wholesalers and mechanics.

### 5.16 B2B Campaign Detail

Campaign detail and progress context for B2B users if shown.

---

## 6. Customer App Modules

### 6.1 Customer Dashboard

Customer home screen after login.

### 6.2 Product Catalog

Customer-facing product browsing area.

### 6.3 Product Detail

Product detail for retail purchase.

### 6.4 Cart

Customer cart.

### 6.5 Checkout

Checkout flow.

### 6.6 Address List

Saved delivery addresses.

### 6.7 Add / Edit Address

Address management screen.

### 6.8 Payment Method

Payment selection screen.

### 6.9 Payment Proof Upload

Manual EasyPaisa screenshot upload area.

### 6.10 Order Confirmation

Order placed confirmation.

### 6.11 Orders

Customer order history.

### 6.12 Order Detail

Order tracking and item detail.

### 6.13 Customer Campaigns

Customer campaign list.

### 6.14 Customer Campaign Detail

Customer campaign detail.

---

## 7. Role-Based Navigation Groups

The design agent can structure navigation using Material 3 bottom navigation, navigation rail, tabs, or nested sections as appropriate.

### Mechanic Main Areas

- Home.
- Scan.
- Wallet.
- Products.
- Campaigns.
- Notifications.
- Profile.

### Wholesaler Main Areas

- Home.
- Wallet.
- Inventory.
- Products.
- Campaigns.
- Notifications.
- Profile.

### Customer Main Areas

- Home.
- Products.
- Cart.
- Orders.
- Campaigns.
- Notifications.
- Profile.

---

## 8. Campaign Design Placement

Campaigns should be visible in mobile because campaigns are created from admin for selected roles.

Design places to consider:

- Dashboard campaign card/banner.
- Campaigns list.
- Campaign detail.
- Notification deep-link target.

Campaign images from the admin panel should appear as mobile campaign artwork/banner visuals.

---

## 9. Design Agent Input File

Give this file to the mobile design agent:

```text
docs/mobile-app-design/modules.md
```

Also provide these context files if the design agent needs business meaning, but keep `modules.md` as the primary design brief:

```text
docs/00_Requirements_v1.3.md
docs/02_System_Architecture_v1.0.md
docs/Module_10_QR_Codes_v1.0.md
docs/Module_11_Withdrawals_v1.0.md
docs/Module_16_Campaigns_v1.0.md
```

The design agent should not use admin-panel HTML previews as mobile layouts. Those previews are desktop/admin references only.

---

## 10. Design Agent Boundary

The mobile design agent should focus on:

- Visual design.
- Screen hierarchy.
- Mobile navigation.
- Material 3 component choices.
- Role-based experience.
- Campaign image placement.
- Empty/loading/error visuals.
- Light and dark theme consistency.

The mobile design agent should not define:

- Database schema.
- Backend APIs.
- Validation wording.
- Exact field-level business rules.
- Admin-panel desktop UI.
- Implementation architecture.

