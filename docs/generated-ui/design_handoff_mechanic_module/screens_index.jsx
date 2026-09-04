// Mount all mechanic screens onto the DesignCanvas
// Grouped by flow, phone-sized artboards

const { useState, useEffect } = React;

function App() {
  return (
    <DesignCanvas>
      {/* 1. Auth & Onboarding */}
      <DCSection id="auth" title="1 · Authentication & Onboarding" subtitle="MEC-00 → MEC-04 · Splash, phone login, OTP, blocked, complete profile">
        <DCArtboard id="mec-00" label="MEC-00 · Splash" width={PHONE_W} height={PHONE_H}><MecSplash /></DCArtboard>
        <DCArtboard id="mec-01" label="MEC-01 · Phone Login" width={PHONE_W} height={PHONE_H}><MecPhoneLogin /></DCArtboard>
        <DCArtboard id="mec-02" label="MEC-02 · OTP Verification" width={PHONE_W} height={PHONE_H}><MecOtp /></DCArtboard>
        <DCArtboard id="mec-03" label="MEC-03 · Account Unavailable" width={PHONE_W} height={PHONE_H}><MecAccountUnavailable /></DCArtboard>
        <DCArtboard id="mec-04" label="MEC-04 · Complete Mechanic Profile" width={PHONE_W} height={PHONE_H}><MecOnboarding /></DCArtboard>
      </DCSection>

      {/* 2. Home */}
      <DCSection id="home" title="2 · Home" subtitle="MEC-05 · The mechanic's daily launchpad">
        <DCArtboard id="mec-05" label="MEC-05 · Home" width={PHONE_W} height={PHONE_H}><MecHome /></DCArtboard>
      </DCSection>

      {/* 3. Scanner & Results */}
      <DCSection id="scan" title="3 · QR Scanner & Result States" subtitle="MEC-06 → MEC-07 · Online scanning with 6 result variants">
        <DCArtboard id="mec-06a" label="MEC-06 · Scanner (ready)" width={PHONE_W} height={PHONE_H}><MecScanner /></DCArtboard>
        <DCArtboard id="mec-06b" label="MEC-06 · Scanner (no internet)" width={PHONE_W} height={PHONE_H}><MecScannerOffline /></DCArtboard>
        <DCArtboard id="mec-07a" label="MEC-07 · Success · Reward added" width={PHONE_W} height={PHONE_H}><MecScanSuccess /></DCArtboard>
        <DCArtboard id="mec-07b" label="MEC-07 · Already scanned" width={PHONE_W} height={PHONE_H}><MecScanAlready /></DCArtboard>
        <DCArtboard id="mec-07c" label="MEC-07 · QR not active" width={PHONE_W} height={PHONE_H}><MecScanNotActive /></DCArtboard>
        <DCArtboard id="mec-07d" label="MEC-07 · Invalid QR" width={PHONE_W} height={PHONE_H}><MecScanInvalid /></DCArtboard>
        <DCArtboard id="mec-07e" label="MEC-07 · Expired QR" width={PHONE_W} height={PHONE_H}><MecScanExpired /></DCArtboard>
        <DCArtboard id="mec-07f" label="MEC-07 · Network failure" width={PHONE_W} height={PHONE_H}><MecScanNetwork /></DCArtboard>
      </DCSection>

      {/* 4. Wallet & Money */}
      <DCSection id="wallet" title="4 · Wallet & Withdrawals" subtitle="MEC-08 → MEC-12 · Scan history, balance, withdraw, list, detail">
        <DCArtboard id="mec-08" label="MEC-08 · Scan History" width={PHONE_W} height={PHONE_H}><MecScanHistory /></DCArtboard>
        <DCArtboard id="mec-09" label="MEC-09 · Wallet" width={PHONE_W} height={PHONE_H}><MecWallet /></DCArtboard>
        <DCArtboard id="mec-10" label="MEC-10 · Withdraw Money" width={PHONE_W} height={PHONE_H}><MecWithdraw /></DCArtboard>
        <DCArtboard id="mec-11" label="MEC-11 · Withdrawals" width={PHONE_W} height={PHONE_H}><MecWithdrawals /></DCArtboard>
        <DCArtboard id="mec-12" label="MEC-12 · Withdrawal Detail (Paid)" width={PHONE_W} height={PHONE_H}><MecWithdrawalDetail /></DCArtboard>
      </DCSection>

      {/* 5. Catalog */}
      <DCSection id="catalog" title="5 · Products & Campaigns" subtitle="MEC-13 → MEC-16 · Price-free catalog and promotional content">
        <DCArtboard id="mec-13" label="MEC-13 · Products" width={PHONE_W} height={PHONE_H}><MecProducts /></DCArtboard>
        <DCArtboard id="mec-14" label="MEC-14 · Product Detail" width={PHONE_W} height={PHONE_H}><MecProductDetail /></DCArtboard>
        <DCArtboard id="mec-15" label="MEC-15 · Campaigns" width={PHONE_W} height={PHONE_H}><MecCampaigns /></DCArtboard>
        <DCArtboard id="mec-16" label="MEC-16 · Campaign Detail" width={PHONE_W} height={PHONE_H}><MecCampaignDetail /></DCArtboard>
      </DCSection>

      {/* 6. Notifications & Profile */}
      <DCSection id="account" title="6 · Notifications, Profile & Settings" subtitle="MEC-17 → MEC-20 · Alerts, identity, preferences">
        <DCArtboard id="mec-17" label="MEC-17 · Notifications" width={PHONE_W} height={PHONE_H}><MecNotifications /></DCArtboard>
        <DCArtboard id="mec-18" label="MEC-18 · Profile" width={PHONE_W} height={PHONE_H}><MecProfile /></DCArtboard>
        <DCArtboard id="mec-19" label="MEC-19 · Edit Profile" width={PHONE_W} height={PHONE_H}><MecEditProfile /></DCArtboard>
        <DCArtboard id="mec-20" label="MEC-20 · Language & Theme" width={PHONE_W} height={PHONE_H}><MecPreferences /></DCArtboard>
      </DCSection>

      {/* 7. Localization stress */}
      <DCSection id="urdu" title="7 · Urdu / RTL Sample" subtitle="Right-to-left home screen — proves the theme + component set work bilingually">
        <DCArtboard id="urdu-home" label="Home · اردو" width={PHONE_W} height={PHONE_H}><MecHomeUrdu /></DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
