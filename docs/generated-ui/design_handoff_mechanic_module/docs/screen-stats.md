# SGX Partners — Mechanic Screen Statistics

**Purpose:** Screen inventory, complexity, state coverage, and design workload for the mechanic role.

---

## 1. Summary

| Category | Count |
|---|---:|
| Navigable screens | 20 |
| Scan-result state family | 1 |
| Reusable state family | 1 |
| Standard bottom destinations | 4 |
| Raised center Scan action | 1 |
| Authentication/onboarding screens | 5 |
| Home/scan screens | 4 |
| Wallet/withdrawal screens | 4 |
| Product screens | 2 |
| Campaign screens | 2 |
| Notification/profile/preferences screens | 4 |
| Offline scan screens | 0 |
| Role-selection screens | 0 |
| Wholesaler-selection screens | 0 |

## 2. Screen Complexity

| ID | Screen | Complexity | Reason |
|---|---|---|---|
| MEC-00 | Splash | Low | Session, role, and profile routing. |
| MEC-01 | Phone Login | Medium | Phone validation and OTP request. |
| MEC-02 | OTP Verification | Medium | OTP states and role/profile branching. |
| MEC-03 | Account Unavailable | Low | Inactive and wrong-role variants. |
| MEC-04 | Complete Mechanic Profile | Medium | Minimal onboarding form and trusted role creation. |
| MEC-05 | Home | High | Balance, scan CTA, activity, withdrawal, campaign. |
| MEC-06 | QR Scanner | Very High | Camera, connectivity, permission, detection, processing. |
| MEC-07 | Scan Result | High | Success plus five clear failure variants. |
| MEC-08 | Scan History | Medium | Confirmed server scan list and empty/error states. |
| MEC-09 | Wallet | High | Three balances and mixed transaction states. |
| MEC-10 | Withdraw Money | High | Conditional method fields and confirmation sheet. |
| MEC-11 | Withdrawals | Medium | Status list and filters. |
| MEC-12 | Withdrawal Detail | Very High | Payment confirmation, dispute, and closed states. |
| MEC-13 | Products | Medium | Search, categories, and read-only catalog. |
| MEC-14 | Product Detail | Low | Read-only product content. |
| MEC-15 | Campaigns | Medium | List and empty state. |
| MEC-16 | Campaign Detail | Low | Read-only campaign content. |
| MEC-17 | Notifications | Medium | Typed deep links and unread state. |
| MEC-18 | Profile | Low | Identity and app actions. |
| MEC-19 | Edit Profile | Medium | Small form and dirty-state protection. |
| MEC-20 | Language and Theme | Low | Two preference groups. |
| MEC-21 | Reusable States | Medium | Shared async and offline handling. |

## 3. Required Design Frames

| Group | Minimum Frames |
|---|---:|
| Authentication and onboarding | 9 |
| Home and navigation | 5 |
| Scanner and results | 12 |
| Scan history | 3 |
| Wallet and withdrawals | 14 |
| Products | 5 |
| Campaigns and notifications | 6 |
| Profile and preferences | 5 |
| Reusable states | 7 |
| Dark theme samples | 6 |
| Urdu/RTL stress samples | 5 |
| Total recommended frames | 77 |

The authentication, onboarding, Home, light-theme, and dark-theme frame sets must use the shared SGX Partners icon placements defined in `screen-specs.md`; do not design a separate mechanic icon.

## 4. Required State Coverage

### Authentication and Onboarding

- Phone default and validation error.
- OTP default, invalid, resend countdown.
- New mechanic profile.
- Existing mechanic route.
- Active wholesaler route.
- Inactive account.
- Customer/staff blocked.

### Navigation

- Home selected.
- Products selected.
- Wallet selected.
- Profile selected.
- Center Scan at rest, pressed, and focus-visible/semantic states.
- Safe-area/home-indicator variants.

### Scanner

- Camera permission explanation.
- Camera permission denied.
- Permanently denied/Open Settings.
- Scanner ready.
- QR detected/processing.
- Offline scanner blocked.
- Success.
- Already scanned.
- Not active.
- Invalid.
- Expired.
- Network/server retry.

### Scan History

- Loading.
- Populated confirmed scans.
- Empty.
- Error/offline.

