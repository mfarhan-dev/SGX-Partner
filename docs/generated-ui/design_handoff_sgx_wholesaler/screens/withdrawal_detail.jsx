// SGX Partners — Wholesaler · Withdrawal Detail states
// WHL-09 · Pending · Payment Sent · Received-confirm dialog · Not-Received dialog
// · Disputed · Confirmed / Auto-confirmed · Refunded

// ── Shared header block for all withdrawal states ────────────────────
function _WdHeader({ amount, status, statusLabel, method, dest, submitted }) {
  const methodColor = { 'JazzCash': '#EF4444', 'EasyPaisa': '#22C55E', 'Bank Transfer': '#0EA5E9', 'Cash from SGX': '#8B5CF6' };
  const methodIcon = { 'JazzCash': 'phone_android', 'EasyPaisa': 'phone_android', 'Bank Transfer': 'account_balance', 'Cash from SGX': 'store' };
  return (
    <div style={{ padding: '4px 16px 0' }}>
      {/* Big amount */}
      <div style={{ textAlign: 'center', padding: '16px 0' }}>
        <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>Withdrawal amount</div>
        <div style={{ marginTop: 4, fontSize: 44, fontWeight: 800, letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>Rs. {amount}</div>
        <div style={{ marginTop: 10 }}>
          <StatusChip status={status} label={statusLabel} />
        </div>
      </div>

      {/* Method + destination card */}
      <div style={{
        padding: 14, borderRadius: 12,
        background: 'var(--sgx-surface-container)',
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <div style={{
          width: 44, height: 44, borderRadius: 10,
          background: `${methodColor[method]}18`, color: methodColor[method],
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <span className="material-symbols-rounded mi-fill" style={{ fontSize: 24 }}>{methodIcon[method]}</span>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 14, fontWeight: 700 }}>{method}</div>
          <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{dest}</div>
        </div>
        <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', textAlign: 'right' }}>
          <div>Submitted</div>
          <div style={{ fontWeight: 600, color: 'var(--sgx-on-surface)', marginTop: 2 }}>{submitted}</div>
        </div>
      </div>
    </div>
  );
}

// ── Timeline component ───────────────────────────────────────────────
function _Timeline({ steps }) {
  return (
    <div style={{ padding: '0 4px' }}>
      {steps.map((s, i) => (
        <div key={i} style={{ display: 'flex', gap: 12, position: 'relative' }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
            <div style={{
              width: 28, height: 28, borderRadius: 14,
              background: s.done ? 'var(--sgx-primary)' : 'var(--sgx-surface-container-high)',
              color: s.done ? 'white' : 'var(--sgx-on-surface-variant)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
              border: s.current ? '3px solid rgba(30,58,138,0.20)' : 'none',
              boxSizing: 'content-box',
            }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 16 }}>{s.icon}</span>
            </div>
            {i < steps.length - 1 && (
              <div style={{
                width: 2, flex: 1, minHeight: 30,
                background: s.done ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)',
                marginTop: 2, marginBottom: 2,
              }}/>
            )}
          </div>
          <div style={{ flex: 1, paddingBottom: 16 }}>
            <div style={{ fontSize: 14, fontWeight: 700, color: s.done ? 'var(--sgx-on-surface)' : 'var(--sgx-on-surface-variant)' }}>{s.title}</div>
            {s.time && <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{s.time}</div>}
            {s.note && <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 4, lineHeight: 1.4 }}>{s.note}</div>}
          </div>
        </div>
      ))}
    </div>
  );
}

// ── WHL-09 · Pending ─────────────────────────────────────────────────
function WhlWdPending() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdrawal" trailing={<IconBtn icon="more_vert" />} />
      <Scroll pad={0} gap={16}>
        <_WdHeader amount="10,000" status="pending" statusLabel="Pending"
          method="Bank Transfer" dest="Meezan Bank · IBAN ••• 4237" submitted="20 Jul" />

        <div style={{
          margin: '0 16px', padding: '14px 16px', borderRadius: 12,
          background: 'var(--sgx-warning-container)',
          display: 'flex', gap: 10, alignItems: 'flex-start',
        }}>
          <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22, color: '#8A5A00', flexShrink: 0 }}>schedule</span>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 700 }}>SGX is processing your withdrawal</div>
            <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 4, lineHeight: 1.5 }}>
              Bank transfers usually take 1 working day. You will be notified when the payment is sent.
            </div>
          </div>
        </div>

        <div style={{ padding: '0 16px' }}>
          <SectionHeader title="Progress" />
          <_Timeline steps={[
            { icon: 'edit_document', title: 'Withdrawal submitted', time: '20 Jul · 03:12 PM', done: true },
            { icon: 'hourglass_top', title: 'Being processed by SGX', time: 'In progress', done: true, current: true, note: 'Usually completes in 1 working day.' },
            { icon: 'send', title: 'Payment will be sent', done: false },
            { icon: 'check_circle', title: 'Payment confirmation', done: false },
          ]}/>
        </div>
      </Scroll>
    </Phone>
  );
}

