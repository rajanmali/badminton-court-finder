// cards.jsx — Smash venue cards, filter bar, map pins, preview, states
// (depends on glass.jsx atoms via window)

// ─────────────────────────────────────────────────────────────
// Venue card — primary "glass standard" variant (V1)
// ─────────────────────────────────────────────────────────────
function VenueCard({ v, onOpen, delay = 0 }) {
  return (
    <Glass level="regular" onClick={onOpen} className="tap spring rise"
      style={{ borderRadius: "var(--r-card)", padding: 14, display: "flex", gap: 14, alignItems: "center", animationDelay: `${delay}ms` }}>
      <CourtTile initial={v.initial} dedicated={v.dedicated} size={58} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 7, marginBottom: 3 }}>
          <span style={{ fontWeight: 800, fontSize: 17, letterSpacing: "-.4px", color: "var(--text)", lineHeight: 1.1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{v.name.replace(" — Wetherill Park", "").replace(" — Kings Park", "")}</span>
          {v.dedicated && <span className="badge-ded" style={{ flex: "none" }}>Dedicated</span>}
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 5, color: "var(--text-2)", fontSize: 13.5, fontWeight: 550, marginBottom: 9 }}>
          <Icon name="pin" size={13} stroke={2} style={{ opacity: .8 }} />{v.suburb}
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 12, fontSize: 13, color: "var(--text-2)", fontWeight: 600 }}>
          <span style={{ display: "inline-flex", alignItems: "center", gap: 4 }}><Icon name="courts" size={14} stroke={1.8} />{v.courts}</span>
          <span style={{ display: "inline-flex", alignItems: "center", gap: 4 }}><Icon name="nav" size={13} stroke={1.8} />{v.dist} km</span>
        </div>
      </div>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 2, flex: "none" }}>
        <div style={{ fontSize: 11, color: "var(--text-3)", fontWeight: 650, letterSpacing: ".3px", textTransform: "uppercase" }}>From</div>
        <div style={{ fontSize: 22, fontWeight: 850, letterSpacing: "-1px", color: "var(--green)", lineHeight: .9 }}>${v.from}<span style={{ fontSize: 12, fontWeight: 650, color: "var(--text-3)" }}>/hr</span></div>
        <div style={{ marginTop: 6, color: "var(--text-3)" }}><Icon name="chevR" size={18} stroke={2.4} /></div>
      </div>
    </Glass>
  );
}

// ─────────────────────────────────────────────────────────────
// Filter bar (glass panel) — distance, price, dedicated toggle
// ─────────────────────────────────────────────────────────────
const DIST = [["any","Any"],["5","5 km"],["10","10 km"],["20","20 km"]];
const PRICE = [["any","Any"],["30","≤$30"],["35","≤$35"],["40","≤$40"]];

function FilterBar({ f, setF, compact = false }) {
  const Row = ({ label, items, val, set }) => (
    <div style={{ display: "flex", alignItems: "center", gap: 9 }}>
      <span style={{ width: 58, flex: "none", fontSize: 11, fontWeight: 750, letterSpacing: ".4px", textTransform: "uppercase", color: "var(--text-3)" }}>{label}</span>
      <div className="noscroll" style={{ display: "flex", gap: 7, overflowX: "auto" }}>
        {items.map(([id, lbl]) => <Chip key={id} on={val === id} onClick={() => set(id)}>{lbl}</Chip>)}
      </div>
    </div>
  );
  return (
    <Glass level="thick" className="glass-edge" style={{ borderRadius: 24, padding: "13px 14px", display: "flex", flexDirection: "column", gap: 11 }}>
      <Row label="Distance" items={DIST} val={f.dist} set={(v) => setF({ ...f, dist: v })} />
      <div style={{ height: 0.5, background: "var(--hairline)", margin: "1px 0" }} />
      <Row label="Max price" items={PRICE} val={f.price} set={(v) => setF({ ...f, price: v })} />
      <div style={{ height: 0.5, background: "var(--hairline)", margin: "1px 0" }} />
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", paddingRight: 2 }}>
        <span style={{ display: "inline-flex", alignItems: "center", gap: 7, fontWeight: 700, fontSize: 15, color: "var(--text)" }}>
          <Icon name="bolt" size={15} style={{ color: "var(--green)" }} /> Dedicated courts only
        </span>
        <Switch on={f.dedicated} onClick={() => setF({ ...f, dedicated: !f.dedicated })} />
      </div>
    </Glass>
  );
}

