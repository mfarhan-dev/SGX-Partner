// SGX Partners — Wholesaler · Home & QR Progress
// WHL-04 Home (populated + empty-rewards variant) · WHL-05 QR Progress (populated + empty)

// ── WHL-04 Home ──────────────────────────────────────────────────────
function WhlHome() {
  return (
    <Phone>
      <TopAppBar
        title="SGX Partners"
        showBrand
        leading={<div style={{ width: 12 }}/>}
        trailing={<IconBtn icon="notifications" badge="4" />}
      />
      <Scroll pad={0} gap={20}>
        {/* Greeting */}
        <div style={{ padding: '4px 20px 0' }}>
          <div style={{ fontSize: 14, color: 'var(--sgx-on-surface-variant)' }}>Assalam-o-Alaikum,</div>
          <div style={{ fontSize: 22, fontWeight: 700, marginTop: 2, letterSpacing: -0.2 }}>Muhammad Farhan</div>
          <div style={{ fontSize: 13, color: 'var(--sgx-primary)', fontWeight: 600, marginTop: 2, display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            <span className="material-symbols-rounded mi-fill" style={{ fontSize: 14 }}>storefront</span>
            Farhan Motor Parts · Lahore
          </div>
        </div>

        {/* Wallet Hero — 3 values max, per PRD simplicity rule */}
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
            <div style={{ marginTop: 6, fontSize: 42, fontWeight: 800, letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>
              Rs. 18,420
            </div>

            <div style={{ display: 'flex', gap: 20, marginTop: 20, paddingTop: 14, borderTop: '1px solid rgba(255,255,255,0.15)' }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 10.5, opacity: 0.7, textTransform: 'uppercase', letterSpacing: 0.4, fontWeight: 600 }}>Pending</div>
                <div style={{ fontSize: 15, fontWeight: 700, marginTop: 3, fontVariantNumeric: 'tabular-nums' }}>Rs. 5,000</div>
              </div>
              <div style={{ width: 1, background: 'rgba(255,255,255,0.15)' }}/>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 10.5, opacity: 0.7, textTransform: 'uppercase', letterSpacing: 0.4, fontWeight: 600 }}>Lifetime</div>
                <div style={{ fontSize: 15, fontWeight: 700, marginTop: 3, fontVariantNumeric: 'tabular-nums' }}>Rs. 1.42L</div>
              </div>
            </div>

            <button style={{
              marginTop: 16, width: '100%', height: 44,
              borderRadius: 22, border: 'none',
              background: 'white', color: 'var(--sgx-primary)',
              fontSize: 15, fontWeight: 700,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              cursor: 'pointer',
            }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20 }}>payments</span>
              Withdraw Money
            </button>
          </div>
        </div>

        {/* QR Progress summary card */}
        <div>
          <SectionHeader title="QR Progress" action="View all" />
          <div style={{ padding: '0 16px' }}>
            <div style={{
              padding: 16, borderRadius: 16,
              background: 'var(--sgx-surface-container)',
            }}>
              <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 6 }}>
                <div>
                  <span style={{ fontSize: 28, fontWeight: 800, color: 'var(--sgx-primary)', fontVariantNumeric: 'tabular-nums' }}>486</span>
                  <span style={{ fontSize: 15, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}> / 720 scanned</span>
                </div>
                <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', fontWeight: 600 }}>67%</div>
              </div>
              <ProgressBar value={486} total={720} height={10} />
              <div style={{ display: 'flex', gap: 14, marginTop: 14 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, flex: 1 }}>
                  <div style={{ width: 10, height: 10, borderRadius: 5, background: 'var(--sgx-primary)' }}/>
                  <div>
                    <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>Scanned</div>
                    <div style={{ fontSize: 13, fontWeight: 700 }}>486 QRs</div>
                  </div>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, flex: 1 }}>
                  <div style={{ width: 10, height: 10, borderRadius: 5, background: 'var(--sgx-outline-variant)' }}/>
                  <div>
                    <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>Remaining</div>
                    <div style={{ fontSize: 13, fontWeight: 700 }}>234 QRs</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Latest reward */}
        <div>
          <SectionHeader title="Latest reward" />
          <div style={{ padding: '0 16px' }}>
            <div style={{
              padding: 14, borderRadius: 12,
              background: 'var(--sgx-success-container)',
              display: 'flex', alignItems: 'center', gap: 12,
              border: '1px solid rgba(34, 197, 94, 0.15)',
            }}>
              <div style={{
                width: 44, height: 44, borderRadius: 22,
                background: 'var(--sgx-success)', color: 'white',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <span className="material-symbols-rounded mi-fill" style={{ fontSize: 24 }}>add_circle</span>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 15, fontWeight: 700 }}>Rs. 12 added to wallet</div>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>
                  Shell Advance AX7 · 2 mins ago
                </div>
              </div>
              <div style={{ fontSize: 18, fontWeight: 800, color: 'var(--sgx-success)', fontVariantNumeric: 'tabular-nums' }}>+12</div>
            </div>
          </div>
        </div>

        {/* Active withdrawal — appears only when open */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 14, borderRadius: 12,
            background: 'var(--sgx-warning-container)',
            display: 'flex', alignItems: 'center', gap: 12,
            border: '1px solid rgba(234, 179, 8, 0.20)',
          }}>
            <div style={{ width: 40, height: 40, borderRadius: 20, background: 'rgba(0,0,0,0.06)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22, color: '#8A5A00' }}>schedule</span>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700 }}>Payment sent — please confirm</div>
              <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>Rs. 5,000 · JazzCash · Today</div>
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
              <ImgSlot w="100%" h={130} radius={0} kind="camp" label="Wholesaler Bonus" />
              <div style={{ padding: 14, background: 'var(--sgx-surface-container)' }}>
                <div style={{ fontSize: 15, fontWeight: 700 }}>Distributor Growth Bonus</div>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 4 }}>Until 31 Jul · Extra 10% on filter sales</div>
              </div>
            </div>
          </div>
        </div>

        {/* Quick actions */}
        <div>
          <SectionHeader title="Quick actions" />
          <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            {[
              { icon: 'qr_code_2', label: 'QR Progress', c: '#1E3A8A' },
              { icon: 'account_balance_wallet', label: 'Wallet', c: '#7C3AED' },
              { icon: 'payments', label: 'Withdraw', c: '#059669' },
              { icon: 'category', label: 'Products', c: '#0EA5E9' },
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
      <WholesalerBottomBar active="home" />
    </Phone>
  );
}

