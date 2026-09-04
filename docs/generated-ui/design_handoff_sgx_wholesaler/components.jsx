// SGX Partners — Shared Components (Mechanic module)
// Material 3 primitives, SGX-themed. Used by every screen mockup.

const PHONE_W = 390;
const PHONE_H = 844;

// ── SGX App Icon (recreates the approved sgx-app-icon.svg) ───────────
function SgxIcon({ size = 48, radius }) {
  const r = radius ?? Math.round(size * 0.22);
  return (
    <div style={{
      width: size, height: size, borderRadius: r,
      background: '#ffffff',
      boxShadow: '0 1px 2px rgba(15,23,42,0.15), 0 0 0 1px rgba(15,23,42,0.04)',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0,
    }}>
      <svg viewBox="0 0 100 100" width={size * 0.72} height={size * 0.72} aria-label="SGX Partners logo">
        {/* Stylized SG monogram with mechanical bolt */}
        <g fill="#1E3A8A" stroke="#1E3A8A" strokeLinejoin="round">
          <path d="M18 22 L58 22 L58 34 L34 34 L34 42 L54 42 L58 46 L58 62 L18 62 L18 50 L44 50 L44 42 L24 42 L18 36 Z"/>
          <path d="M62 22 L86 22 L86 62 L74 62 L74 34 L62 34 Z"/>
          <path d="M18 70 L38 82 L58 70 L58 78 L48 84 L58 90 L48 90 L38 84 L28 90 L18 90 L28 84 L18 78 Z"/>
        </g>
      </svg>
    </div>
  );
}

// ── Android Status Bar (SGX-themed, tunable) ─────────────────────────
function StatusBar({ dark = false, transparent = false, tint }) {
  const c = tint || (dark || transparent ? '#ffffff' : '#0F172A');
  return (
    <div style={{
      height: 32, display: 'flex', alignItems: 'center',
      justifyContent: 'space-between', padding: '0 20px',
      position: 'relative', flexShrink: 0,
      background: transparent ? 'transparent' : 'transparent',
      color: c,
    }}>
      <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: 0.25 }}>9:41</div>
      <div style={{
        position: 'absolute', left: '50%', top: 6, transform: 'translateX(-50%)',
        width: 20, height: 20, borderRadius: 100,
        background: transparent ? 'rgba(0,0,0,0.55)' : '#0F172A',
      }} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
        <svg width="15" height="12" viewBox="0 0 15 12"><path d="M7.5 12L.2 4.7a10.3 10.3 0 0114.6 0L7.5 12z" fill={c}/></svg>
        <svg width="14" height="12" viewBox="0 0 14 12"><path d="M13 12V0L1 12h12z" fill={c}/></svg>
        <svg width="22" height="12" viewBox="0 0 22 12">
          <rect x="0.5" y="1" width="18" height="10" rx="2" fill="none" stroke={c} strokeOpacity="0.6"/>
          <rect x="2" y="2.5" width="14" height="7" rx="1" fill={c}/>
          <rect x="19" y="4" width="1.5" height="4" rx="0.5" fill={c} fillOpacity="0.6"/>
        </svg>
      </div>
    </div>
  );
}

// ── Home Indicator (gesture nav pill) ────────────────────────────────
function HomeIndicator({ dark = false, tint }) {
  return (
    <div style={{ height: 20, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
      <div style={{
        width: 108, height: 4, borderRadius: 2,
        background: tint || (dark ? '#ffffff' : '#0F172A'), opacity: 0.5,
      }} />
    </div>
  );
}

// ── Phone Shell — the frame everything renders into ──────────────────
function Phone({ children, dark = false, statusBarTint, transparentStatus = false, homeIndicatorTint, bg }) {
  return (
    <div className={dark ? 'sgx-dark' : ''} style={{
      width: PHONE_W, height: PHONE_H,
      background: bg || 'var(--sgx-surface)',
      display: 'flex', flexDirection: 'column',
      color: 'var(--sgx-on-surface)',
      fontFamily: 'var(--sgx-font)',
      overflow: 'hidden',
      position: 'relative',
      borderRadius: 40,
    }}>
      <StatusBar dark={dark} transparent={transparentStatus} tint={statusBarTint} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minHeight: 0, position: 'relative' }}>
        {children}
      </div>
      <HomeIndicator dark={dark} tint={homeIndicatorTint} />
    </div>
  );
}

