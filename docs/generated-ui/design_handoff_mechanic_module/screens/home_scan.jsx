// SGX Partners — Home, Scanner, and Scan Result variants
// MEC-05 Home, MEC-06 Scanner (ready + offline), MEC-07 Scan Result (6 states)

// ── MEC-05 Home ──────────────────────────────────────────────────────
function MecHome() {
  return (
    <Phone>
      <TopAppBar
        title="SGX Partners"
        showBrand
        leading={<div style={{ width: 12 }}/>}
        trailing={<IconBtn icon="notifications" badge="3" />}
      />
      <Scroll pad={0} gap={20}>
        {/* Greeting */}
        <div style={{ padding: '4px 20px 0' }}>
          <div style={{ fontSize: 14, color: 'var(--sgx-on-surface-variant)' }}>Assalam-o-Alaikum,</div>
          <div style={{ fontSize: 22, fontWeight: 700, marginTop: 2 }}>Muhammad Farhan 👋</div>
        </div>

        {/* Wallet Hero */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 20, borderRadius: 20,
            background: 'linear-gradient(135deg, var(--sgx-primary) 0%, oklch(0.28 0.14 265) 100%)',
            color: 'white', position: 'relative', overflow: 'hidden',
            boxShadow: '0 8px 20px rgba(30,58,138,0.25)',
          }}>
            <div style={{ position: 'absolute', right: -30, top: -30, width: 140, height: 140, borderRadius: 70, background: 'rgba(255,255,255,0.06)' }}/>
            <div style={{ position: 'absolute', right: 30, bottom: -50, width: 100, height: 100, borderRadius: 50, background: 'rgba(255,255,255,0.04)' }}/>

            <div style={{ display: 'flex', alignItems: 'center', gap: 8, opacity: 0.85 }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20 }}>account_balance_wallet</span>
              <span style={{ fontSize: 13, fontWeight: 500 }}>Available Balance</span>
            </div>
            <div style={{ marginTop: 6, fontSize: 40, fontWeight: 800, letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>
              Rs. 4,285
            </div>

            <div style={{ display: 'flex', gap: 20, marginTop: 20, paddingTop: 14, borderTop: '1px solid rgba(255,255,255,0.15)' }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 11, opacity: 0.7, textTransform: 'uppercase', letterSpacing: 0.4 }}>Pending</div>
                <div style={{ fontSize: 15, fontWeight: 700, marginTop: 2 }}>Rs. 1,500</div>
              </div>
              <div style={{ width: 1, background: 'rgba(255,255,255,0.15)' }}/>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 11, opacity: 0.7, textTransform: 'uppercase', letterSpacing: 0.4 }}>Lifetime</div>
                <div style={{ fontSize: 15, fontWeight: 700, marginTop: 2 }}>Rs. 28,540</div>
              </div>
            </div>

            <button style={{
              marginTop: 16, width: '100%', height: 44,
              borderRadius: 22, border: 'none',
              background: 'white', color: 'var(--sgx-primary)',
              fontSize: 15, fontWeight: 700,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              cursor: 'pointer', position: 'relative',
            }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20 }}>payments</span>
              Withdraw Money
            </button>
          </div>
        </div>

        {/* Big Scan CTA */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: '20px 16px', borderRadius: 16,
            background: 'var(--sgx-surface-container)',
            border: '2px dashed rgba(30,58,138,0.20)',
            display: 'flex', alignItems: 'center', gap: 16,
          }}>
            <div style={{
              width: 64, height: 64, borderRadius: 32,
              background: 'var(--sgx-primary)', color: 'white',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: '0 4px 12px rgba(30,58,138,0.35)',
            }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 34 }}>qr_code_scanner</span>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 17, fontWeight: 700 }}>Scan SGX QR</div>
              <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>Scan a product QR to earn rupees.</div>
            </div>
            <span className="material-symbols-rounded" style={{ fontSize: 24, color: 'var(--sgx-primary)' }}>arrow_forward</span>
          </div>
        </div>

        {/* Latest scan */}
        <div>
          <SectionHeader title="Latest scan" action="History" />
          <div style={{ padding: '0 16px' }}>
            <div style={{
              padding: 14, borderRadius: 12,
              background: 'var(--sgx-surface-container)',
              display: 'flex', alignItems: 'center', gap: 12,
            }}>
              <ImgSlot w={56} h={56} radius={10} kind="oil" />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 15, fontWeight: 600, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>Shell Advance AX7 10W-40</div>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>Today · 10:24 AM</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: 17, fontWeight: 700, color: 'var(--sgx-success)', fontVariantNumeric: 'tabular-nums' }}>+ Rs. 15</div>
                <StatusChip status="confirmed" label="Confirmed" size="sm" />
              </div>
            </div>
          </div>
        </div>

        {/* Withdrawal in progress */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 14, borderRadius: 12,
            background: 'var(--sgx-warning-container)',
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{ width: 40, height: 40, borderRadius: 20, background: 'rgba(0,0,0,0.06)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22, color: '#8A5A00' }}>schedule</span>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600 }}>Withdrawal in progress</div>
              <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>Rs. 1,500 · JazzCash · Submitted today</div>
            </div>
            <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>chevron_right</span>
          </div>
        </div>

        {/* Campaign banner */}
        <div>
          <SectionHeader title="Active campaign" action="See all" />
          <div style={{ padding: '0 16px' }}>
            <div style={{
              borderRadius: 16, overflow: 'hidden',
              boxShadow: 'var(--sgx-e1)',
            }}>
              <ImgSlot w="100%" h={140} radius={0} kind="camp" label="Ramzan Bonus" />
              <div style={{ padding: 14, background: 'var(--sgx-surface-container)' }}>
                <div style={{ fontSize: 15, fontWeight: 700 }}>Ramzan Bonus — Double Rewards</div>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 4 }}>Until 30 Ramzan · On all Shell products</div>
              </div>
            </div>
          </div>
        </div>

        {/* Quick actions */}
        <div>
          <SectionHeader title="Quick actions" />
          <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            {[
              { icon: 'history', label: 'Scan History', c: '#7C3AED' },
              { icon: 'category', label: 'Products', c: '#0EA5E9' },
              { icon: 'account_balance_wallet', label: 'Wallet', c: '#1E3A8A' },
              { icon: 'campaign', label: 'Campaigns', c: '#059669' },
            ].map(q => (
              <div key={q.label} style={{
                padding: 14, borderRadius: 12,
                background: 'var(--sgx-surface-container)',
                display: 'flex', alignItems: 'center', gap: 10,
              }}>
                <div style={{ width: 36, height: 36, borderRadius: 10, background: `${q.c}18`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22, color: q.c }}>{q.icon}</span>
                </div>
                <div style={{ fontSize: 13, fontWeight: 600 }}>{q.label}</div>
              </div>
            ))}
          </div>
        </div>

        <div style={{ height: 8 }} />
      </Scroll>
      <BottomBar active="home" />
    </Phone>
  );
}