// ── WHL-09 · Payment Sent (awaiting confirmation) ────────────────────
function WhlWdPaymentSent() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdrawal" trailing={<IconBtn icon="more_vert" />} />
      <Scroll pad={0} gap={16}>
        <_WdHeader amount="5,000" status="paid" statusLabel="Payment Sent"
          method="JazzCash" dest="0300 ••• 4567" submitted="Today" />

        {/* Payment details */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 14, borderRadius: 12,
            background: 'var(--sgx-surface-container)',
          }}>
            <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: 0.5 }}>Payment details</div>
            <div style={{ marginTop: 8, display: 'grid', gap: 8, fontSize: 13 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: 'var(--sgx-on-surface-variant)' }}>Payment date</span>
                <span style={{ fontWeight: 600 }}>Today, 11:20 AM</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: 'var(--sgx-on-surface-variant)' }}>Reference</span>
                <span style={{ fontWeight: 600, fontFamily: 'monospace' }}>JC-8827145</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ color: 'var(--sgx-on-surface-variant)' }}>Payment proof</span>
                <div style={{
                  display: 'inline-flex', alignItems: 'center', gap: 4,
                  color: 'var(--sgx-primary)', fontWeight: 600,
                }}>
                  <span className="material-symbols-rounded" style={{ fontSize: 18 }}>image</span>
                  View proof
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Confirmation prompt */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 16, borderRadius: 16,
            background: 'rgba(30,58,138,0.06)',
            border: '1px solid rgba(30,58,138,0.15)',
          }}>
            <div style={{ fontSize: 15, fontWeight: 700, textAlign: 'center' }}>Did you receive Rs. 5,000?</div>
            <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', textAlign: 'center', marginTop: 4 }}>
              Check your JazzCash before confirming.
            </div>
            <div style={{ display: 'flex', gap: 10, marginTop: 14 }}>
              <div style={{ flex: 1 }}>
                <button style={{
                  width: '100%', height: 48, borderRadius: 24,
                  border: '1.5px solid var(--sgx-error)',
                  background: 'var(--sgx-surface)', color: 'var(--sgx-error)',
                  fontSize: 14, fontWeight: 700,
                  display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
                }}>
                  <span className="material-symbols-rounded" style={{ fontSize: 18 }}>close</span>
                  Not Received
                </button>
              </div>
              <div style={{ flex: 1.4 }}>
                <FilledBtn icon="check_circle" tone="success">Yes, Received</FilledBtn>
              </div>
            </div>
          </div>
        </div>

        <div style={{ padding: '0 16px', fontSize: 12, color: 'var(--sgx-on-surface-variant)', textAlign: 'center', lineHeight: 1.5 }}>
          <span className="material-symbols-rounded" style={{ fontSize: 14, verticalAlign: 'middle', marginRight: 4 }}>info</span>
          If you don't respond within 3 days, this payment will be auto-confirmed.
        </div>
      </Scroll>
    </Phone>
  );
}

