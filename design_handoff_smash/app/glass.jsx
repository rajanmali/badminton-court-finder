// glass.jsx — Smash primitives: icons, glass, halftone, court lines, phone frame, atoms
// Exports to window for cross-script use.

// ─────────────────────────────────────────────────────────────
// SF-Symbol-style icons (thin strokes, currentColor)
// ─────────────────────────────────────────────────────────────
function Icon({ name, size = 22, stroke = 2, style = {} }) {
  const p = { fill: "none", stroke: "currentColor", strokeWidth: stroke, strokeLinecap: "round", strokeLinejoin: "round" };
  const paths = {
    list:    <g {...p}><path d="M8 6h13M8 12h13M8 18h13"/><circle cx="3.5" cy="6" r="1.3" fill="currentColor" stroke="none"/><circle cx="3.5" cy="12" r="1.3" fill="currentColor" stroke="none"/><circle cx="3.5" cy="18" r="1.3" fill="currentColor" stroke="none"/></g>,
    map:     <g {...p}><path d="M9 4 3 6v14l6-2 6 2 6-2V4l-6 2-6-2Z"/><path d="M9 4v14M15 6v14"/></g>,
    chevR:   <g {...p}><path d="M9 5l7 7-7 7"/></g>,
    chevL:   <g {...p}><path d="M15 5l-7 7 7 7"/></g>,
    chevD:   <g {...p}><path d="M5 9l7 7 7-7"/></g>,
    share:   <g {...p}><path d="M12 15V4M8.5 7.5 12 4l3.5 3.5"/><path d="M6 11v7a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2v-7"/></g>,
    pin:     <g {...p}><path d="M12 21s7-6.3 7-11a7 7 0 0 0-14 0c0 4.7 7 11 7 11Z"/><circle cx="12" cy="10" r="2.6"/></g>,
    clock:   <g {...p}><circle cx="12" cy="12" r="8.4"/><path d="M12 7.5V12l3 1.8"/></g>,
    sliders: <g {...p}><path d="M4 7h10M18 7h2M4 17h2M10 17h10"/><circle cx="16" cy="7" r="2.2"/><circle cx="8" cy="17" r="2.2"/></g>,
    nav:     <g {...p}><path d="M3 11 21 4l-7 18-2.5-7.5L3 11Z"/></g>,
    dollar:  <g {...p}><path d="M12 3v18M16 7.5c0-1.7-1.8-2.8-4-2.8s-4 1-4 2.8 1.8 2.6 4 2.9 4 1.1 4 2.9-1.8 2.8-4 2.8-4-1-4-2.8"/></g>,
    courts:  <g {...p}><rect x="3.5" y="5" width="17" height="14" rx="1.4"/><path d="M12 5v14M3.5 12h17M8 5v14M16 5v14"/></g>,
    star:    <g><path d="M12 3.6l2.4 5 5.5.7-4 3.8 1 5.4L12 16l-4.9 2.5 1-5.4-4-3.8 5.5-.7L12 3.6Z" fill="currentColor"/></g>,
    check:   <g {...p}><path d="M5 12.5 10 17l9-10"/></g>,
    x:       <g {...p}><path d="M6 6l12 12M18 6 6 18"/></g>,
    info:    <g {...p}><circle cx="12" cy="12" r="8.5"/><path d="M12 11v5"/><circle cx="12" cy="7.8" r="1" fill="currentColor" stroke="none"/></g>,
    retry:   <g {...p}><path d="M20 11a8 8 0 1 0-1.5 6"/><path d="M20 5v6h-6"/></g>,
    bolt:    <g><path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z" fill="currentColor"/></g>,
    parking: <g {...p}><rect x="4" y="4" width="16" height="16" rx="4"/><path d="M9.5 17V7h3.2a3 3 0 0 1 0 6H9.5"/></g>,
    transit: <g {...p}><rect x="6" y="4" width="12" height="13" rx="3"/><path d="M6 12h12M9 21l-2-2M15 21l2-2"/><circle cx="9" cy="14.5" r=".6" fill="currentColor" stroke="none"/><circle cx="15" cy="14.5" r=".6" fill="currentColor" stroke="none"/></g>,
    shuttle: <g {...p}><circle cx="12" cy="17" r="3.2"/><path d="M12 13.8 9.5 5M12 13.8 14.5 5M10 6.5h4M9 8.5h6"/></g>,
    plus:    <g {...p}><path d="M12 5v14M5 12h14"/></g>,
    minus:   <g {...p}><path d="M5 12h14"/></g>,
  };
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: "block", ...style }}>
      {paths[name] || null}
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Glass surface
// ─────────────────────────────────────────────────────────────
function Glass({ level = "regular", edge = true, className = "", style = {}, children, ...rest }) {
  return (
    <div className={`glass m-${level} ${edge ? "glass-edge" : ""} ${className}`} style={style} {...rest}>
      {children}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Halftone — masked dot field that fades by radius
// ─────────────────────────────────────────────────────────────
function Halftone({ color = "currentColor", size = "lg", from = "70% 18%", style = {}, opacity = 1, className = "" }) {
  const cls = size === "sm" ? "halftone halftone-sm" : size === "md" ? "halftone" : "halftone halftone-lg";
  return (
    <div className={`${cls} ${className}`} style={{
      position: "absolute", inset: 0, color, opacity,
      WebkitMaskImage: `radial-gradient(70% 70% at ${from}, #000 0%, rgba(0,0,0,.5) 38%, transparent 72%)`,
      maskImage: `radial-gradient(70% 70% at ${from}, #000 0%, rgba(0,0,0,.5) 38%, transparent 72%)`,
      pointerEvents: "none", ...style
    }} />
  );
}

// Badminton court lines (simple geometric strokes — on-brand motif)
function CourtLines({ color = "rgba(255,255,255,.5)", w = 1.4, style = {}, className = "" }) {
  return (
    <svg viewBox="0 0 100 220" preserveAspectRatio="xMidYMid meet" className={className}
      style={{ position: "absolute", inset: 0, width: "100%", height: "100%", ...style }}>
      <g fill="none" stroke={color} strokeWidth={w}>
        <rect x="6" y="6" width="88" height="208" />
        <line x1="14" y1="6" x2="14" y2="214" />
        <line x1="86" y1="6" x2="86" y2="214" />
        <line x1="6" y1="40" x2="94" y2="40" />
        <line x1="6" y1="180" x2="94" y2="180" />
        <line x1="6" y1="92" x2="94" y2="92" />
        <line x1="6" y1="128" x2="94" y2="128" />
        <line x1="50" y1="40" x2="50" y2="92" />
        <line x1="50" y1="128" x2="50" y2="180" />
        <line x1="6" y1="110" x2="94" y2="110" stroke={color} strokeDasharray="3 4" />
      </g>
    </svg>
  );
}

// Court "tile" used as a venue thumbnail / pin glyph
function CourtTile({ initial, dedicated, size = 56, radius = 15, style = {} }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: radius, position: "relative", overflow: "hidden", flex: "none",
      background: dedicated
        ? "linear-gradient(150deg, var(--green-bright), var(--green-deep))"
        : "linear-gradient(150deg, #3a4046, #1d2125)",
      boxShadow: "inset 0 1px 0 rgba(255,255,255,.25), 0 4px 12px rgba(0,0,0,.18)", ...style
    }}>
      <CourtLines color="rgba(255,255,255,.30)" w={1.2} />
      <Halftone color="rgba(255,255,255,.5)" size="sm" from="78% 20%" opacity={.35} />
      <div style={{
        position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center",
        fontWeight: 800, fontSize: size * 0.4, color: "#fff", letterSpacing: "-1px",
        textShadow: "0 1px 4px rgba(0,0,0,.3)"
      }}>{initial}</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Rich screen backdrop (gradient mesh + halftone + court ghost)
// ─────────────────────────────────────────────────────────────
function Backdrop({ tone = "green", children }) {
  const light = document.documentElement.getAttribute("data-theme") !== "dark";
  const mesh = light
    ? "radial-gradient(110% 60% at 86% -2%, rgba(25,214,128,.30), transparent 50%), radial-gradient(90% 55% at -12% 8%, rgba(229,57,43,.10), transparent 50%), linear-gradient(178deg, #EEEBE3, #E4E0D6)"
    : "radial-gradient(110% 58% at 88% -4%, rgba(0,185,100,.26), transparent 50%), radial-gradient(95% 55% at -10% 6%, rgba(229,57,43,.14), transparent 48%), linear-gradient(178deg, #0E1112, #090A0B)";
  const scrim = light
    ? "linear-gradient(180deg, rgba(243,241,235,.72), rgba(243,241,235,0) 16%)"
    : "linear-gradient(180deg, rgba(7,8,9,.66), rgba(7,8,9,0) 17%)";
  return (
    <div style={{ position: "absolute", inset: 0, background: mesh, overflow: "hidden" }}>
      <Halftone color={light ? "rgba(10,110,66,.45)" : "rgba(25,214,128,.36)"} size="lg" from="88% 4%" opacity={light ? .45 : .5} />
      <div style={{ position: "absolute", left: "-18%", bottom: "-8%", width: "70%", height: "55%", opacity: light ? .09 : .12 }}>
        <CourtLines color={light ? "var(--green-deep)" : "var(--green-bright)"} w={1.4} />
      </div>
      <div style={{ position: "absolute", insetInline: 0, top: 0, height: 200, background: scrim, pointerEvents: "none" }} />
      {children}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Status bar (compact, tint-aware)
// ─────────────────────────────────────────────────────────────
function StatusBar({ light = false, time = "9:41" }) {
  const c = light ? "#fff" : "var(--text)";
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "13px 30px 4px", color: c, position: "relative", zIndex: 30 }}>
      <span style={{ fontWeight: 650, fontSize: 16, letterSpacing: ".2px", minWidth: 54 }}>{time}</span>
      <div style={{ display: "flex", alignItems: "center", gap: 7 }}>
        <svg width="18" height="11" viewBox="0 0 19 12"><rect x="0" y="7.5" width="3.2" height="4.5" rx="0.7" fill={c}/><rect x="4.8" y="5" width="3.2" height="7" rx="0.7" fill={c}/><rect x="9.6" y="2.5" width="3.2" height="9.5" rx="0.7" fill={c}/><rect x="14.4" y="0" width="3.2" height="12" rx="0.7" fill={c}/></svg>
        <svg width="16" height="11" viewBox="0 0 17 12"><path d="M8.5 3.2C10.8 3.2 12.9 4.1 14.4 5.6L15.5 4.5C13.7 2.7 11.2 1.5 8.5 1.5C5.8 1.5 3.3 2.7 1.5 4.5L2.6 5.6C4.1 4.1 6.2 3.2 8.5 3.2Z" fill={c}/><path d="M8.5 6.8C9.9 6.8 11.1 7.3 12 8.2L13.1 7.1C11.8 5.9 10.2 5.1 8.5 5.1C6.8 5.1 5.2 5.9 3.9 7.1L5 8.2C5.9 7.3 7.1 6.8 8.5 6.8Z" fill={c}/><circle cx="8.5" cy="10.5" r="1.5" fill={c}/></svg>
        <svg width="25" height="12" viewBox="0 0 27 13"><rect x="0.5" y="0.5" width="23" height="12" rx="3.5" stroke={c} strokeOpacity="0.35" fill="none"/><rect x="2" y="2" width="20" height="9" rx="2" fill={c}/><path d="M25 4.5V8.5C25.8 8.2 26.5 7.2 26.5 6.5C26.5 5.8 25.8 4.8 25 4.5Z" fill={c} fillOpacity="0.4"/></svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Phone frame — bezel, dynamic island, status bar slot, home indicator
// ─────────────────────────────────────────────────────────────
function Phone({ statusLight = false, children, time = "9:41" }) {
  const dark = document.documentElement.getAttribute("data-theme") === "dark";
  return (
    <div style={{
      width: 396, height: 858, borderRadius: 56, position: "relative", overflow: "hidden",
      background: "var(--page)",
      boxShadow: "0 50px 100px rgba(0,0,0,.55), 0 0 0 11px #1b1c1e, 0 0 0 12.5px #2c2d30, 0 0 0 14px rgba(0,0,0,.5)",
    }}>
      <div style={{ position: "absolute", top: 12, left: "50%", transform: "translateX(-50%)", width: 122, height: 35, borderRadius: 24, background: "#000", zIndex: 60 }} />
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, zIndex: 30 }}>
        <StatusBar light={statusLight} time={time} />
      </div>
      <div style={{ position: "absolute", inset: 0 }}>{children}</div>
      <div style={{ position: "absolute", bottom: 8, left: 0, right: 0, height: 5, zIndex: 70, display: "flex", justifyContent: "center", pointerEvents: "none" }}>
        <div style={{ width: 138, height: 5, borderRadius: 99, background: statusLight ? "rgba(255,255,255,.7)" : (dark ? "rgba(255,255,255,.6)" : "rgba(0,0,0,.32)") }} />
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Shared atoms
// ─────────────────────────────────────────────────────────────
function Segmented({ options, value, onChange }) {
  const i = options.findIndex(o => o.id === value);
  return (
    <Glass level="regular" className="seg" style={{ borderRadius: 999, width: 230, margin: "0 auto" }}>
      <div className="seg-thumb" style={{ width: `calc(${100 / options.length}% - 4px)`, left: 3, transform: `translateX(calc(${i * 100}% + ${i * 4}px))`, background: "var(--seg-thumb, linear-gradient(180deg,var(--green-bright),var(--green)))" }} />
      {options.map(o => (
        <div key={o.id} className="seg-opt tap" onClick={() => onChange(o.id)}
          style={{ color: o.id === value ? "#04190f" : "var(--text-2)", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
          <Icon name={o.icon} size={16} stroke={2.2} />{o.label}
        </div>
      ))}
    </Glass>
  );
}

function Chip({ on, children, onClick }) {
  return (
    <button onClick={onClick} className={`chip tap spring ${on ? "chip-on" : ""}`} style={{ border: "none", fontFamily: "var(--sf)" }}>
      {on && <Icon name="check" size={14} stroke={2.6} />}{children}
    </button>
  );
}

function Switch({ on, onClick }) {
  return (
    <div onClick={onClick} className={`sw tap ${on ? "sw-on" : ""}`} style={{ background: on ? "var(--green)" : (document.documentElement.getAttribute("data-theme") === "dark" ? "rgba(255,255,255,.18)" : "rgba(120,120,128,.32)") }}>
      <div className="sw-knob" />
    </div>
  );
}

function GlassPill({ onClick, children, size = 42, light = false }) {
  return (
    <Glass level="ultrathin" onClick={onClick} className="tap spring"
      style={{ width: size, height: size, borderRadius: 999, display: "flex", alignItems: "center", justifyContent: "center", color: light ? "#fff" : "var(--text)", flex: "none" }}>
      {children}
    </Glass>
  );
}

// Floating bottom tab bar (iOS-26 style) — primary List/Map navigation
function TabBar({ tab, setTab, items }) {
  const tabs = items || [{ id: "list", label: "List", icon: "list" }, { id: "map", label: "Map", icon: "map" }];
  return (
    <div style={{ position: "absolute", left: 0, right: 0, bottom: 26, zIndex: 45, display: "flex", justifyContent: "center", pointerEvents: "none" }}>
      <Glass level="thick" className="glass-edge" style={{ borderRadius: 999, padding: 5, display: "flex", gap: 4, pointerEvents: "auto", boxShadow: "0 8px 30px rgba(0,0,0,.30), inset 0 0.75px 0 var(--glass-sheen)" }}>
        {tabs.map(it => {
          const on = tab === it.id;
          return (
            <div key={it.id} onClick={() => { setTab(it.id); if (navigator.vibrate) navigator.vibrate(6); }} className="tap spring"
              style={{ display: "flex", alignItems: "center", gap: 8, padding: "11px 22px", borderRadius: 999, transition: "background .3s ease, color .25s ease",
                background: on ? "linear-gradient(180deg, var(--green-bright), var(--green))" : "transparent",
                color: on ? "#04190f" : "var(--text-2)", fontWeight: 750, fontSize: 15, letterSpacing: "-.2px",
                boxShadow: on ? "0 2px 10px rgba(0,185,100,.4), inset 0 1px 0 rgba(255,255,255,.4)" : "none" }}>
              <Icon name={it.icon} size={19} stroke={2.2} />{it.label}
            </div>
          );
        })}
      </Glass>
    </div>
  );
}

Object.assign(window, { Icon, Glass, Halftone, CourtLines, CourtTile, Backdrop, StatusBar, Phone, Segmented, Chip, Switch, GlassPill, TabBar });
