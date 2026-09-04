// SGX Partners — Wholesaler screens mounted on the Design Canvas
// Grouped by flow. Phone-sized artboards (390 × 844).

function App() {
  return (
    <DesignCanvas>

      {/* 1 · Auth & Access */}
      <DCSection
        id="auth"
        title="1 · Authentication & Access"
        subtitle="WHL-00 → WHL-03 · Splash, phone login, OTP, and 3 access-blocked states. Admin creates wholesaler accounts — there is no signup here."
      >
        <DCArtboard id="whl-00"  label="WHL-00 · Splash"                     width={PHONE_W} height={PHONE_H}><WhlSplash /></DCArtboard>
        <DCArtboard id="whl-01"  label="WHL-01 · Phone Login"                width={PHONE_W} height={PHONE_H}><WhlPhoneLogin /></DCArtboard>
        <DCArtboard id="whl-02"  label="WHL-02 · OTP Verification"           width={PHONE_W} height={PHONE_H}><WhlOtp /></DCArtboard>
        <DCArtboard id="whl-03a" label="WHL-03 · Account inactive"           width={PHONE_W} height={PHONE_H}><WhlAccountInactive /></DCArtboard>
        <DCArtboard id="whl-03b" label="WHL-03 · B2B access unavailable"     width={PHONE_W} height={PHONE_H}><WhlWrongRole /></DCArtboard>
        <DCArtboard id="whl-03c" label="WHL-03 · Account unavailable"        width={PHONE_W} height={PHONE_H}><WhlAccountNotFound /></DCArtboard>
      </DCSection>

      {/* 2 · Home & QR Progress */}
      <DCSection
        id="home"
        title="2 · Home & QR Progress"
        subtitle="WHL-04 & WHL-05 · The daily dashboard for a wholesaler — money in, QRs scanned, one primary Withdraw action."
      >
        <DCArtboard id="whl-04"  label="WHL-04 · Home"                       width={PHONE_W} height={PHONE_H}><WhlHome /></DCArtboard>
        <DCArtboard id="whl-04b" label="WHL-04 · Home (new account, no rewards)" width={PHONE_W} height={PHONE_H}><WhlHomeEmpty /></DCArtboard>
        <DCArtboard id="whl-05"  label="WHL-05 · QR Progress"                width={PHONE_W} height={PHONE_H}><WhlQrProgress /></DCArtboard>
        <DCArtboard id="whl-05b" label="WHL-05 · QR Progress (empty)"        width={PHONE_W} height={PHONE_H}><WhlQrProgressEmpty /></DCArtboard>
      </DCSection>

      {/* 3 · Wallet & Withdrawals */}
      <DCSection
        id="wallet"
        title="3 · Wallet & Withdrawal Flow"
        subtitle="WHL-06 → WHL-08 · Available / Pending / Lifetime · request → confirmation sheet → list"
      >
        <DCArtboard id="whl-06"   label="WHL-06 · Wallet"                     width={PHONE_W} height={PHONE_H}><WhlWallet /></DCArtboard>
        <DCArtboard id="whl-07"   label="WHL-07 · Withdraw Money"             width={PHONE_W} height={PHONE_H}><WhlWithdraw /></DCArtboard>
        <DCArtboard id="whl-07b"  label="WHL-07 · Confirm bottom sheet"       width={PHONE_W} height={PHONE_H}><WhlWithdrawConfirm /></DCArtboard>
        <DCArtboard id="whl-08"   label="WHL-08 · Withdrawals"                width={PHONE_W} height={PHONE_H}><WhlWithdrawals /></DCArtboard>
      </DCSection>

      {/* 4 · Withdrawal Detail — every lifecycle state */}
      <DCSection
        id="withdrawal-detail"
        title="4 · Withdrawal Detail Lifecycle"
        subtitle="WHL-09 · Pending → Payment Sent → Confirmed / Disputed / Auto-confirmed / Refunded. The critical trust surface."
      >
        <DCArtboard id="whl-09a" label="WHL-09 · Pending"                       width={PHONE_W} height={PHONE_H}><WhlWdPending /></DCArtboard>
        <DCArtboard id="whl-09b" label="WHL-09 · Payment Sent (awaiting user)"  width={PHONE_W} height={PHONE_H}><WhlWdPaymentSent /></DCArtboard>
        <DCArtboard id="whl-09c" label="WHL-09 · Not Received dialog"           width={PHONE_W} height={PHONE_H}><WhlWdNotReceivedDialog /></DCArtboard>
        <DCArtboard id="whl-09d" label="WHL-09 · Disputed"                      width={PHONE_W} height={PHONE_H}><WhlWdDisputed /></DCArtboard>
        <DCArtboard id="whl-09e" label="WHL-09 · Confirmed"                     width={PHONE_W} height={PHONE_H}><WhlWdConfirmed /></DCArtboard>
        <DCArtboard id="whl-09f" label="WHL-09 · Auto-confirmed"                width={PHONE_W} height={PHONE_H}><WhlWdConfirmed auto /></DCArtboard>
        <DCArtboard id="whl-09g" label="WHL-09 · Refunded"                      width={PHONE_W} height={PHONE_H}><WhlWdRefunded /></DCArtboard>
      </DCSection>

      {/* 5 · Products & Campaigns */}
      <DCSection
        id="catalog"
        title="5 · Products & Campaigns"
        subtitle="WHL-10 → WHL-13 · Price-free browsing + wholesaler-targeted promotions"
      >
        <DCArtboard id="whl-10" label="WHL-10 · Products"          width={PHONE_W} height={PHONE_H}><WhlProducts /></DCArtboard>
        <DCArtboard id="whl-11" label="WHL-11 · Product Detail"    width={PHONE_W} height={PHONE_H}><WhlProductDetail /></DCArtboard>
        <DCArtboard id="whl-12" label="WHL-12 · Campaigns"         width={PHONE_W} height={PHONE_H}><WhlCampaigns /></DCArtboard>
        <DCArtboard id="whl-13" label="WHL-13 · Campaign Detail"   width={PHONE_W} height={PHONE_H}><WhlCampaignDetail /></DCArtboard>
      </DCSection>

      {/* 6 · Notifications, Profile & Preferences */}
      <DCSection
        id="account"
        title="6 · Notifications, Profile & Preferences"
        subtitle="WHL-14 → WHL-16 · Alerts, read-only business identity, and language/theme"
      >
        <DCArtboard id="whl-14" label="WHL-14 · Notifications"       width={PHONE_W} height={PHONE_H}><WhlNotifications /></DCArtboard>
        <DCArtboard id="whl-15" label="WHL-15 · Profile"             width={PHONE_W} height={PHONE_H}><WhlProfile /></DCArtboard>
        <DCArtboard id="whl-16" label="WHL-16 · Language & Theme"    width={PHONE_W} height={PHONE_H}><WhlPreferences /></DCArtboard>
      </DCSection>

      {/* 7 · Urdu / RTL sample */}
      <DCSection
        id="urdu"
        title="7 · اردو / RTL Sample"
        subtitle="Right-to-left home screen — proves the theme + component set work bilingually for low-literacy users."
      >
        <DCArtboard id="urdu-home" label="WHL-04 · Home · اردو" width={PHONE_W} height={PHONE_H}><WhlHomeUrdu /></DCArtboard>
      </DCSection>

    </DesignCanvas>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