// ── Top App Bar (small M3) ───────────────────────────────────────────
function TopAppBar({ title, leading, trailing, showBrand = false, subtitle }) {
  return (
    <div style={{
      height: 64, padding: '0 4px 0 4px',
      display: 'flex', alignItems: 'center', gap: 4,
      background: 'var(--sgx-surface)', flexShrink: 0,
    }}>
      {leading || <div style={{ width: 48 }} />}
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 10, minWidth: 0 }}>
        {showBrand && <SgxIcon size={32} radius={7} />}
        <div style={{ minWidth: 0 }}>
          <div className="t-card-title" style={{ fontSize: 20, fontWeight: 600, lineHeight: '24px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {title}
          </div>
          {subtitle && <div className="t-supporting" style={{ color: 'var(--sgx-on-surface-variant)' }}>{subtitle}</div>}
        </div>
      </div>
      {trailing}
    </div>
  );
}

// ── Icon Button (48dp touch target) ──────────────────────────────────
function IconBtn({ icon, badge, onClick, tint }) {
  return (
    <button onClick={onClick} style={{
      width: 48, height: 48, borderRadius: 24, border: 'none',
      background: 'transparent', display: 'inline-flex',
      alignItems: 'center', justifyContent: 'center',
      cursor: 'pointer', position: 'relative', color: tint || 'var(--sgx-on-surface)',
    }}>
      <span className="material-symbols-rounded">{icon}</span>
      {badge && (
        <div style={{
          position: 'absolute', top: 10, right: 8,
          minWidth: 18, height: 18, padding: '0 5px',
          borderRadius: 9, background: 'var(--sgx-error)',
          color: 'white', fontSize: 11, fontWeight: 700,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          border: '2px solid var(--sgx-surface)',
        }}>{badge}</div>
      )}
    </button>
  );
}

// ── Back Button ──────────────────────────────────────────────────────
function BackBtn() {
  return <IconBtn icon="arrow_back" />;
}

// ── Filled / Outlined / Text buttons ─────────────────────────────────
function FilledBtn({ children, icon, tone = 'primary', full = true, small = false }) {
  const bg = tone === 'primary' ? 'var(--sgx-primary)'
    : tone === 'success' ? 'var(--sgx-success)'
    : tone === 'error' ? 'var(--sgx-error)' : 'var(--sgx-primary)';
  const fg = 'white';
  return (
    <button style={{
      height: small ? 40 : 48, padding: small ? '0 20px' : '0 24px',
      minWidth: full ? '100%' : 'auto',
      width: full ? '100%' : 'auto',
      borderRadius: 9999, border: 'none', background: bg, color: fg,
      fontSize: 15, fontWeight: 600, letterSpacing: 0.1,
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      cursor: 'pointer', fontFamily: 'var(--sgx-font)',
      boxShadow: '0 1px 2px rgba(0,0,0,0.10)',
    }}>
      {icon && <span className="material-symbols-rounded" style={{ fontSize: 20 }}>{icon}</span>}
      {children}
    </button>
  );
}
function OutlinedBtn({ children, icon, full = true, small = false }) {
  return (
    <button style={{
      height: small ? 40 : 48, padding: small ? '0 20px' : '0 24px',
      width: full ? '100%' : 'auto',
      borderRadius: 9999, border: '1.5px solid var(--sgx-outline)',
      background: 'transparent', color: 'var(--sgx-primary)',
      fontSize: 15, fontWeight: 600,
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      cursor: 'pointer', fontFamily: 'var(--sgx-font)',
    }}>
      {icon && <span className="material-symbols-rounded" style={{ fontSize: 20 }}>{icon}</span>}
      {children}
    </button>
  );
}
function TextBtn({ children, icon, tone }) {
  return (
    <button style={{
      height: 40, padding: '0 12px',
      borderRadius: 9999, border: 'none', background: 'transparent',
      color: tone === 'error' ? 'var(--sgx-error)' : 'var(--sgx-primary)',
      fontSize: 15, fontWeight: 600,
      display: 'inline-flex', alignItems: 'center', gap: 8,
      cursor: 'pointer', fontFamily: 'var(--sgx-font)',
    }}>
      {icon && <span className="material-symbols-rounded" style={{ fontSize: 20 }}>{icon}</span>}
      {children}
    </button>
  );
}

