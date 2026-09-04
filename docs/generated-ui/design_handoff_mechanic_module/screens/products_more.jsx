// SGX Partners — Products, Campaigns, Notifications
// MEC-13 Products, MEC-14 Product Detail, MEC-15 Campaigns, MEC-16 Campaign Detail, MEC-17 Notifications

// ── MEC-13 Products ──────────────────────────────────────────────────
function MecProducts() {
  const cats = ['All', 'Engine Oil', 'Spark Plugs', 'Filters', 'Tires', 'Chains', 'Battery'];
  const products = [
    { name: 'Shell Advance AX7', brand: 'Shell · Engine Oil', kind: 'oil' },
    { name: 'NGK CR7HSA', brand: 'NGK · Spark Plug', kind: 'spark' },
    { name: 'K&N HD-1013', brand: 'K&N · Air Filter', kind: 'filter' },
    { name: 'DID Chain 428H', brand: 'DID · Chain', kind: 'chain' },
    { name: 'CEAT Milaze 90/90-18', brand: 'CEAT · Tire', kind: 'tire' },
    { name: 'Osaka YB5L-B', brand: 'Osaka · Battery', kind: 'battery' },
  ];
  return (
    <Phone>
      <TopAppBar title="Products" leading={<div style={{width:12}}/>} trailing={<IconBtn icon="notifications" />} />

      {/* Search */}
      <div style={{ padding: '0 16px 12px' }}>
        <div style={{
          height: 48, borderRadius: 24, background: 'var(--sgx-surface-container)',
          display: 'flex', alignItems: 'center', gap: 10, padding: '0 16px',
        }}>
          <span className="material-symbols-rounded" style={{ color: 'var(--sgx-on-surface-variant)' }}>search</span>
          <div style={{ flex: 1, color: 'var(--sgx-on-surface-variant)', fontSize: 15 }}>Search parts, brands…</div>
          <span className="material-symbols-rounded" style={{ color: 'var(--sgx-on-surface-variant)' }}>tune</span>
        </div>
      </div>

      {/* Categories */}
      <div style={{ padding: '0 16px 16px', display: 'flex', gap: 8, overflowX: 'auto' }}>
        {cats.map((c, i) => (
          <div key={c} style={{
            height: 34, padding: '0 14px', borderRadius: 17, flexShrink: 0,
            border: `1px solid ${i === 0 ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'}`,
            background: i === 0 ? 'var(--sgx-primary)' : 'var(--sgx-surface)',
            color: i === 0 ? 'white' : 'var(--sgx-on-surface)',
            fontSize: 13, fontWeight: 600, display: 'inline-flex', alignItems: 'center',
          }}>{c}</div>
        ))}
      </div>

      <Scroll pad={16} gap={12}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {products.map((p, i) => (
            <div key={i} style={{
              borderRadius: 12, background: 'var(--sgx-surface)',
              border: '1px solid var(--sgx-outline-variant)',
              overflow: 'hidden',
            }}>
              <ImgSlot w="100%" h={110} radius={0} kind={p.kind} />
              <div style={{ padding: 10 }}>
                <div style={{ fontSize: 14, fontWeight: 700, lineHeight: '18px', minHeight: 36 }}>{p.name}</div>
                <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', marginTop: 4 }}>{p.brand}</div>
              </div>
            </div>
          ))}
        </div>
      </Scroll>
      <BottomBar active="products" />
    </Phone>
  );
}

// ── MEC-14 Product Detail ────────────────────────────────────────────
function MecProductDetail() {
  return (
    <Phone>
      <div style={{ position: 'absolute', top: 32, left: 8, zIndex: 3 }}>
        <button style={{
          width: 44, height: 44, borderRadius: 22, border: 'none',
          background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(8px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <span className="material-symbols-rounded">arrow_back</span>
        </button>
      </div>
      <Scroll pad={0} gap={0} bg="var(--sgx-surface)">
        <ImgSlot w="100%" h={280} radius={0} kind="oil" />

        <div style={{ padding: '20px 16px' }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: 'var(--sgx-primary)', letterSpacing: 0.5 }}>SHELL · ENGINE OIL</div>
          <div style={{ marginTop: 6, fontSize: 22, fontWeight: 700, letterSpacing: -0.3 }}>Shell Advance AX7 10W-40</div>
          <div style={{ marginTop: 4, fontSize: 13, color: 'var(--sgx-on-surface-variant)' }}>Product code · SH-AX7-1040</div>

          <div style={{ marginTop: 20, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <div style={{ padding: 12, borderRadius: 12, background: 'var(--sgx-surface-container)' }}>
              <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: 0.4 }}>Volume</div>
              <div style={{ marginTop: 4, fontSize: 15, fontWeight: 700 }}>1 Litre</div>
            </div>
            <div style={{ padding: 12, borderRadius: 12, background: 'var(--sgx-surface-container)' }}>
              <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: 0.4 }}>Grade</div>
              <div style={{ marginTop: 4, fontSize: 15, fontWeight: 700 }}>10W-40 · SL</div>
            </div>
          </div>

          <div style={{ marginTop: 20 }}>
            <div className="t-section-title" style={{ marginBottom: 8 }}>About this product</div>
            <div style={{ fontSize: 14, color: 'var(--sgx-on-surface-variant)', lineHeight: '22px' }}>
              Semi-synthetic 4-stroke motorcycle engine oil built for Pakistani conditions.
              Protects the engine at high temperatures, keeps the gearbox smooth, and helps
              your bike run cleaner for longer. Suitable for most 100cc — 200cc motorcycles.
            </div>
          </div>

          <div style={{
            marginTop: 20, padding: 14, borderRadius: 12,
            background: 'var(--sgx-success-container)',
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <span className="material-symbols-rounded mi-fill" style={{ fontSize: 28, color: 'var(--sgx-success)' }}>redeem</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700 }}>Earn on every scan</div>
              <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)' }}>Scan the QR on the pack to get your reward.</div>
            </div>
          </div>
        </div>
      </Scroll>
    </Phone>
  );
}

