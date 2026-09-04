// SGX Partners — Wholesaler · Wallet, Withdraw, Withdrawals List
// WHL-06 Wallet · WHL-07 Withdraw Money (+ confirmation sheet) · WHL-08 Withdrawals

// ── WHL-06 Wallet ────────────────────────────────────────────────────
function WhlWallet() {
  // No invoice-redemption rows per PRD §11
  const tx = [
    { icon: 'add_circle', title: 'QR reward added',      sub: 'Shell Advance AX7 · Today, 10:24 AM', amt: '+12',     pos: true },
    { icon: 'add_circle', title: 'QR reward added',      sub: 'NGK Spark Plug · Today, 09:12 AM',    amt: '+5',      pos: true },
    { icon: 'send',       title: 'Payment sent',         sub: 'JazzCash · Today, 08:40 AM',          amt: '−5,000',  pos: false, status: 'paid', statusLabel: 'Confirm now' },
    { icon: 'add_circle', title: 'QR reward added',      sub: 'K&N Air Filter · Yesterday',          amt: '+12',     pos: true },
    { icon: 'schedule',   title: 'Withdrawal requested', sub: 'Bank transfer · 20 Jul',              amt: '−10,000', pos: false, status: 'pending', statusLabel: 'Pending' },
    { icon: 'check_circle', title: 'Withdrawal confirmed', sub: 'EasyPaisa · 18 Jul',                amt: '−8,000',  pos: false, status: 'confirmed', statusLabel: 'Confirmed' },
    { icon: 'restart_alt', title: 'Money returned to wallet', sub: 'Refund · 15 Jul',                amt: '+2,500',  pos: true,  status: 'refunded', statusLabel: 'Refunded' },
    { icon: 'add_circle', title: 'QR reward added',      sub: 'CEAT Milaze · 15 Jul',                amt: '+40',     pos: true },
  ];
  return (
    <Phone>
      <TopAppBar title="Wallet" leading={<div style={{width:12}}/>} trailing={<IconBtn icon="notifications" badge="4" />} />
      <Scroll pad={0} gap={16}>
        {/* Balance hero */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 20, borderRadius: 20,
            background: 'linear-gradient(135deg, var(--sgx-primary) 0%, oklch(0.28 0.14 265) 100%)',
            color: 'white', position: 'relative', overflow: 'hidden',
            boxShadow: '0 8px 20px rgba(30,58,138,0.25)',
          }}>
            <div style={{ position: 'absolute', right: -40, top: -20, opacity: 0.08 }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 180, color: '#fff' }}>account_balance_wallet</span>
            </div>
            <div style={{ fontSize: 13, opacity: 0.8, fontWeight: 500 }}>Available Balance</div>
            <div style={{ marginTop: 6, fontSize: 44, fontWeight: 800, letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>Rs. 18,420</div>

            <div style={{ display: 'flex', gap: 12, marginTop: 20 }}>
              <div style={{ flex: 1, padding: 12, borderRadius: 12, background: 'rgba(255,255,255,0.10)' }}>
                <div style={{ fontSize: 10.5, opacity: 0.75, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>Pending</div>
                <div style={{ marginTop: 4, fontSize: 17, fontWeight: 700, fontVariantNumeric: 'tabular-nums' }}>Rs. 5,000</div>
              </div>
              <div style={{ flex: 1, padding: 12, borderRadius: 12, background: 'rgba(255,255,255,0.10)' }}>
                <div style={{ fontSize: 10.5, opacity: 0.75, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>Lifetime</div>
                <div style={{ marginTop: 4, fontSize: 17, fontWeight: 700, fontVariantNumeric: 'tabular-nums' }}>Rs. 1,42,340</div>
              </div>
            </div>
          </div>
        </div>

        {/* Actions */}
        <div style={{ padding: '0 16px', display: 'flex', gap: 10 }}>
          <div style={{ flex: 2 }}>
            <FilledBtn icon="payments">Withdraw Money</FilledBtn>
          </div>
          <button style={{
            width: 48, height: 48, borderRadius: 24,
            border: '1.5px solid var(--sgx-outline-variant)',
            background: 'var(--sgx-surface)', color: 'var(--sgx-primary)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <span className="material-symbols-rounded">receipt_long</span>
          </button>
        </div>

        <div style={{ padding: '0 16px' }}>
          <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', display: 'flex', alignItems: 'center', gap: 6 }}>
            <span className="material-symbols-rounded" style={{ fontSize: 14 }}>info</span>
            Minimum withdrawal is Rs. 500.
          </div>
        </div>

        {/* Transactions header */}
        <SectionHeader title="Recent activity" action="View Withdrawals" />

        {/* Transaction list — continuous per spec §10 */}
        <div style={{ background: 'var(--sgx-surface)' }}>
          {tx.map((t, i) => (
            <div key={i} style={{
              padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 12,
              borderTop: '1px solid var(--sgx-outline-variant)',
            }}>
              <div style={{
                width: 40, height: 40, borderRadius: 20,
                background: t.pos
                  ? 'var(--sgx-success-container)'
                  : (t.status === 'pending' || t.status === 'paid')
                    ? 'var(--sgx-warning-container)'
                    : t.status === 'refunded'
                      ? 'var(--sgx-success-container)'
                      : 'rgba(30,58,138,0.10)',
                color: t.pos
                  ? 'var(--sgx-success)'
                  : (t.status === 'pending' || t.status === 'paid')
                    ? '#8A5A00'
                    : t.status === 'refunded'
                      ? 'var(--sgx-success)'
                      : 'var(--sgx-primary)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22 }}>{t.icon}</span>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 600 }}>{t.title}</div>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{t.sub}</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{
                  fontSize: 15, fontWeight: 700, fontVariantNumeric: 'tabular-nums',
                  color: t.pos ? 'var(--sgx-success)' : 'var(--sgx-on-surface)',
                }}>Rs. {t.amt}</div>
                {t.statusLabel && <div style={{ marginTop: 3 }}>
                  <StatusChip status={t.status} label={t.statusLabel} size="sm" />
                </div>}
              </div>
            </div>
          ))}
        </div>
      </Scroll>
      <WholesalerBottomBar active="wallet" />
    </Phone>
  );
}

// ── WHL-07 Withdraw Money ────────────────────────────────────────────
function WhlWithdraw() {
  const methods = [
    { id: 'easypaisa', name: 'EasyPaisa',      sub: 'Mobile wallet · usually 2 hrs', icon: 'phone_android', selected: false, color: '#22C55E' },
    { id: 'jazzcash',  name: 'JazzCash',       sub: 'Mobile wallet · usually 2 hrs', icon: 'phone_android', selected: true,  color: '#EF4444' },
    { id: 'bank',      name: 'Bank Transfer',  sub: 'IBAN · 1 working day',          icon: 'account_balance', selected: false, color: '#0EA5E9' },
    { id: 'cash',      name: 'Cash from SGX',  sub: 'Collect from SGX branch',       icon: 'store',           selected: false, color: '#8B5CF6' },
  ];
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdraw Money" />
      <Scroll pad={16} gap={20}>
        {/* Balance banner */}
        <div style={{
          padding: 14, borderRadius: 12,
          background: 'var(--sgx-primary)', color: 'white',
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <span className="material-symbols-rounded mi-fill" style={{ fontSize: 28 }}>account_balance_wallet</span>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, opacity: 0.8 }}>Available Balance</div>
            <div style={{ fontSize: 22, fontWeight: 800, fontVariantNumeric: 'tabular-nums', marginTop: 2 }}>Rs. 18,420</div>
          </div>
          <div style={{ textAlign: 'right', fontSize: 11, opacity: 0.75 }}>
            <div>Minimum</div>
            <div style={{ fontSize: 14, fontWeight: 700, opacity: 1 }}>Rs. 500</div>
          </div>
        </div>

        {/* Amount */}
        <div>
          <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 8, color: 'var(--sgx-on-surface-variant)' }}>How much?</div>
          <TextField label="Amount" value="5,000" prefix="Rs." icon="payments" />
          <div style={{ marginTop: 10, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {['Rs. 500', 'Rs. 1,000', 'Rs. 5,000', 'All (Rs. 18,420)'].map((c, i) => (
              <div key={c} style={{
                height: 32, padding: '0 14px', borderRadius: 16,
                display: 'inline-flex', alignItems: 'center',
                background: i === 2 ? 'var(--sgx-primary)' : 'var(--sgx-surface)',
                color: i === 2 ? 'white' : 'var(--sgx-on-surface)',
                border: '1.5px solid ' + (i === 2 ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'),
                fontSize: 13, fontWeight: 600, cursor: 'pointer',
              }}>{c}</div>
            ))}
          </div>
        </div>

        {/* Payment method */}
        <div>
          <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 8, color: 'var(--sgx-on-surface-variant)' }}>Send to</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {methods.map(m => (
              <div key={m.id} style={{
                padding: 14, borderRadius: 12,
                border: '1.5px solid ' + (m.selected ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'),
                background: m.selected ? 'rgba(30,58,138,0.05)' : 'var(--sgx-surface)',
                display: 'flex', alignItems: 'center', gap: 12,
              }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 10,
                  background: `${m.color}20`, color: m.color,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22 }}>{m.icon}</span>
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 700 }}>{m.name}</div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{m.sub}</div>
                </div>
                <div style={{
                  width: 20, height: 20, borderRadius: 10,
                  border: '2px solid ' + (m.selected ? 'var(--sgx-primary)' : 'var(--sgx-outline)'),
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {m.selected && <div style={{ width: 10, height: 10, borderRadius: 5, background: 'var(--sgx-primary)' }}/>}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Conditional destination — JazzCash selected here */}
        <div>
          <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 8, color: 'var(--sgx-on-surface-variant)' }}>JazzCash details</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <TextField label="Account title" value="Muhammad Farhan" icon="person" />
            <TextField label="Mobile number" value="0300-1234567" icon="phone_iphone" />
          </div>
        </div>

        <FilledBtn icon="arrow_forward">Continue</FilledBtn>

        <div style={{ padding: '4px 4px 8px', fontSize: 12, color: 'var(--sgx-on-surface-variant)', textAlign: 'center', lineHeight: 1.55 }}>
          <span className="material-symbols-rounded" style={{ fontSize: 14, verticalAlign: 'middle', marginRight: 4 }}>lock</span>
          SGX processes withdrawals during business hours. You'll be notified when payment is sent.
        </div>
      </Scroll>
    </Phone>
  );
}

// ── WHL-07 Withdraw Money · Confirmation bottom sheet ────────────────
function WhlWithdrawConfirm() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdraw Money" />
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden' }}>
        {/* Dimmed backdrop */}
        <div style={{
          position: 'absolute', inset: 0,
          background: 'rgba(15, 23, 42, 0.55)', backdropFilter: 'blur(2px)',
        }}/>
        {/* Bottom sheet */}
        <div style={{
          position: 'absolute', left: 0, right: 0, bottom: 0,
          background: 'var(--sgx-surface)',
          borderTopLeftRadius: 28, borderTopRightRadius: 28,
          padding: '12px 20px 24px', display: 'flex', flexDirection: 'column', gap: 16,
          boxShadow: '0 -8px 24px rgba(0,0,0,0.15)',
        }}>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{ width: 32, height: 4, borderRadius: 2, background: 'var(--sgx-outline-variant)' }}/>
          </div>

          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>Confirm withdrawal</div>
            <div style={{ marginTop: 6, fontSize: 40, fontWeight: 800, color: 'var(--sgx-primary)', fontVariantNumeric: 'tabular-nums', letterSpacing: -1 }}>
              Rs. 5,000
            </div>
          </div>

          {/* Review rows */}
          <div style={{
            borderRadius: 16, background: 'var(--sgx-surface-container)',
            padding: '4px 16px',
          }}>
            {[
              { icon: 'phone_android', k: 'Method', v: 'JazzCash', c: '#EF4444' },
              { icon: 'person', k: 'Account title', v: 'Muhammad Farhan', c: 'var(--sgx-primary)' },
              { icon: 'phone_iphone', k: 'Mobile number', v: '0300 ••• 4567', c: 'var(--sgx-primary)' },
              { icon: 'schedule', k: 'Processing time', v: 'Usually within 2 hours', c: '#8A5A00' },
            ].map((r, i, a) => (
              <div key={r.k} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '12px 0',
                borderBottom: i < a.length - 1 ? '1px solid var(--sgx-outline-variant)' : 'none',
              }}>
                <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20, color: r.c }}>{r.icon}</span>
                <div style={{ flex: 1, fontSize: 13, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>{r.k}</div>
                <div style={{ fontSize: 14, fontWeight: 700 }}>{r.v}</div>
              </div>
            ))}
          </div>

          <div style={{ display: 'flex', gap: 10 }}>
            <div style={{ flex: 1 }}><OutlinedBtn>Cancel</OutlinedBtn></div>
            <div style={{ flex: 2 }}><FilledBtn icon="check">Confirm Withdrawal</FilledBtn></div>
          </div>
        </div>
      </div>
    </Phone>
  );
}

