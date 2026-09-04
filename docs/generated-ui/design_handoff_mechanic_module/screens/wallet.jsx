// SGX Partners — Wallet, Withdrawals, Scan History
// MEC-08 Scan History, MEC-09 Wallet, MEC-10 Withdraw, MEC-11 Withdrawals, MEC-12 Withdrawal Detail

// ── MEC-08 Scan History ──────────────────────────────────────────────
function MecScanHistory() {
  const rows = [
    { name: 'Shell Advance AX7 10W-40', when: 'Today · 10:24 AM', amt: 15, shop: 'Auto Zone Wholesale', kind: 'oil' },
    { name: 'NGK Spark Plug CR7HSA', when: 'Today · 09:12 AM', amt: 5, shop: 'Auto Zone Wholesale', kind: 'spark' },
    { name: 'K&N Air Filter HD-1013', when: 'Yesterday · 04:40 PM', amt: 12, shop: 'Rehman Parts House', kind: 'filter' },
    { name: 'DID Chain 428H-118L', when: 'Yesterday · 11:20 AM', amt: 25, shop: 'Rehman Parts House', kind: 'chain' },
    { name: 'CEAT Milaze 90/90-18', when: '20 Jul · 03:14 PM', amt: 40, shop: 'MotoMax Distributors', kind: 'tire' },
    { name: 'Osaka Battery YB5L-B', when: '19 Jul · 10:02 AM', amt: 30, shop: 'MotoMax Distributors', kind: 'battery' },
  ];
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Scan History" trailing={<IconBtn icon="filter_list" />} />
      <Scroll pad={0} gap={0}>
        {/* Summary card */}
        <div style={{ padding: '4px 16px 20px' }}>
          <div style={{
            padding: 16, borderRadius: 16,
            background: 'var(--sgx-surface-container)',
            display: 'flex', gap: 16,
          }}>
            <div style={{ flex: 1 }}>
              <div className="t-supporting" style={{ color: 'var(--sgx-on-surface-variant)' }}>Total scans</div>
              <div style={{ fontSize: 24, fontWeight: 700, fontVariantNumeric: 'tabular-nums' }}>124</div>
            </div>
            <div style={{ width: 1, background: 'var(--sgx-outline-variant)' }}/>
            <div style={{ flex: 1 }}>
              <div className="t-supporting" style={{ color: 'var(--sgx-on-surface-variant)' }}>Earned from scans</div>
              <div style={{ fontSize: 24, fontWeight: 700, color: 'var(--sgx-success)', fontVariantNumeric: 'tabular-nums' }}>Rs. 28,540</div>
            </div>
          </div>
        </div>

        {/* Date groups */}
        {['Today', 'Yesterday', '20 Jul 2026'].map((day, di) => (
          <div key={day}>
            <div style={{
              padding: '10px 20px 8px', fontSize: 12, fontWeight: 700, letterSpacing: 0.6,
              color: 'var(--sgx-on-surface-variant)', textTransform: 'uppercase',
              background: 'var(--sgx-surface-low)',
            }}>{day}</div>
            {rows.filter(r => r.when.startsWith(day.split(' ')[0])).slice(0, di === 0 ? 2 : 2).map((r, i) => (
              <div key={i} style={{
                padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 12,
                borderBottom: '1px solid var(--sgx-outline-variant)',
                background: 'var(--sgx-surface)',
              }}>
                <ImgSlot w={44} h={44} radius={8} kind={r.kind} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 14, fontWeight: 600, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{r.name}</div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2, display: 'flex', alignItems: 'center', gap: 6 }}>
                    <span>{r.when.split(' · ')[1]}</span>
                    <span>·</span>
                    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 3 }}>
                      <span className="material-symbols-rounded" style={{ fontSize: 12 }}>storefront</span>
                      {r.shop}
                    </span>
                  </div>
                </div>
                <div style={{ textAlign: 'right', flexShrink: 0 }}>
                  <div style={{ fontSize: 16, fontWeight: 700, color: 'var(--sgx-success)', fontVariantNumeric: 'tabular-nums' }}>+Rs. {r.amt}</div>
                  <div style={{ fontSize: 11, color: 'var(--sgx-success)', display: 'inline-flex', alignItems: 'center', gap: 2, fontWeight: 600 }}>
                    <span className="material-symbols-rounded mi-fill" style={{ fontSize: 12 }}>check_circle</span>
                    Confirmed
                  </div>
                </div>
              </div>
            ))}
          </div>
        ))}
      </Scroll>
    </Phone>
  );
}