// ── Text field (M3 outlined) ─────────────────────────────────────────
function TextField({ label, value, placeholder, prefix, suffix, icon, error, helper, readonly, verified, style }) {
  const filled = value != null && value !== '';
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6, ...style }}>
      <div style={{
        height: 56, position: 'relative',
        border: `1.5px solid ${error ? 'var(--sgx-error)' : (readonly ? 'var(--sgx-outline-variant)' : 'var(--sgx-outline)')}`,
        borderRadius: 8, padding: '0 16px',
        display: 'flex', alignItems: 'center', gap: 10,
        background: readonly ? 'var(--sgx-surface-variant)' : 'var(--sgx-surface)',
      }}>
        {icon && <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--sgx-on-surface-variant)' }}>{icon}</span>}
        {prefix && <span style={{ color: 'var(--sgx-on-surface-variant)', fontSize: 16, fontWeight: 500 }}>{prefix}</span>}
        <div style={{ flex: 1, position: 'relative' }}>
          <div style={{
            position: 'absolute', top: filled ? -20 : 16,
            left: 0, fontSize: filled ? 12 : 16,
            color: error ? 'var(--sgx-error)' : 'var(--sgx-on-surface-variant)',
            background: filled ? 'var(--sgx-surface)' : 'transparent',
            padding: filled ? '0 4px' : '0',
            transition: 'all 150ms',
            pointerEvents: 'none',
            fontWeight: filled ? 500 : 400,
          }}>{label}</div>
          {filled ? (
            <div style={{ fontSize: 16, color: 'var(--sgx-on-surface)', fontWeight: 500 }}>{value}</div>
          ) : (
            placeholder && <div style={{ opacity: 0 }}>{placeholder}</div>
          )}
        </div>
        {verified && <span className="material-symbols-rounded mi-fill" style={{ fontSize: 22, color: 'var(--sgx-success)' }}>check_circle</span>}
        {suffix && <span style={{ color: 'var(--sgx-on-surface-variant)', fontSize: 14 }}>{suffix}</span>}
      </div>
      {(error || helper) && (
        <div className="t-supporting" style={{
          color: error ? 'var(--sgx-error)' : 'var(--sgx-on-surface-variant)',
          paddingLeft: 16,
        }}>{error || helper}</div>
      )}
    </div>
  );
}

