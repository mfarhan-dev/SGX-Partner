// SGX Partners — Profile, Edit Profile, Language & Theme, Urdu sample
// MEC-18 Profile, MEC-19 Edit Profile, MEC-20 Language & Theme

// ── MEC-18 Profile ───────────────────────────────────────────────────
function MecProfile() {
  return (
    <Phone>
      <TopAppBar title="Profile" leading={<div style={{width:12}}/>} trailing={<IconBtn icon="notifications" />} />
      <Scroll pad={0} gap={16}>
        {/* Identity card */}
        <div style={{ padding: '4px 16px 0' }}>
          <div style={{
            padding: 20, borderRadius: 16,
            background: 'linear-gradient(135deg, var(--sgx-primary) 0%, oklch(0.28 0.14 265) 100%)',
            color: 'white', display: 'flex', gap: 14, alignItems: 'center',
            boxShadow: '0 6px 16px rgba(30,58,138,0.2)',
          }}>
            <div style={{
              width: 64, height: 64, borderRadius: 32,
              background: 'rgba(255,255,255,0.18)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 26, fontWeight: 800, letterSpacing: -0.5,
            }}>MF</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 18, fontWeight: 700 }}>Muhammad Farhan</div>
              <div style={{ fontSize: 13, opacity: 0.85, marginTop: 2 }}>Farhan Motors · Lahore</div>
              <div style={{
                marginTop: 8, display: 'inline-flex', alignItems: 'center', gap: 4,
                padding: '3px 8px', borderRadius: 999,
                background: 'rgba(34,197,94,0.25)', fontSize: 11, fontWeight: 700,
              }}>
                <div style={{ width: 6, height: 6, borderRadius: 3, background: '#86EFAC' }}/>
                ACTIVE MECHANIC
              </div>
            </div>
          </div>
        </div>

        {/* Info list */}
        <div style={{ padding: '0 16px' }}>
          <div style={{ background: 'var(--sgx-surface)', border: '1px solid var(--sgx-outline-variant)', borderRadius: 12, overflow: 'hidden' }}>
            {[
              { icon: 'smartphone', l: 'Verified Phone', v: '+92 300-1234567', lock: true },
              { icon: 'storefront', l: 'Workshop', v: 'Farhan Motors' },
              { icon: 'location_on', l: 'Area / City', v: 'Lahore, Gulberg' },
            ].map((r, i, a) => (
              <div key={r.l} style={{
                padding: '14px', display: 'flex', alignItems: 'center', gap: 12,
                borderBottom: i < a.length - 1 ? '1px solid var(--sgx-outline-variant)' : 'none',
              }}>
                <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>{r.icon}</span>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)' }}>{r.l}</div>
                  <div style={{ fontSize: 15, fontWeight: 600 }}>{r.v}</div>
                </div>
                {r.lock && <span className="material-symbols-rounded" style={{ fontSize: 20, color: 'var(--sgx-on-surface-variant)' }}>lock</span>}
              </div>
            ))}
          </div>
        </div>

        {/* Actions */}
        <div style={{ padding: '0 16px' }}>
          <div style={{ background: 'var(--sgx-surface)', border: '1px solid var(--sgx-outline-variant)', borderRadius: 12, overflow: 'hidden' }}>
            {[
              { icon: 'edit', l: 'Edit Profile' },
              { icon: 'language', l: 'Language & Theme', sub: 'English · Light' },
              { icon: 'support_agent', l: 'Contact SGX', sub: 'WhatsApp: 0300-8880000' },
              { icon: 'help', l: 'Help & FAQs' },
            ].map((r, i, a) => (
              <div key={r.l} style={{
                padding: '14px', display: 'flex', alignItems: 'center', gap: 12,
                borderBottom: i < a.length - 1 ? '1px solid var(--sgx-outline-variant)' : 'none',
              }}>
                <div style={{ width: 40, height: 40, borderRadius: 10, background: 'var(--sgx-surface-container)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-primary)' }}>{r.icon}</span>
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 15, fontWeight: 600 }}>{r.l}</div>
                  {r.sub && <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{r.sub}</div>}
                </div>
                <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>chevron_right</span>
              </div>
            ))}
          </div>
        </div>

        {/* Logout */}
        <div style={{ padding: '4px 16px 20px' }}>
          <button style={{
            width: '100%', height: 48, borderRadius: 24,
            border: '1.5px solid var(--sgx-error)',
            background: 'transparent', color: 'var(--sgx-error)',
            fontSize: 15, fontWeight: 700,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          }}>
            <span className="material-symbols-rounded" style={{ fontSize: 20 }}>logout</span>
            Logout
          </button>
          <div style={{ marginTop: 16, textAlign: 'center', fontSize: 11, color: 'var(--sgx-on-surface-variant)' }}>
            SGX Partners · v1.0.0
          </div>
        </div>
      </Scroll>
      <BottomBar active="profile" />
    </Phone>
  );
}

