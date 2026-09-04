# SGX Partners — Mechanic Screen Flow

**Purpose:** Navigation and journey map for the mechanic role.  
**Rules:** Unknown verified phone numbers may self-register as mechanics. Scanning is online-only.

---

## 1. Entry and Authentication

```text
App Launch
-> MEC-00 Splash: SGX Partners icon and name
-> Auth session check
   -> No session: MEC-01 Phone Login
   -> Active mechanic session: MEC-05 Home
   -> Active wholesaler session: Wholesaler Home
   -> Inactive/wrong-role session: MEC-03 Account Unavailable
```

```text
MEC-01 Phone Login
-> Enter phone
-> Send OTP
-> MEC-02 OTP Verification
-> Verify OTP
-> Resolve protected profile
   -> Active mechanic: MEC-05 Home
   -> No profile: MEC-04 Complete Mechanic Profile
   -> Active wholesaler: Wholesaler Home
   -> Inactive mechanic/wholesaler: MEC-03 Account Unavailable
   -> Customer/staff: MEC-03 Account Unavailable
```

```text
MEC-04 Complete Mechanic Profile
-> Enter Full Name
-> Optional Workshop/Shop Name
-> Select Area/City
-> Continue
-> Create mechanic profile
-> MEC-05 Home
```

No role selection or wholesaler selection appears.

## 2. Main Navigation

Approved reference pattern:

```text
Material 3 BottomAppBar
  Home       -> MEC-05
  Products   -> MEC-13
  [Scan]     -> MEC-06, raised center action
  Wallet     -> MEC-09
  Profile    -> MEC-18
```

The center Scan action is visually larger and raised above the bar. It opens the scanner and is not a persistent tab.

Top app bar:

- Notifications -> MEC-17.
- Back arrow on pushed screens.

## 3. Home Flow

```text
MEC-05 Home
-> Scan QR -> MEC-06 Scanner
-> Latest scan / View history -> MEC-08 Scan History
-> Wallet card -> MEC-09 Wallet
-> Withdraw action -> MEC-10 Withdraw Money
-> Product shortcut -> MEC-13 Products
-> Campaign banner -> MEC-16 Campaign Detail
-> Notifications icon -> MEC-17 Notifications
-> Withdrawal status -> MEC-12 Withdrawal Detail
```

## 4. Online Scan Flow

```text
MEC-06 QR Scanner
-> Check internet
   -> Offline: show reconnect state, do not scan/queue
   -> Online: check camera permission
-> Camera sees QR
-> Pause scanner to prevent duplicate reads
-> Send payload to trusted server operation
-> Processing state
-> MEC-07 Scan Result state
```

### Success

```text
Server validates active, unused QR
-> Atomically credit mechanic and invoice wholesaler
-> Mark QR scanned
-> Return reward and product
-> Show Reward Added
   -> Scan Another: MEC-06
   -> Open Wallet: MEC-09
```

### Failure

```text
Already scanned -> show Already Scanned
Invoice not dispatched -> show QR Not Active
Invalid signature/unknown QR -> show Invalid SGX QR
Expired -> show Expired QR
Inactive mechanic -> MEC-03 Account Unavailable
Network/server interruption -> show Retry or Close; never queue
```

## 5. Scan History Flow

```text
MEC-08 Scan History
-> Load confirmed scans from server
-> View product, time, and reward
-> Pull to refresh
```

There are no Pending, Offline, Syncing, or Rejected offline rows.

## 6. Wallet Flow

```text
MEC-09 Wallet
-> Review Available / Pending / Lifetime Earned
-> Review recent transactions
-> Withdraw Money -> MEC-10
-> View Withdrawals -> MEC-11
-> Open active/recent withdrawal -> MEC-12
```

## 7. Withdrawal Request Flow

```text
MEC-10 Withdraw Money
-> Enter amount
-> Choose method
-> Enter destination details
-> Continue
-> Confirmation bottom sheet
   -> Cancel: remain on MEC-10
   -> Confirm: submit online
      -> Success -> MEC-12 Withdrawal Detail
      -> Failure -> preserve form and Retry
```

No withdrawal write is queued offline.

## 8. Withdrawal Lifecycle

```text
Pending
-> Admin sends payment
-> Paid Awaiting Confirmation
   -> Received -> Confirmed
   -> Not Received -> Disputed
   -> No response -> Auto-confirmed
```