// ── WHL-09 · "Not Received" confirmation dialog ──────────────────────
function WhlWdNotReceivedDialog() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdrawal" />
      <div style={{ flex: 1, position: 'relative' }}>
        {/* dimmed underlay */}
        <div style={{ position: 'absolute', inset: 0, background: 'rgba(15, 23, 42, 0.55)' }}/>

        {/* Dialog */}
        <div style={{
          position: 'absolute', top: '50%', left: '50%',
          transform: 'translate(-50%, -50%)',
          width: 320, borderRadius: 28,
          background: 'var(--sgx-surface)',
          padding: 24, boxShadow: '0 20px 40px rgba(0,0,0,0.25)',
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: 28,
            background: 'var(--sgx-error-container)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            margin: '0 auto 16px',
          }}>
            <span className="material-symbols-rounded mi-fill" style={{ fontSize: 32, color: 'var(--sgx-error)' }}>error</span>
          </div>
          <div style={{ fontSize: 20, fontWeight: 700, textAlign: 'center', letterSpacing: -0.3 }}>Payment not received?</div>
          <div style={{ fontSize: 14, color: 'var(--sgx-on-surface-variant)', textAlign: 'center', marginTop: 8, lineHeight: 1.5 }}>
            This will report a payment problem to SGX. SGX will review and contact you.
          </div>
          <div style={{ display: 'flex', gap: 10, marginTop: 24 }}>
            <div style={{ flex: 1 }}><OutlinedBtn>Cancel</OutlinedBtn></div>
            <div style={{ flex: 1.3 }}>
              <button style={{
                width: '100%', height: 48, borderRadius: 24,
                background: 'var(--sgx-error)', color: 'white', border: 'none',
                fontSize: 14, fontWeight: 700, cursor: 'pointer',
              }}>Report Problem</button>
            </div>
          </div>
        </div>
      </div>
    </Phone>
  );
}

// ── WHL-09 · Disputed ────────────────────────────────────────────────
function WhlWdDisputed() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdrawal" trailing={<IconBtn icon="more_vert" />} />
      <Scroll pad={0} gap={16}>
        <_WdHeader amount="4,200" status="disputed" statusLabel="Disputed"
          method="Cash from SGX" dest="Collection · Lahore branch" submitted="02 Jul" />

        {/* Warning container */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 16, borderRadius: 12,
            background: 'var(--sgx-error-container)',
            border: '1px solid rgba(220,38,38,0.25)',
            display: 'flex', gap: 12, alignItems: 'flex-start',
          }}>
            <span className="material-symbols-rounded mi-fill" style={{ fontSize: 24, color: 'var(--sgx-error)', flexShrink: 0 }}>error</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--sgx-error)' }}>SGX is reviewing this payment problem</div>
              <div style={{ fontSize: 12, color: 'var(--sgx-on-surface)', marginTop: 6, lineHeight: 1.5 }}>
                We received your report on 03 Jul. Your Rs. 4,200 remains locked until this is resolved.
              </div>
            </div>
          </div>
        </div>

        {/* Contact SGX */}
        <div style={{ padding: '0 16px' }}>
          <button style={{
            width: '100%', height: 56, borderRadius: 12,
            background: '#25D366', color: 'white', border: 'none',
            fontSize: 15, fontWeight: 700,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 10,
            cursor: 'pointer',
          }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
              <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51l-.57-.01c-.198 0-.52.074-.792.372s-1.04 1.016-1.04 2.479 1.065 2.876 1.213 3.074c.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
            </svg>
            Contact SGX on WhatsApp
          </button>
        </div>

        <div style={{ padding: '0 16px' }}>
          <SectionHeader title="Progress" />
          <_Timeline steps={[
            { icon: 'edit_document', title: 'Withdrawal submitted', time: '02 Jul · 02:10 PM', done: true },
            { icon: 'send', title: 'Payment marked as sent', time: '03 Jul · 10:00 AM', done: true },
            { icon: 'error', title: 'You reported not received', time: '03 Jul · 05:22 PM', done: true, note: 'Amount stays locked in Pending.' },
            { icon: 'hourglass_top', title: 'SGX is reviewing', done: true, current: true },
            { icon: 'task_alt', title: 'Resolution', done: false },
          ]}/>
        </div>
      </Scroll>
    </Phone>
  );
}