// ── Bottom App Bar with center Scan FAB ──────────────────────────────
function BottomBar({ active = 'home' }) {
  const items = [
    { id: 'home', icon: 'home', label: 'Home' },
    { id: 'products', icon: 'category', label: 'Products' },
    { id: 'scan', icon: 'qr_code_scanner', label: 'Scan', center: true },
    { id: 'wallet', icon: 'account_balance_wallet', label: 'Wallet' },
    { id: 'profile', icon: 'person', label: 'Profile' },
  ];
  return (
    <div style={{
      height: 80, background: 'var(--sgx-surface-container)',
      display: 'flex', alignItems: 'flex-start',
      position: 'relative', flexShrink: 0,
      boxShadow: '0 -1px 0 var(--sgx-outline-variant)',
      paddingTop: 10,
    }}>
      {items.map(item => {
        if (item.center) {
          return (
            <div key={item.id} style={{ flex: 1, display: 'flex', justifyContent: 'center', position: 'relative' }}>
              <div style={{
                position: 'absolute', top: -22,
                width: 72, height: 72, borderRadius: 36,
                background: 'var(--sgx-primary)', color: 'white',
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                boxShadow: '0 6px 14px rgba(30, 58, 138, 0.35), 0 2px 4px rgba(0,0,0,0.10)',
                border: '4px solid var(--sgx-surface-container)',
              }}>
                <span className="material-symbols-rounded mi-fill" style={{ fontSize: 32 }}>qr_code_scanner</span>
              </div>
              <div style={{ marginTop: 54, fontSize: 11, fontWeight: 600, color: 'var(--sgx-primary)' }}>Scan</div>
            </div>
          );
        }
        const isActive = item.id === active;
        return (
          <button key={item.id} style={{
            flex: 1, height: 68, background: 'transparent', border: 'none',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
            cursor: 'pointer', padding: 0,
          }}>
            <div style={{
              width: 56, height: 32, borderRadius: 16,
              background: isActive ? 'var(--sgx-secondary)' : 'transparent',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: isActive ? 'var(--sgx-on-secondary)' : 'var(--sgx-on-surface-variant)',
            }}>
              <span className={'material-symbols-rounded' + (isActive ? ' mi-fill' : '')} style={{ fontSize: 24 }}>{item.icon}</span>
            </div>
            <div style={{ fontSize: 11, fontWeight: isActive ? 600 : 500, color: isActive ? 'var(--sgx-on-surface)' : 'var(--sgx-on-surface-variant)' }}>{item.label}</div>
          </button>
        );
      })}
    </div>
  );
}

// ── Status Chip (icon + text + color) ────────────────────────────────
function StatusChip({ status, label, size = 'md' }) {
  const map = {
    confirmed: { bg: 'var(--sgx-success-container)', fg: 'var(--sgx-success)', icon: 'check_circle' },
    success:   { bg: 'var(--sgx-success-container)', fg: 'var(--sgx-success)', icon: 'check_circle' },
    pending:   { bg: 'var(--sgx-warning-container)', fg: '#8A5A00', icon: 'schedule' },
    warning:   { bg: 'var(--sgx-warning-container)', fg: '#8A5A00', icon: 'schedule' },
    paid:      { bg: 'rgba(30,58,138,0.10)', fg: 'var(--sgx-primary)', icon: 'send' },
    disputed:  { bg: 'var(--sgx-error-container)', fg: 'var(--sgx-error)', icon: 'error' },
    error:     { bg: 'var(--sgx-error-container)', fg: 'var(--sgx-error)', icon: 'error' },
    auto:      { bg: 'var(--sgx-surface-container-high)', fg: 'var(--sgx-on-surface-variant)', icon: 'lock_clock' },
    refunded:  { bg: 'var(--sgx-success-container)', fg: 'var(--sgx-success)', icon: 'restart_alt' },
    neutral:   { bg: 'var(--sgx-surface-container-high)', fg: 'var(--sgx-on-surface-variant)', icon: 'info' },
  };
  const s = map[status] || map.neutral;
  const compact = size === 'sm';
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      height: compact ? 24 : 32, padding: compact ? '0 10px 0 8px' : '0 14px 0 10px',
      borderRadius: 9999, background: s.bg, color: s.fg,
      fontSize: compact ? 12 : 13, fontWeight: 600,
    }}>
      <span className="material-symbols-rounded mi-fill" style={{ fontSize: compact ? 14 : 18 }}>{s.icon}</span>
      {label}
    </div>
  );
}

// ── Section Header ───────────────────────────────────────────────────
function SectionHeader({ title, action }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 16px', marginBottom: 12,
    }}>
      <div className="t-section-title" style={{ color: 'var(--sgx-on-surface)' }}>{title}</div>
      {action && <div style={{ color: 'var(--sgx-primary)', fontSize: 13, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>{action} <span className="material-symbols-rounded" style={{ fontSize: 16 }}>chevron_right</span></div>}
    </div>
  );
}

