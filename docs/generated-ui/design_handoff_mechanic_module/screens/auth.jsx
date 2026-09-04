// SGX Partners — Auth & Onboarding screens
// MEC-00 Splash, MEC-01 Phone Login, MEC-02 OTP, MEC-03 Account Unavailable,
// MEC-04 Complete Mechanic Profile

// ── MEC-00 Splash ────────────────────────────────────────────────────
function MecSplash() {
  return (
    <Phone bg="var(--sgx-primary)" statusBarTint="#ffffff" homeIndicatorTint="#ffffff">
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        color: 'white', gap: 24, padding: 32,
      }}>
        <SgxIcon size={112} radius={24} />
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.5 }}>SGX Partners</div>
          <div style={{ fontSize: 14, opacity: 0.8, marginTop: 6, letterSpacing: 0.4 }}>Scan · Earn · Withdraw</div>
        </div>
      </div>
      <div style={{
        position: 'absolute', bottom: 40, left: 0, right: 0,
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12,
      }}>
        <div style={{ width: 32, height: 32, borderRadius: 16, border: '3px solid rgba(255,255,255,0.25)', borderTopColor: '#fff' }}/>
        <div style={{ color: 'rgba(255,255,255,0.7)', fontSize: 12 }}>Loading…</div>
      </div>
    </Phone>
  );
}

