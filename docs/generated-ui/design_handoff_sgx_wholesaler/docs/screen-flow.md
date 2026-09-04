# SGX Partners — Wholesaler Screen Flow

**Purpose:** Navigation and journey map for the wholesaler role.  
**Rule:** Wholesaler accounts are created by admin; no wholesaler signup or role selection exists.

---

## 1. Entry and Authentication

```text
App Launch
-> WHL-00 Splash: SGX Partners icon and name
-> Auth session check
   -> No session: WHL-01 Phone Login
   -> Valid active wholesaler session: WHL-04 Home
   -> Expired session: WHL-01 Phone Login
```

```text
WHL-01 Phone Login
-> Enter phone
-> Send OTP
-> WHL-02 OTP Verification
-> Verify OTP
-> Resolve protected profile role
   -> Active wholesaler: WHL-04 Home
   -> Inactive wholesaler: WHL-03 Account Unavailable
   -> Mechanic: mechanic role Home
   -> Customer/staff: WHL-03 Account Unavailable
   -> Unknown phone: mechanic onboarding outside this module
```

There is no wholesaler profile-completion screen because staff complete the account in the admin panel.

## 2. Main Navigation

```text
Material 3 NavigationBar
  Home         -> WHL-04
  QR Progress  -> WHL-05
  Wallet       -> WHL-06
  Products     -> WHL-10
  Profile      -> WHL-15
```

Top app bar:

- Notifications -> WHL-14.
- Back arrow on pushed screens.
- No scanner action anywhere in the wholesaler shell.

## 3. Home Flow

```text
WHL-04 Home
-> QR Progress card -> WHL-05 QR Progress
-> Wallet card -> WHL-06 Wallet
-> Withdraw action -> WHL-07 Withdraw Money
-> Product shortcut -> WHL-10 Products
-> Campaign banner -> WHL-13 Campaign Detail
-> Notifications icon -> WHL-14 Notifications
-> Withdrawal status card -> WHL-09 Withdrawal Detail
```

## 4. Passive Reward Flow

This flow happens because of mechanic activity; the wholesaler does not initiate it.

```text
Mechanic scans an active QR tied to wholesaler invoice
-> Server validates and credits both reward shares
-> Wholesaler wallet refreshes
-> WHL-05 QR Progress aggregate refreshes
-> Reward notification arrives
-> Tapping notification opens WHL-06 Wallet
```

There is no QR-level detail destination.

## 5. QR Progress Flow

```text
WHL-05 QR Progress
-> View product cards
-> Read Total / Scanned / Remaining / Earned
-> Pull to refresh
```

Cards do not navigate. There are no individual QR rows, scan-event rows, or invoice-inventory screens.

## 6. Wallet Flow

```text
WHL-06 Wallet
-> Review Available / Pending / Lifetime Earned
-> Review recent transactions
-> Withdraw Money -> WHL-07
-> View all withdrawals -> WHL-08
-> Open active/recent withdrawal -> WHL-09
```

## 7. Withdrawal Request Flow

```text
WHL-06 Wallet
-> WHL-07 Withdraw Money
   -> Enter amount
   -> Select method
   -> Enter destination details if required
   -> Tap Continue
   -> Review confirmation bottom sheet
      -> Cancel: remain on WHL-07
      -> Confirm: submit request
         -> Success message
         -> WHL-09 Withdrawal Detail
```

Failure branches:

```text
Amount below minimum -> inline error
Amount above available -> inline error
Missing account details -> inline error
Offline/network failure -> preserve input and show Retry
Duplicate submission -> show existing request instead of creating another
```

## 8. Withdrawal Lifecycle Flow

```text
Submitted
-> Pending
-> Admin marks payment sent
-> Paid Awaiting Confirmation
   -> Received -> Confirmed
   -> Not Received -> Disputed
   -> No response in configured window -> Auto-confirmed
```

Dispute resolution:

```text
Disputed
-> Show Contact SGX / WhatsApp
-> Admin re-pays -> Paid Awaiting Confirmation
-> Admin resolves as received -> Confirmed
-> Admin refunds -> Refunded, amount returns to Available
```

All statuses render within WHL-09 Withdrawal Detail rather than separate confirmation screens.

## 9. Products Flow

```text
WHL-10 Products
-> Search or choose category
-> Tap product
-> WHL-11 Product Detail
```

Product Detail is read-only. It has no price, cart, order, or stock action.

## 10. Campaign Flow

```text
WHL-04 Home campaign banner
-> WHL-13 Campaign Detail

WHL-12 Campaigns
-> Select campaign
-> WHL-13 Campaign Detail

WHL-14 Campaign notification
-> WHL-13 Campaign Detail
```

Only active wholesaler-targeted campaigns appear. No progress bar is shown.

## 11. Notifications Flow

```text
WHL-14 Notifications
-> Reward notification -> WHL-06 Wallet
-> Withdrawal notification -> WHL-09 Withdrawal Detail
-> Campaign notification -> WHL-13 Campaign Detail
```

Opening a notification marks it read. Unknown/deleted targets show a safe unavailable message.

## 12. Profile Flow

```text
WHL-15 Profile
-> Read business identity
-> Language and Theme -> WHL-16 Preferences
-> Contact SGX -> phone/WhatsApp intent
-> Logout confirmation
   -> Clear protected state
   -> WHL-01 Phone Login
```

Business information is read-only.

## 13. Route Transition Map

| From | Action | To |
|---|---|---|
| WHL-00 Splash | no valid session | WHL-01 Phone Login |
| WHL-00 Splash | active wholesaler session | WHL-04 Home |
| WHL-01 Phone Login | Send OTP | WHL-02 OTP Verification |
| WHL-02 OTP Verification | active wholesaler | WHL-04 Home |
| WHL-02 OTP Verification | inactive/wrong role | WHL-03 Account Unavailable |
| WHL-04 Home | QR Progress | WHL-05 QR Progress |
| WHL-04 Home | Wallet | WHL-06 Wallet |
| WHL-04 Home | Withdraw | WHL-07 Withdraw Money |
| WHL-04 Home | Campaign | WHL-13 Campaign Detail |
| WHL-04 Home | Notification icon | WHL-14 Notifications |
| WHL-05 QR Progress | refresh | WHL-05 QR Progress |
| WHL-06 Wallet | Withdraw Money | WHL-07 Withdraw Money |
| WHL-06 Wallet | View Withdrawals | WHL-08 Withdrawals |
| WHL-07 Withdraw Money | Confirm success | WHL-09 Withdrawal Detail |
| WHL-08 Withdrawals | Select request | WHL-09 Withdrawal Detail |
| WHL-09 Withdrawal Detail | Not Received | WHL-09 Disputed state |
| WHL-10 Products | Select product | WHL-11 Product Detail |
| WHL-12 Campaigns | Select campaign | WHL-13 Campaign Detail |
| WHL-14 Notifications | Reward | WHL-06 Wallet |
| WHL-14 Notifications | Withdrawal | WHL-09 Withdrawal Detail |
| WHL-14 Notifications | Campaign | WHL-13 Campaign Detail |
| WHL-15 Profile | Preferences | WHL-16 Language and Theme |
| WHL-15 Profile | Logout | WHL-01 Phone Login |

## 14. Error and Offline Flow

```text
Any network-backed screen
-> Loading
   -> Content
   -> Empty
   -> Error with Retry
   -> Offline with Retry
```

No writes are queued offline. Withdrawal input is preserved locally only long enough to let the user retry safely.

## 15. Recommended Prototype Path

```text
Splash
-> Phone Login
-> OTP Verification
-> Home
-> QR Progress
-> Wallet
-> Withdraw Money
-> Confirm bottom sheet
-> Withdrawal Detail
-> Products
-> Product Detail
-> Campaigns
-> Campaign Detail
-> Notifications
-> Profile
-> Preferences
```
