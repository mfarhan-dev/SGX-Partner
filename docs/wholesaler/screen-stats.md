# SGX Partners — Wholesaler Screen Statistics

**Purpose:** Screen inventory, complexity, state coverage, and design workload for the wholesaler role.

---

## 1. Summary

| Category | Count |
|---|---:|
| Navigable screens | 17 |
| Reusable state family | 1 |
| Bottom-navigation tabs | 5 |
| Authentication screens | 4 |
| Wholesaler dashboard/QR screens | 2 |
| Wallet/withdrawal screens | 4 |
| Product screens | 2 |
| Campaign screens | 2 |
| Notification/profile/preferences screens | 3 |
| QR detail screens | 0 |
| Signup/role-selection screens | 0 |
| Invoice inventory screens | 0 |
| Invoice redemption screens | 0 |

## 2. Screen Complexity

| ID | Screen | Complexity | Reason |
|---|---|---|---|
| WHL-00 | Splash | Low | Session restoration and route decision. |
| WHL-01 | Phone Login | Medium | Phone validation and OTP request states. |
| WHL-02 | OTP Verification | Medium | OTP, resend, timeout, and role routing. |
| WHL-03 | Account Unavailable | Low | Three clear access-blocked variants. |
| WHL-04 | Home | High | Balances, QR summary, reward, withdrawal, campaign, shortcuts. |
| WHL-05 | QR Progress | Medium | Aggregate cards and progress indicators with no detail flow. |
| WHL-06 | Wallet | High | Three balances, actions, and mixed transaction states. |
| WHL-07 | Withdraw Money | High | Conditional fields and confirmation sheet. |
| WHL-08 | Withdrawals | Medium | Status list and simple filters. |
| WHL-09 | Withdrawal Detail | Very High | Pending, paid confirmation, dispute, closed, and refund states. |
| WHL-10 | Products | Medium | Search, categories, read-only catalog states. |
| WHL-11 | Product Detail | Low | Read-only image and product information. |
| WHL-12 | Campaigns | Medium | Campaign list and empty state. |
| WHL-13 | Campaign Detail | Low | Read-only campaign content. |
| WHL-14 | Notifications | Medium | Typed deep links and read/unread states. |
| WHL-15 | Profile | Low | Read-only identity and app actions. |
| WHL-16 | Language and Theme | Low | Two preference groups. |
| WHL-17 | Reusable States | Medium | Consistent loading, empty, error, and offline components. |

## 3. Required Design Frames

| Group | Minimum Frames |
|---|---:|
| Authentication and access | 7 |
| Home | 4 |
| QR Progress | 4 |
| Wallet and withdrawals | 14 |
| Products | 5 |
| Campaigns and notifications | 6 |
| Profile and preferences | 3 |
| Reusable states | 7 |
| Dark theme samples | 5 |
| Urdu/RTL stress samples | 5 |
| Total recommended frames | 60 |

The authentication, Home, light-theme, and dark-theme frame sets must use the shared SGX Partners icon placements defined in `screen-specs.md`; do not design a separate wholesaler icon.

## 4. Required State Coverage

### Authentication

- Phone login default.
- Phone validation error.
- OTP default.
- OTP invalid.
- OTP resend countdown.
- Inactive wholesaler.
- Customer/staff access unavailable.

### Home

- New account with no rewards.
- Populated rewards and QR progress.
- Active withdrawal awaiting payment.
- Payment awaiting user confirmation.

### QR Progress

- Loading.
- Populated active and complete cards.
- No QR progress.
- Error/offline.

### Wallet

- Empty wallet.
- Wallet with reward credits.
- Balance below minimum.
- Balance eligible for withdrawal.
- Pending withdrawal present.

### Withdrawal

- Form default.
- Each payment-method variant.
- Amount below minimum.
- Amount above available.
- Confirmation bottom sheet.
- Submit error with preserved form.
- Pending detail.
- Payment sent detail.
- Received confirmation dialog.
- Not Received dialog.
- Disputed detail.
- Confirmed detail.
- Auto-confirmed detail.
- Refunded detail.