### Wallet and Withdrawals

- Empty wallet.
- Below-minimum balance.
- Eligible balance.
- Pending withdrawal.
- Each payment-method form.
- Validation errors.
- Confirmation bottom sheet.
- Submit error with preserved form.
- Pending detail.
- Payment Sent detail.
- Received dialog.
- Not Received dialog.
- Disputed.
- Confirmed.
- Auto-confirmed.
- Refunded.

### Products, Campaigns, Notifications

- Product loading/populated/filtered empty/detail/offline.
- Campaign list/detail/empty.
- Notification unread/empty/deleted target.

### Profile

- Profile populated.
- Edit default/dirty/validation/save error.
- English/Urdu.
- System/light/dark.

## 5. Navigation Counts

| Navigation type | Count |
|---|---:|
| BottomAppBar labeled destinations | 4 |
| Center-docked primary action | 1 |
| Pushed detail screens | 3 |
| Pushed forms | 3 |
| Pushed list screens | 4 |
| Confirmation dialog/sheet patterns | 3 |
| Scan result variants | 6 |
| Role/profile auth outcomes | 5 |

## 6. Component Inventory

| Component | Usage |
|---|---|
| `BottomAppBar` | Approved four-destination shell. |
| Center scan FAB | Raised primary QR action. |
| Small `AppBar` | Titles, back, notifications. |
| WalletBalanceCard | Available, Pending, Lifetime. |
| ScanActionCard | Large Home scan entry. |
| CameraScanFrame | Online QR capture guidance. |
| ScanResultSurface | Success/failure states. |
| ScanHistoryRow | Confirmed product reward. |
| TransactionRow | Wallet activity. |
| PaymentMethodCard | EasyPaisa, JazzCash, Bank, Cash. |
| ConfirmationSheet | Withdrawal review. |
| WithdrawalCard | Withdrawal list. |
| StatusChip | Confirmed and withdrawal statuses. |
| ProductCard | Price-free catalog. |
| CampaignCard | Home and campaign list. |
| NotificationRow | Read/unread updates. |
| ProfileForm | Minimal mechanic identity editing. |
| Empty/Error/OfflineState | Shared async behavior. |

## 7. Design Priority

1. Bottom navigation and center Scan action.
2. MEC-06 QR Scanner.
3. MEC-07 Scan Result variants.
4. MEC-05 Home.
5. MEC-09 Wallet.
6. MEC-10 Withdraw Money.
7. MEC-12 Withdrawal Detail.
8. Authentication and onboarding.
9. MEC-08 Scan History.
10. Products, Campaigns, Notifications.
11. Profile, Preferences, reusable/dark/Urdu variants.

## 8. Design Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Center Scan conflicts with safe area | FAB or bar overlaps system navigation | Use scaffold insets and test gesture/three-button navigation. |
| Users assume scanner works offline | Lost expected reward | Block scanner before capture and show explicit internet requirement. |
| Repeated camera frames create duplicate calls | Confusing results or load | Pause detection after first QR and enforce one request/idempotency. |
| Unknown phone creates mechanic | Wrong identity if another role should exist | Check protected profile after OTP; never overwrite existing roles. |
| Mechanics expect one assigned wholesaler | Incorrect onboarding expectation | No selector; explain rewards come from the scanned product QR. |
| Low literacy | Misread scan or payment status | Large icons/amounts, short copy, Urdu, usability testing. |
| Balance buckets confuse users | Pending appears lost | Display Available and Pending together with plain explanations. |
| Old offline docs leak into design | Unapproved queue returns | Locked owner decision and online-only test checklist. |

## 9. Confirmed Scope Checklist

- One shared B2B app.
- Mechanic self-registration via phone plus OTP.
- Unknown phone defaults to mechanic onboarding.
- No role or wholesaler selection.
- Independent mechanic model.
- Home, Products, center Scan, Wallet, Profile order.
- Online-only QR scanning.
- No offline queue or pending scan state.
- Confirmed Scan History.
- Wallet and withdrawal lifecycle.
- No invoice redemption.
- Price-free products.
- Mechanic campaigns and notifications.
- Editable basic profile; phone/role read-only.
- No GST/NTN/tax fields.
- English, Urdu, light, and dark support.
