// SGX Partners — Wholesaler · Authentication & Access States
// WHL-00 Splash · WHL-01 Phone Login · WHL-02 OTP Verification · WHL-03 Account Unavailable (×3 variants)

// ── WHL-00 Splash ────────────────────────────────────────────────────
function WhlSplash() {
  return (
    <Phone bg="var(--sgx-primary)" statusBarTint="#ffffff" homeIndicatorTint="#ffffff">
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        color: 'white', gap: 24, padding: 24, textAlign: 'center',
      }}>
        {/* 112dp brand icon per spec */}
        <div style={{
          padding: 6, borderRadius: 28, background: 'rgba(255,255,255,0.06)',
          boxShadow: '0 20px 60px rgba(0,0,0,0.25)',
        }}>
          <SgxIcon size={112} radius={26} />
        </div>
        <div>
          <div style={{ fontSize: 28, fontWeight: 800, letterSpacing: -0.5 }}>SGX Partners</div>
          <div style={{ marginTop: 6, fontSize: 14, opacity: 0.75, fontWeight: 500 }}>Business rewards, one tap away.</div>
        </div>
      </div>
      <div style={{ paddingBottom: 40, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10 }}>
        {/* Loading indicator only when >1s */}
        <div style={{ display: 'flex', gap: 6 }}>
          {[0,1,2].map(i => (
            <div key={i} style={{
              width: 8, height: 8, borderRadius: 4, background: 'white',
              opacity: 0.35 + i * 0.2,
            }} />
          ))}
        </div>
        <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.55)', fontWeight: 500, letterSpacing: 0.5 }}>SGX PARTNERS · v1.0</div>
      </div>
    </Phone>
  );
}

// ── WHL-01 Phone Login ───────────────────────────────────────────────
function WhlPhoneLogin() {
  return (
    <Phone>
      <TopAppBar
        title=""
        leading={<div style={{width:12}}/>}
        trailing={<TextBtn icon="language">EN</TextBtn>}
      />
      <Scroll pad={24} gap={0}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', paddingTop: 20 }}>
          <SgxIcon size={72} radius={16} />
          <div style={{ marginTop: 20, fontSize: 26, fontWeight: 700, textAlign: 'center', letterSpacing: -0.3 }}>Login to SGX Partners</div>
          <div style={{ marginTop: 8, fontSize: 14, color: 'var(--sgx-on-surface-variant)', textAlign: 'center', lineHeight: 1.5 }}>
            Enter your registered mobile number.
          </div>
        </div>

        <div style={{ marginTop: 40, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <TextField
            label="Mobile number"
            value="0300-1234567"
            prefix="🇵🇰"
            icon="phone_iphone"
            helper="Format: 03XX-XXXXXXX"
          />
        </div>

        <div style={{ marginTop: 32 }}>
          <FilledBtn icon="sms">Send OTP</FilledBtn>
        </div>

        {/* Help notice */}
        <div style={{
          marginTop: 24, padding: '14px 16px', borderRadius: 12,
          background: 'var(--sgx-surface-container)',
          display: 'flex', gap: 12, alignItems: 'flex-start',
        }}>
          <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22, color: 'var(--sgx-primary)' }}>badge</span>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 600 }}>Wholesaler account required</div>
            <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 3, lineHeight: 1.5 }}>
              Wholesaler accounts are created by SGX staff. Contact SGX to be added.
            </div>
          </div>
        </div>

        <div style={{ marginTop: 'auto', paddingTop: 32, textAlign: 'center', fontSize: 12, color: 'var(--sgx-on-surface-variant)' }}>
          By continuing you agree to our <span style={{ color: 'var(--sgx-primary)', fontWeight: 600 }}>Terms</span> and <span style={{ color: 'var(--sgx-primary)', fontWeight: 600 }}>Privacy</span>.
        </div>
      </Scroll>
    </Phone>
  );
}