// ── MEC-19 Edit Profile ──────────────────────────────────────────────
function MecEditProfile() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Edit Profile" trailing={<TextBtn>Save</TextBtn>} />
      <Scroll pad={20} gap={20}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
          <div style={{
            width: 96, height: 96, borderRadius: 48,
            background: 'var(--sgx-primary)', color: 'white',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 36, fontWeight: 800, position: 'relative',
          }}>
            MF
            <div style={{
              position: 'absolute', bottom: 0, right: 0,
              width: 32, height: 32, borderRadius: 16,
              background: 'var(--sgx-surface)', border: '2px solid var(--sgx-primary)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--sgx-primary)',
            }}>
              <span className="material-symbols-rounded" style={{ fontSize: 18 }}>photo_camera</span>
            </div>
          </div>
        </div>

        <TextField label="Verified Phone" value="+92 300-1234567" icon="smartphone" readonly verified />
        <TextField label="Full Name *" value="Muhammad Farhan" icon="person" />
        <TextField label="Workshop / Shop Name" value="Farhan Motors" icon="storefront" helper="Optional — helps customers recognize your shop." />

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

        <div style={{ marginTop: 8, display: 'flex', gap: 10 }}>
          <div style={{ flex: 1 }}><OutlinedBtn>Cancel</OutlinedBtn></div>
          <div style={{ flex: 1 }}><FilledBtn icon="check">Save</FilledBtn></div>
        </div>
      </Scroll>
    </Phone>
  );
}

// ── MEC-20 Language & Theme ──────────────────────────────────────────
function MecPreferences() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Language & Theme" />
      <Scroll pad={16} gap={20}>
        {/* Language */}
        <div>
          <div className="t-section-title" style={{ marginBottom: 10, paddingLeft: 4 }}>Language</div>
          <div style={{ background: 'var(--sgx-surface)', border: '1px solid var(--sgx-outline-variant)', borderRadius: 12, overflow: 'hidden' }}>
            {[
              { name: 'English', sub: 'English (Pakistan)', sel: true },
              { name: 'اردو', sub: 'Urdu · دائیں سے بائیں', sel: false, urdu: true },
            ].map((l, i, a) => (
              <div key={l.name} style={{
                padding: '14px', display: 'flex', alignItems: 'center', gap: 12,
                borderBottom: i < a.length - 1 ? '1px solid var(--sgx-outline-variant)' : 'none',
              }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 20,
                  background: 'var(--sgx-surface-container)', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 16, fontWeight: 700, color: 'var(--sgx-primary)',
                }}>{l.name === 'English' ? 'Aa' : 'ا'}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 15, fontWeight: 700, fontFamily: l.urdu ? 'serif' : 'inherit' }}>{l.name}</div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)' }}>{l.sub}</div>
                </div>
                <div style={{
                  width: 22, height: 22, borderRadius: 11,
                  border: `2px solid ${l.sel ? 'var(--sgx-primary)' : 'var(--sgx-outline)'}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {l.sel && <div style={{ width: 12, height: 12, borderRadius: 6, background: 'var(--sgx-primary)' }}/>}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Theme */}
        <div>
          <div className="t-section-title" style={{ marginBottom: 10, paddingLeft: 4 }}>Theme</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
            {[
              { name: 'System', icon: 'brightness_auto', bg: 'linear-gradient(135deg, #fff 50%, #1a1a1a 50%)', sel: false },
              { name: 'Light', icon: 'light_mode', bg: '#F1F5F9', sel: true },
              { name: 'Dark', icon: 'dark_mode', bg: '#0F172A', sel: false, dark: true },
            ].map(t => (
              <div key={t.name} style={{
                padding: 12, borderRadius: 12,
                border: `2px solid ${t.sel ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'}`,
                background: 'var(--sgx-surface)',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
              }}>
                <div style={{
                  width: 56, height: 56, borderRadius: 12, background: t.bg,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  border: '1px solid var(--sgx-outline-variant)',
                }}>
                  <span className="material-symbols-rounded" style={{ fontSize: 24, color: t.dark ? '#fff' : '#0F172A' }}>{t.icon}</span>
                </div>
                <div style={{ fontSize: 13, fontWeight: 700 }}>{t.name}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Preview */}
        <div>
          <div className="t-section-title" style={{ marginBottom: 10, paddingLeft: 4 }}>Preview</div>
          <div style={{
            padding: 16, borderRadius: 14,
            background: 'var(--sgx-surface-container)',
          }}>
            <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', fontWeight: 600 }}>Available Balance</div>
            <div style={{ fontSize: 32, fontWeight: 800, color: 'var(--sgx-primary)', marginTop: 4, fontVariantNumeric: 'tabular-nums' }}>Rs. 4,285</div>
            <div style={{ marginTop: 12, display: 'flex', gap: 10 }}>
              <div style={{ flex: 1 }}><FilledBtn small icon="qr_code_scanner">Scan QR</FilledBtn></div>
              <div style={{ flex: 1 }}><OutlinedBtn small icon="payments">Withdraw</OutlinedBtn></div>
            </div>
          </div>
        </div>
      </Scroll>
    </Phone>
  );
}