// ── MEC-06 QR Scanner (ready) ────────────────────────────────────────
function MecScanner() {
  return (
    <Phone bg="#0A0A0F" statusBarTint="#ffffff" transparentStatus homeIndicatorTint="#ffffff">
      {/* Camera dark background */}
      <div style={{
        position: 'absolute', inset: 0, top: 32, bottom: 20,
        background: 'radial-gradient(ellipse at center, #1a1f2e 0%, #05070d 100%)',
      }}>
        {/* Subtle grid to hint at camera preview */}
        <div style={{
          position: 'absolute', inset: 0,
          backgroundImage: 'linear-gradient(rgba(255,255,255,0.02) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.02) 1px, transparent 1px)',
          backgroundSize: '20px 20px',
        }}/>
      </div>

      {/* Top bar */}
      <div style={{
        position: 'relative', zIndex: 2,
        padding: '8px 8px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        color: 'white',
      }}>
        <button style={{
          width: 44, height: 44, borderRadius: 22, border: 'none',
          background: 'rgba(0,0,0,0.55)', color: 'white',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <span className="material-symbols-rounded">close</span>
        </button>
        <div style={{ fontSize: 15, fontWeight: 600, letterSpacing: 0.2 }}>Scan SGX QR</div>
        <button style={{
          width: 44, height: 44, borderRadius: 22, border: 'none',
          background: 'rgba(0,0,0,0.55)', color: 'white',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <span className="material-symbols-rounded">flashlight_on</span>
        </button>
      </div>

      {/* Scan frame — 68% width */}
      <div style={{
        position: 'absolute', inset: 0,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        pointerEvents: 'none', zIndex: 1,
      }}>
        <div style={{
          width: PHONE_W * 0.68, height: PHONE_W * 0.68,
          borderRadius: 20, position: 'relative',
          boxShadow: '0 0 0 9999px rgba(0,0,0,0.55)',
        }}>
          {/* corner brackets */}
          {[
            { t:0, l:0, r: null, b: null, tl: true },
            { t:0, r:0, l: null, b: null, tr: true },
            { b:0, l:0, r: null, t: null, bl: true },
            { b:0, r:0, l: null, t: null, br: true },
          ].map((p, i) => (
            <div key={i} style={{
              position: 'absolute', width: 36, height: 36,
              top: p.t, bottom: p.b, left: p.l, right: p.r,
              borderTop: p.tl || p.tr ? '4px solid #FFFFFF' : 'none',
              borderBottom: p.bl || p.br ? '4px solid #FFFFFF' : 'none',
              borderLeft: p.tl || p.bl ? '4px solid #FFFFFF' : 'none',
              borderRight: p.tr || p.br ? '4px solid #FFFFFF' : 'none',
              borderRadius:
                p.tl ? '12px 0 0 0' :
                p.tr ? '0 12px 0 0' :
                p.bl ? '0 0 0 12px' :
                '0 0 12px 0',
            }}/>
          ))}
          {/* scanning line */}
          <div style={{
            position: 'absolute', top: '50%', left: 20, right: 20, height: 2,
            background: 'linear-gradient(90deg, transparent, #60A5FA, transparent)',
            boxShadow: '0 0 12px #60A5FA',
          }}/>
        </div>
      </div>

      {/* Bottom instruction */}
      <div style={{
        position: 'absolute', bottom: 40, left: 24, right: 24,
        color: 'white', textAlign: 'center', zIndex: 2,
      }}>
        <div style={{ fontSize: 20, fontWeight: 700 }}>Place the QR inside the frame</div>
        <div style={{ marginTop: 6, fontSize: 13, opacity: 0.75 }}>Hold steady until the code is detected.</div>
        <div style={{
          marginTop: 16, display: 'inline-flex', alignItems: 'center', gap: 8,
          padding: '8px 14px', borderRadius: 999,
          background: 'rgba(34,197,94,0.15)', color: '#86EFAC',
          fontSize: 12, fontWeight: 600,
        }}>
          <div style={{ width: 8, height: 8, borderRadius: 4, background: '#22C55E' }}/>
          Connected
        </div>
      </div>
    </Phone>
  );
}

// ── MEC-06 QR Scanner — Offline blocked ──────────────────────────────
function MecScannerOffline() {
  return (
    <Phone bg="#0A0A0F" statusBarTint="#ffffff" transparentStatus homeIndicatorTint="#ffffff">
      <div style={{ position: 'absolute', inset: 0, top: 32, bottom: 20, background: '#05070d' }}/>
      <div style={{
        position: 'relative', zIndex: 2,
        padding: '8px 8px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        color: 'white',
      }}>
        <button style={{ width: 44, height: 44, borderRadius: 22, border: 'none', background: 'rgba(0,0,0,0.55)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <span className="material-symbols-rounded">close</span>
        </button>
        <div style={{ fontSize: 15, fontWeight: 600 }}>Scan SGX QR</div>
        <div style={{ width: 44 }}/>
      </div>

      <div style={{
        position: 'absolute', inset: 0,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        padding: 24, zIndex: 2,
      }}>
        <div style={{
          background: 'rgba(15,23,42,0.85)', border: '1px solid rgba(255,255,255,0.10)',
          padding: 24, borderRadius: 20, color: 'white', textAlign: 'center',
          backdropFilter: 'blur(8px)', maxWidth: 320,
        }}>
          <div style={{
            width: 80, height: 80, borderRadius: 40, margin: '0 auto',
            background: 'rgba(239,68,68,0.15)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <span className="material-symbols-rounded" style={{ fontSize: 48, color: '#FCA5A5' }}>wifi_off</span>
          </div>
          <div style={{ marginTop: 16, fontSize: 20, fontWeight: 700 }}>No internet</div>
          <div style={{ marginTop: 8, fontSize: 14, opacity: 0.85, lineHeight: '20px' }}>
            Internet is required to scan a QR. Please reconnect and try again.
          </div>
          <div style={{ marginTop: 20, display: 'flex', gap: 10 }}>
            <button style={{
              flex: 1, height: 44, borderRadius: 22, border: '1px solid rgba(255,255,255,0.3)',
              background: 'transparent', color: 'white', fontSize: 14, fontWeight: 600,
            }}>Close</button>
            <button style={{
              flex: 1, height: 44, borderRadius: 22, border: 'none',
              background: 'white', color: '#0F172A', fontSize: 14, fontWeight: 700,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            }}>
              <span className="material-symbols-rounded" style={{ fontSize: 18 }}>refresh</span>
              Try Again
            </button>
          </div>
        </div>
      </div>
    </Phone>
  );
}

// ── MEC-07 Scan Result — shared result surface ──────────────────────
function ScanResult({ variant }) {
  const V = {
    success: {
      accent: 'var(--sgx-success)',
      accentBg: 'var(--sgx-success-container)',
      icon: 'check_circle',
      title: 'Reward added!',
      body: 'Rs. 15 has been added to your wallet.',
      showReward: true,
      product: 'Shell Advance AX7 10W-40',
      primary: { label: 'Scan Another', icon: 'qr_code_scanner' },
      secondary: { label: 'Open Wallet', icon: 'account_balance_wallet' },
    },
    already: {
      accent: 'var(--sgx-error)',
      accentBg: 'var(--sgx-error-container)',
      icon: 'block',
      title: 'Already scanned',
      body: 'This QR has already been scanned. Each SGX QR can only be used once.',
      primary: { label: 'Scan Another', icon: 'qr_code_scanner' },
    },
    notactive: {
      accent: '#B45309',
      accentBg: 'var(--sgx-warning-container)',
      icon: 'schedule',
      title: 'QR not active',
      body: 'This QR is not active yet. It will work after the invoice is dispatched.',
      primary: { label: 'Scan Another', icon: 'qr_code_scanner' },
    },
    invalid: {
      accent: 'var(--sgx-error)',
      accentBg: 'var(--sgx-error-container)',
      icon: 'qr_code_2',
      title: 'Invalid QR',
      body: 'This is not a valid SGX QR. Please try another product.',
      primary: { label: 'Scan Another', icon: 'qr_code_scanner' },
    },
    expired: {
      accent: 'var(--sgx-error)',
      accentBg: 'var(--sgx-error-container)',
      icon: 'event_busy',
      title: 'QR expired',
      body: 'This QR has expired and can no longer be used.',
      primary: { label: 'Scan Another', icon: 'qr_code_scanner' },
    },
    network: {
      accent: '#B45309',
      accentBg: 'var(--sgx-warning-container)',
      icon: 'wifi_tethering_error',
      title: 'Could not check QR',
      body: 'Check your internet connection and try again.',
      primary: { label: 'Try Again', icon: 'refresh' },
      secondary: { label: 'Close', icon: 'close' },
    },
  }[variant];

  return (
    <Phone bg="#0A0A0F" statusBarTint="#ffffff" transparentStatus homeIndicatorTint="#ffffff">
      {/* Dim camera behind */}
      <div style={{ position: 'absolute', inset: 0, top: 32, bottom: 20, background: 'rgba(5,7,13,0.85)' }}/>

      {/* Result surface — slides up from bottom, occupies ~70% */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, top: '25%',
        background: 'var(--sgx-surface)',
        borderTopLeftRadius: 28, borderTopRightRadius: 28,
        padding: '20px 24px 32px',
        display: 'flex', flexDirection: 'column',
        zIndex: 3,
      }}>
        {/* Grabber */}
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 20 }}>
          <div style={{ width: 40, height: 4, borderRadius: 2, background: 'var(--sgx-outline-variant)' }}/>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', flex: 1 }}>
          <div style={{
            width: 96, height: 96, borderRadius: 48,
            background: V.accentBg,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <span className="material-symbols-rounded mi-fill" style={{ fontSize: 56, color: V.accent }}>{V.icon}</span>
          </div>

          <div style={{ marginTop: 16, fontSize: 24, fontWeight: 700 }}>{V.title}</div>

          {V.showReward && (
            <div style={{ marginTop: 20 }}>
              <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', textTransform: 'uppercase', letterSpacing: 1, fontWeight: 600 }}>You earned</div>
              <div style={{ fontSize: 56, fontWeight: 800, color: V.accent, letterSpacing: -1, fontVariantNumeric: 'tabular-nums', lineHeight: '60px', marginTop: 4 }}>
                Rs. 15
              </div>
            </div>
          )}

          <div style={{ marginTop: 12, fontSize: 15, color: 'var(--sgx-on-surface-variant)', maxWidth: 300, lineHeight: '22px' }}>
            {V.body}
          </div>

          {V.product && (
            <div style={{
              marginTop: 20, width: '100%',
              padding: 12, borderRadius: 12,
              background: 'var(--sgx-surface-container)',
              display: 'flex', alignItems: 'center', gap: 12,
            }}>
              <ImgSlot w={48} h={48} radius={8} kind="oil" />
              <div style={{ flex: 1, textAlign: 'left' }}>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)' }}>Product</div>
                <div style={{ fontSize: 14, fontWeight: 600 }}>{V.product}</div>
              </div>
            </div>
          )}
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <FilledBtn icon={V.primary.icon}>{V.primary.label}</FilledBtn>
          {V.secondary && <OutlinedBtn icon={V.secondary.icon}>{V.secondary.label}</OutlinedBtn>}
        </div>
      </div>
    </Phone>
  );
}

const MecScanSuccess = () => <ScanResult variant="success" />;
const MecScanAlready = () => <ScanResult variant="already" />;
const MecScanNotActive = () => <ScanResult variant="notactive" />;
const MecScanInvalid = () => <ScanResult variant="invalid" />;
const MecScanExpired = () => <ScanResult variant="expired" />;
const MecScanNetwork = () => <ScanResult variant="network" />;

Object.assign(window, {
  MecHome, MecScanner, MecScannerOffline,
  MecScanSuccess, MecScanAlready, MecScanNotActive, MecScanInvalid, MecScanExpired, MecScanNetwork,
});
