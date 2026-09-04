// SGX Partners — Wholesaler · Notifications, Profile, Preferences + Urdu RTL sample
// WHL-14 Notifications · WHL-15 Profile · WHL-16 Language & Theme · Home in Urdu

// ── WHL-14 Notifications ─────────────────────────────────────────────
function WhlNotifications() {
  const notifs = [
    { type: 'reward',     title: 'Rs. 12 added to your wallet',                  sub: 'Shell Advance AX7 scan',              time: '2m ago',  unread: true,  icon: 'add_circle',   c: '#22C55E' },
    { type: 'reward',     title: 'Rs. 5 added to your wallet',                    sub: 'NGK Spark Plug scan',                 time: '12m ago', unread: true,  icon: 'add_circle',   c: '#22C55E' },
    { type: 'paid',       title: 'Your payment has been sent',                    sub: 'JazzCash · Rs. 5,000',                time: '3h ago',  unread: true,  icon: 'send',         c: '#1E3A8A' },
    { type: 'campaign',   title: 'A new SGX campaign has started',                sub: 'Distributor Growth Bonus · +10%',     time: 'Today',   unread: true,  icon: 'campaign',     c: '#F59E0B' },
    { type: 'submitted',  title: 'Your withdrawal request was submitted',         sub: 'Bank Transfer · Rs. 10,000',          time: 'Yesterday', unread: false, icon: 'edit_document', c: '#1E3A8A' },
    { type: 'refunded',   title: 'Money was returned to your wallet',             sub: 'Refund · Rs. 2,500',                  time: '15 Jul',  unread: false, icon: 'currency_exchange', c: '#22C55E' },
    { type: 'confirmed',  title: 'Your withdrawal was confirmed',                 sub: 'EasyPaisa · Rs. 8,000',               time: '18 Jul',  unread: false, icon: 'task_alt',     c: '#22C55E' },
    { type: 'auto',       title: 'Your withdrawal was closed automatically',      sub: 'Bank Transfer · Rs. 3,000',           time: '13 Jul',  unread: false, icon: 'lock_clock',   c: '#64748B' },
  ];
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Notifications" trailing={<IconBtn icon="done_all" />} />
      <Scroll pad={0} gap={0}>
        {/* Unread summary */}
        <div style={{
          padding: '10px 16px',
          background: 'rgba(30,58,138,0.06)',
          display: 'flex', alignItems: 'center', gap: 8,
          fontSize: 12, color: 'var(--sgx-primary)', fontWeight: 600,
        }}>
          <span className="material-symbols-rounded mi-fill" style={{ fontSize: 16 }}>notifications_active</span>
          4 unread notifications
        </div>

        {notifs.map((n, i) => (
          <div key={i} style={{
            padding: '14px 16px', display: 'flex', gap: 12,
            background: n.unread ? 'rgba(30,58,138,0.03)' : 'var(--sgx-surface)',
            borderBottom: '1px solid var(--sgx-outline-variant)',
            position: 'relative',
          }}>
            <div style={{
              width: 40, height: 40, borderRadius: 20,
              background: `${n.c}18`, color: n.c,
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
            }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22 }}>{n.icon}</span>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: n.unread ? 700 : 500, lineHeight: 1.35 }}>{n.title}</div>
              <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 3 }}>{n.sub}</div>
              <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', marginTop: 4, fontWeight: 500 }}>{n.time}</div>
            </div>
            {n.unread && (
              <div style={{
                width: 10, height: 10, borderRadius: 5, background: 'var(--sgx-primary)',
                flexShrink: 0, alignSelf: 'flex-start', marginTop: 6,
              }}/>
            )}
          </div>
        ))}
      </Scroll>
    </Phone>
  );
}