// ── WHL-02 OTP Verification ──────────────────────────────────────────
function WhlOtp() {
  const digits = ['4','8','2','1','',''];
  return (
    <Phone>
      <TopAppBar
        leading={<BackBtn />}
        title=""
      />
      <Scroll pad={24} gap={0}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <SgxIcon size={48} radius={11} />
          <div style={{ marginTop: 20, fontSize: 24, fontWeight: 700, textAlign: 'center' }}>Verify your number</div>
          <div style={{ marginTop: 8, fontSize: 14, color: 'var(--sgx-on-surface-variant)', textAlign: 'center', lineHeight: 1.5 }}>
            We sent a 6-digit code to<br/>
            <span style={{ color: 'var(--sgx-on-surface)', fontWeight: 600, letterSpacing: 0.5 }}>+92 300 ••• 4567</span>
          </div>
        </div>

        {/* OTP boxes */}
        <div style={{ marginTop: 36, display: 'flex', gap: 10, justifyContent: 'center' }}>
          {digits.map((d, i) => (
            <div key={i} style={{
              width: 48, height: 56, borderRadius: 12,
              border: `2px solid ${d ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              background: d ? 'rgba(30,58,138,0.06)' : 'var(--sgx-surface)',
              fontSize: 24, fontWeight: 700, fontVariantNumeric: 'tabular-nums',
              color: d ? 'var(--sgx-primary)' : 'var(--sgx-on-surface-variant)',
              position: 'relative',
            }}>
              {d}
              {i === 4 && (
                <div style={{
                  position: 'absolute', width: 2, height: 24, background: 'var(--sgx-primary)',
                  animation: 'blink 1s infinite',
                }}/>
              )}
            </div>
          ))}
        </div>

        {/* Resend */}
        <div style={{ marginTop: 24, textAlign: 'center', fontSize: 13, color: 'var(--sgx-on-surface-variant)' }}>
          Didn't get the code? <span style={{ color: 'var(--sgx-on-surface-variant)', opacity: 0.6, fontWeight: 500 }}>Resend in 0:32</span>
        </div>

        <div style={{ marginTop: 32 }}>
          <FilledBtn icon="check">Verify</FilledBtn>
        </div>

        <div style={{ marginTop: 12, textAlign: 'center' }}>
          <TextBtn icon="edit">Change number</TextBtn>
        </div>
      </Scroll>
    </Phone>
  );
}

// ── WHL-03 Account Unavailable ───────────────────────────────────────
// 3 variants: inactive · wrong-role · not-found

function _UnavailableFrame({ icon, iconTint, iconBg, title, message, primary, secondary }) {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="" />
      <Scroll pad={24} gap={0}>
        <div style={{
          flex: 1, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center',
          textAlign: 'center', padding: '20px 0',
        }}>
          <div style={{
            width: 96, height: 96, borderRadius: 48,
            background: iconBg,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            marginBottom: 24,
          }}>
            <span className="material-symbols-rounded mi-fill" style={{ fontSize: 56, color: iconTint }}>{icon}</span>
          </div>
          <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.3 }}>{title}</div>
          <div style={{ marginTop: 10, fontSize: 14, color: 'var(--sgx-on-surface-variant)', lineHeight: 1.55, maxWidth: 280 }}>
            {message}
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, paddingBottom: 20 }}>
          <FilledBtn icon={primary.icon}>{primary.label}</FilledBtn>
          {secondary && <OutlinedBtn>{secondary}</OutlinedBtn>}
        </div>
      </Scroll>
    </Phone>
  );
}

function WhlAccountInactive() {
  return _UnavailableFrame({
    icon: 'person_off',
    iconTint: 'var(--sgx-error)',
    iconBg: 'var(--sgx-error-container)',
    title: 'Account inactive',
    message: 'Your account is inactive. Please contact SGX to reactivate your wholesaler account.',
    primary: { icon: 'support_agent', label: 'Contact SGX' },
    secondary: 'Use another number',
  });
}

function WhlWrongRole() {
  return _UnavailableFrame({
    icon: 'lock',
    iconTint: 'var(--sgx-primary)',
    iconBg: 'rgba(30,58,138,0.10)',
    title: 'B2B access unavailable',
    message: 'This account cannot access the B2B app. Please use your registered wholesaler number.',
    primary: { icon: 'phone_iphone', label: 'Use another number' },
  });
}

function WhlAccountNotFound() {
  return _UnavailableFrame({
    icon: 'person_search',
    iconTint: '#8A5A00',
    iconBg: 'var(--sgx-warning-container)',
    title: 'Account unavailable',
    message: 'We could not find an active account for this number. Contact SGX if you think this is a mistake.',
    primary: { icon: 'arrow_back', label: 'Back to Login' },
  });
}

Object.assign(window, {
  WhlSplash, WhlPhoneLogin, WhlOtp,
  WhlAccountInactive, WhlWrongRole, WhlAccountNotFound,
});
