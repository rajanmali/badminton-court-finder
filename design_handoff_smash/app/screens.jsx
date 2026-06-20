// screens.jsx — Smash: List, Map (with stylized map backdrop), Detail
// depends on glass.jsx + cards.jsx via window

// ─────────────────────────────────────────────────────────────
// Stylized Sydney map backdrop (abstract, tasteful — not a real map)
// ─────────────────────────────────────────────────────────────
function MapBackdrop() {
  return (
    <div style={{ position: "absolute", inset: 0, background: "var(--map-land)", overflow: "hidden" }}>
      <svg viewBox="0 0 400 858" preserveAspectRatio="xMidYMid slice" style={{ position: "absolute", inset: 0, width: "100%", height: "100%" }}>
        {/* harbour / water */}
        <path d="M400 0 L400 858 L250 858 C255 720 200 640 240 560 C280 480 200 470 250 380 C300 300 330 250 290 180 C260 120 330 60 400 40 Z" fill="var(--map-water)" />
        <path d="M0 858 L0 690 C60 700 120 760 110 858 Z" fill="var(--map-water)" />
        <path d="M150 470 C200 460 210 510 175 540 C150 560 120 520 150 470 Z" fill="var(--map-water)" opacity=".7" />
        {/* parks */}
        <ellipse cx="120" cy="300" rx="80" ry="60" fill="var(--map-park)" opacity=".9" />
        <ellipse cx="300" cy="640" rx="70" ry="55" fill="var(--map-park)" opacity=".8" />
        <ellipse cx="70" cy="560" rx="55" ry="44" fill="var(--map-park)" opacity=".7" />
        {/* roads */}
        <g stroke="var(--map-road)" fill="none" strokeLinecap="round">
          <path d="M-20 220 C120 240 240 180 430 250" strokeWidth="9" />
          <path d="M-20 420 C140 400 260 460 430 430" strokeWidth="9" />
          <path d="M60 -20 C80 200 40 460 120 880" strokeWidth="8" />
          <path d="M240 -20 C220 220 260 480 200 880" strokeWidth="8" />
          <path d="M-20 640 C120 620 260 660 430 620" strokeWidth="7" />
          <path d="M-20 120 C160 140 300 90 430 130" strokeWidth="5" opacity=".7" />
        </g>
        <g stroke="var(--map-road)" fill="none" strokeWidth="3" opacity=".5">
          <path d="M-20 320 C160 310 300 340 430 330" />
          <path d="M150 -20 C170 300 130 560 180 880" />
          <path d="M-20 520 C140 540 280 500 430 530" />
        </g>
      </svg>
      {/* place labels */}
      {[["Chatswood", "22%", "16%"], ["Manly", "82%", "20%"], ["Sydney", "44%", "52%", 18], ["Parramatta", "12%", "44%"], ["Bankstown", "30%", "72%"]].map(([t, l, top, fs], i) => (
        <div key={i} style={{ position: "absolute", left: l, top, transform: "translate(-50%,-50%)", fontSize: fs || 12.5, fontWeight: fs ? 800 : 650, color: "var(--text-2)", letterSpacing: fs ? "-.3px" : 0, textShadow: "0 1px 2px var(--map-veil)", whiteSpace: "nowrap", opacity: .9 }}>{t}</div>
      ))}
      {/* green tint veil so glass reads */}
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(90% 60% at 70% 12%, rgba(0,185,100,.10), transparent 60%)", pointerEvents: "none" }} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Shared header: wordmark + segmented (used by list & map)
// ─────────────────────────────────────────────────────────────
function AppHeader({ tab, setTab, overMap = false }) {
  return (
    <div style={{ padding: "2px 18px 0" }}>
      <div style={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between", marginBottom: 14 }}>
        <div>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <span style={{ fontWeight: 850, fontSize: 34, letterSpacing: "-1.6px", color: "var(--text)", lineHeight: .95 }}>Smash</span>
            <span style={{ width: 9, height: 9, borderRadius: 99, background: "var(--green)", marginBottom: 6, boxShadow: "0 0 10px var(--green)" }} />
          </div>
          <div style={{ fontSize: 13.5, fontWeight: 600, color: "var(--text-2)", letterSpacing: ".2px", marginTop: 1 }}>Find a court · Sydney</div>
        </div>
        <GlassPill size={42}><Icon name="nav" size={19} stroke={2} style={{ color: "var(--green)" }} /></GlassPill>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// LIST SCREEN
// ─────────────────────────────────────────────────────────────
function ListScreen({ tab, setTab, f, setF, venues, state, onOpen, onReset, onRetry }) {
  return (
    <div style={{ position: "absolute", inset: 0 }}>
      <Backdrop />
      <div className="noscroll" style={{ position: "absolute", inset: 0, overflowY: "auto", paddingTop: 52 }}>
        <AppHeader tab={tab} setTab={setTab} />
        <div style={{ padding: "16px 16px 6px" }}>
          <FilterBar f={f} setF={setF} />
        </div>
        {state === "loading" ? <LoadingState />
          : state === "error" ? <ErrorState onRetry={onRetry} />
          : venues.length === 0 ? <EmptyState onReset={onReset} />
          : (
            <div style={{ display: "flex", flexDirection: "column", gap: 13, padding: "8px 16px 120px" }}>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "2px 4px" }}>
                <span style={{ fontSize: 13, fontWeight: 700, color: "var(--text-2)" }}>{venues.length} {venues.length === 1 ? "venue" : "venues"}</span>
                <span style={{ display: "inline-flex", alignItems: "center", gap: 5, fontSize: 13, fontWeight: 650, color: "var(--text-2)" }}>Nearest first <Icon name="chevD" size={13} stroke={2.2} /></span>
              </div>
              {venues.map((v, i) => <VenueCard key={v.id} v={v} delay={i * 55} onOpen={() => onOpen(v)} />)}
            </div>
          )}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// MAP SCREEN
// ─────────────────────────────────────────────────────────────
function MapScreen({ tab, setTab, f, setF, venues, pinStyle, onOpen }) {
  const [sel, setSel] = React.useState(null);
  const [showFilters, setShowFilters] = React.useState(false);
  React.useEffect(() => { setSel(null); }, [f]);
  const Pin = pinStyle === "price" ? PinPrice : pinStyle === "dot" ? PinDot : PinTeardrop;
  const selV = venues.find(v => v.id === sel);
  const dark = document.documentElement.getAttribute("data-theme") === "dark";
  const mapScrim = dark
    ? "linear-gradient(180deg, rgba(7,9,10,.92) 0%, rgba(7,9,10,.5) 55%, transparent 100%)"
    : "linear-gradient(180deg, rgba(238,236,230,.94) 0%, rgba(238,236,230,.5) 55%, transparent 100%)";
  return (
    <div style={{ position: "absolute", inset: 0, overflow: "hidden" }}>
      <MapBackdrop />
      {/* pins */}
      {venues.map(v => (
        <div key={v.id} style={{ position: "absolute", left: `${v.x * 100}%`, top: `${22 + v.y * 60}%`, transform: "translate(-50%,-50%)" }}>
          <Pin v={v} selected={sel === v.id} onClick={() => setSel(sel === v.id ? null : v.id)} />
        </div>
      ))}

      {/* top glass chrome */}
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, zIndex: 20 }}>
        <div style={{ position: "absolute", inset: "0 0 auto 0", height: 200, background: mapScrim, pointerEvents: "none" }} />
        <div style={{ position: "relative", padding: "50px 16px 0" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 7 }}>
              <span style={{ fontWeight: 850, fontSize: 22, letterSpacing: "-1px", color: "var(--text)" }}>Smash</span>
              <span style={{ width: 7, height: 7, borderRadius: 99, background: "var(--green)", boxShadow: "0 0 8px var(--green)" }} />
            </div>
            <Glass level="thick" onClick={() => setShowFilters(s => !s)} className="tap spring" style={{ borderRadius: 999, padding: "8px 14px", display: "flex", alignItems: "center", gap: 7, fontWeight: 700, fontSize: 14, color: "var(--text)" }}>
              <Icon name="sliders" size={16} stroke={2} style={{ color: "var(--green)" }} /> Filters
              {(f.dist !== "any" || f.price !== "any" || f.dedicated) && <span style={{ width: 7, height: 7, borderRadius: 99, background: "var(--red)" }} />}
            </Glass>
          </div>
          {showFilters && <div style={{ marginTop: 11 }} className="rise"><FilterBar f={f} setF={setF} /></div>}
        </div>
      </div>

      {/* locate button */}
      <div style={{ position: "absolute", right: 16, bottom: selV ? 300 : 110, zIndex: 18 }} className="spring">
        <GlassPill size={46}><Icon name="nav" size={19} stroke={2} style={{ color: "var(--green)" }} /></GlassPill>
      </div>

      {/* preview card */}
      {selV && (
        <div className="rise" style={{ position: "absolute", left: 14, right: 14, bottom: 96, zIndex: 25 }}>
          <PreviewCard v={selV} onOpen={() => onOpen(selV)} onClose={() => setSel(null)} />
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// DETAIL SCREEN
// ─────────────────────────────────────────────────────────────
function RateCard({ r }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 12, padding: "13px 0" }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 3 }}>
          <span style={{ fontWeight: 750, fontSize: 16, color: "var(--text)", letterSpacing: "-.3px" }}>{r.label}</span>
          {r.note && <span style={{ fontSize: 10.5, fontWeight: 750, textTransform: "uppercase", letterSpacing: ".4px", color: "var(--green-deep)", background: "rgba(0,185,100,.14)", padding: "2px 7px", borderRadius: 999 }}>{r.note}</span>}
        </div>
        <div style={{ fontSize: 13, color: "var(--text-2)", fontWeight: 550 }}>{r.days} · {r.time}</div>
      </div>
      <div style={{ fontWeight: 850, fontSize: 19, letterSpacing: "-.6px", color: "var(--green)" }}>${r.price}<span style={{ fontSize: 11, color: "var(--text-3)", fontWeight: 650 }}>/hr</span></div>
    </div>
  );
}

function DetailScreen({ v, onBack }) {
  const today = new Date().getDay(); // 0 Sun..6 Sat
  const idx = today === 0 ? 6 : today - 1;
  return (
    <div style={{ position: "absolute", inset: 0, background: "var(--page)" }}>
      <div className="noscroll" style={{ position: "absolute", inset: 0, overflowY: "auto" }}>
        {/* HERO */}
        <div style={{ position: "relative", height: 330 }}>
          <div style={{ position: "absolute", inset: 0, background: v.dedicated ? "linear-gradient(160deg, var(--green-bright), var(--green-deep))" : "linear-gradient(160deg, #3a4046, #15181b)", overflow: "hidden" }}>
            <CourtLines color="rgba(255,255,255,.28)" w={1.6} style={{ transform: "scale(1.1)" }} />
            <Halftone color="rgba(255,255,255,.55)" size="lg" from="84% 18%" opacity={.4} />
            <div style={{ position: "absolute", right: -30, bottom: -40, fontWeight: 850, fontSize: 240, color: "rgba(255,255,255,.10)", lineHeight: .7, letterSpacing: "-12px" }}>{v.initial}</div>
            <div style={{ position: "absolute", inset: 0, background: "linear-gradient(180deg, rgba(0,0,0,.28) 0%, transparent 26%, transparent 55%, rgba(0,0,0,.0) 100%)" }} />
            <div style={{ position: "absolute", left: 0, right: 0, bottom: 0, height: 90, background: "linear-gradient(180deg, transparent, var(--page))" }} />
          </div>
          {/* top chrome */}
          <div style={{ position: "absolute", top: 50, left: 16, right: 16, display: "flex", justifyContent: "space-between", zIndex: 5 }}>
            <GlassPill size={42} light onClick={onBack}><Icon name="chevL" size={20} stroke={2.4} /></GlassPill>
            <div style={{ display: "flex", gap: 9 }}>
              <GlassPill size={42} light><Icon name="star" size={19} /></GlassPill>
              <GlassPill size={42} light><Icon name="share" size={19} stroke={2} /></GlassPill>
            </div>
          </div>
        </div>

        {/* TITLE BLOCK — glass card overlapping hero */}
        <div style={{ padding: "0 16px", marginTop: -56, position: "relative", zIndex: 4 }}>
          <Glass level="thick" className="glass-edge" style={{ borderRadius: 26, padding: 18 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 8, flexWrap: "wrap" }}>
              {v.dedicated && <span className="badge-ded">Dedicated</span>}
              <span style={{ fontSize: 12, fontWeight: 700, color: "var(--text-2)", display: "inline-flex", alignItems: "center", gap: 4 }}><Icon name="star" size={13} style={{ color: "var(--green)" }} />4.8 · 212 reviews</span>
            </div>
            <div style={{ fontWeight: 850, fontSize: 26, letterSpacing: "-1px", color: "var(--text)", lineHeight: 1.05, marginBottom: 7 }}>{v.name}</div>
            <div style={{ display: "flex", alignItems: "flex-start", gap: 6, color: "var(--text-2)", fontSize: 14, fontWeight: 550, marginBottom: 14 }}>
              <Icon name="pin" size={15} stroke={2} style={{ marginTop: 1, flex: "none" }} />{v.address}
            </div>
            <div style={{ display: "flex", gap: 10 }}>
              {[["courts", `${v.courts} courts`], ["dollar", `From $${v.from}/hr`], ["nav", `${v.dist} km away`]].map(([ic, t], i) => (
                <div key={i} style={{ flex: 1, background: "var(--chip-bg)", borderRadius: 14, padding: "10px 8px", textAlign: "center" }}>
                  <Icon name={ic} size={18} stroke={1.9} style={{ color: "var(--green)", margin: "0 auto 5px" }} />
                  <div style={{ fontSize: 12.5, fontWeight: 700, color: "var(--text)", letterSpacing: "-.2px" }}>{t}</div>
                </div>
              ))}
            </div>
          </Glass>
        </div>

        {/* RATES */}
        <div style={{ padding: "20px 16px 0" }}>
          <SectionTitle icon="dollar" title="Court hire rates" />
          <Glass level="regular" style={{ borderRadius: 22, padding: "2px 16px" }}>
            {v.rates.map((r, i) => (
              <React.Fragment key={i}>
                {i > 0 && <div style={{ height: 0.5, background: "var(--hairline)" }} />}
                <RateCard r={r} />
              </React.Fragment>
            ))}
          </Glass>
        </div>

        {/* HOURS */}
        <div style={{ padding: "20px 16px 0" }}>
          <SectionTitle icon="clock" title="Opening hours" />
          <Glass level="regular" style={{ borderRadius: 22, padding: "4px 16px" }}>
            {v.hours.map(([d, t], i) => {
              const open = i === idx;
              const closed = t === "Closed";
              return (
                <div key={d} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "11px 0", borderTop: i > 0 ? "0.5px solid var(--hairline)" : "none" }}>
                  <span style={{ fontWeight: open ? 800 : 600, fontSize: 15, color: open ? "var(--text)" : "var(--text-2)", display: "inline-flex", alignItems: "center", gap: 8 }}>
                    {open && <span style={{ width: 7, height: 7, borderRadius: 99, background: "var(--green)", boxShadow: "0 0 8px var(--green)" }} />}{d}{open && <span style={{ fontSize: 11, fontWeight: 750, color: "var(--green-deep)", background: "rgba(0,185,100,.14)", padding: "1px 6px", borderRadius: 999 }}>Today</span>}
                  </span>
                  <span style={{ fontWeight: open ? 750 : 600, fontSize: 14.5, color: closed ? "var(--red)" : open ? "var(--text)" : "var(--text-2)" }}>{t}</span>
                </div>
              );
            })}
          </Glass>
          <div style={{ height: 130 }} />
        </div>
      </div>

      {/* FLOATING CTA */}
      <div style={{ position: "absolute", left: 0, right: 0, bottom: 0, padding: "14px 16px 26px", zIndex: 10 }}>
        <div style={{ position: "absolute", inset: 0, background: "linear-gradient(180deg, transparent, var(--page) 55%)", pointerEvents: "none" }} />
        <Glass level="thick" className="glass-edge" style={{ borderRadius: 22, padding: 10, display: "flex", alignItems: "center", gap: 12, position: "relative" }}>
          <div style={{ paddingLeft: 8 }}>
            <div style={{ fontSize: 11, fontWeight: 650, color: "var(--text-3)", textTransform: "uppercase", letterSpacing: ".4px" }}>From</div>
            <div style={{ fontWeight: 850, fontSize: 22, letterSpacing: "-1px", color: "var(--text)", lineHeight: .95 }}>${v.from}<span style={{ fontSize: 12, color: "var(--text-3)", fontWeight: 650 }}>/hr</span></div>
          </div>
          <button className="btn-primary" style={{ flex: 1, height: 54 }} onClick={() => { if (navigator.vibrate) navigator.vibrate(8); }}>
            Book a court <Icon name="chevR" size={18} stroke={2.6} />
          </button>
        </Glass>
      </div>
    </div>
  );
}

function SectionTitle({ icon, title }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "0 4px 11px" }}>
      <Icon name={icon} size={18} stroke={2} style={{ color: "var(--green)" }} />
      <span style={{ fontWeight: 800, fontSize: 18, letterSpacing: "-.5px", color: "var(--text)" }}>{title}</span>
    </div>
  );
}

Object.assign(window, { MapBackdrop, AppHeader, ListScreen, MapScreen, DetailScreen, RateCard, SectionTitle });