// ── MEC-15 Campaigns ─────────────────────────────────────────────────
function MecCampaigns() {
  const camps = [
    { title: 'Ramzan Bonus — Double Rewards', sub: 'Until 30 Ramzan · Shell products', kind: 'camp', label: 'Ramzan Bonus' },
    { title: 'Chain & Sprocket Special', sub: 'Until 15 Aug · DID chains', kind: 'camp', label: 'Chain Special' },
    { title: 'Spark Plug Boost', sub: 'Until 05 Sep · NGK plugs', kind: 'camp', label: 'Spark Boost' },
  ];
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Campaigns" />
      <Scroll pad={16} gap={16}>
        <div style={{
          padding: 12, borderRadius: 12, background: 'var(--sgx-surface-container)',
          display: 'flex', gap: 10, alignItems: 'center',
        }}>
          <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22, color: 'var(--sgx-primary)' }}>campaign</span>
          <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)' }}>SGX runs promotional campaigns to help you earn more.</div>
        </div>

        {camps.map((c, i) => (
          <div key={i} style={{
            borderRadius: 16, overflow: 'hidden',
            background: 'var(--sgx-surface)', boxShadow: 'var(--sgx-e1)',
            border: '1px solid var(--sgx-outline-variant)',
          }}>
            <ImgSlot w="100%" h={140} radius={0} kind="camp" label={c.label} />
            <div style={{ padding: 14 }}>
              <div style={{ fontSize: 16, fontWeight: 700 }}>{c.title}</div>
              <div style={{ marginTop: 4, fontSize: 12, color: 'var(--sgx-on-surface-variant)' }}>{c.sub}</div>
              <div style={{ marginTop: 10, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{
                  display: 'inline-flex', alignItems: 'center', gap: 4,
                  padding: '4px 10px', borderRadius: 999,
                  background: 'var(--sgx-success-container)', color: 'var(--sgx-success)',
                  fontSize: 11, fontWeight: 700,
                }}>
                  <div style={{ width: 6, height: 6, borderRadius: 3, background: 'var(--sgx-success)' }}/>
                  ACTIVE
                </div>
                <div style={{ fontSize: 13, color: 'var(--sgx-primary)', fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 2 }}>
                  View Campaign <span className="material-symbols-rounded" style={{ fontSize: 16 }}>chevron_right</span>
                </div>
              </div>
            </div>
          </div>
        ))}
      </Scroll>
    </Phone>
  );
}