### Products

- Loading.
- Populated.
- Filtered empty.
- Product Detail.
- Offline/error.

### Campaigns and Notifications

- Campaign list.
- Campaign detail.
- No campaigns.
- Unread notifications.
- Empty notifications.
- Deleted deep-link target.

### Profile and Preferences

- Read-only profile.
- Inactive-state behavior after session refresh.
- English/light.
- Urdu/RTL.
- Dark theme.

## 5. Navigation Counts

| Navigation type | Count |
|---|---:|
| Bottom-nav roots | 5 |
| Pushed detail screens | 3 |
| Pushed form screens | 1 |
| List screens outside bottom nav | 3 |
| Confirmation dialog/sheet patterns | 3 |
| Role-guarded auth outcomes | 5 |

## 6. Component Inventory

| Component | Usage |
|---|---|
| `NavigationBar` | Five main destinations with labels. |
| Small `AppBar` | Titles, back navigation, notifications. |
| WalletBalanceCard | Available, Pending, Lifetime values. |
| QRProgressCard | Image, counts, progress, earned value; non-tappable. |
| `LinearProgressIndicator` | Overall and per-card QR progress. |
| TransactionRow | Reward and withdrawal ledger entries. |
| WithdrawalCard | Withdrawal list. |
| StatusChip | Active, Complete, Pending, Sent, Confirmed, Disputed, Refunded. |
| PaymentMethodCard | EasyPaisa, JazzCash, Bank, Cash. |
| ConfirmationSheet | Withdrawal review. |
| ProductCard | Price-free B2B catalog. |
| CampaignCard | Home and campaign list. |
| NotificationRow | Read/unread typed notification. |
| ReadOnlyInfoRow | Profile identity. |
| EmptyState | All lists and no-reward states. |
| ErrorState | Retryable failures. |
| OfflineState | Online-only wholesaler module. |

## 7. Design Priority

1. WHL-04 Home.
2. WHL-05 QR Progress.
3. WHL-06 Wallet.
4. WHL-07 Withdraw Money.
5. WHL-09 Withdrawal Detail states.
6. WHL-01 and WHL-02 authentication.
7. WHL-08 Withdrawals.
8. WHL-10 Products.
9. WHL-14 Notifications.
10. Campaigns, Profile, and Preferences.
11. Reusable, dark, and Urdu variants.

## 8. Design Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Users confuse remaining QRs with physical stock | Incorrect business interpretation | Label the screen `QR Progress`; never use Inventory or Stock wording. |
| Unknown number becomes a mechanic | A wholesaler may enter onboarding if admin did not provision them | Admin must register the exact phone before first login; show wholesaler help copy on Login. |
| Low literacy | Dense finance and status language may be misunderstood | Large icons, short labels, Urdu, one primary action, usability testing. |
| Balance-bucket confusion | Users may think pending money disappeared | Always show Available and Pending together with plain explanations. |
| Cash withdrawal ambiguity | Unclear collection and proof rules | Lock cash collection instructions before final design. |
| QR cards appear tappable | Users expect a removed detail screen | No chevron, ripple, button, or raised interactive styling. |
| Campaign complexity | Users expect visible progress or guaranteed prizes | Use simple participation copy and no progress bar. |
| Stale existing docs | Old invoice redemption may leak back into design | Treat PRD Locked Owner Decisions as module precedence. |

## 9. Confirmed Scope Checklist

- One shared B2B app.
- Admin-provisioned wholesaler accounts.
- Phone plus OTP login.
- No role selection.
- No tax identifiers.
- Five-item wholesaler navigation.
- One QR Progress screen with no detail route.
- No invoice inventory.
- No QR scanner.
- No invoice redemption.
- Wallet and withdrawal lifecycle.
- Price-free products.
- Campaigns and notifications.
- Read-only business profile.
- English, Urdu, light, and dark support.