// ── MEC-01 Phone Login ───────────────────────────────────────────────
function MecPhoneLogin() {
  return (
    <Phone>
      <div style={{ flex: 1, padding: '24px 24px 24px', display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
          <button style={{
            height: 36, padding: '0 14px', borderRadius: 18,
            border: '1px solid var(--sgx-outline-variant)',
            background: 'var(--sgx-surface)', color: 'var(--sgx-on-surface)',
            fontSize: 13, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 6,
            cursor: 'pointer',
          }}>
            <span className="material-symbols-rounded" style={{ fontSize: 18 }}>language</span>
            English
          </button>
        </div>
        <div style={{ marginTop: 40, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <SgxIcon size={72} radius={16} />
          <div style={{ marginTop: 20, fontSize: 26, fontWeight: 700, letterSpacing: -0.5 }}>Login to SGX Partners</div>
          <div style={{ marginTop: 8, fontSize: 15, color: 'var(--sgx-on-surface-variant)', textAlign: 'center', maxWidth: 280 }}>
            Enter your mobile number to continue.
          </div>
        </div>
        <div style={{ marginTop: 40 }}>
          <TextField label="Mobile Number" value="0300-1234567" prefix="+92" icon="smartphone" />
          <div style={{ marginTop: 20 }}>
            <FilledBtn icon="sms">Send OTP</FilledBtn>
          </div>
          <div style={{ marginTop: 16, fontSize: 12, color: 'var(--sgx-on-surface-variant)', textAlign: 'center' }}>
            An SMS with a 6-digit code will be sent.<br/>
            Standard SMS charges may apply.
          </div>
        </div>
        <div style={{ flex: 1 }} />
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6, color: 'var(--sgx-on-surface-variant)', fontSize: 12 }}>
          <span className="material-symbols-rounded" style={{ fontSize: 16 }}>shield</span>
          Secure login by SGX
        </div>
      </div>
    </Phone>
  );
}

// ── MEC-02 OTP Verification ──────────────────────────────────────────
function MecOtp() {
  const digits = ['3','8','4','5','', ''];
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="" />
      <div style={{ flex: 1, padding: '0 24px 24px', display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <SgxIcon size={48} radius={11} />
          <div style={{ marginTop: 16, fontSize: 24, fontWeight: 700 }}>Verify your number</div>
          <div style={{ marginTop: 8, fontSize: 14, color: 'var(--sgx-on-surface-variant)', textAlign: 'center' }}>
            We sent a 6-digit code to<br/>
            <span style={{ color: 'var(--sgx-on-surface)', fontWeight: 600 }}>+92 300-****567</span>
          </div>
        </div>

        <div style={{ marginTop: 32, display: 'flex', gap: 8, justifyContent: 'center' }}>
          {digits.map((d, i) => (
            <div key={i} style={{
              width: 46, height: 56, borderRadius: 8,
              border: `2px solid ${d ? 'var(--sgx-primary)' : (i === 4 ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)')}`,
              background: 'var(--sgx-surface)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 24, fontWeight: 700, fontVariantNumeric: 'tabular-nums',
              color: 'var(--sgx-on-surface)',
              position: 'relative',
            }}>
              {d}
              {i === 4 && !d && <div style={{
                position: 'absolute', width: 2, height: 24, background: 'var(--sgx-primary)',
                animation: 'blink 1s infinite',
              }}/>}
            </div>
          ))}
        </div>

        <div style={{ marginTop: 24, textAlign: 'center', color: 'var(--sgx-on-surface-variant)', fontSize: 14 }}>
          Resend code in <span style={{ color: 'var(--sgx-primary)', fontWeight: 600 }}>00:24</span>
        </div>

        <div style={{ marginTop: 32 }}>
          <FilledBtn icon="check">Verify</FilledBtn>
        </div>
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'center' }}>
          <TextBtn icon="edit">Change number</TextBtn>
        </div>
      </div>
    </Phone>
  );
}

// ── MEC-03 Account Unavailable (Inactive B2B) ────────────────────────
function MecAccountUnavailable() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="" />
      <div style={{ flex: 1, padding: '24px 24px 32px', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
        <div style={{ marginTop: 40, width: 112, height: 112, borderRadius: 56, background: 'var(--sgx-error-container)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <span className="material-symbols-rounded mi-fill" style={{ fontSize: 56, color: 'var(--sgx-error)' }}>person_off</span>
        </div>
        <div style={{ marginTop: 28, fontSize: 24, fontWeight: 700 }}>Account inactive</div>
        <div style={{ marginTop: 12, fontSize: 15, color: 'var(--sgx-on-surface-variant)', maxWidth: 300, lineHeight: '22px' }}>
          Your SGX Partners account is currently inactive. Please contact SGX to reactivate it.
        </div>
        <div style={{ flex: 1 }} />
        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 12 }}>
          <FilledBtn icon="support_agent">Contact SGX</FilledBtn>
          <OutlinedBtn icon="refresh">Use another number</OutlinedBtn>
        </div>
      </div>
    </Phone>
  );
}

// ── MEC-04 Complete Mechanic Profile ─────────────────────────────────
function MecOnboarding() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Complete your profile" />
      <Scroll pad={20} gap={20}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
          <SgxIcon size={48} radius={11} />
          <div style={{ marginTop: 12, fontSize: 14, color: 'var(--sgx-on-surface-variant)', maxWidth: 300 }}>
            Tell us a little about yourself so we can send your rewards to the right place.
          </div>
        </div>

        {/* Verified phone card */}
        <div style={{
          padding: 14, borderRadius: 12,
          background: 'var(--sgx-success-container)',
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <span className="material-symbols-rounded mi-fill" style={{ fontSize: 24, color: 'var(--sgx-success)' }}>verified</span>
          <div style={{ flex: 1 }}>
            <div className="t-supporting" style={{ color: 'var(--sgx-on-surface-variant)' }}>Verified phone</div>
            <div style={{ fontSize: 16, fontWeight: 700 }}>+92 300-1234567</div>
          </div>
          <span className="material-symbols-rounded" style={{ fontSize: 20, color: 'var(--sgx-on-surface-variant)' }}>lock</span>
        </div>

        <TextField label="Full Name *" value="Muhammad Farhan" icon="person" />
        <TextField label="Workshop / Shop Name (optional)" value="Farhan Motors" icon="storefront" />

        <div>
          <div style={{
            height: 56, borderRadius: 8,
            border: '1.5px solid var(--sgx-outline)',
            padding: '0 16px', display: 'flex', alignItems: 'center', gap: 10,
            background: 'var(--sgx-surface)',
          }}>
            <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>location_on</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>Area / City *</div>
              <div style={{ fontSize: 16, fontWeight: 500 }}>Lahore, Gulberg</div>
            </div>
            <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>expand_more</span>
          </div>
        </div>

        <div style={{
          padding: 12, borderRadius: 12,
          background: 'var(--sgx-surface-container)',
          display: 'flex', gap: 10, alignItems: 'flex-start',
        }}>
          <span className="material-symbols-rounded" style={{ fontSize: 20, color: 'var(--sgx-primary)' }}>info</span>
          <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', lineHeight: '18px' }}>
            You do not need to choose a shop or wholesaler. Rewards come from the SGX QR you scan.
          </div>
        </div>

        <div style={{ marginTop: 8 }}>
          <FilledBtn icon="arrow_forward">Continue</FilledBtn>
        </div>
      </Scroll>
    </Phone>
  );
}

Object.assign(window, { MecSplash, MecPhoneLogin, MecOtp, MecAccountUnavailable, MecOnboarding });