// ── Placeholder Image (for products, campaigns) ──────────────────────
function ImgSlot({ w = '100%', h = 120, radius = 12, kind = 'part', label }) {
  const palettes = {
    part:   ['#EEF2F7', '#CBD5E1', '#64748B'],
    oil:    ['#FEF3C7', '#F59E0B', '#78350F'],
    tire:   ['#E5E7EB', '#374151', '#111827'],
    spark:  ['#DBEAFE', '#3B82F6', '#1E3A8A'],
    battery:['#DCFCE7', '#22C55E', '#166534'],
    camp:   ['#1E3A8A', '#3B82F6', '#EEF2F7'],
    filter: ['#FEE2E2', '#EF4444', '#7F1D1D'],
    chain:  ['#E2E8F0', '#475569', '#0F172A'],
  };
  const [bg, mid, fg] = palettes[kind] || palettes.part;
  return (
    <div style={{
      width: w, height: h, borderRadius: radius, background: bg,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      overflow: 'hidden', position: 'relative', flexShrink: 0,
    }}>
      {kind === 'part' && (
        <svg width="60%" height="60%" viewBox="0 0 100 100">
          <circle cx="50" cy="50" r="30" fill="none" stroke={mid} strokeWidth="8"/>
          <circle cx="50" cy="50" r="10" fill={fg}/>
          {[0,60,120,180,240,300].map(a => (
            <rect key={a} x="47" y="10" width="6" height="14" fill={mid} transform={`rotate(${a} 50 50)`}/>
          ))}
        </svg>
      )}
      {kind === 'oil' && (
        <svg width="55%" height="70%" viewBox="0 0 60 80">
          <rect x="10" y="15" width="40" height="60" rx="4" fill={mid}/>
          <rect x="18" y="5" width="24" height="14" rx="2" fill={fg}/>
          <rect x="16" y="30" width="28" height="20" fill="#fff" fillOpacity="0.9"/>
        </svg>
      )}
      {kind === 'tire' && (
        <svg width="60%" height="60%" viewBox="0 0 100 100">
          <circle cx="50" cy="50" r="40" fill={mid}/>
          <circle cx="50" cy="50" r="22" fill={bg}/>
          <circle cx="50" cy="50" r="10" fill={fg}/>
        </svg>
      )}
      {kind === 'spark' && (
        <svg width="35%" height="75%" viewBox="0 0 30 80">
          <rect x="10" y="0" width="10" height="18" fill={fg}/>
          <rect x="6" y="18" width="18" height="30" fill="#fff"/>
          <rect x="10" y="48" width="10" height="24" fill={mid}/>
          <circle cx="15" cy="76" r="3" fill={fg}/>
        </svg>
      )}
      {kind === 'battery' && (
        <svg width="70%" height="55%" viewBox="0 0 100 60">
          <rect x="5" y="10" width="90" height="45" rx="4" fill={mid}/>
          <rect x="20" y="4" width="15" height="8" fill={fg}/>
          <rect x="65" y="4" width="15" height="8" fill={fg}/>
          <text x="30" y="38" fill="#fff" fontSize="18" fontWeight="800">+</text>
          <text x="60" y="38" fill="#fff" fontSize="18" fontWeight="800">−</text>
        </svg>
      )}
      {kind === 'filter' && (
        <svg width="55%" height="65%" viewBox="0 0 60 70">
          <circle cx="30" cy="35" r="25" fill={mid}/>
          <circle cx="30" cy="35" r="14" fill={bg}/>
          <rect x="26" y="4" width="8" height="14" fill={fg}/>
        </svg>
      )}
      {kind === 'chain' && (
        <svg width="80%" height="30%" viewBox="0 0 100 30">
          {[8,26,44,62,80].map(x => (
            <rect key={x} x={x} y="6" width="14" height="18" rx="4" fill={mid} stroke={fg} strokeWidth="1.5"/>
          ))}
        </svg>
      )}
      {kind === 'camp' && (
        <div style={{
          position: 'absolute', inset: 0,
          background: `linear-gradient(135deg, ${mid} 0%, ${bg} 100%)`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: fg, fontSize: 22, fontWeight: 800, letterSpacing: -0.5,
          textAlign: 'center', padding: 20,
        }}>{label || 'Campaign'}</div>
      )}
    </div>
  );
}