// ─────────────────────────────────────────────────────────────
// MAP PINS — 3 variants
// ─────────────────────────────────────────────────────────────
// V1 — teardrop glass pin with initial (default for dedicated/multisport)
function PinTeardrop({ v, selected, onClick }) {
  const c = v.dedicated ? "var(--green)" : "var(--court)";
  const cb = v.dedicated ? "var(--green-bright)" : "#878d94";
  return (
    <div onClick={onClick} className="tap spring" style={{ position: "relative", transform: selected ? "scale(1.18)" : "scale(1)", zIndex: selected ? 5 : 1 }}>
      <div style={{ width: 38, height: 38, borderRadius: "50% 50% 50% 4px", transform: "rotate(45deg)", background: `linear-gradient(145deg, ${cb}, ${c})`, boxShadow: selected ? `0 0 0 4px ${v.dedicated ? "rgba(0,185,100,.3)" : "rgba(107,113,120,.3)"}, 0 8px 18px rgba(0,0,0,.35)` : "0 4px 10px rgba(0,0,0,.32)", border: "1.5px solid rgba(255,255,255,.7)" }} />
      <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", paddingBottom: 4, fontWeight: 850, fontSize: 16, color: "#fff" }}>{v.initial}</div>
    </div>
  );
}
// V2 — price bubble pin
function PinPrice({ v, selected, onClick }) {
  const ded = v.dedicated;
  return (
    <div onClick={onClick} className="tap spring" style={{ transform: selected ? "scale(1.1)" : "scale(1)", zIndex: selected ? 5 : 1 }}>
      <Glass level="thick" className="glass-edge" style={{ borderRadius: 999, padding: "6px 11px 6px 7px", display: "flex", alignItems: "center", gap: 6, boxShadow: selected ? "0 8px 20px rgba(0,0,0,.3)" : "var(--glass-shadow)" }}>
        <span style={{ width: 18, height: 18, borderRadius: 6, flex: "none", background: ded ? "linear-gradient(145deg,var(--green-bright),var(--green))" : "linear-gradient(145deg,#3a4046,#1d2125)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, fontWeight: 850, color: "#fff" }}>{v.initial}</span>
        <span style={{ fontWeight: 850, fontSize: 14, letterSpacing: "-.4px", color: "var(--text)" }}>${v.from}</span>
      </Glass>
    </div>
  );
}
// V3 — dot + halo
function PinDot({ v, selected, onClick }) {
  const c = v.dedicated ? "var(--green)" : "var(--court)";
  return (
    <div onClick={onClick} className="tap spring" style={{ width: 26, height: 26, position: "relative", transform: selected ? "scale(1.3)" : "scale(1)", zIndex: selected ? 5 : 1 }}>
      <div style={{ position: "absolute", inset: 0, borderRadius: "50%", background: c, opacity: .22 }} />
      <div style={{ position: "absolute", inset: 6, borderRadius: "50%", background: c, border: "2px solid #fff", boxShadow: "0 3px 8px rgba(0,0,0,.3)" }} />
    </div>
  );
}
// cluster pin
function PinCluster({ count, onClick, style }) {
  return (
    <div onClick={onClick} className="tap spring" style={style}>
      <Glass level="thick" style={{ width: 46, height: 46, borderRadius: 999, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 6px 16px rgba(0,0,0,.3)" }}>
        <span style={{ fontWeight: 850, fontSize: 16, color: "var(--green)" }}>{count}</span>
      </Glass>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Map preview card (slides up)
// ─────────────────────────────────────────────────────────────
function PreviewCard({ v, onOpen, onClose }) {
  return (
    <Glass level="thick" className="glass-edge" style={{ borderRadius: 26, padding: 16, position: "relative" }}>
      <div onClick={onClose} className="tap" style={{ position: "absolute", top: 12, right: 12, width: 28, height: 28, borderRadius: 999, background: "var(--chip-bg)", display: "flex", alignItems: "center", justifyContent: "center", color: "var(--text-2)" }}><Icon name="x" size={16} stroke={2.4} /></div>
      <div style={{ display: "flex", gap: 14, alignItems: "center" }}>
        <CourtTile initial={v.initial} dedicated={v.dedicated} size={62} />
        <div style={{ flex: 1, minWidth: 0, paddingRight: 24 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 7, marginBottom: 3 }}>
            <span style={{ fontWeight: 800, fontSize: 17, letterSpacing: "-.4px", color: "var(--text)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{v.name.replace(" — Wetherill Park", "").replace(" — Kings Park", "")}</span>
            {v.dedicated && <span className="badge-ded" style={{ flex: "none" }}>Dedicated</span>}
          </div>
          <div style={{ color: "var(--text-2)", fontSize: 13.5, fontWeight: 550, marginBottom: 6, display: "flex", alignItems: "center", gap: 5 }}><Icon name="pin" size={13} stroke={2} />{v.suburb} · {v.dist} km</div>
          <div style={{ display: "flex", alignItems: "center", gap: 12, fontSize: 13, fontWeight: 650 }}>
            <span style={{ color: "var(--green)", fontWeight: 850, fontSize: 16, letterSpacing: "-.4px" }}>From ${v.from}<span style={{ fontSize: 11, color: "var(--text-3)" }}>/hr</span></span>
            <span style={{ color: "var(--text-2)", display: "inline-flex", alignItems: "center", gap: 4 }}><Icon name="courts" size={14} stroke={1.8} />{v.courts} courts</span>
          </div>
        </div>
      </div>
      <button className="btn-primary" onClick={onOpen} style={{ marginTop: 14, height: 50, fontSize: 16 }}>
        View venue <Icon name="chevR" size={17} stroke={2.6} />
      </button>
    </Glass>
  );
}

// ─────────────────────────────────────────────────────────────
// States: loading / empty / error
// ─────────────────────────────────────────────────────────────
function SkeletonCard() {
  return (
    <Glass level="regular" style={{ borderRadius: "var(--r-card)", padding: 14, display: "flex", gap: 14, alignItems: "center" }}>
      <div style={{ width: 58, height: 58, borderRadius: 15, position: "relative", overflow: "hidden", background: "var(--chip-bg)" }}><div className="skeleton" style={{ position: "absolute", inset: 0 }} /></div>
      <div style={{ flex: 1 }}>
        {[70, 40, 55].map((w, i) => <div key={i} style={{ height: i === 0 ? 14 : 10, width: `${w}%`, borderRadius: 6, background: "var(--chip-bg)", marginBottom: 8, position: "relative", overflow: "hidden" }}><div className="skeleton" style={{ position: "absolute", inset: 0 }} /></div>)}
      </div>
    </Glass>
  );
}
function LoadingState() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 14, padding: "4px 16px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, color: "var(--text-2)", fontSize: 14, fontWeight: 650, padding: "2px 4px 4px" }}>
        <div style={{ width: 16, height: 16, borderRadius: "50%", border: "2.4px solid var(--hairline-strong)", borderTopColor: "var(--green)", animation: "spin .8s linear infinite" }} /> Finding courts near you…
      </div>
      {[0, 1, 2, 3].map(i => <SkeletonCard key={i} />)}
    </div>
  );
}
function EmptyState({ onReset }) {
  return (
    <div style={{ padding: "30px 26px", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center" }}>
      <Glass level="regular" style={{ width: 96, height: 96, borderRadius: 28, position: "relative", overflow: "hidden", marginBottom: 22, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <Halftone color="var(--green)" size="md" from="50% 50%" opacity={.45} />
        <Icon name="shuttle" size={42} stroke={1.8} style={{ color: "var(--green)", position: "relative" }} />
      </Glass>
      <div style={{ fontWeight: 850, fontSize: 22, letterSpacing: "-.6px", color: "var(--text)", marginBottom: 8 }}>No venues match your filters</div>
      <div style={{ color: "var(--text-2)", fontSize: 15, lineHeight: 1.45, maxWidth: 260, marginBottom: 22 }}>Try widening the distance or raising the max price to see more courts.</div>
      <button className="btn-primary" onClick={onReset} style={{ width: "auto", padding: "0 26px", height: 50, fontSize: 16 }}>Reset filters</button>
    </div>
  );
}
function ErrorState({ onRetry }) {
  return (
    <div style={{ padding: "30px 26px", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center" }}>
      <Glass level="regular" style={{ width: 96, height: 96, borderRadius: 28, position: "relative", overflow: "hidden", marginBottom: 22, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <Halftone color="var(--red)" size="md" from="50% 50%" opacity={.4} />
        <Icon name="info" size={42} stroke={1.8} style={{ color: "var(--red)", position: "relative" }} />
      </Glass>
      <div style={{ fontWeight: 850, fontSize: 22, letterSpacing: "-.6px", color: "var(--text)", marginBottom: 8 }}>Couldn’t load courts</div>
      <div style={{ color: "var(--text-2)", fontSize: 15, lineHeight: 1.45, maxWidth: 260, marginBottom: 22 }}>Check your connection and try again. Your filters have been saved.</div>
      <button className="btn-primary" onClick={onRetry} style={{ width: "auto", padding: "0 24px", height: 50, fontSize: 16, background: "linear-gradient(180deg,#fff,#f0eee7)", color: "var(--text)", boxShadow: "0 8px 20px rgba(0,0,0,.12)" }}><Icon name="retry" size={18} stroke={2.2} /> Try again</button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Venue card — VARIATION 2 "Hero strip" (banner + glass info)
// ─────────────────────────────────────────────────────────────
function VenueCardHero({ v, onOpen }) {
  return (
    <Glass level="regular" onClick={onOpen} className="tap spring" style={{ borderRadius: "var(--r-card)", padding: 0, overflow: "hidden" }}>
      <div style={{ position: "relative", height: 92, overflow: "hidden", background: v.dedicated ? "linear-gradient(150deg, var(--green-bright), var(--green-deep))" : "linear-gradient(150deg, #3a4046, #1d2125)" }}>
        <CourtLines color="rgba(255,255,255,.28)" w={1.3} />
        <Halftone color="rgba(255,255,255,.55)" size="md" from="82% 16%" opacity={.4} />
        <div style={{ position: "absolute", right: -8, bottom: -34, fontWeight: 850, fontSize: 120, color: "rgba(255,255,255,.12)", lineHeight: .7, letterSpacing: "-6px" }}>{v.initial}</div>
        <div style={{ position: "absolute", top: 11, left: 12, display: "flex", gap: 7 }}>
          {v.dedicated && <span className="badge-ded">Dedicated</span>}
        </div>
        <Glass level="thick" style={{ position: "absolute", top: 10, right: 10, borderRadius: 999, padding: "5px 11px", fontWeight: 800, fontSize: 14, color: "var(--green)", letterSpacing: "-.3px" }}>From ${v.from}<span style={{ fontSize: 10, color: "var(--text-3)" }}>/hr</span></Glass>
      </div>
      <div style={{ padding: 14, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div style={{ minWidth: 0 }}>
          <div style={{ fontWeight: 800, fontSize: 17, letterSpacing: "-.4px", color: "var(--text)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{v.name.replace(" — Wetherill Park", "").replace(" — Kings Park", "")}</div>
          <div style={{ display: "flex", alignItems: "center", gap: 5, color: "var(--text-2)", fontSize: 13.5, fontWeight: 550, marginTop: 2 }}><Icon name="pin" size={13} stroke={2} />{v.suburb}</div>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 12, fontSize: 13, color: "var(--text-2)", fontWeight: 650, flex: "none" }}>
          <span style={{ display: "inline-flex", alignItems: "center", gap: 4 }}><Icon name="courts" size={14} stroke={1.8} />{v.courts}</span>
          <span style={{ display: "inline-flex", alignItems: "center", gap: 4 }}><Icon name="nav" size={13} stroke={1.8} />{v.dist} km</span>
        </div>
      </div>
    </Glass>
  );
}

// ─────────────────────────────────────────────────────────────
// Venue card — VARIATION 3 "Compact row" (accent bar, price-led)
// ─────────────────────────────────────────────────────────────
function VenueCardCompact({ v, onOpen }) {
  return (
    <Glass level="ultrathin" onClick={onOpen} className="tap spring" style={{ borderRadius: 18, padding: "12px 14px", display: "flex", alignItems: "center", gap: 13 }}>
      <div style={{ width: 4, height: 38, borderRadius: 99, flex: "none", background: v.dedicated ? "linear-gradient(var(--green-bright),var(--green-deep))" : "linear-gradient(#5b626a,#2a2e33)" }} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <span style={{ fontWeight: 750, fontSize: 15.5, letterSpacing: "-.3px", color: "var(--text)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{v.name.replace(" — Wetherill Park", "").replace(" — Kings Park", "")}</span>
          {v.dedicated && <span style={{ width: 6, height: 6, borderRadius: 99, background: "var(--green)", flex: "none" }} />}
        </div>
        <div style={{ color: "var(--text-2)", fontSize: 12.5, fontWeight: 550, marginTop: 1 }}>{v.suburb} · {v.dist} km · {v.courts} courts</div>
      </div>
      <div style={{ fontWeight: 850, fontSize: 18, letterSpacing: "-.6px", color: "var(--green)", flex: "none" }}>${v.from}<span style={{ fontSize: 10.5, color: "var(--text-3)", fontWeight: 650 }}>/hr</span></div>
      <Icon name="chevR" size={17} stroke={2.4} style={{ color: "var(--text-3)", flex: "none" }} />
    </Glass>
  );
}

Object.assign(window, { VenueCard, FilterBar, PinTeardrop, PinPrice, PinDot, PinCluster, PreviewCard, SkeletonCard, LoadingState, EmptyState, ErrorState, DIST, PRICE, VenueCardHero, VenueCardCompact });
