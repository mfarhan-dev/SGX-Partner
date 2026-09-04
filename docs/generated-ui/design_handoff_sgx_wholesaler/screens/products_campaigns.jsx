// SGX Partners — Wholesaler · Products & Campaigns
// WHL-10 Products · WHL-11 Product Detail · WHL-12 Campaigns · WHL-13 Campaign Detail

// ── WHL-10 Products ──────────────────────────────────────────────────
function WhlProducts() {
  const cats = ['All', 'Engine Oil', 'Spark Plugs', 'Tires', 'Batteries', 'Filters', 'Chains'];
  const products = [
    { name: 'Shell Advance AX7 10W-40', brand: 'Shell', code: 'SHL-AX7-1L', kind: 'oil' },
    { name: 'NGK Spark Plug CR7HSA',    brand: 'NGK',   code: 'NGK-CR7',   kind: 'spark' },
    { name: 'K&N Air Filter HD-1013',   brand: 'K&N',   code: 'KN-HD1013', kind: 'filter' },
    { name: 'DID Chain 428H-118L',      brand: 'DID',   code: 'DID-428H',  kind: 'chain' },
    { name: 'CEAT Milaze 90/90-18',     brand: 'CEAT',  code: 'CEAT-M90',  kind: 'tire' },
    { name: 'Osaka Battery YB5L-B',     brand: 'Osaka', code: 'OSK-YB5',   kind: 'battery' },
  ];
  return (
    <Phone>
      <TopAppBar
        title="Products"
        leading={<div style={{width:12}}/>}
        trailing={<IconBtn icon="notifications" badge="4" />}
      />
      <Scroll pad={0} gap={12}>
        {/* Search */}
        <div style={{ padding: '4px 16px 0' }}>
          <div style={{
            height: 48, borderRadius: 24,
            background: 'var(--sgx-surface-container)',
            display: 'flex', alignItems: 'center', gap: 10, padding: '0 16px',
          }}>
            <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>search</span>
            <div style={{ flex: 1, fontSize: 14, color: 'var(--sgx-on-surface-variant)' }}>Search products…</div>
            <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>tune</span>
          </div>
        </div>

        {/* Category chips */}
        <div style={{
          display: 'flex', gap: 8, padding: '4px 16px 4px', overflowX: 'auto',
        }}>
          {cats.map((c, i) => (
            <div key={c} style={{
              height: 32, padding: '0 14px', borderRadius: 16,
              background: i === 0 ? 'var(--sgx-primary)' : 'var(--sgx-surface)',
              color: i === 0 ? 'white' : 'var(--sgx-on-surface)',
              border: '1.5px solid ' + (i === 0 ? 'var(--sgx-primary)' : 'var(--sgx-outline-variant)'),
              display: 'inline-flex', alignItems: 'center',
              fontSize: 13, fontWeight: 600, whiteSpace: 'nowrap',
            }}>{c}</div>
          ))}
        </div>

        {/* Grid */}
        <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {products.map((p, i) => (
            <div key={i} style={{
              borderRadius: 12, overflow: 'hidden',
              background: 'var(--sgx-surface)',
              border: '1px solid var(--sgx-outline-variant)',
            }}>
              <ImgSlot w="100%" h={110} radius={0} kind={p.kind} />
              <div style={{ padding: 10 }}>
                <div style={{ fontSize: 10.5, color: 'var(--sgx-primary)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: 0.4 }}>{p.brand}</div>
                <div style={{ fontSize: 13, fontWeight: 600, marginTop: 2, lineHeight: 1.3, height: 34, overflow: 'hidden' }}>{p.name}</div>
                <div style={{ fontSize: 11, color: 'var(--sgx-on-surface-variant)', marginTop: 4, fontFamily: 'monospace' }}>{p.code}</div>
              </div>
            </div>
          ))}
        </div>

        <div style={{ height: 8 }}/>
      </Scroll>
      <WholesalerBottomBar active="products" />
    </Phone>
  );
}

// ── WHL-11 Product Detail ────────────────────────────────────────────
function WhlProductDetail() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Product" trailing={<IconBtn icon="share" />} />
      <Scroll pad={0} gap={16}>
        <div style={{ padding: '0 16px' }}>
          <ImgSlot w="100%" h={220} radius={16} kind="oil" />
        </div>

        <div style={{ padding: '0 16px' }}>
          <div style={{ fontSize: 11, color: 'var(--sgx-primary)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: 0.6 }}>Shell · Engine Oil</div>
          <div style={{ fontSize: 22, fontWeight: 800, marginTop: 6, letterSpacing: -0.3, lineHeight: 1.25 }}>Shell Advance AX7 10W-40</div>
          <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', marginTop: 8, fontFamily: 'monospace' }}>SKU: SHL-AX7-1L</div>
        </div>

        {/* Attribute grid */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            borderRadius: 12, background: 'var(--sgx-surface-container)',
            padding: '4px 16px',
          }}>
            {[
              { k: 'Brand', v: 'Shell' },
              { k: 'Category', v: 'Engine Oil' },
              { k: 'Volume', v: '1 Litre' },
              { k: 'Type', v: 'Semi-synthetic 4T' },
              { k: 'Grade', v: '10W-40 · API SN' },
            ].map((r, i, a) => (
              <div key={r.k} style={{
                display: 'flex', justifyContent: 'space-between', padding: '12px 0',
                borderBottom: i < a.length - 1 ? '1px solid var(--sgx-outline-variant)' : 'none',
                fontSize: 13,
              }}>
                <span style={{ color: 'var(--sgx-on-surface-variant)' }}>{r.k}</span>
                <span style={{ fontWeight: 700 }}>{r.v}</span>
              </div>
            ))}
          </div>
        </div>

        <div style={{ padding: '0 16px' }}>
          <SectionHeader title="Description" />
          <div style={{ padding: '0 16px', fontSize: 14, lineHeight: 1.6, color: 'var(--sgx-on-surface)' }}>
            Premium semi-synthetic engine oil for 4-stroke motorcycles. Provides excellent wear protection, cleaner engines, and consistent performance under heavy stop-and-go conditions typical to Pakistani roads.
          </div>
        </div>

        {/* NO price, cart, order per spec §15 */}
        <div style={{ padding: '0 16px 16px', fontSize: 12, color: 'var(--sgx-on-surface-variant)', textAlign: 'center' }}>
          <span className="material-symbols-rounded" style={{ fontSize: 14, verticalAlign: 'middle', marginRight: 4 }}>info</span>
          For pricing and orders, contact SGX directly.
        </div>
      </Scroll>
    </Phone>
  );
}

// ── WHL-12 Campaigns ─────────────────────────────────────────────────
function WhlCampaigns() {
  const camps = [
    { title: 'Distributor Growth Bonus', desc: 'Extra 10% reward on all filter sales', date: '15 Jul – 31 Jul', tag: 'ACTIVE', hero: 'Filter Bonus' },
    { title: 'Shell Ramzan Multiplier',   desc: 'Double rewards on Shell Advance range', date: '10 Jul – 15 Aug', tag: 'ACTIVE', hero: 'Ramzan 2x' },
    { title: 'NGK Loyalty Rewards',       desc: 'Extra Rs. 2 per spark plug scan', date: '01 Jul – 30 Jul', tag: 'ENDING SOON', hero: 'NGK Rewards' },
  ];
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Campaigns" />
      <Scroll pad={16} gap={12}>
        {camps.map((c, i) => (
          <div key={i} style={{
            borderRadius: 16, overflow: 'hidden',
            background: 'var(--sgx-surface)',
            boxShadow: 'var(--sgx-e1)',
            border: '1px solid var(--sgx-outline-variant)',
          }}>
            <div style={{ position: 'relative' }}>
              <ImgSlot w="100%" h={130} radius={0} kind="camp" label={c.hero} />
              <div style={{
                position: 'absolute', top: 12, left: 12,
                padding: '4px 10px', borderRadius: 10,
                background: c.tag === 'ACTIVE' ? 'var(--sgx-success)' : '#F59E0B',
                color: 'white', fontSize: 10.5, fontWeight: 700, letterSpacing: 0.5,
              }}>{c.tag}</div>
            </div>
            <div style={{ padding: 14 }}>
              <div style={{ fontSize: 16, fontWeight: 700 }}>{c.title}</div>
              <div style={{ fontSize: 13, color: 'var(--sgx-on-surface-variant)', marginTop: 4, lineHeight: 1.4 }}>{c.desc}</div>
              <div style={{
                marginTop: 10, paddingTop: 10, borderTop: '1px solid var(--sgx-outline-variant)',
                display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              }}>
                <div style={{ fontSize: 12, color: 'var(--sgx-on-surface-variant)', display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                  <span className="material-symbols-rounded" style={{ fontSize: 14 }}>calendar_month</span>
                  {c.date}
                </div>
                <div style={{ fontSize: 12, color: 'var(--sgx-primary)', fontWeight: 700, display: 'inline-flex', alignItems: 'center', gap: 3 }}>
                  View <span className="material-symbols-rounded" style={{ fontSize: 16 }}>chevron_right</span>
                </div>
              </div>
            </div>
          </div>
        ))}
      </Scroll>
    </Phone>
  );
}

// ── WHL-13 Campaign Detail ───────────────────────────────────────────
function WhlCampaignDetail() {
  return (
    <Phone>
      <TopAppBar leading={<BackBtn />} title="Campaign" trailing={<IconBtn icon="share" />} />
      <Scroll pad={0} gap={16}>
        <div style={{ padding: '0 16px' }}>
          <div style={{ borderRadius: 16, overflow: 'hidden' }}>
            <ImgSlot w="100%" h={180} radius={0} kind="camp" label="Distributor Growth Bonus" />
          </div>
        </div>

        <div style={{ padding: '0 16px' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '4px 10px', borderRadius: 10, background: 'var(--sgx-success-container)', color: 'var(--sgx-success)', fontSize: 11, fontWeight: 700 }}>
            <span className="material-symbols-rounded mi-fill" style={{ fontSize: 14 }}>bolt</span>
            ACTIVE CAMPAIGN
          </div>
          <div style={{ fontSize: 24, fontWeight: 800, marginTop: 8, letterSpacing: -0.3, lineHeight: 1.2 }}>Distributor Growth Bonus</div>

          <div style={{ marginTop: 12, display: 'flex', gap: 16, fontSize: 13 }}>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, color: 'var(--sgx-on-surface-variant)' }}>
              <span className="material-symbols-rounded" style={{ fontSize: 16 }}>event</span>
              15 Jul – 31 Jul 2026
            </div>
          </div>
        </div>

        {/* Reward highlight */}
        <div style={{ padding: '0 16px' }}>
          <div style={{
            padding: 18, borderRadius: 16,
            background: 'linear-gradient(135deg, var(--sgx-primary), oklch(0.28 0.14 265))',
            color: 'white', display: 'flex', alignItems: 'center', gap: 14,
          }}>
            <div style={{
              width: 56, height: 56, borderRadius: 14,
              background: 'rgba(255,255,255,0.15)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
            }}>
              <span className="material-symbols-rounded mi-fill" style={{ fontSize: 32 }}>redeem</span>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12, opacity: 0.75, fontWeight: 600, textTransform: 'uppercase', letterSpacing: 0.5 }}>Reward</div>
              <div style={{ fontSize: 20, fontWeight: 800, marginTop: 2 }}>+10% on filter sales</div>
              <div style={{ fontSize: 12, opacity: 0.85, marginTop: 2 }}>On top of regular QR reward</div>
            </div>
          </div>
        </div>

        <div style={{ padding: '0 16px' }}>
          <SectionHeader title="About this campaign" />
          <div style={{ fontSize: 14, lineHeight: 1.6, color: 'var(--sgx-on-surface)', padding: '0 16px' }}>
            Boost your filter category rewards for 16 days. Every K&N, Bosch, and Purolator filter QR that a mechanic scans from your dispatched invoices earns you an extra 10% on top of the base wholesaler reward.
          </div>
        </div>

        <div style={{ padding: '0 16px' }}>
          <SectionHeader title="How to participate" />
          <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
            {[
              'Order filter products from SGX as usual.',
              'SGX dispatches invoices with reward QRs.',
              'When mechanics scan them, you earn the extra 10%.',
            ].map((step, i) => (
              <div key={i} style={{ display: 'flex', gap: 10, alignItems: 'flex-start' }}>
                <div style={{
                  width: 24, height: 24, borderRadius: 12,
                  background: 'var(--sgx-primary)', color: 'white',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 12, fontWeight: 800, flexShrink: 0,
                }}>{i + 1}</div>
                <div style={{ fontSize: 14, color: 'var(--sgx-on-surface)', lineHeight: 1.5, paddingTop: 2 }}>{step}</div>
              </div>
            ))}
          </div>
        </div>

        {/* No progress bar per PRD §14 */}
        <div style={{ padding: '0 16px 16px', fontSize: 12, color: 'var(--sgx-on-surface-variant)', textAlign: 'center', lineHeight: 1.5 }}>
          <span className="material-symbols-rounded" style={{ fontSize: 14, verticalAlign: 'middle', marginRight: 4 }}>info</span>
          Bonus is credited when scans are confirmed by SGX.
        </div>
      </Scroll>
    </Phone>
  );
}

Object.assign(window, { WhlProducts, WhlProductDetail, WhlCampaigns, WhlCampaignDetail });