// ── WHL-15 Profile ───────────────────────────────────────────────────
function WhlProfile() {
  return (
    <Phone>
      <TopAppBar title="Profile" leading={<div style={{width:12}}/>}
        trailing={<IconBtn icon="notifications" badge="4" />} />
      <Scroll pad={0} gap={16}>
        {/* Identity header */}
        <div style={{ padding: '4px 16px 0' }}>
          <div style={{
            padding: 20, borderRadius: 20,
            background: 'linear-gradient(135deg, var(--sgx-primary), oklch(0.28 0.14 265))',
            color: 'white', textAlign: 'center', position: 'relative', overflow: 'hidden',
          }}>
            <div style={{ position: 'absolute', right: -20, top: -20, opacity: 0.08 }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 140 }}>storefront</span>
            </div>
            <div style={{
              width: 76, height: 76, borderRadius: 38, background: 'white',
              margin: '0 auto', display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: '0 6px 14px rgba(0,0,0,0.15)',
            }}>
              <span style={{ fontSize: 32, fontWeight: 800, color: 'var(--sgx-primary)' }}>FM</span>
            </div>
            <div style={{ marginTop: 12, fontSize: 20, fontWeight: 800, letterSpacing: -0.3 }}>Farhan Motor Parts</div>
            <div style={{ marginTop: 2, fontSize: 13, opacity: 0.85 }}>Muhammad Farhan · Owner</div>
            <div style={{ marginTop: 8, display: 'inline-flex', alignItems: 'center', gap: 5, padding: '4px 10px', borderRadius: 12, background: 'rgba(255,255,255,0.16)', fontSize: 11, fontWeight: 700 }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 14 }}>check_circle</span>
              ACTIVE WHOLESALER
            </div>
          </div>
        </div>

        {/* Info list — read-only per spec §19 */}
        <div>
          <SectionHeader title="Business information" />
          <div style={{ background: 'var(--sgx-surface)' }}>
            {[
              { icon: 'phone_iphone', k: 'Phone', v: '+92 300 1234567', c: 'var(--sgx-success)', verified: true },
              { icon: 'location_city', k: 'Area / City', v: 'Gulberg III, Lahore' },
              { icon: 'home_work',   k: 'Shop address', v: '54-A Main Boulevard, Lahore' },
            ].map((r, i, a) => (
              <div key={r.k} style={{
                padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 12,
                borderTop: '1px solid var(--sgx-outline-variant)',
                borderBottom: i === a.length - 1 ? '1px solid var(--sgx-outline-variant)' : 'none',
              }}>
                <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>{r.icon}</span>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', textTransform: 'uppercase', letterSpacing: 0.4, fontWeight: 600 }}>{r.k}</div>
                  <div style={{ fontSize: 14, fontWeight: 600, marginTop: 3 }}>{r.v}</div>
                </div>
                {r.verified && <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20, color: 'var(--sgx-success)' }}>verified</span>}
              </div>
            ))}
          </div>
        </div>

        {/* Read-only notice */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 12, borderRadius: 10,
            background: 'var(--sgx-surface-container)',
            display: 'flex', gap: 10, alignItems: 'flex-start',
          }}>
            <span className="material-symbols-rounded" style={{ fontSize: 20, color: 'var(--sgx-on-surface-variant)' }}>info</span>
            <div style={{ flex: 1, fontSize: 12, color: 'var(--sgx-on-surface-variant)', lineHeight: 1.5 }}>
              Contact SGX to update your business information.
            </div>
          </div>
        </div>

        {/* Menu */}
        <div>
          <SectionHeader title="Preferences" />
          <div style={{ background: 'var(--sgx-surface)' }}>
            {[
              { icon: 'language',      label: 'Language & Theme',  sub: 'English · Light',    color: 'var(--sgx-primary)' },
              { icon: 'support_agent', label: 'Contact SGX',       sub: 'WhatsApp · Call',    color: '#0EA5E9' },
              { icon: 'help',          label: 'Help & FAQs',       sub: 'How rewards work',   color: '#8B5CF6' },
              { icon: 'logout',        label: 'Log out',           sub: 'Sign out of SGX',    color: 'var(--sgx-error)', destructive: true },
            ].map((r, i, a) => (
              <div key={r.label} style={{
                padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 12,
                borderTop: '1px solid var(--sgx-outline-variant)',
                borderBottom: i === a.length - 1 ? '1px solid var(--sgx-outline-variant)' : 'none',
              }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 10,
                  background: `${r.destructive ? 'rgba(220,38,38,0.10)' : 'rgba(30,58,138,0.08)'}`,
                  color: r.color, display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22 }}>{r.icon}</span>
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 600, color: r.destructive ? 'var(--sgx-error)' : 'var(--sgx-on-surface)' }}>{r.label}</div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{r.sub}</div>
                </div>
                <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>chevron_right</span>
              </div>
            ))}
          </div>
        </div>

        {/* App version */}
        <div style={{ textAlign: 'center', fontSize: 11, color: 'var(--sgx-on-surface-variant)', padding: '4px 0 16px' }}>
          SGX Partners · v1.0.0
        </div>
      </Scroll>
      <WholesalerBottomBar active="profile" />
    </Phone>
  );
}