// ── WHL-08 Withdrawals ───────────────────────────────────────────────
function WhlWithdrawals() {
  const items = [
    { amt: 5000,  date: 'Today · 08:40 AM', method: 'JazzCash',      status: 'paid',      label: 'Payment Sent',  note: 'Confirm receipt' },
    { amt: 10000, date: '20 Jul · 03:12 PM', method: 'Bank Transfer', status: 'pending',   label: 'Pending',       note: 'SGX is processing' },
    { amt: 8000,  date: '18 Jul · 11:20 AM', method: 'EasyPaisa',    status: 'confirmed', label: 'Confirmed',     note: 'Payment received' },
    { amt: 2500,  date: '15 Jul · 04:40 PM', method: 'JazzCash',      status: 'refunded',  label: 'Refunded',      note: 'Returned to wallet' },
    { amt: 3000,  date: '10 Jul · 09:00 AM', method: 'Bank Transfer', status: 'auto',      label: 'Auto-confirmed',note: 'Closed after 3 days' },
    { amt: 4200,  date: '02 Jul · 02:10 PM', method: 'Cash from SGX', status: 'disputed',  label: 'Disputed',      note: 'Under review' },
  ];
  const methodIcon = { 'JazzCash': 'phone_android', 'EasyPaisa': 'phone_android', 'Bank Transfer': 'account_balance', 'Cash from SGX': 'store' };
  const methodColor = { 'JazzCash': '#EF4444', 'EasyPaisa': '#22C55E', 'Bank Transfer': '#0EA5E9', 'Cash from SGX': '#8B5CF6' };
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdrawals" trailing={<IconBtn icon="tune" />} />
      <Scroll pad={0} gap={0}>
        {/* Filter chips */}
        <div style={{ display: 'flex', gap: 8, padding: '4px 16px 16px', overflowX: 'auto' }}>
          {[
            { label: 'All', count: 6, active: true },
            { label: 'Open', count: 3 },
            { label: 'Completed', count: 3 },
          ].map(f => (
            <div key={f.label} style={{
              height: 32, padding: '0 14px', borderRadius: 16,
              background: f.active ? 'var(--sgx-primary)' : 'var(--sgx-surface)',
              color: f.active ? 'white' : 'var(--sgx-on-surface)',
              border: '1.5px solid ' + (f.active ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'),
              display: 'inline-flex', alignItems: 'center', gap: 6,
              fontSize: 13, fontWeight: 600, whiteSpace: 'nowrap',
            }}>
              {f.label}
              <span style={{
                minWidth: 18, height: 18, borderRadius: 9, padding: '0 5px',
                background: f.active ? 'rgba(255,255,255,0.20)' : 'var(--sgx-surface-container-high)',
                fontSize: 11, display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}>{f.count}</span>
            </div>
          ))}
        </div>

        {/* Withdrawal cards */}
        <div style={{ padding: '0 16px 20px', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {items.map((w, i) => (
            <div key={i} style={{
              padding: 14, borderRadius: 12,
              border: '1px solid var(--sgx-outline-variant)',
              background: 'var(--sgx-surface)',
            }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
                <div style={{
                  width: 44, height: 44, borderRadius: 10,
                  background: `${methodColor[w.method]}18`, color: methodColor[w.method],
                  display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                }}>
                  <span className="material-symbols-rounded mi-fill" style={{ fontSize: 24 }}>{methodIcon[w.method]}</span>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', gap: 8 }}>
                    <div style={{ fontSize: 18, fontWeight: 800, fontVariantNumeric: 'tabular-nums' }}>Rs. {w.amt.toLocaleString()}</div>
                    <StatusChip status={w.status} label={w.label} size="sm" />
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 4 }}>
                    {w.method} · {w.date}
                  </div>
                  <div style={{
                    marginTop: 10, paddingTop: 10,
                    borderTop: '1px solid var(--sgx-outline-variant)',
                    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  }}>
                    <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)' }}>{w.note}</div>
                    <span className="material-symbols-rounded" style={{ fontSize: 20, color: 'var(--sgx-on-surface-variant)' }}>chevron_right</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </Scroll>
    </Phone>
  );
}

Object.assign(window, { WhlWallet, WhlWithdraw, WhlWithdrawConfirm, WhlWithdrawals });