// ── Bonus: Home in Urdu / RTL ───────────────────────────────────────
function MecHomeUrdu() {
  return (
    <div dir="rtl" style={{ direction: 'rtl' }}>
      <Phone>
        <TopAppBar
          title="SGX پارٹنرز"
          showBrand
          leading={<div style={{ width: 12 }}/>}
          trailing={<IconBtn icon="notifications" badge="3" />}
        />
        <Scroll pad={0} gap={20}>
          <div style={{ padding: '4px 20px 0' }}>
            <div style={{ fontSize: 14, color: 'var(--sgx-on-surface-variant)' }}>السلام علیکم،</div>
            <div style={{ fontSize: 22, fontWeight: 700, marginTop: 2 }}>محمد فرحان 👋</div>
          </div>

          <div style={{ padding: '0 16px' }}>
            <div style={{
              padding: 20, borderRadius: 20,
              background: 'linear-gradient(135deg, var(--sgx-primary) 0%, oklch(0.28 0.14 265) 100%)',
              color: 'white', position: 'relative', overflow: 'hidden',
              boxShadow: '0 8px 20px rgba(30,58,138,0.25)',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, opacity: 0.85 }}>
                <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20 }}>account_balance_wallet</span>
                <span style={{ fontSize: 14, fontWeight: 500 }}>دستیاب بیلنس</span>
              </div>
              <div style={{ marginTop: 6, fontSize: 40, fontWeight: 800, letterSpacing: -1, direction: 'ltr', textAlign: 'right' }}>
                Rs. 4,285
              </div>
              <div style={{ display: 'flex', gap: 20, marginTop: 20, paddingTop: 14, borderTop: '1px solid rgba(255,255,255,0.15)' }}>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 11, opacity: 0.7 }}>زیر التوا</div>
                  <div style={{ fontSize: 15, fontWeight: 700, marginTop: 2, direction: 'ltr', textAlign: 'right' }}>Rs. 1,500</div>
                </div>
                <div style={{ width: 1, background: 'rgba(255,255,255,0.15)' }}/>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 11, opacity: 0.7 }}>کل کمائی</div>
                  <div style={{ fontSize: 15, fontWeight: 700, marginTop: 2, direction: 'ltr', textAlign: 'right' }}>Rs. 28,540</div>
                </div>
              </div>
              <button style={{
                marginTop: 16, width: '100%', height: 44,
                borderRadius: 22, border: 'none',
                background: 'white', color: 'var(--sgx-primary)',
                fontSize: 15, fontWeight: 700,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              }}>
                <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20 }}>payments</span>
                رقم نکالیں
              </button>
            </div>
          </div>

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
                <div style={{ fontSize: 17, fontWeight: 700 }}>SGX کیو آر اسکین کریں</div>
                <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>پروڈکٹ QR اسکین کر کے روپے کمائیں</div>
              </div>
              <span className="material-symbols-rounded" style={{ fontSize: 24, color: 'var(--sgx-primary)', transform: 'scaleX(-1)' }}>arrow_forward</span>
            </div>
          </div>

          <div>
            <div style={{ padding: '0 16px', marginBottom: 12, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ fontSize: 16, fontWeight: 600 }}>آخری اسکین</div>
              <div style={{ color: 'var(--sgx-primary)', fontSize: 13, fontWeight: 600 }}>تاریخ</div>
            </div>
            <div style={{ padding: '0 16px' }}>
              <div style={{
                padding: 14, borderRadius: 12,
                background: 'var(--sgx-surface-container)',
                display: 'flex', alignItems: 'center', gap: 12,
              }}>
                <ImgSlot w={56} h={56} radius={10} kind="oil" />
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 15, fontWeight: 600 }}>شیل ایڈوانس AX7</div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>آج · 10:24 صبح</div>
                </div>
                <div style={{ textAlign: 'left' }}>
                  <div style={{ fontSize: 17, fontWeight: 700, color: 'var(--sgx-success)', direction: 'ltr' }}>+ Rs. 15</div>
                  <StatusChip status="confirmed" label="تصدیق شدہ" size="sm" />
                </div>
              </div>
            </div>
          </div>
        </Scroll>
        <BottomBar active="home" />
      </Phone>
    </div>
  );
}

Object.assign(window, { MecProfile, MecEditProfile, MecPreferences, MecHomeUrdu });