// ── WHL-04 Home · Empty rewards (new account) ────────────────────────
function WhlHomeEmpty() {
  return (
    <Phone>
      <TopAppBar title="SGX Partners" showBrand leading={<div style={{width:12}}/>}
        trailing={<IconBtn icon="notifications" />} />
      <Scroll pad={0} gap={20}>
        <div style={{ padding: '4px 20px 0' }}>
          <div style={{ fontSize: 14, color: 'var(--sgx-on-surface-variant)' }}>Assalam-o-Alaikum,</div>
          <div style={{ fontSize: 22, fontWeight: 700, marginTop: 2 }}>Muhammad Farhan</div>
          <div style={{ fontSize: 13, color: 'var(--sgx-primary)', fontWeight: 600, marginTop: 2, display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            <span className="material-symbols-rounded mi-fill" style={{ fontSize: 14 }}>storefront</span>
            Farhan Motor Parts · Lahore
          </div>
        </div>

        {/* Wallet Hero at zero */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 20, borderRadius: 20,
            background: 'linear-gradient(135deg, var(--sgx-primary) 0%, oklch(0.28 0.14 265) 100%)',
            color: 'white', position: 'relative', overflow: 'hidden',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, opacity: 0.85 }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 20 }}>account_balance_wallet</span>
              <span style={{ fontSize: 13, fontWeight: 500 }}>Available Balance</span>
            </div>
            <div style={{ marginTop: 6, fontSize: 42, fontWeight: 800, letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>Rs. 0</div>
            <div style={{ marginTop: 8, fontSize: 12, opacity: 0.75 }}>Minimum withdrawal Rs. 500</div>

            <button disabled style={{
              marginTop: 16, width: '100%', height: 44, borderRadius: 22, border: 'none',
              background: 'rgba(255,255,255,0.15)', color: 'rgba(255,255,255,0.6)',
              fontSize: 15, fontWeight: 700, cursor: 'not-allowed',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            }}>
              <span className="material-symbols-rounded" style={{ fontSize: 20 }}>lock</span>
              Withdraw Money
            </button>
          </div>
        </div>

        {/* Empty reward state */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 24, borderRadius: 16,
            background: 'var(--sgx-surface-container)',
            display: 'flex', flexDirection: 'column', alignItems: 'center',
            textAlign: 'center', gap: 12,
          }}>
            <div style={{
              width: 72, height: 72, borderRadius: 36,
              background: 'rgba(30,58,138,0.10)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span className="material-symbols-rounded" style={{ fontSize: 40, color: 'var(--sgx-primary)' }}>qr_code_2</span>
            </div>
            <div>
              <div style={{ fontSize: 16, fontWeight: 700 }}>No rewards yet</div>
              <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', marginTop: 6, lineHeight: 1.5, maxWidth: 260 }}>
                Rewards will appear when mechanics scan your SGX product QRs.
              </div>
            </div>
          </div>
        </div>

        {/* Quick actions */}
        <div>
          <SectionHeader title="Explore" />
          <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            {[
              { icon: 'category', label: 'Products', c: '#0EA5E9' },
              { icon: 'campaign', label: 'Campaigns', c: '#059669' },
              { icon: 'support_agent', label: 'Contact SGX', c: '#7C3AED' },
              { icon: 'person', label: 'Profile', c: '#1E3A8A' },
            ].map(q => (
              <div key={q.label} style={{
                padding: 14, borderRadius: 12, background: 'var(--sgx-surface-container)',
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
      </Scroll>
      <WholesalerBottomBar active="home" />
    </Phone>
  );
}

// ── WHL-05 QR Progress ───────────────────────────────────────────────
function WhlQrProgress() {
  const groups = [
    { name: 'Shell Advance AX7 10W-40', ref: 'INV-0058', total: 200, scanned: 148, earned: 1776, kind: 'oil', status: 'active' },
    { name: 'NGK Spark Plug CR7HSA',    ref: 'INV-0058', total: 150, scanned: 150, earned: 750,  kind: 'spark', status: 'complete' },
    { name: 'K&N Air Filter HD-1013',   ref: 'INV-0061', total: 100, scanned:  58, earned: 696,  kind: 'filter', status: 'active' },
    { name: 'CEAT Milaze 90/90-18',     ref: 'INV-0061', total:  80, scanned:  40, earned: 1600, kind: 'tire',  status: 'active' },
    { name: 'DID Chain 428H-118L',      ref: 'INV-0055', total: 120, scanned:  90, earned: 2250, kind: 'chain', status: 'active' },
    { name: 'Osaka Battery YB5L-B',     ref: 'INV-0055', total:  70, scanned:  70, earned: 2100, kind: 'battery', status: 'complete' },
  ];
  return (
    <Phone>
      <TopAppBar
        title="QR Progress"
        leading={<div style={{width:12}}/>}
        trailing={<IconBtn icon="notifications" badge="4" />}
      />
      <Scroll pad={0} gap={0}>
        {/* Aggregate summary */}
        <div style={{ padding: '4px 16px 16px' }}>
          <div style={{
            padding: 18, borderRadius: 16,
            background: 'var(--sgx-surface-container)',
          }}>
            <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', textTransform: 'uppercase', letterSpacing: 0.5, fontWeight: 600 }}>Overall progress</div>
            <div style={{ display: 'flex', gap: 20, marginTop: 12, marginBottom: 14 }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>Total</div>
                <div style={{ fontSize: 22, fontWeight: 800, fontVariantNumeric: 'tabular-nums' }}>720</div>
              </div>
              <div style={{ flex: 1, borderLeft: '1px solid var(--sgx-outline-variant)', paddingLeft: 20 }}>
                <div style={{ fontSize: 11, color: 'var(--sgx-primary)', fontWeight: 500 }}>Scanned</div>
                <div style={{ fontSize: 22, fontWeight: 800, color: 'var(--sgx-primary)', fontVariantNumeric: 'tabular-nums' }}>486</div>
              </div>
              <div style={{ flex: 1, borderLeft: '1px solid var(--sgx-outline-variant)', paddingLeft: 20 }}>
                <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>Remaining</div>
                <div style={{ fontSize: 22, fontWeight: 800, color: 'var(--sgx-on-surface-variant)', fontVariantNumeric: 'tabular-nums' }}>234</div>
              </div>
            </div>
            <ProgressBar value={486} total={720} height={10} />
            <div style={{ marginTop: 12, fontSize: 12, color: 'var(--sgx-on-surface-variant)', display: 'flex', alignItems: 'center', gap: 6 }}>
              <span className="material-symbols-rounded" style={{ fontSize: 14 }}>refresh</span>
              Updated just now · Pull down to refresh
            </div>
          </div>
        </div>

        {/* Group cards — NON-tappable per spec §9 */}
        <div style={{ padding: '0 16px 20px', display: 'flex', flexDirection: 'column', gap: 12 }}>
          {groups.map((g, i) => {
            const remaining = g.total - g.scanned;
            const isComplete = g.status === 'complete';
            return (
              <div key={i} style={{
                padding: 16, borderRadius: 16,
                background: 'var(--sgx-surface)',
                border: '1px solid var(--sgx-outline-variant)',
                // no cursor:pointer — cards are not tappable
              }}>
                <div style={{ display: 'flex', gap: 12, marginBottom: 12 }}>
                  <ImgSlot w={56} h={56} radius={12} kind={g.kind} />
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 15, fontWeight: 700, lineHeight: 1.3 }}>{g.name}</div>
                    <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 4, display: 'flex', alignItems: 'center', gap: 6 }}>
                      <span className="material-symbols-rounded" style={{ fontSize: 14 }}>receipt_long</span>
                      {g.ref}
                    </div>
                  </div>
                  <StatusChip
                    status={isComplete ? 'confirmed' : 'paid'}
                    label={isComplete ? 'Complete' : 'Active'}
                    size="sm"
                  />
                </div>

                {/* Counts row */}
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8, fontSize: 13 }}>
                  <div style={{ color: 'var(--sgx-primary)', fontWeight: 700 }}>
                    <span style={{ fontSize: 18, fontVariantNumeric: 'tabular-nums' }}>{g.scanned}</span>
                    <span style={{ color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}> scanned</span>
                  </div>
                  <div style={{ color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>
                    <span style={{ fontWeight: 700, color: 'var(--sgx-on-surface)' }}>{remaining}</span> remaining
                  </div>
                </div>

                <ProgressBar
                  value={g.scanned}
                  total={g.total}
                  height={8}
                  tone={isComplete ? 'success' : 'primary'}
                />

                {/* Earned line */}
                <div style={{
                  marginTop: 14, paddingTop: 12,
                  borderTop: '1px solid var(--sgx-outline-variant)',
                  display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                }}>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', fontWeight: 500 }}>Earned from this batch</div>
                  <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--sgx-success)', fontVariantNumeric: 'tabular-nums' }}>
                    Rs. {g.earned.toLocaleString()}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </Scroll>
      <WholesalerBottomBar active="qr" />
    </Phone>
  );
}

// ── WHL-05 QR Progress · Empty ───────────────────────────────────────
function WhlQrProgressEmpty() {
  return (
    <Phone>
      <TopAppBar title="QR Progress" leading={<div style={{width:12}}/>}
        trailing={<IconBtn icon="notifications" />} />
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        textAlign: 'center', padding: 32, gap: 16,
      }}>
        <div style={{
          width: 96, height: 96, borderRadius: 48,
          background: 'var(--sgx-surface-container)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <span className="material-symbols-rounded" style={{ fontSize: 56, color: 'var(--sgx-on-surface-variant)' }}>qr_code_2</span>
        </div>
        <div>
          <div style={{ fontSize: 18, fontWeight: 700 }}>No QR progress yet</div>
          <div style={{ marginTop: 8, fontSize: 14, color: 'var(--sgx-on-surface-variant)', lineHeight: 1.5, maxWidth: 280 }}>
            Your SGX reward QR progress will appear here once SGX dispatches an invoice to your shop.
          </div>
        </div>
        <div style={{ width: '100%', maxWidth: 240, marginTop: 8 }}>
          <OutlinedBtn icon="support_agent">Contact SGX</OutlinedBtn>
        </div>
      </div>
      <WholesalerBottomBar active="qr" />
    </Phone>
  );
}

Object.assign(window, { WhlHome, WhlHomeEmpty, WhlQrProgress, WhlQrProgressEmpty });