// ── MEC-16 Campaign Detail ───────────────────────────────────────────
function MecCampaignDetail() {
  return (
    <Phone>
      <div style={{ position: 'absolute', top: 32, left: 8, right: 8, zIndex: 3, display: 'flex', justifyContent: 'space-between' }}>
        <button style={{
          width: 44, height: 44, borderRadius: 22, border: 'none',
          background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(8px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <span className="material-symbols-rounded">arrow_back</span>
        </button>
        <button style={{
          width: 44, height: 44, borderRadius: 22, border: 'none',
          background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(8px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <span className="material-symbols-rounded">share</span>
        </button>
      </div>
      <Scroll pad={0} gap={0}>
        <ImgSlot w="100%" h={260} radius={0} kind="camp" label="Ramzan Bonus" />
        <div style={{ padding: '20px 16px 24px' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 4, padding: '4px 10px', borderRadius: 999, background: 'var(--sgx-success-container)', color: 'var(--sgx-success)', fontSize: 11, fontWeight: 700 }}>
            <div style={{ width: 6, height: 6, borderRadius: 3, background: 'var(--sgx-success)' }}/>
            ACTIVE
          </div>
          <div style={{ marginTop: 12, fontSize: 24, fontWeight: 700 }}>Ramzan Bonus — Double Rewards</div>
          <div style={{ marginTop: 8, display: 'flex', alignItems: 'center', gap: 10, color: 'var(--sgx-on-surface-variant)', fontSize: 13 }}>
            <span className="material-symbols-rounded" style={{ fontSize: 18 }}>calendar_month</span>
            10 Mar 2026 → 30 Mar 2026
          </div>

          <div style={{
            marginTop: 16, padding: 14, borderRadius: 14,
            background: 'linear-gradient(135deg, #FEF3C7, #FDE68A)',
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <span className="material-symbols-rounded mi-fill" style={{ fontSize: 32, color: '#B45309' }}>emoji_events</span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12, color: '#78350F', fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>Reward</div>
              <div style={{ fontSize: 17, fontWeight: 800, color: '#78350F' }}>Double reward on every Shell product</div>
            </div>
          </div>

          <div style={{ marginTop: 20 }}>
            <div className="t-section-title" style={{ marginBottom: 8 }}>About this campaign</div>
            <div style={{ fontSize: 14, color: 'var(--sgx-on-surface-variant)', lineHeight: '22px' }}>
              During the holy month of Ramzan, SGX is giving 2x rewards on every Shell engine oil
              you scan. No signup needed — just scan the QR on the pack as usual, and the extra
              reward will be added to your wallet.
            </div>
          </div>

          <div style={{ marginTop: 20 }}>
            <div className="t-section-title" style={{ marginBottom: 10 }}>How to participate</div>
            {[
              { n: 1, t: 'Buy or install any Shell product', s: 'Look for the SGX QR sticker.' },
              { n: 2, t: 'Open the app and tap Scan', s: 'Use the center scan button.' },
              { n: 3, t: 'Get double reward instantly', s: 'Added to your wallet after confirmation.' },
            ].map(s => (
              <div key={s.n} style={{ display: 'flex', gap: 12, padding: '10px 0' }}>
                <div style={{
                  width: 32, height: 32, borderRadius: 16, flexShrink: 0,
                  background: 'var(--sgx-primary)', color: 'white',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 14, fontWeight: 700,
                }}>{s.n}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 700 }}>{s.t}</div>
                  <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{s.s}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </Scroll>
    </Phone>
  );
}

// ── MEC-17 Notifications ─────────────────────────────────────────────
function MecNotifications() {
  const items = [
    { icon: 'redeem', tone: 'success', title: 'Rs. 15 added to your wallet.', sub: 'Shell Advance AX7 QR scanned', time: '10 min ago', unread: true },
    { icon: 'send', tone: 'primary', title: 'Your payment has been sent.', sub: 'Rs. 2,000 → EasyPaisa', time: '2 hrs ago', unread: true },
    { icon: 'campaign', tone: 'warning', title: 'A new SGX campaign has started.', sub: 'Ramzan Bonus — Double Rewards', time: '1 day ago', unread: true },
    { icon: 'check_circle', tone: 'success', title: 'Your withdrawal was confirmed.', sub: 'Rs. 2,000 · EasyPaisa', time: '3 days ago' },
    { icon: 'lock_clock', tone: 'neutral', title: 'Your withdrawal was closed automatically.', sub: 'Rs. 3,500 · Bank Transfer', time: '12 Jul' },
    { icon: 'redeem', tone: 'success', title: 'Rs. 40 added to your wallet.', sub: 'CEAT Milaze 90/90 QR scanned', time: '20 Jul' },
  ];
  const toneMap = {
    success: { bg: 'var(--sgx-success-container)', fg: 'var(--sgx-success)' },
    primary: { bg: 'rgba(30,58,138,0.10)', fg: 'var(--sgx-primary)' },
    warning: { bg: 'var(--sgx-warning-container)', fg: '#8A5A00' },
    neutral: { bg: 'var(--sgx-surface-container-high)', fg: 'var(--sgx-on-surface-variant)' },
  };
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Notifications" trailing={<TextBtn>Mark all</TextBtn>} />
      <Scroll pad={0} gap={0}>
        {items.map((n, i) => {
          const t = toneMap[n.tone];
          return (
            <div key={i} style={{
              padding: '14px 16px', display: 'flex', gap: 12,
              background: n.unread ? 'rgba(30,58,138,0.03)' : 'var(--sgx-surface)',
              borderBottom: '1px solid var(--sgx-outline-variant)',
              position: 'relative',
            }}>
              {n.unread && <div style={{ position: 'absolute', left: 6, top: '50%', width: 6, height: 6, borderRadius: 3, background: 'var(--sgx-primary)', transform: 'translateY(-50%)' }}/>}
              <div style={{
                width: 40, height: 40, borderRadius: 20,
                background: t.bg, color: t.fg,
                display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
              }}>
                <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22 }}>{n.icon}</span>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: n.unread ? 700 : 500, color: 'var(--sgx-on-surface)' }}>{n.title}</div>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', marginTop: 2 }}>{n.sub}</div>
                <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', marginTop: 4 }}>{n.time}</div>
              </div>
            </div>
          );
        })}
      </Scroll>
    </Phone>
  );
}

Object.assign(window, { MecProducts, MecProductDetail, MecCampaigns, MecCampaignDetail, MecNotifications });