// ── MEC-09 Wallet ────────────────────────────────────────────────────
function MecWallet() {
  const tx = [
    { icon: 'qr_code_2', title: 'QR reward added', sub: 'Shell Advance AX7 · Today, 10:24 AM', amt: '+15', pos: true },
    { icon: 'qr_code_2', title: 'QR reward added', sub: 'NGK Spark Plug · Today, 09:12 AM', amt: '+5', pos: true },
    { icon: 'payments', title: 'Withdrawal requested', sub: 'JazzCash · Today, 08:40 AM', amt: '−1,500', pos: false, status: 'pending' },
    { icon: 'qr_code_2', title: 'QR reward added', sub: 'K&N Air Filter · Yesterday', amt: '+12', pos: true },
    { icon: 'check_circle', title: 'Withdrawal confirmed', sub: 'EasyPaisa · 18 Jul', amt: '−2,000', pos: false, status: 'confirmed' },
    { icon: 'restart_alt', title: 'Money returned to wallet', sub: 'Refund · 15 Jul', amt: '+500', pos: true, status: 'refunded' },
  ];
  return (
    <Phone>
      <TopAppBar title="Wallet" leading={<div style={{width:12}}/>} trailing={<IconBtn icon="notifications" />} />
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
            <div style={{ marginTop: 6, fontSize: 44, fontWeight: 800, letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>Rs. 4,285</div>

            <div style={{ display: 'flex', gap: 12, marginTop: 20 }}>
              <div style={{ flex: 1, padding: 12, borderRadius: 12, background: 'rgba(255,255,255,0.10)' }}>
                <div style={{ fontSize: 11, opacity: 0.75, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>Pending</div>
                <div style={{ marginTop: 4, fontSize: 17, fontWeight: 700, fontVariantNumeric: 'tabular-nums' }}>Rs. 1,500</div>
              </div>
              <div style={{ flex: 1, padding: 12, borderRadius: 12, background: 'rgba(255,255,255,0.10)' }}>
                <div style={{ fontSize: 11, opacity: 0.75, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>Lifetime</div>
                <div style={{ marginTop: 4, fontSize: 17, fontWeight: 700, fontVariantNumeric: 'tabular-nums' }}>Rs. 28,540</div>
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
            <span className="material-symbols-rounded">history</span>
          </button>
        </div>

        <div style={{ padding: '0 16px' }}>
          <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', display: 'flex', alignItems: 'center', gap: 6 }}>
            <span className="material-symbols-rounded" style={{ fontSize: 14 }}>info</span>
            Minimum withdrawal is Rs. 500.
          </div>
        </div>

        {/* Transactions header */}
        <SectionHeader title="Recent activity" action="View Withdrawals" />

        {/* Transaction list */}
        <div style={{ background: 'var(--sgx-surface)' }}>
          {tx.map((t, i) => (
            <div key={i} style={{
              padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 12,
              borderTop: '1px solid var(--sgx-outline-variant)',
            }}>
              <div style={{
                width: 40, height: 40, borderRadius: 20,
                background: t.pos ? 'var(--sgx-success-container)' : 'rgba(30,58,138,0.10)',
                color: t.pos ? 'var(--sgx-success)' : 'var(--sgx-primary)',
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
                {t.status && <StatusChip status={t.status} label={t.status === 'pending' ? 'Pending' : t.status === 'confirmed' ? 'Confirmed' : 'Refunded'} size="sm" />}
              </div>
            </div>
          ))}
        </div>
      </Scroll>
      <BottomBar active="wallet" />
    </Phone>
  );
}

// ── MEC-10 Withdraw Money ────────────────────────────────────────────
function MecWithdraw() {
  const methods = [
    { id: 'easypaisa', name: 'EasyPaisa', sub: 'Mobile wallet · usually 2 hrs', icon: 'phone_android', selected: false, color: '#22C55E' },
    { id: 'jazzcash', name: 'JazzCash', sub: 'Mobile wallet · usually 2 hrs', icon: 'phone_android', selected: true, color: '#EF4444' },
    { id: 'bank', name: 'Bank Transfer', sub: 'IBAN · 1 working day', icon: 'account_balance', selected: false, color: '#0EA5E9' },
    { id: 'cash', name: 'Cash from SGX', sub: 'Collect from SGX branch', icon: 'store', selected: false, color: '#8B5CF6' },
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
            <div style={{ fontSize: 22, fontWeight: 800, fontVariantNumeric: 'tabular-nums' }}>Rs. 4,285</div>
          </div>
          <div style={{ fontSize: 11, opacity: 0.75, textAlign: 'right' }}>Min Rs. 500</div>
        </div>

        {/* Amount input */}
        <div>
          <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--sgx-on-surface-variant)', marginBottom: 8 }}>How much do you want?</div>
          <div style={{
            padding: '16px 16px', borderRadius: 12,
            border: '2px solid var(--sgx-primary)',
            background: 'var(--sgx-surface)',
            display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <span style={{ fontSize: 24, fontWeight: 700, color: 'var(--sgx-on-surface-variant)' }}>Rs.</span>
            <div style={{ flex: 1, fontSize: 32, fontWeight: 800, color: 'var(--sgx-on-surface)', fontVariantNumeric: 'tabular-nums' }}>1,500</div>
            <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>backspace</span>
          </div>
          <div style={{ marginTop: 12, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {['Rs. 500', 'Rs. 1,000', 'Rs. 2,000', 'All'].map((c, i) => (
              <div key={c} style={{
                height: 32, padding: '0 14px', borderRadius: 16,
                border: `1px solid ${i === 1 ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'}`,
                background: i === 1 ? 'var(--sgx-secondary)' : 'var(--sgx-surface)',
                color: i === 1 ? 'var(--sgx-on-secondary)' : 'var(--sgx-on-surface)',
                fontSize: 13, fontWeight: 600,
                display: 'inline-flex', alignItems: 'center',
              }}>{c}</div>
            ))}
          </div>
        </div>

        {/* Method */}
        <div>
          <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--sgx-on-surface-variant)', marginBottom: 8 }}>Choose payment method</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {methods.map(m => (
              <div key={m.id} style={{
                padding: 14, borderRadius: 12,
                border: `${m.selected ? '2px' : '1.5px'} solid ${m.selected ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'}`,
                background: m.selected ? 'var(--sgx-secondary)' : 'var(--sgx-surface)',
                display: 'flex', alignItems: 'center', gap: 12,
              }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 20,
                  background: `${m.color}18`, color: m.color,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22 }}>{m.icon}</span>
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 15, fontWeight: 700 }}>{m.name}</div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)' }}>{m.sub}</div>
                </div>
                <div style={{
                  width: 22, height: 22, borderRadius: 11,
                  border: `2px solid ${m.selected ? 'var(--sgx-primary)' : 'var(--sgx-outline)'}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {m.selected && <div style={{ width: 12, height: 12, borderRadius: 6, background: 'var(--sgx-primary)' }}/>}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* JazzCash fields (conditional) */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <TextField label="Account Title *" value="Muhammad Farhan" icon="person" />
          <TextField label="Mobile Number *" value="0300-1234567" icon="phone" prefix="+92" />
        </div>

        <div style={{
          padding: 12, borderRadius: 10, background: 'var(--sgx-surface-container)',
          display: 'flex', gap: 8, alignItems: 'flex-start',
          fontSize: 12, color: 'var(--sgx-on-surface-variant)',
        }}>
          <span className="material-symbols-rounded" style={{ fontSize: 18, color: 'var(--sgx-primary)' }}>schedule</span>
          <span>JazzCash withdrawals usually arrive within <strong style={{color:'var(--sgx-on-surface)'}}>2 hours</strong> during working hours.</span>
        </div>

        <FilledBtn icon="arrow_forward">Continue</FilledBtn>
      </Scroll>
    </Phone>
  );
}

// ── MEC-11 Withdrawals list ──────────────────────────────────────────
function MecWithdrawals() {
  const items = [
    { amt: 1500, method: 'JazzCash', date: 'Today · 08:40 AM', status: 'pending', msg: 'SGX is processing your payment.' },
    { amt: 2000, method: 'EasyPaisa', date: '18 Jul · 11:20 AM', status: 'confirmed', msg: 'You confirmed receipt.' },
    { amt: 3500, method: 'Bank Transfer', date: '10 Jul · 09:15 AM', status: 'auto', msg: 'Closed automatically after 3 days.' },
    { amt: 500,  method: 'Cash from SGX', date: '05 Jul · 03:00 PM', status: 'disputed', msg: 'SGX is reviewing this payment problem.' },
    { amt: 1000, method: 'EasyPaisa', date: '28 Jun · 02:20 PM', status: 'refunded', msg: 'Money returned to your wallet.' },
  ];
  const chips = ['All', 'Open', 'Completed'];
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdrawals" />
      <div style={{ padding: '4px 16px 12px', display: 'flex', gap: 8 }}>
        {chips.map((c, i) => (
          <div key={c} style={{
            height: 32, padding: '0 14px', borderRadius: 16,
            border: `1px solid ${i === 0 ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'}`,
            background: i === 0 ? 'var(--sgx-secondary)' : 'var(--sgx-surface)',
            color: i === 0 ? 'var(--sgx-on-secondary)' : 'var(--sgx-on-surface-variant)',
            fontSize: 13, fontWeight: 600, display: 'inline-flex', alignItems: 'center',
          }}>{c}</div>
        ))}
      </div>
      <Scroll pad={16} gap={10}>
        {items.map((w, i) => (
          <div key={i} style={{
            padding: 14, borderRadius: 12,
            border: '1px solid var(--sgx-outline-variant)',
            background: 'var(--sgx-surface)',
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div>
                <div style={{ fontSize: 20, fontWeight: 800, fontVariantNumeric: 'tabular-nums' }}>Rs. {w.amt.toLocaleString()}</div>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{w.method} · {w.date}</div>
              </div>
              <StatusChip
                status={w.status === 'auto' ? 'auto' : w.status}
                label={{pending:'Pending',confirmed:'Confirmed',auto:'Auto-confirmed',disputed:'Disputed',refunded:'Refunded'}[w.status]}
                size="sm"
              />
            </div>
            <div style={{ marginTop: 10, paddingTop: 10, borderTop: '1px solid var(--sgx-outline-variant)', fontSize: 13, color: 'var(--sgx-on-surface-variant)', display: 'flex', alignItems: 'center', gap: 6 }}>
              <span className="material-symbols-rounded" style={{ fontSize: 16 }}>info</span>
              {w.msg}
            </div>
          </div>
        ))}
      </Scroll>
    </Phone>
  );
}

// ── MEC-12 Withdrawal Detail (Payment Sent state — most useful) ──────
function MecWithdrawalDetail() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdrawal" />
      <Scroll pad={16} gap={16}>
        {/* Hero */}
        <div style={{ textAlign: 'center', padding: '8px 0 4px' }}>
          <StatusChip status="paid" label="Payment Sent" />
          <div style={{ marginTop: 14, fontSize: 44, fontWeight: 800, letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>Rs. 2,000</div>
          <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>EasyPaisa · Sent today at 11:20 AM</div>
        </div>

        {/* Confirmation prompt */}
        <div style={{
          padding: 16, borderRadius: 16,
          background: 'linear-gradient(180deg, var(--sgx-secondary) 0%, var(--sgx-surface-container) 100%)',
          border: '1px solid var(--sgx-outline-variant)',
        }}>
          <div style={{ fontSize: 16, fontWeight: 700, textAlign: 'center' }}>Did you receive this payment?</div>
          <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', textAlign: 'center', marginTop: 6 }}>
            Please check your EasyPaisa balance and confirm.
          </div>
          <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
            <div style={{ flex: 1 }}><OutlinedBtn icon="close">Not Received</OutlinedBtn></div>
            <div style={{ flex: 1 }}><FilledBtn tone="success" icon="check">Received</FilledBtn></div>
          </div>
        </div>

        {/* Details */}
        <div style={{
          borderRadius: 12, background: 'var(--sgx-surface-container)', overflow: 'hidden',
        }}>
          {[
            { l: 'Payment method', v: 'EasyPaisa' },
            { l: 'Sent to', v: '0300-****567 · Muhammad Farhan' },
            { l: 'Reference', v: 'EP-8842-5619-7203' },
            { l: 'Submitted', v: '20 Jul 2026 · 09:12 AM' },
            { l: 'Payment sent', v: '20 Jul 2026 · 11:20 AM' },
          ].map((r, i, a) => (
            <div key={r.l} style={{
              padding: '12px 14px', display: 'flex', justifyContent: 'space-between', gap: 12,
              borderBottom: i < a.length - 1 ? '1px solid var(--sgx-outline-variant)' : 'none',
            }}>
              <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)' }}>{r.l}</div>
              <div style={{ fontSize: 13, fontWeight: 600, textAlign: 'right' }}>{r.v}</div>
            </div>
          ))}
        </div>

        {/* Timeline */}
        <div>
          <div className="t-section-title" style={{ marginBottom: 12, paddingLeft: 4 }}>Timeline</div>
          <div style={{ position: 'relative', paddingLeft: 28 }}>
            <div style={{ position: 'absolute', left: 11, top: 4, bottom: 20, width: 2, background: 'var(--sgx-outline-variant)' }}/>
            {[
              { t: 'Withdrawal requested', d: 'Today · 09:12 AM', done: true },
              { t: 'Payment sent by SGX', d: 'Today · 11:20 AM', done: true, active: true },
              { t: 'Waiting for your confirmation', d: 'Auto-confirms in 2 days', done: false },
            ].map((e, i) => (
              <div key={i} style={{ position: 'relative', paddingBottom: 20 }}>
                <div style={{
                  position: 'absolute', left: -22, top: 0,
                  width: 24, height: 24, borderRadius: 12,
                  background: e.done ? (e.active ? 'var(--sgx-primary)' : 'var(--sgx-success)') : 'var(--sgx-surface)',
                  border: e.done ? 'none' : '2px solid var(--sgx-outline-variant)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  color: 'white',
                }}>
                  {e.done && <span className="material-symbols-rounded" style={{ fontSize: 14 }}>{e.active ? 'send' : 'check'}</span>}
                </div>
                <div style={{ fontSize: 14, fontWeight: e.done ? 600 : 500, color: e.done ? 'var(--sgx-on-surface)' : 'var(--sgx-on-surface-variant)' }}>{e.t}</div>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{e.d}</div>
              </div>
            ))}
          </div>
        </div>

        <TextBtn icon="support_agent">Contact SGX on WhatsApp</TextBtn>
      </Scroll>
    </Phone>
  );
}

Object.assign(window, { MecScanHistory, MecWallet, MecWithdraw, MecWithdrawals, MecWithdrawalDetail });