```text
Disputed
-> Contact SGX
-> Admin re-pays -> Paid Awaiting Confirmation
-> Admin resolves -> Confirmed
-> Admin refunds -> Refunded and amount returns to Available
```

All states render within MEC-12.

## 9. Products Flow

```text
MEC-13 Products
-> Search/category filter
-> Select product
-> MEC-14 Product Detail
```

No price, cart, order, or stock action.

## 10. Campaign Flow

```text
MEC-05 Home campaign banner -> MEC-16 Campaign Detail
MEC-15 Campaigns -> MEC-16 Campaign Detail
MEC-17 Campaign notification -> MEC-16 Campaign Detail
```

Only active mechanic-targeted campaigns appear. No progress bar.

## 11. Notifications Flow

```text
MEC-17 Notifications
-> Reward notification -> MEC-09 Wallet or MEC-08 Scan History
-> Withdrawal notification -> MEC-12 Withdrawal Detail
-> Campaign notification -> MEC-16 Campaign Detail
```

## 12. Profile Flow

```text
MEC-18 Profile
-> Edit Profile -> MEC-19
-> Language and Theme -> MEC-20
-> Contact SGX
-> Logout confirmation
   -> Clear protected state
   -> MEC-01 Phone Login
```

```text
MEC-19 Edit Profile
-> Update name/workshop/area
-> Save
-> MEC-18 Profile
```

Phone and role remain read-only.

## 13. Route Transition Map

| From | Action | To |
|---|---|---|
| MEC-00 Splash | no valid session | MEC-01 Phone Login |
| MEC-00 Splash | active mechanic session | MEC-05 Home |
| MEC-01 Phone Login | Send OTP | MEC-02 OTP Verification |
| MEC-02 OTP Verification | existing mechanic | MEC-05 Home |
| MEC-02 OTP Verification | unknown phone | MEC-04 Complete Profile |
| MEC-02 OTP Verification | inactive/wrong role | MEC-03 Account Unavailable |
| MEC-04 Complete Profile | Continue | MEC-05 Home |
| MEC-05 Home | Scan QR | MEC-06 QR Scanner |
| MEC-05 Home | Scan History | MEC-08 Scan History |
| MEC-05 Home | Wallet | MEC-09 Wallet |
| MEC-06 QR Scanner | server result | MEC-07 Scan Result state |
| MEC-07 Scan Result | Scan Another | MEC-06 QR Scanner |
| MEC-07 Scan Result | Open Wallet | MEC-09 Wallet |
| MEC-09 Wallet | Withdraw Money | MEC-10 Withdraw Money |
| MEC-09 Wallet | View Withdrawals | MEC-11 Withdrawals |
| MEC-10 Withdraw Money | Confirm success | MEC-12 Withdrawal Detail |
| MEC-11 Withdrawals | Select request | MEC-12 Withdrawal Detail |
| MEC-13 Products | Select product | MEC-14 Product Detail |
| MEC-15 Campaigns | Select campaign | MEC-16 Campaign Detail |
| MEC-17 Notifications | Reward | MEC-09 Wallet or MEC-08 History |
| MEC-17 Notifications | Withdrawal | MEC-12 Withdrawal Detail |
| MEC-17 Notifications | Campaign | MEC-16 Campaign Detail |
| MEC-18 Profile | Edit | MEC-19 Edit Profile |
| MEC-18 Profile | Preferences | MEC-20 Language and Theme |
| MEC-18 Profile | Logout | MEC-01 Phone Login |

## 14. Error and Offline Flow

```text
Any network-backed screen
-> Loading
   -> Content
   -> Empty
   -> Error with Retry
   -> Offline with Retry
```

Scanner-specific offline flow:

```text
Open Scanner without internet
-> Show “Internet is required to scan a QR.”
-> Retry connectivity or Close
-> Do not open processing and do not store payload
```

## 15. Recommended Prototype Path

```text
Splash
-> Phone Login
-> OTP Verification
-> Complete Mechanic Profile
-> Home
-> Products
-> Product Detail
-> Center Scan
-> Scan Success
-> Scan History
-> Wallet
-> Withdraw Money
-> Withdrawal Detail
-> Campaigns
-> Campaign Detail
-> Notifications
-> Profile
-> Edit Profile
-> Preferences
```