// ── WHL-16 Language & Theme ──────────────────────────────────────────
function WhlPreferences() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Language & Theme" />
      <Scroll pad={0} gap={20}>
        {/* Language */}
        <div>
          <SectionHeader title="Language" />
          <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
            {[
              { label: 'English',            sub: 'Default',           selected: true, hint: 'AA · aa · 123' },
              { label: 'اردو',                sub: 'Urdu (Right-to-Left)', selected: false, hint: 'ا · ب · ۱۲۳', urdu: true },
            ].map(l => (
              <div key={l.label} style={{
                padding: 14, borderRadius: 12,
                border: '1.5px solid ' + (l.selected ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'),
                background: l.selected ? 'rgba(30,58,138,0.05)' : 'var(--sgx-surface)',
                display: 'flex', alignItems: 'center', gap: 12,
              }}>
                <div style={{
                  width: 44, height: 44, borderRadius: 12,
                  background: 'var(--sgx-surface-container)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: l.urdu ? 22 : 16, fontWeight: 700,
                  fontFamily: l.urdu ? 'var(--sgx-font-urdu)' : 'var(--sgx-font)',
                }}>{l.hint.split(' · ')[0]}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 16, fontWeight: 700, fontFamily: l.urdu ? 'var(--sgx-font-urdu)' : 'var(--sgx-font)' }}>{l.label}</div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{l.sub}</div>
                </div>
                <div style={{
                  width: 22, height: 22, borderRadius: 11,
                  border: '2px solid ' + (l.selected ? 'var(--sgx-primary)' : 'var(--sgx-outline)'),
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {l.selected && <div style={{ width: 12, height: 12, borderRadius: 6, background: 'var(--sgx-primary)' }}/>}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Theme */}
        <div>
          <SectionHeader title="Theme" />
          <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
            {[
              { label: 'System', icon: 'phone_iphone', bg: 'linear-gradient(135deg, #ffffff 50%, #0F172A 50%)', selected: true },
              { label: 'Light',  icon: 'light_mode',    bg: '#ffffff', border: 'var(--sgx-outline-variant)', selected: false },
              { label: 'Dark',   icon: 'dark_mode',     bg: '#0F172A', selected: false, dark: true },
            ].map(t => (
              <div key={t.label} style={{
                borderRadius: 12,
                border: '2px solid ' + (t.selected ? 'var(--sgx-primary)' : 'transparent'),
                background: 'var(--sgx-surface)',
                overflow: 'hidden',
              }}>
                <div style={{
                  height: 70, background: t.bg, border: t.border ? `1px solid ${t.border}` : 'none',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <span className="material-symbols-rounded mi-fill" style={{
                    fontSize: 30, color: t.dark ? '#ffffff' : (t.label === 'Light' ? '#0F172A' : '#0F172A'),
                    mixBlendMode: t.label === 'System' ? 'difference' : 'normal',
                    filter: t.label === 'System' ? 'invert(1)' : 'none',
                  }}>{t.icon}</span>
                </div>
                <div style={{
                  padding: '10px 4px', fontSize: 12, fontWeight: 600, textAlign: 'center',
                  color: t.selected ? 'var(--sgx-primary)' : 'var(--sgx-on-surface)',
                }}>
                  {t.label}
                  {t.selected && <span className="material-symbols-rounded mi-fill" style={{ fontSize: 14, verticalAlign: 'middle', marginLeft: 4 }}>check_circle</span>}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Preview */}
        <div>
          <SectionHeader title="Preview" />
          <div style={{ padding: '0 16px' }}>
            <div style={{
              padding: 16, borderRadius: 12,
              background: 'var(--sgx-surface-container)',
              display: 'flex', flexDirection: 'column', gap: 10,
            }}>
              <div style={{ fontSize: 22, fontWeight: 800, color: 'var(--sgx-primary)', fontVariantNumeric: 'tabular-nums' }}>Rs. 18,420</div>
              <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)' }}>Available Balance</div>
              <button style={{
                marginTop: 6, height: 40, borderRadius: 20, border: 'none',
                background: 'var(--sgx-primary)', color: 'white',
                fontSize: 13, fontWeight: 700, cursor: 'pointer',
              }}>Withdraw Money</button>
            </div>
          </div>
        </div>

        <div style={{ padding: '0 16px 16px', fontSize: 12, color: 'var(--sgx-on-surface-variant)', textAlign: 'center' }}>
          Changes apply immediately.
        </div>
      </Scroll>
    </Phone>
  );
}

// ── Urdu / RTL Home stress sample ────────────────────────────────────
function WhlHomeUrdu() {
  return (
    <div dir="rtl" style={{ direction: 'rtl' }}>
      <Phone>
        <div style={{ direction: 'rtl' }}>
          {/* AppBar reversed */}
          <div style={{
            height: 64, padding: '0 4px', display: 'flex', alignItems: 'center', gap: 4,
            background: 'var(--sgx-surface)', flexShrink: 0, direction: 'rtl',
          }}>
            <div style={{ width: 12 }}/>
            <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 10, minWidth: 0 }}>
              <SgxIcon size={32} radius={7} />
              <div style={{ fontSize: 20, fontWeight: 700, fontFamily: 'var(--sgx-font-urdu)', lineHeight: 1.4 }}>ایس جی ایکس پارٹنرز</div>
            </div>
            <IconBtn icon="notifications" badge="4" />
          </div>

          <Scroll pad={0} gap={20}>
            {/* Greeting */}
            <div style={{ padding: '4px 20px 0', textAlign: 'right' }}>
              <div style={{ fontSize: 15, color: 'var(--sgx-on-surface-variant)', fontFamily: 'var(--sgx-font-urdu)', lineHeight: 1.6 }}>السلام علیکم،</div>
              <div style={{ fontSize: 24, fontWeight: 700, marginTop: 2, fontFamily: 'var(--sgx-font-urdu)', lineHeight: 1.5 }}>محمد فرحان</div>
              <div style={{ fontSize: 14, color: 'var(--sgx-primary)', fontWeight: 600, marginTop: 4, fontFamily: 'var(--sgx-font-urdu)', display: 'inline-flex', alignItems: 'center', gap: 5, flexDirection: 'row-reverse' }}>
                <span className="material-symbols-rounded mi-fill" style={{ fontSize: 14 }}>storefront</span>
                فرحان موٹر پارٹس · لاہور
              </div>
            </div>

            {/* Wallet Hero */}
            <div style={{ padding: '0 16px' }}>
              <div style={{
                padding: 20, borderRadius: 20,
                background: 'linear-gradient(135deg, var(--sgx-primary) 0%, oklch(0.28 0.14 265) 100%)',
                color: 'white', position: 'relative', overflow: 'hidden',
                boxShadow: '0 8px 20px rgba(30,58,138,0.25)',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, opacity: 0.85, flexDirection: 'row-reverse' }}>
                  <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20 }}>account_balance_wallet</span>
                  <span style={{ fontSize: 15, fontWeight: 500, fontFamily: 'var(--sgx-font-urdu)' }}>دستیاب رقم</span>
                </div>
                {/* Numbers stay LTR — financial format */}
                <div dir="ltr" style={{ marginTop: 6, fontSize: 42, fontWeight: 800, letterSpacing: -1, fontVariantNumeric: 'tabular-nums', textAlign: 'right' }}>
                  Rs. 18,420
                </div>

                <div style={{ display: 'flex', gap: 20, marginTop: 20, paddingTop: 14, borderTop: '1px solid rgba(255,255,255,0.15)', flexDirection: 'row-reverse' }}>
                  <div style={{ flex: 1, textAlign: 'right' }}>
                    <div style={{ fontSize: 12, opacity: 0.7, fontWeight: 600, fontFamily: 'var(--sgx-font-urdu)' }}>زیر التوا</div>
                    <div dir="ltr" style={{ fontSize: 15, fontWeight: 700, marginTop: 3, textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>Rs. 5,000</div>
                  </div>
                  <div style={{ width: 1, background: 'rgba(255,255,255,0.15)' }}/>
                  <div style={{ flex: 1, textAlign: 'right' }}>
                    <div style={{ fontSize: 12, opacity: 0.7, fontWeight: 600, fontFamily: 'var(--sgx-font-urdu)' }}>مجموعی کمائی</div>
                    <div dir="ltr" style={{ fontSize: 15, fontWeight: 700, marginTop: 3, textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>Rs. 1.42L</div>
                  </div>
                </div>

                <button style={{
                  marginTop: 16, width: '100%', height: 44,
                  borderRadius: 22, border: 'none',
                  background: 'white', color: 'var(--sgx-primary)',
                  fontSize: 16, fontWeight: 700, fontFamily: 'var(--sgx-font-urdu)',
                  display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                  cursor: 'pointer', flexDirection: 'row-reverse',
                }}>
                  <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20 }}>payments</span>
                  رقم نکالیں
                </button>
              </div>
            </div>

            {/* QR Progress card */}
            <div>
              <div style={{ padding: '0 16px', marginBottom: 12, textAlign: 'right' }}>
                <div style={{ fontSize: 17, fontWeight: 700, fontFamily: 'var(--sgx-font-urdu)' }}>کیو آر پیش رفت</div>
              </div>
              <div style={{ padding: '0 16px' }}>
                <div style={{ padding: 16, borderRadius: 16, background: 'var(--sgx-surface-container)' }}>
                  <div dir="ltr" style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 6 }}>
                    <div>
                      <span style={{ fontSize: 28, fontWeight: 800, color: 'var(--sgx-primary)', fontVariantNumeric: 'tabular-nums' }}>486</span>
                      <span style={{ fontSize: 14, color: 'var(--sgx-on-surface-variant)' }}> / 720</span>
                    </div>
                    <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', fontWeight: 600 }}>67%</div>
                  </div>
                  <ProgressBar value={486} total={720} height={10} />
                  <div style={{ marginTop: 12, fontSize: 13, color: 'var(--sgx-on-surface-variant)', fontFamily: 'var(--sgx-font-urdu)', textAlign: 'right', lineHeight: 1.6 }}>
                    486 اسکین ہو چکے · 234 باقی
                  </div>
                </div>
              </div>
            </div>

            {/* Latest reward */}
            <div style={{ padding: '0 16px' }}>
              <div style={{
                padding: 14, borderRadius: 12,
                background: 'var(--sgx-success-container)',
                display: 'flex', alignItems: 'center', gap: 12, flexDirection: 'row-reverse',
              }}>
                <div style={{ width: 44, height: 44, borderRadius: 22, background: 'var(--sgx-success)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <span className="material-symbols-rounded mi-fill" style={{ fontSize: 24 }}>add_circle</span>
                </div>
                <div style={{ flex: 1, textAlign: 'right' }}>
                  <div style={{ fontSize: 15, fontWeight: 700, fontFamily: 'var(--sgx-font-urdu)' }}>والٹ میں 12 روپے شامل کیے گئے</div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2, fontFamily: 'var(--sgx-font-urdu)' }}>شیل ایڈوانس · ابھی 2 منٹ پہلے</div>
                </div>
                <div dir="ltr" style={{ fontSize: 18, fontWeight: 800, color: 'var(--sgx-success)', fontVariantNumeric: 'tabular-nums' }}>+12</div>
              </div>
            </div>

            <div style={{ height: 8 }} />
          </Scroll>

          {/* RTL bottom bar — reverse order */}
          <div style={{
            height: 80, background: 'var(--sgx-surface-container)',
            display: 'flex', alignItems: 'flex-start', flexShrink: 0,
            boxShadow: '0 -1px 0 var(--sgx-outline-variant)', paddingTop: 10,
            flexDirection: 'row-reverse',
          }}>
            {[
              { id: 'home', icon: 'home', label: 'ہوم', active: true },
              { id: 'qr', icon: 'qr_code_2', label: 'کیو آر' },
              { id: 'wallet', icon: 'account_balance_wallet', label: 'والٹ' },
              { id: 'products', icon: 'category', label: 'مصنوعات' },
              { id: 'profile', icon: 'person', label: 'پروفائل' },
            ].map(item => (
              <button key={item.id} style={{
                flex: 1, background: 'transparent', border: 'none',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, padding: 0,
              }}>
                <div style={{
                  width: 56, height: 32, borderRadius: 16,
                  background: item.active ? 'var(--sgx-secondary)' : 'transparent',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  color: item.active ? 'var(--sgx-on-secondary)' : 'var(--sgx-on-surface-variant)',
                }}>
                  <span className={'material-symbols-rounded' + (item.active ? ' mi-fill' : '')} style={{ fontSize: 24 }}>{item.icon}</span>
                </div>
                <div style={{
                  fontSize: 11, fontWeight: item.active ? 600 : 500,
                  color: item.active ? 'var(--sgx-on-surface)' : 'var(--sgx-on-surface-variant)',
                  fontFamily: 'var(--sgx-font-urdu)',
                }}>{item.label}</div>
              </button>
            ))}
          </div>
        </div>
      </Phone>
    </div>
  );
}

Object.assign(window, { WhlNotifications, WhlProfile, WhlPreferences, WhlHomeUrdu });
