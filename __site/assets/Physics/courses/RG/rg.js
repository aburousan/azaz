/* Interactive widgets for the renormalisation-group course.
 *
 * Each widget mounts only if its container is on the page, so every part of
 * the course can load this one file. No libraries: plain canvas.
 *
 *   #rg-cutoff     Part 2  bare parameters move with the cutoff, physics doesn't
 *   #rg-decimate   Part 3  exact decimation of the 1D Ising chain
 *   #rg-ising      Part 4  2D Ising Monte Carlo, block-spun live
 *   #rg-wfflow     Part 6  the one-loop Wilson flow of phi^4 in d = 4 - eps
 *   #rg-running    Part 7  one-loop running couplings (QED, QCD, phi^4)
 */
(function () {
  "use strict";

  // ------------------------------------------------------------ shared bits
  function css(el, name) {
    return getComputedStyle(el).getPropertyValue(name).trim() || "#000";
  }

  function palette(el) {
    return {
      bg: css(el, "--rg-panel"), ink: css(el, "--rg-ink"), mute: css(el, "--rg-mute"),
      line: css(el, "--rg-line"), blue: css(el, "--rg-blue"), red: css(el, "--rg-red"),
      green: css(el, "--rg-green"), orange: css(el, "--rg-orange"),
      accent: css(el, "--rg-accent"),
    };
  }

  // A canvas that keeps its drawing buffer matched to its CSS size and the
  // device pixel ratio and calls `draw` whenever that or the theme changes.
  function hiDPI(canvas, aspect, draw) {
    const ctx = canvas.getContext("2d");
    function fit() {
      const w = canvas.clientWidth || 600;
      const h = Math.round(w * aspect);
      const r = window.devicePixelRatio || 1;
      canvas.style.height = h + "px";
      canvas.width = Math.round(w * r);
      canvas.height = Math.round(h * r);
      ctx.setTransform(r, 0, 0, r, 0, 0);
      draw(ctx, w, h);
    }
    new ResizeObserver(fit).observe(canvas);
    new MutationObserver(fit).observe(document.documentElement,
      { attributes: true, attributeFilter: ["class"] });
    fit();
    return { ctx, redraw: fit };
  }

  function el(tag, attrs, html) {
    const e = document.createElement(tag);
    if (attrs) for (const k in attrs) e.setAttribute(k, attrs[k]);
    if (html !== undefined) e.innerHTML = html;
    return e;
  }

  function slider(label, min, max, step, value, fmt) {
    const lab = el("label");
    const txt = el("span", null, label);
    const inp = el("input", { type: "range", min, max, step, value });
    const out = el("span", { class: "rgw-val" });
    const show = () => { out.textContent = fmt(parseFloat(inp.value)); };
    inp.addEventListener("input", show);
    show();
    lab.append(txt, inp, out);
    return { lab, inp, get value() { return parseFloat(inp.value); } };
  }

  // Simple axes on a plotting rectangle; returns the data->pixel maps.
  function axes(ctx, P, box, xr, yr, opt) {
    const { x0, y0, w, h } = box;
    const X = (x) => x0 + (x - xr[0]) / (xr[1] - xr[0]) * w;
    const Y = (y) => y0 + h - (y - yr[0]) / (yr[1] - yr[0]) * h;
    ctx.strokeStyle = P.line; ctx.lineWidth = 1;
    ctx.strokeRect(x0, y0, w, h);
    ctx.fillStyle = P.mute; ctx.font = "11px sans-serif";
    ctx.textAlign = "center"; ctx.textBaseline = "top";
    for (const t of opt.xt) {
      const px = opt.xlog ? x0 + (Math.log10(t) - xr[0]) / (xr[1] - xr[0]) * w : X(t);
      ctx.beginPath(); ctx.moveTo(px, y0 + h); ctx.lineTo(px, y0 + h + 4); ctx.stroke();
      ctx.fillText(opt.xfmt ? opt.xfmt(t) : String(t), px, y0 + h + 6);
    }
    ctx.textAlign = "right"; ctx.textBaseline = "middle";
    for (const t of opt.yt) {
      ctx.beginPath(); ctx.moveTo(x0 - 4, Y(t)); ctx.lineTo(x0, Y(t)); ctx.stroke();
      ctx.fillText(opt.yfmt ? opt.yfmt(t) : String(t), x0 - 6, Y(t));
    }
    ctx.fillStyle = P.ink; ctx.font = "12px sans-serif";
    ctx.textAlign = "center"; ctx.textBaseline = "bottom";
    ctx.fillText(opt.xlabel, x0 + w / 2, y0 + h + 34);
    ctx.save(); ctx.translate(x0 - 40, y0 + h / 2); ctx.rotate(-Math.PI / 2);
    ctx.fillText(opt.ylabel, 0, 0); ctx.restore();
    return { X, Y };
  }

  function dot(ctx, x, y, r, fill, stroke) {
    ctx.beginPath(); ctx.arc(x, y, r, 0, 2 * Math.PI);
    if (fill) { ctx.fillStyle = fill; ctx.fill(); }
    if (stroke) { ctx.strokeStyle = stroke; ctx.lineWidth = 1.8; ctx.stroke(); }
  }

  function arrowHead(ctx, x1, y1, x2, y2, size, color) {
    const a = Math.atan2(y2 - y1, x2 - x1);
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(x2, y2);
    ctx.lineTo(x2 - size * Math.cos(a - 0.4), y2 - size * Math.sin(a - 0.4));
    ctx.lineTo(x2 - size * Math.cos(a + 0.4), y2 - size * Math.sin(a + 0.4));
    ctx.closePath(); ctx.fill();
  }

  // Seeded RNG so a reset gives the same chain every time.
  function mulberry32(a) {
    return function () {
      a |= 0; a = (a + 0x6D2B79F5) | 0;
      let t = Math.imul(a ^ (a >>> 15), 1 | a);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }


  // ================================= 0. bare parameters chase the cutoff
  function mountCutoff(root) {
    const PI2 = Math.PI * Math.PI;
    root.classList.add("rgw");
    root.append(
      el("p", { class: "rgw-title" }, "Hold the physics fixed, move the cutoff"),
      el("p", { class: "rgw-sub" },
        "Pick a physical mass and coupling, the numbers an experiment measures. Then choose a " +
        "cutoff Λ. The bare parameters in the Lagrangian are whatever they must be for the " +
        "measured numbers to come out right. Drag Λ and watch them move while the physics stays put.")
    );
    const ctrl = el("div", { class: "rgw-controls" });
    const sL = slider("log₁₀(Λ / GeV) =", 2.5, 19.1, 0.01, 4, (v) => v.toFixed(2));
    const sLam = slider("λ =", 0.02, 1.5, 0.01, 0.1, (v) => v.toFixed(2));
    const sM = slider("m<sub>phys</sub> (GeV) =", 1, 1000, 1, 125, (v) => v.toFixed(0));
    ctrl.append(sL.lab, sLam.lab, sM.lab);
    root.append(ctrl);
    const cv = el("canvas");
    root.append(cv);
    const out = el("div", { class: "rgw-readout" });
    root.append(out);

    // One loop, hard cutoff (Part 2): m_phys^2 = m0^2 + lambda/(32 pi^2) [L^2 - m^2 ln(1+L^2/m^2)].
    // At this order the m^2 inside the bracket may be the physical one.
    const dm2 = (lam, m, L) => lam / (32 * PI2) * (L * L - m * m * Math.log1p(L * L / (m * m)));
    // Bare quartic from its one-loop running: d lambda0 / d ln Lambda = 3 lambda0^2/(16 pi^2).
    const lam0 = (lam, m, L) => {
      const den = 1 - 3 * lam / (16 * PI2) * Math.log(L / m);
      return den > 0 ? lam / den : Infinity;
    };

    const view = hiDPI(cv, 0.45, (ctx, w, h) => {
      const P = palette(root), lam = sLam.value, m = sM.value, L = Math.pow(10, sL.value);
      ctx.clearRect(0, 0, w, h);
      const half = (w - 30) / 2;
      const xr = [2.5, 19.1], xt = [3, 7, 11, 15, 19];

      // left: how many digits m0^2 must cancel, against log10 Lambda
      const boxA = { x0: 52, y0: 12, w: half - 60, h: h - 58 };
      const A = axes(ctx, P, boxA, xr, [0, 36], { xt, yt: [0, 10, 20, 30],
        xlabel: "log₁₀ Λ", ylabel: "log₁₀ |δm²/m²|" });
      ctx.save(); ctx.beginPath(); ctx.rect(boxA.x0, boxA.y0, boxA.w, boxA.h); ctx.clip();
      ctx.strokeStyle = P.red; ctx.lineWidth = 2.2; ctx.beginPath();
      for (let i = 0; i <= 300; i++) {
        const lg = xr[0] + (xr[1] - xr[0]) * i / 300, LL = Math.pow(10, lg);
        const v = Math.log10(Math.abs(dm2(lam, m, LL)) / (m * m) + 1e-300);
        i ? ctx.lineTo(A.X(lg), A.Y(Math.max(v, 0))) : ctx.moveTo(A.X(lg), A.Y(Math.max(v, 0)));
      }
      ctx.stroke(); ctx.restore();
      const vNow = Math.log10(Math.abs(dm2(lam, m, L)) / (m * m));
      dot(ctx, A.X(sL.value), A.Y(Math.max(vNow, 0)), 5, P.ink);

      // right: the bare quartic coupling
      const boxB = { x0: half + 76, y0: 12, w: half - 84, h: h - 58 };
      let ymax = 0;
      for (let i = 0; i <= 300; i++) {
        const v = lam0(lam, m, Math.pow(10, xr[0] + (xr[1] - xr[0]) * i / 300));
        if (isFinite(v)) ymax = Math.max(ymax, v);
      }
      ymax = Math.min(Math.max(ymax * 1.1, lam * 1.5), lam * 8);
      const yt = [0, ymax / 4, ymax / 2, 3 * ymax / 4].map((t) => +t.toPrecision(2));
      const B = axes(ctx, P, boxB, xr, [0, ymax], { xt, yt,
        xlabel: "log₁₀ Λ", ylabel: "bare λ₀(Λ)" });
      ctx.save(); ctx.beginPath(); ctx.rect(boxB.x0, boxB.y0, boxB.w, boxB.h); ctx.clip();
      ctx.strokeStyle = P.blue; ctx.lineWidth = 2.2; ctx.beginPath();
      let pen = false;
      for (let i = 0; i <= 400; i++) {
        const lg = xr[0] + (xr[1] - xr[0]) * i / 400, v = lam0(lam, m, Math.pow(10, lg));
        if (!isFinite(v)) { pen = false; continue; }
        pen ? ctx.lineTo(B.X(lg), B.Y(v)) : ctx.moveTo(B.X(lg), B.Y(v)); pen = true;
      }
      ctx.stroke();
      ctx.setLineDash([4, 4]); ctx.strokeStyle = P.mute; ctx.lineWidth = 1;
      ctx.beginPath(); ctx.moveTo(boxB.x0, B.Y(lam)); ctx.lineTo(boxB.x0 + boxB.w, B.Y(lam));
      ctx.stroke(); ctx.setLineDash([]); ctx.restore();
      const l0 = lam0(lam, m, L);
      if (isFinite(l0) && l0 < ymax) dot(ctx, B.X(sL.value), B.Y(l0), 5, P.ink);

      const d = dm2(lam, m, L), m02 = m * m - d;
      const digits = Math.log10(Math.abs(d) / (m * m));
      const pole = Math.log10(m) + 16 * PI2 / (3 * lam) / Math.LN10;
      out.innerHTML =
        `δm² = <b>${d.toExponential(3)}</b> GeV² &nbsp;·&nbsp; so the bare mass must be ` +
        `m₀² = m² − δm² = <b>${m02.toExponential(3)}</b> GeV²` +
        (digits > 1 ? ` &nbsp;(cancelling ${digits.toFixed(0)} digits)` : "") + `<br>` +
        `Bare coupling needed: λ₀ = <b>${isFinite(l0) ? l0.toFixed(4) : "∞"}</b> ` +
        `(physical λ = ${lam.toFixed(2)}). λ₀ blows up at log₁₀ Λ ≈ ${pole.toFixed(1)}, the Landau pole ` +
        `of Part 7.`;
    });
    for (const s of [sL, sLam, sM]) s.inp.addEventListener("input", () => view.redraw());
  }

  // ======================================================= 1. decimation
  function mountDecimate(root) {
    const R = (k) => Math.atanh(Math.pow(Math.tanh(k), 2));
    const xi = (k) => -1 / Math.log(Math.tanh(k));   // in units of the current spacing
    const N0 = 64;

    root.classList.add("rgw");
    root.append(
      el("p", { class: "rgw-title" }, "Decimate the Ising chain yourself"),
      el("p", { class: "rgw-sub" },
        "The chain below is an exact sample at coupling K. Each click throws away every " +
        "second spin. The spins that survive are an exact sample of a chain at the new " +
        "coupling K′ = artanh(tanh²K), with twice the spacing.")
    );
    const ctrl = el("div", { class: "rgw-controls" });
    const sK = slider("starting K =", 0.1, 3.0, 0.01, 1.6, (v) => v.toFixed(2));
    const bStep = el("button", { class: "primary" }, "Coarse-grain once");
    const bReset = el("button", null, "Reset");
    ctrl.append(sK.lab, bStep, bReset);
    root.append(ctrl);

    const chainCanvas = el("canvas");
    root.append(chainCanvas);
    const row = el("div", { class: "rgw-row" });
    row.style.marginTop = "10px";
    const cob = el("canvas");
    const tw = el("div", { class: "rgw-tablewrap" });
    row.append(cob, tw);
    root.append(row);
    root.append(el("p", { class: "rgw-note" },
      "The last column is the whole point. Measured in its own lattice units the " +
      "correlation length halves at every step, but in units of the <i>original</i> " +
      "spacing it never changes. Coarse-graining throws away detail, never physics."));

    let spins = [], hist = [];
    function sample(K) {
      // An exact draw: in 1D, neighbouring spins agree with probability (1 + tanh K)/2.
      const rnd = mulberry32(12345);
      const p = (1 + Math.tanh(K)) / 2;
      const s = [rnd() < 0.5 ? 1 : -1];
      for (let i = 1; i < N0; i++) s.push(rnd() < p ? s[i - 1] : -s[i - 1]);
      return s;
    }
    function reset() {
      spins = sample(sK.value);
      hist = [sK.value];
      draw();
    }
    function step() {
      if (spins.length < 3) return;
      spins = spins.filter((_, i) => i % 2 === 0);
      hist.push(R(hist[hist.length - 1]));
      draw();
    }

    const chain = hiDPI(chainCanvas, 0.16, (ctx, w, h) => {
      const P = palette(root);
      ctx.clearRect(0, 0, w, h);
      const n = hist.length - 1;
      const spacing = (w - 30) / N0;
      const a = spacing * Math.pow(2, n);
      ctx.strokeStyle = P.blue; ctx.lineWidth = Math.min(1 + n, 4);
      ctx.beginPath(); ctx.moveTo(15, h / 2); ctx.lineTo(15 + a * (spins.length - 1), h / 2);
      ctx.stroke();
      for (let i = 0; i < spins.length; i++) {
        const x = 15 + i * a, up = spins[i] > 0;
        const c = up ? P.red : P.blue, L = h * 0.32;
        ctx.strokeStyle = c; ctx.lineWidth = 2;
        ctx.beginPath(); ctx.moveTo(x, h / 2 + (up ? L : -L) / 2);
        ctx.lineTo(x, h / 2 - (up ? L : -L) / 2); ctx.stroke();
        arrowHead(ctx, x, h / 2 + (up ? L : -L) / 2, x, h / 2 - (up ? L : -L) / 2, 6, c);
      }
      ctx.fillStyle = P.mute; ctx.font = "11px sans-serif"; ctx.textAlign = "left";
      ctx.textBaseline = "top";
      ctx.fillText(`${spins.length} spins, spacing ${Math.pow(2, n)}a`, 6, 3);
    });

    const cobweb = hiDPI(cob, 0.82, (ctx, w, h) => {
      const P = palette(root);
      ctx.clearRect(0, 0, w, h);
      const K0 = hist[0], top = Math.max(1.0, Math.ceil(K0 * 1.1 * 2) / 2);
      const box = { x0: 48, y0: 12, w: w - 62, h: h - 58 };
      const tk = []; for (let t = 0; t <= top + 1e-9; t += top > 2 ? 1 : 0.5) tk.push(+t.toFixed(1));
      const { X, Y } = axes(ctx, P, box, [0, top], [0, top],
        { xt: tk, yt: tk, xlabel: "K", ylabel: "K′" });
      ctx.setLineDash([4, 4]); ctx.strokeStyle = P.mute; ctx.lineWidth = 1;
      ctx.beginPath(); ctx.moveTo(X(0), Y(0)); ctx.lineTo(X(top), Y(top)); ctx.stroke();
      ctx.setLineDash([]);
      ctx.strokeStyle = P.blue; ctx.lineWidth = 2; ctx.beginPath();
      for (let i = 0; i <= 200; i++) {
        const k = top * i / 200, y = Math.min(R(k), top);
        i ? ctx.lineTo(X(k), Y(y)) : ctx.moveTo(X(k), Y(y));
      }
      ctx.stroke();
      ctx.strokeStyle = P.red; ctx.lineWidth = 1.4; ctx.beginPath();
      ctx.moveTo(X(hist[0]), Y(hist[0]));
      for (let i = 1; i < hist.length; i++) {
        ctx.lineTo(X(hist[i - 1]), Y(hist[i]));
        ctx.lineTo(X(hist[i]), Y(hist[i]));
      }
      ctx.stroke();
      for (const k of hist) dot(ctx, X(k), Y(k), 3, P.red);
      dot(ctx, X(0), Y(0), 5, P.ink);
    });

    function draw() {
      chain.redraw(); cobweb.redraw();
      let rows = "<table class='rgw-table'><tr><th>step</th><th>spacing</th>" +
        "<th>K</th><th>ξ / spacing</th><th>ξ / a</th></tr>";
      hist.forEach((k, i) => {
        const x = xi(k), b = Math.pow(2, i);
        const xs = isFinite(x) ? x.toFixed(3) : "∞";
        const xa = isFinite(x) ? (x * b).toFixed(3) : "∞";
        rows += `<tr class="${i === hist.length - 1 ? "rgw-hi" : ""}"><td>${i}</td>` +
          `<td>${b}a</td><td>${k.toExponential(3)}</td><td>${xs}</td><td>${xa}</td></tr>`;
      });
      tw.innerHTML = rows + "</table>";
      tw.scrollTop = tw.scrollHeight;
    }

    sK.inp.addEventListener("change", reset);
    bStep.addEventListener("click", step);
    bReset.addEventListener("click", reset);
    reset();
  }

  // ============================================ 2. 2D Ising, block-spun live
  function mountIsing(root) {
    const L = 128, KC = 0.5 * Math.log(1 + Math.SQRT2);
    root.classList.add("rgw");
    root.style.setProperty("--w", "940px");
    root.append(
      el("p", { class: "rgw-title" }, "Block-spin a live 2D Ising magnet"),
      el("p", { class: "rgw-sub" },
        "Left: a 128×128 Ising model being simulated right now (Wolff cluster moves). " +
        "Then three rounds of 2×2 majority-rule blocking. Move the temperature and watch " +
        "the blocked pictures. Only at T = T<sub>c</sub> do they keep looking like the original.")
    );
    const ctrl = el("div", { class: "rgw-controls" });
    const sT = slider("T / T<sub>c</sub> =", 0.70, 1.40, 0.005, 1.0, (v) => v.toFixed(3));
    const bRun = el("button", { class: "primary" }, "Pause");
    const bTc = el("button", null, "Snap to T<sub>c</sub>");
    ctrl.append(sT.lab, bRun, bTc);
    root.append(ctrl);
    const cv = el("canvas");
    root.append(cv);
    const out = el("div", { class: "rgw-readout" });
    root.append(out);
    root.append(el("p", { class: "rgw-note" },
      "Give it a second or two to settle after you move the temperature: the simulation has to find its new equilibrium before the picture means anything. Below T<sub>c</sub> the blocks go uniform: the flow runs to the ordered, zero-temperature " +
      "fixed point. Above T<sub>c</sub> they go to salt-and-pepper noise: the infinite-temperature " +
      "fixed point. At T<sub>c</sub> neither wins and the picture is self-similar. That " +
      "self-similarity is the fixed point. Exact T<sub>c</sub> = 2J / ln(1+√2) ≈ 2.269 J/k<sub>B</sub>."));

    const s = new Int8Array(L * L);
    const rnd = mulberry32(7);
    for (let i = 0; i < L * L; i++) s[i] = rnd() < 0.5 ? 1 : -1;
    const stack = new Int32Array(L * L);

    function wolffMove(K) {
      const padd = 1 - Math.exp(-2 * K);
      const i0 = (rnd() * L * L) | 0, sign = s[i0];
      let top = 0; stack[top++] = i0; s[i0] = -sign;
      let size = 1;
      while (top) {
        const i = stack[--top], x = i % L, y = (i / L) | 0;
        const nb = [y * L + (x + 1) % L, y * L + (x + L - 1) % L,
                    ((y + 1) % L) * L + x, ((y + L - 1) % L) * L + x];
        for (const j of nb) {
          if (s[j] === sign && rnd() < padd) { s[j] = -sign; stack[top++] = j; size++; }
        }
      }
      return size;
    }

    function block(a, n) {
      const m = n >> 1, b = new Int8Array(m * m);
      for (let y = 0; y < m; y++) for (let x = 0; x < m; x++) {
        const t = a[2 * y * n + 2 * x] + a[2 * y * n + 2 * x + 1] +
                  a[(2 * y + 1) * n + 2 * x] + a[(2 * y + 1) * n + 2 * x + 1];
        // ties broken by a fixed checkerboard, so the rule favours neither sign
        b[y * m + x] = t > 0 ? 1 : t < 0 ? -1 : ((x + y) % 2 === 0 ? 1 : -1);
      }
      return b;
    }

    let running = true;
    // A random start is an infinite-temperature state, which is far from
    // equilibrium at K_c: the sampler needs a good number of cluster flips
    // before the picture means anything. Burn in once before the first paint.
    let burnedIn = false;
    const off = document.createElement("canvas");
    const view = hiDPI(cv, 0.29, (ctx, w, h) => paint(ctx, w, h));

    function paint(ctx, w, h) {
      const P = palette(root);
      ctx.clearRect(0, 0, w, h);
      const gap = 10, side = Math.min((w - 3 * gap) / 4, h - 22);
      let a = s, n = L;
      const dark = document.documentElement.classList.contains("dark-mode");
      const up = dark ? [236, 230, 216] : [28, 28, 28];
      const dn = dark ? [42, 39, 34] : [244, 244, 244];
      for (let k = 0; k < 4; k++) {
        off.width = n; off.height = n;
        const octx = off.getContext("2d"), img = octx.createImageData(n, n);
        for (let i = 0; i < n * n; i++) {
          const c = a[i] > 0 ? up : dn;
          img.data[4 * i] = c[0]; img.data[4 * i + 1] = c[1];
          img.data[4 * i + 2] = c[2]; img.data[4 * i + 3] = 255;
        }
        octx.putImageData(img, 0, 0);
        const x0 = k * (side + gap);
        ctx.imageSmoothingEnabled = false;
        ctx.drawImage(off, x0, 0, side, side);
        ctx.strokeStyle = P.line; ctx.strokeRect(x0 + 0.5, 0.5, side - 1, side - 1);
        ctx.fillStyle = P.mute; ctx.font = "11px sans-serif"; ctx.textAlign = "center";
        ctx.textBaseline = "top";
        ctx.fillText(k === 0 ? `original ${n}×${n}` : `blocked ${k}× → ${n}×${n}`,
                     x0 + side / 2, side + 5);
        if (k < 3) { a = block(a, n); n >>= 1; }
      }
    }

    let frames = 0;
    function tick() {
      if (running) {
        const K = KC / sT.value;
        if (!burnedIn) {
          let done = 0;
          while (done < 400000) done += wolffMove(K);   // settle before showing anything
          burnedIn = true;
        }
        // spend roughly a fixed number of spin flips per frame, whatever the cluster size
        let flipped = 0;
        while (flipped < 6000) flipped += wolffMove(K);
        frames++;
        if (frames % 2 === 0) {
          view.redraw();
          let m = 0; for (let i = 0; i < L * L; i++) m += s[i];
          out.innerHTML = `K = J/k<sub>B</sub>T = <b>${K.toFixed(4)}</b> &nbsp; ` +
            `(K<sub>c</sub> = ${KC.toFixed(4)}) &nbsp;·&nbsp; magnetisation |m| = ` +
            `<b>${Math.abs(m / (L * L)).toFixed(3)}</b>`;
        }
      }
      if (root.isConnected) requestAnimationFrame(tick);
    }
    bRun.addEventListener("click", () => {
      running = !running; bRun.textContent = running ? "Pause" : "Run";
    });
    bTc.addEventListener("click", () => {
      sT.inp.value = 1.0; sT.inp.dispatchEvent(new Event("input"));
    });
    // Don't burn a laptop's battery on an off-screen simulation. Only resume
    // what we paused ourselves, never something the reader paused.
    let autoPaused = false;
    new IntersectionObserver((es) => {
      for (const e of es) {
        if (!e.isIntersecting && running) { bRun.click(); autoPaused = true; }
        else if (e.isIntersecting && autoPaused) { autoPaused = false; if (!running) bRun.click(); }
      }
    }).observe(root);
    bRun.addEventListener("click", (ev) => { if (ev.isTrusted) autoPaused = false; });
    requestAnimationFrame(tick);
  }

  // ================================= 3. one-loop Wilson flow, d = 4 - eps
  function mountWF(root) {
    const Kd = 1 / (8 * Math.PI * Math.PI);
    const RX = [-0.35, 0.35], UY = [0, 95];
    let eps = 1.0, trajs = [];

    const f = (r, u) => [2 * r + Kd * u / (2 * (1 + r)),
                         eps * u - 1.5 * Kd * u * u / ((1 + r) * (1 + r))];

    function rk4(r, u, h) {
      const k1 = f(r, u);
      const k2 = f(r + h * k1[0] / 2, u + h * k1[1] / 2);
      const k3 = f(r + h * k2[0] / 2, u + h * k2[1] / 2);
      const k4 = f(r + h * k3[0], u + h * k3[1]);
      return [r + h / 6 * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0]),
              u + h / 6 * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1])];
    }
    function integrate(r, u, h, n) {
      const pts = [[r, u]];
      for (let i = 0; i < n; i++) {
        [r, u] = rk4(r, u, h);
        if (!(r > -0.9) || Math.abs(r) > 0.6 || u < -1 || u > 140) break;
        pts.push([r, u]);
      }
      return pts;
    }

    // The fixed point of the full one-loop flow (not just its leading-eps form),
    // by Newton's method started from the leading-order answer.
    function fixedPoint() {
      if (eps <= 0) return null;
      let r = -eps / 6, u = 16 * Math.PI * Math.PI * eps / 3;
      for (let it = 0; it < 60; it++) {
        const [a, b] = f(r, u), d = 1e-7;
        const [ar, br] = f(r + d, u), [au, bu] = f(r, u + d);
        const J = [[(ar - a) / d, (au - a) / d], [(br - b) / d, (bu - b) / d]];
        const det = J[0][0] * J[1][1] - J[0][1] * J[1][0];
        r -= (J[1][1] * a - J[0][1] * b) / det;
        u -= (-J[1][0] * a + J[0][0] * b) / det;
      }
      return [r, u];
    }
    function eigen(r, u) {
      const d = 1e-7, [a, b] = f(r, u);
      const [ar, br] = f(r + d, u), [au, bu] = f(r, u + d);
      const A = (ar - a) / d, B = (au - a) / d, C = (br - b) / d, D = (bu - b) / d;
      const tr = A + D, det = A * D - B * C, disc = Math.sqrt(tr * tr / 4 - det);
      return [tr / 2 + disc, tr / 2 - disc];
    }

    root.classList.add("rgw");
    root.append(
      el("p", { class: "rgw-title" }, "The Wilson-Fisher fixed point, live"),
      el("p", { class: "rgw-sub" },
        "This plots the one-loop flow of φ⁴ theory from Part 6, with arrows pointing towards " +
        "the infrared. <b>Click anywhere</b> to start a theory there and watch it flow. Then drag " +
        "ε = 4 − d from 0 upwards and see a second fixed point split off the Gaussian one.")
    );
    const ctrl = el("div", { class: "rgw-controls" });
    const sE = slider("ε = 4 − d =", 0, 1.5, 0.01, 1.0, (v) => v.toFixed(2));
    const bClr = el("button", null, "Clear trajectories");
    const bFan = el("button", null, "Draw a fan");
    ctrl.append(sE.lab, bFan, bClr);
    root.append(ctrl);
    const cv = el("canvas");
    root.append(cv);
    const out = el("div", { class: "rgw-readout" });
    root.append(out);

    let map = null;
    const view = hiDPI(cv, 0.62, (ctx, w, h) => {
      const P = palette(root);
      ctx.clearRect(0, 0, w, h);
      const box = { x0: 56, y0: 12, w: w - 72, h: h - 58 };
      map = { box, ...axes(ctx, P, box, RX, UY, {
        xt: [-0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3], yt: [0, 20, 40, 60, 80],
        xlabel: "r̃ = m² / Λ²", ylabel: "ũ = λ Λ^(d−4)",
        xfmt: (t) => t.toFixed(1) }) };
      const { X, Y } = map;

      // faint direction field
      ctx.strokeStyle = P.line; ctx.lineWidth = 1;
      for (let i = 0; i <= 16; i++) for (let j = 0; j <= 11; j++) {
        const r = RX[0] + (RX[1] - RX[0]) * (i + 0.5) / 17;
        const u = UY[0] + (UY[1] - UY[0]) * (j + 0.5) / 12;
        const [dr, du] = f(r, u);
        const px = dr / (RX[1] - RX[0]) * box.w, py = -du / (UY[1] - UY[0]) * box.h;
        const n = Math.hypot(px, py) || 1, l = 9;
        const x1 = X(r), y1 = Y(u), x2 = x1 + l * px / n, y2 = y1 + l * py / n;
        ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke();
        arrowHead(ctx, x1, y1, x2, y2, 4, P.line);
      }

      ctx.save();
      ctx.beginPath(); ctx.rect(box.x0, box.y0, box.w, box.h); ctx.clip();

      // the critical surface: run the flow backwards out of the fixed point
      const fp = fixedPoint();
      if (fp) {
        ctx.strokeStyle = P.blue; ctx.lineWidth = 3;
        const keepEps = eps;
        for (const sgn of [1, -1]) {
          let r = fp[0] + sgn * 1e-5, u = fp[1] + sgn * 3e-4;
          ctx.beginPath(); ctx.moveTo(X(r), Y(u));
          for (let i = 0; i < 4000; i++) {
            [r, u] = rk4(r, u, -0.004);
            if (!(r > -0.9) || Math.abs(r) > 0.6 || u < 0 || u > 140) break;
            ctx.lineTo(X(r), Y(u));
          }
          ctx.stroke();
        }
        eps = keepEps;
      }

      for (const t of trajs) {
        const pts = integrate(t[0], t[1], 0.004, 3000);
        ctx.strokeStyle = P.orange; ctx.lineWidth = 1.6; ctx.beginPath();
        pts.forEach(([r, u], i) => i ? ctx.lineTo(X(r), Y(u)) : ctx.moveTo(X(r), Y(u)));
        ctx.stroke();
        dot(ctx, X(t[0]), Y(t[1]), 3.5, P.orange);
        const k = Math.min(pts.length - 2, 120);
        if (k > 2) arrowHead(ctx, X(pts[k - 2][0]), Y(pts[k - 2][1]),
                             X(pts[k][0]), Y(pts[k][1]), 8, P.orange);
      }
      ctx.restore();

      dot(ctx, X(0), Y(0), 6, P.ink);
      ctx.fillStyle = P.ink; ctx.font = "12px sans-serif"; ctx.textAlign = "left";
      ctx.textBaseline = "bottom"; ctx.fillText("Gaussian", X(0) + 8, Y(0) - 4);
      if (fp && fp[1] < UY[1]) {
        dot(ctx, X(fp[0]), Y(fp[1]), 7, P.red);
        ctx.fillStyle = P.red; ctx.fillText("Wilson-Fisher", X(fp[0]) + 10, Y(fp[1]) - 6);
      }

      let html = "";
      if (fp) {
        const [e1, e2] = eigen(fp[0], fp[1]);
        const yt1 = 2 - eps / 3, nu1 = 0.5 + eps / 12;
        html += `<b>The ε expansion (trust this):</b> ũ* = 16π²ε/3 = <b>${(16 * Math.PI * Math.PI * eps / 3).toFixed(2)}</b>, ` +
          `r̃* = −ε/6 = <b>${(-eps / 6).toFixed(4)}</b>, y<sub>t</sub> = 2 − ε/3 = <b>${yt1.toFixed(4)}</b>, ` +
          `so ν = ½ + ε/12 = <b>${nu1.toFixed(4)}</b>` +
          (eps >= 0.99 && eps <= 1.01 ? ` &nbsp;(true 3D Ising: 0.6300)` : ``) + `.<br>`;
        html += `<span style="opacity:.75">The red dot is the exact zero of these truncated one-loop equations: ` +
          `r̃* = ${fp[0].toFixed(4)}, ũ* = ${fp[1].toFixed(2)}, eigenvalues ${e1.toFixed(3)} and ${e2.toFixed(3)}. ` +
          `It agrees with the line above as ε → 0 and drifts away at O(ε²), where one loop has no right to be accurate, ` +
          `so don't read physics into the difference.</span>`;
      } else {
        html = "At ε = 0 (four dimensions) the only fixed point is the Gaussian one. " +
          "The quartic coupling creeps to zero in the infrared, logarithmically slowly.";
      }
      out.innerHTML = html;
    });

    cv.addEventListener("click", (ev) => {
      if (!map) return;
      const rect = cv.getBoundingClientRect();
      const px = ev.clientX - rect.left, py = ev.clientY - rect.top, b = map.box;
      if (px < b.x0 || px > b.x0 + b.w || py < b.y0 || py > b.y0 + b.h) return;
      const r = RX[0] + (px - b.x0) / b.w * (RX[1] - RX[0]);
      const u = UY[0] + (b.y0 + b.h - py) / b.h * (UY[1] - UY[0]);
      trajs.push([r, u]); view.redraw();
    });
    sE.inp.addEventListener("input", () => { eps = sE.value; view.redraw(); });
    bClr.addEventListener("click", () => { trajs = []; view.redraw(); });
    bFan.addEventListener("click", () => {
      trajs = [];
      for (const u of [15, 35, 55, 75, 90]) for (const r of [-0.30, -0.22, -0.14, 0.0, 0.15])
        trajs.push([r, u]);
      view.redraw();
    });
  }

  // =============================================== 4. running couplings
  function mountRunning(root) {
    root.classList.add("rgw");
    root.append(
      el("p", { class: "rgw-title" }, "Run a coupling"),
      el("p", { class: "rgw-sub" },
        "Every one-loop coupling here obeys dg/d ln μ = b g², which integrates to " +
        "g(μ) = g₀ / (1 − b g₀ ln(μ/μ₀)). The sign of b decides everything. Positive b means the " +
        "coupling grows with energy and blows up at a Landau pole. Negative b means asymptotic " +
        "freedom, with a blow-up in the infrared instead.")
    );
    const ctrl = el("div", { class: "rgw-controls" });
    const sel = el("select");
    sel.innerHTML = "<option value='qed'>QED: α, one loop</option>" +
      "<option value='qcd' selected>QCD: α_s, one loop</option>" +
      "<option value='phi4'>φ⁴ in d = 4: λ, one loop</option>";
    const selLab = el("label", null, "theory"); selLab.append(sel);
    const sN = slider("flavours n<sub>f</sub> =", 0, 20, 1, 5, (v) => String(v));
    const sG = slider("coupling at μ₀", 0.01, 0.6, 0.001, 0.118, (v) => v.toFixed(3));
    ctrl.append(selLab, sN.lab, sG.lab);
    root.append(ctrl);
    const cv = el("canvas");
    root.append(cv);
    const out = el("div", { class: "rgw-readout" });
    root.append(out);

    function setup() {
      const t = sel.value;
      if (t === "qed") { sN.inp.max = 9; sN.inp.value = 1; sG.inp.value = 1 / 137.036; }
      if (t === "qcd") { sN.inp.max = 20; sN.inp.value = 5; sG.inp.value = 0.118; }
      if (t === "phi4") { sN.inp.max = 0; sN.inp.value = 0; sG.inp.value = 0.5; }
      sN.lab.style.display = t === "phi4" ? "none" : "";
      sN.inp.dispatchEvent(new Event("input")); sG.inp.dispatchEvent(new Event("input"));
      view.redraw();
    }
    function params() {
      const t = sel.value, nf = sN.value, g0 = sG.value;
      if (t === "qed") return { b: 2 * nf / (3 * Math.PI), g0, mu0: 0.000511,
        name: "α", mu0lab: "m_e", xr: [-4, 20] };
      if (t === "qcd") return { b: -(11 - 2 * nf / 3) / (2 * Math.PI), g0, mu0: 91.1876,
        name: "α_s", mu0lab: "m_Z", xr: [-2, 6] };
      return { b: 3 / (16 * Math.PI * Math.PI), g0, mu0: 1.0, name: "λ",
        mu0lab: "μ₀ = 1", xr: [-3, 4] };
    }

    const view = hiDPI(cv, 0.52, (ctx, w, h) => {
      const P = palette(root), p = params();
      ctx.clearRect(0, 0, w, h);
      const box = { x0: 60, y0: 12, w: w - 76, h: h - 58 };
      const x0 = Math.log10(p.mu0);
      const xr = [x0 + p.xr[0], x0 + p.xr[1]];
      const g = (lg) => {
        const den = 1 - p.b * p.g0 * Math.log(Math.pow(10, lg) / p.mu0);
        return den > 0 ? p.g0 / den : Infinity;
      };
      let ymax = 0;
      for (let i = 0; i <= 400; i++) {
        const v = g(xr[0] + (xr[1] - xr[0]) * i / 400);
        if (isFinite(v)) ymax = Math.max(ymax, v);
      }
      ymax = Math.min(ymax * 1.08, Math.max(p.g0 * 6, 0.05));
      const yt = []; const st = niceStep(ymax / 5);
      for (let t = 0; t <= ymax + 1e-12; t += st) yt.push(+t.toPrecision(3));
      const xt = []; for (let t = Math.ceil(xr[0]); t <= xr[1]; t += (xr[1] - xr[0] > 12 ? 4 : 1)) xt.push(t);
      const { X, Y } = axes(ctx, P, box, xr, [0, ymax], {
        xt, yt, xlabel: "log₁₀ (μ / GeV)", ylabel: p.name,
        xfmt: (t) => String(t) });

      ctx.save(); ctx.beginPath(); ctx.rect(box.x0, box.y0, box.w, box.h); ctx.clip();
      ctx.strokeStyle = p.b > 0 ? P.blue : p.b < 0 ? P.red : P.ink;
      ctx.lineWidth = 2.4; ctx.beginPath();
      let pen = false;
      for (let i = 0; i <= 800; i++) {
        const lg = xr[0] + (xr[1] - xr[0]) * i / 800, v = g(lg);
        if (!isFinite(v) || v > ymax * 3) { pen = false; continue; }
        pen ? ctx.lineTo(X(lg), Y(v)) : ctx.moveTo(X(lg), Y(v)); pen = true;
      }
      ctx.stroke();
      const pole = p.b !== 0 ? Math.log10(p.mu0) + 1 / (p.b * p.g0) / Math.LN10 : NaN;
      if (isFinite(pole) && pole > xr[0] && pole < xr[1]) {
        ctx.setLineDash([5, 4]); ctx.strokeStyle = P.mute; ctx.lineWidth = 1.2;
        ctx.beginPath(); ctx.moveTo(X(pole), box.y0); ctx.lineTo(X(pole), box.y0 + box.h);
        ctx.stroke(); ctx.setLineDash([]);
      }
      ctx.restore();
      dot(ctx, X(Math.log10(p.mu0)), Y(p.g0), 4.5, P.ink);

      const muPole = Math.pow(10, pole);
      let html = `b = <b>${p.b.toExponential(4)}</b> &nbsp;·&nbsp; `;
      if (p.b > 0) html += `coupling <b>grows</b> with μ; one-loop Landau pole at ` +
        `μ ≈ <b>${fmtE(muPole)} GeV</b> (log₁₀ = ${pole.toFixed(1)}).`;
      else if (p.b < 0) html += `coupling <b>shrinks</b> with μ: asymptotic freedom. It blows up ` +
        `in the infrared at μ ≈ <b>${fmtE(muPole)} GeV</b> (the one-loop Λ).`;
      else html += `b = 0: the coupling doesn't run at one loop.`;
      if (sel.value === "qcd") {
        const b0 = 11 - 2 * sN.value / 3;
        html += `<br>b₀ = 11 − 2n<sub>f</sub>/3 = <b>${b0.toFixed(3)}</b>` +
          (b0 <= 0 ? ". With 17 or more flavours, asymptotic freedom is lost." : "");
      }
      if (sel.value === "qed")
        html += "<br>With only the electron in the loop, α(m<sub>Z</sub>)⁻¹ comes out near 134.5. " +
          "The measured 127.95 needs every charged particle, quarks included.";
      out.innerHTML = html;
    });

    function niceStep(x) {
      const e = Math.pow(10, Math.floor(Math.log10(x))), m = x / e;
      return (m < 1.5 ? 1 : m < 3.5 ? 2 : m < 7.5 ? 5 : 10) * e;
    }
    function fmtE(v) {
      if (!isFinite(v)) return "∞";
      const e = Math.floor(Math.log10(v));
      return Math.abs(e) < 4 ? v.toPrecision(3) : `${(v / Math.pow(10, e)).toFixed(2)}×10^${e}`;
    }

    sel.addEventListener("change", setup);
    sN.inp.addEventListener("input", () => view.redraw());
    sG.inp.addEventListener("input", () => view.redraw());
    setup();
  }

  // ------------------------------------------------------------ mount
  function boot() {
    const table = { "rg-cutoff": mountCutoff, "rg-decimate": mountDecimate, "rg-ising": mountIsing,
                    "rg-wfflow": mountWF, "rg-running": mountRunning };
    for (const id in table) {
      const node = document.getElementById(id);
      if (node && !node.dataset.mounted) { node.dataset.mounted = "1"; table[id](node); }
    }
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();
})();