// ── WHL-09 · Confirmed ───────────────────────────────────────────────
function WhlWdConfirmed({ auto = false }) {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdrawal" trailing={<IconBtn icon="more_vert" />} />
      <Scroll pad={0} gap={16}>
        <_WdHeader
          amount="8,000"
          status={auto ? 'auto' : 'confirmed'}
          statusLabel={auto ? 'Auto-confirmed' : 'Confirmed'}
          method="EasyPaisa" dest="0301 ••• 8890" submitted="18 Jul"
        />

        {/* Success */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 20, borderRadius: 16,
            background: 'var(--sgx-success-container)',
            border: '1px solid rgba(34,197,94,0.20)',
            display: 'flex', gap: 14, alignItems: 'center',
          }}>
            <div style={{
              width: 56, height: 56, borderRadius: 28,
              background: 'var(--sgx-success)', color: 'white',
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
            }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 32 }}>check</span>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 700 }}>
                {auto ? 'Closed automatically' : 'Payment confirmed'}
              </div>
              <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 4, lineHeight: 1.5 }}>
                {auto
                  ? 'This payment was closed automatically after the 3-day confirmation period.'
                  : 'Rs. 8,000 was successfully received.'}
              </div>
              <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', marginTop: 4 }}>
                Closed on {auto ? '21 Jul · 11:20 AM' : '18 Jul · 03:44 PM'}
              </div>
            </div>
          </div>
        </div>

        <div style={{ padding: '0 16px' }}>
          <SectionHeader title="Progress" />
          <_Timeline steps={[
            { icon: 'edit_document', title: 'Withdrawal submitted', time: '18 Jul · 11:20 AM', done: true },
            { icon: 'send', title: 'Payment sent by SGX', time: '18 Jul · 01:15 PM', done: true },
            { icon: 'check_circle', title: auto ? 'Auto-confirmed after 3 days' : 'You confirmed receipt', time: auto ? '21 Jul · 11:20 AM' : '18 Jul · 03:44 PM', done: true, current: true },
          ]}/>
        </div>
      </Scroll>
    </Phone>
  );
}

// ── WHL-09 · Refunded ────────────────────────────────────────────────
function WhlWdRefunded() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Withdrawal" trailing={<IconBtn icon="more_vert" />} />
      <Scroll pad={0} gap={16}>
        <_WdHeader amount="2,500" status="refunded" statusLabel="Refunded"
          method="JazzCash" dest="0300 ••• 9922" submitted="15 Jul" />

        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 20, borderRadius: 16,
            background: 'var(--sgx-success-container)',
            border: '1px solid rgba(34,197,94,0.20)',
            display: 'flex', gap: 14, alignItems: 'center',
          }}>
            <div style={{
              width: 56, height: 56, borderRadius: 28,
              background: 'var(--sgx-success)', color: 'white',
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
            }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 30 }}>currency_exchange</span>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 700 }}>Rs. 2,500 returned to wallet</div>
              <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 4, lineHeight: 1.5 }}>
                Payment could not be delivered. Your money is safely back in your available balance.
              </div>
            </div>
          </div>
        </div>

        <div style={{ padding: '0 16px' }}>
          <FilledBtn icon="account_balance_wallet">Open Wallet</FilledBtn>
        </div>

        <div style={{ padding: '0 16px' }}>
          <SectionHeader title="Progress" />
          <_Timeline steps={[
            { icon: 'edit_document', title: 'Withdrawal submitted', time: '15 Jul · 04:40 PM', done: true },
            { icon: 'send', title: 'Payment attempted', time: '16 Jul · 09:12 AM', done: true },
            { icon: 'currency_exchange', title: 'Money returned to wallet', time: '16 Jul · 11:30 AM', done: true, current: true, note: 'Reason: JazzCash account not active.' },
          ]}/>
        </div>
      </Scroll>
    </Phone>
  );
}

Object.assign(window, {
  WhlWdPending, WhlWdPaymentSent, WhlWdNotReceivedDialog,
  WhlWdDisputed, WhlWdConfirmed, WhlWdRefunded,
});