// ── Scrollable content region (below top bar) ───────────────────────
function Scroll({ children, style, pad = 16, gap = 16, bg }) {
  return (
    <div style={{
      flex: 1, overflow: 'auto', background: bg || 'var(--sgx-surface)',
      padding: pad, display: 'flex', flexDirection: 'column', gap,
      ...style,
    }}>{children}</div>
  );
}

// ── Wholesaler Bottom Bar — flat M3 NavigationBar (no scan FAB) ──────
// Five destinations per PRD §8: Home · QR Progress · Wallet · Products · Profile
function WholesalerBottomBar({ active = 'home' }) {
  const items = [
    { id: 'home',     icon: 'home',                     label: 'Home' },
    { id: 'qr',       icon: 'qr_code_2',                label: 'QR Progress' },
    { id: 'wallet',   icon: 'account_balance_wallet',   label: 'Wallet' },
    { id: 'products', icon: 'category',                 label: 'Products' },
    { id: 'profile',  icon: 'person',                   label: 'Profile' },
  ];
  return (
    <div style={{
      height: 80, background: 'var(--sgx-surface-container)',
      display: 'flex', alignItems: 'flex-start',
      position: 'relative', flexShrink: 0,
      boxShadow: '0 -1px 0 var(--sgx-outline-variant)',
      paddingTop: 10,
    }}>
      {items.map(item => {
        const isActive = item.id === active;
        return (
          <button key={item.id} style={{
            flex: 1, height: 68, background: 'transparent', border: 'none',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
            cursor: 'pointer', padding: 0, position: 'relative',
          }}>
            <div style={{
              width: 56, height: 32, borderRadius: 16,
              background: isActive ? 'var(--sgx-secondary)' : 'transparent',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: isActive ? 'var(--sgx-on-secondary)' : 'var(--sgx-on-surface-variant)',
            }}>
              <span className={'material-symbols-rounded' + (isActive ? ' mi-fill' : '')} style={{ fontSize: 24 }}>{item.icon}</span>
            </div>
            <div style={{
              fontSize: 10.5, lineHeight: '14px', fontWeight: isActive ? 600 : 500,
              color: isActive ? 'var(--sgx-on-surface)' : 'var(--sgx-on-surface-variant)',
              maxWidth: 68, textAlign: 'center', whiteSpace: 'nowrap',
            }}>{item.label}</div>
          </button>
        );
      })}
    </div>
  );
}

// ── Progress Bar (determinate) ───────────────────────────────────────
function ProgressBar({ value = 0, total = 100, height = 8, tone = 'primary' }) {
  const pct = total === 0 ? 0 : Math.max(0, Math.min(100, (value / total) * 100));
  const trackColor = 'var(--sgx-surface-container-high)';
  const fillColor = tone === 'success' ? 'var(--sgx-success)'
                  : tone === 'warning' ? 'var(--sgx-warning)'
                  : 'var(--sgx-primary)';
  return (
    <div style={{
      width: '100%', height, borderRadius: height,
      background: trackColor, overflow: 'hidden',
    }}>
      <div style={{
        width: `${pct}%`, height: '100%', borderRadius: height,
        background: fillColor,
        transition: 'width 300ms cubic-bezier(0.2, 0, 0, 1)',
      }} />
    </div>
  );
}

// Export to window for cross-file access
Object.assign(window, {
  SgxIcon, StatusBar, HomeIndicator, Phone, TopAppBar, IconBtn, BackBtn,
  FilledBtn, OutlinedBtn, TextBtn, TextField, BottomBar, WholesalerBottomBar,
  StatusChip, SectionHeader, ImgSlot, Scroll, ProgressBar, PHONE_W, PHONE_H,
});
