// oneko.js: Modified for custom Orange Cat AI (No Text, Slightly Bigger, Roaming)

(function oneko() {
  const isReducedMotion =
    window.matchMedia(`(prefers-reduced-motion: reduce)`).matches === true;

  if (isReducedMotion) return;

  const nekoEl = document.createElement("div");
  let glassesEl = null;
  let wearingGlasses = false;
  
  let nekoPosX = 32;
  let nekoPosY = 32;
  let mousePosX = window.innerWidth / 2;
  let mousePosY = window.innerHeight / 2;
  let targetX = mousePosX;
  let targetY = mousePosY;
  let frameCount = 0;
  let idleTime = 0;
  let idleAnimation = null;
  let idleAnimationFrame = 0;
  let nekoSpeed = 10;
  
  // Custom AI States
  let state = "chasing"; // chasing, roaming, sleeping
  let stateTimer = 0;
  let targetElement = null;
  
  let dragTarget = null;
  let dragSliderObj = null; // Used for perfectly syncing JSXGraph sliders
  let dragOriginX = 0;
  let dragOriginY = 0;
  let dragPhase = 0;

  let isInteractingWithGraph = false;
  let isBeingCarried = false;
  let wasDragged = false;
  let carryStartX = 0;
  let carryStartY = 0;
  let lastInteractedGraph = null;

  // --- Extra personality state ---
  let grabFromBelow = false;   // hold the slider from underneath sometimes
  let jumpTicks = 0;           // frames remaining in a hop arc
  let puffTicks = 0;           // frames remaining bristling at a big equation
  let puffCooldown = 0;        // don't get spooked by the same area repeatedly
  let hideTicks = 0;           // frames remaining ducked behind something
  let zLow = false;            // currently lowered behind page content
  let inspecting = false;      // heading over to look at selected text
  let isHidden = false;        // ran off and hid after being pestered
  let hiddenTimer = 0;         // frames remaining out of sight
  let hideImg = null;          // the image it is hiding behind
  let inspectRect = null;      // bounds of the text selection it is reading

  // --- Rare huntable critter (a little mouse that scurries around) ---
  let critterEl = null;
  let critterActive = false;
  let critterX = 0, critterY = 0;     // critter screen position
  let critterTX = 0, critterTY = 0;   // where it is scurrying toward
  let critterLife = 0;                // frames before it escapes
  let critterStep = 0;                // frames until it picks a new direction
  let critterCooldown = 300;          // frames before another can appear

  let purrThisSleep = false;          // does the current nap include a purr?
  let currentSprite = "idle";         // last sprite shown (for the eye glow)
  let eyeL = null, eyeR = null;       // glowing eyes (dark mode only)
  const baseScale = 1.4;       // matches the init() scale
  const JUMP_LEN = 6;          // hop length in frames (~0.6s at 10fps)
  const JUMP_HEIGHT = 26;      // hop arc height in px
  const Z_TOP = 2147483647;    // normal (on top of everything) z-index

  // --- Synthesized purr (Web Audio) — reliable, no asset/CORS/format issues ---
  let purrCtx = null;
  let purrNodes = null;
  let audioUnlocked = false;

  const unlockAudio = () => {
      if (audioUnlocked) return;
      audioUnlocked = true;
      try {
          purrCtx = new (window.AudioContext || window.webkitAudioContext)();
          if (purrCtx.state === "suspended") purrCtx.resume();
      } catch (e) { purrCtx = null; }
      document.removeEventListener("mousedown", unlockAudio, true);
      document.removeEventListener("touchstart", unlockAudio, true);
  };
  document.addEventListener("mousedown", unlockAudio, true);
  document.addEventListener("touchstart", unlockAudio, true);

  function startPurr() {
      if (!purrCtx || purrNodes) return;
      try {
          if (purrCtx.state === "suspended") purrCtx.resume();
          const ctx = purrCtx, now = ctx.currentTime;
          // brown-noise buffer = the low rumble body of the purr
          const len = ctx.sampleRate * 2;
          const buf = ctx.createBuffer(1, len, ctx.sampleRate);
          const d = buf.getChannelData(0);
          let last = 0;
          for (let i = 0; i < len; i++) { const w = Math.random() * 2 - 1; last = (last + 0.02 * w) / 1.02; d[i] = last * 3.2; }
          const noise = ctx.createBufferSource(); noise.buffer = buf; noise.loop = true;
          const lp = ctx.createBiquadFilter(); lp.type = "lowpass"; lp.frequency.value = 300;
          // tremolo at ~22 Hz gives the "rrr-rrr" purr pulsing
          const lfo = ctx.createOscillator(); lfo.type = "sine"; lfo.frequency.value = 22;
          const lfoGain = ctx.createGain(); lfoGain.gain.value = 0.6;
          const amp = ctx.createGain(); amp.gain.value = 0.5;
          lfo.connect(lfoGain); lfoGain.connect(amp.gain);
          const master = ctx.createGain(); master.gain.value = 0;
          master.gain.linearRampToValueAtTime(0.10, now + 0.5); // gentle fade-in
          noise.connect(lp); lp.connect(amp); amp.connect(master); master.connect(ctx.destination);
          noise.start(); lfo.start();
          purrNodes = { noise, lfo, master };
      } catch (e) { purrNodes = null; }
  }

  function stopPurr() {
      if (!purrNodes || !purrCtx) { purrNodes = null; return; }
      try {
          const now = purrCtx.currentTime, n = purrNodes;
          n.master.gain.cancelScheduledValues(now);
          n.master.gain.setValueAtTime(n.master.gain.value, now);
          n.master.gain.linearRampToValueAtTime(0, now + 0.3);
          setTimeout(() => { try { n.noise.stop(); n.lfo.stop(); } catch (e) {} }, 350);
      } catch (e) {}
      purrNodes = null;
  }

  const spriteSets = {
    idle: [[-3, -3]],
    alert: [[-7, -3]],
    scratchSelf: [[-5, 0], [-6, 0], [-7, 0]],
    scratchWallN: [[0, 0], [0, -1]],
    scratchWallS: [[-7, -1], [-6, -2]],
    scratchWallE: [[-2, -2], [-2, -3]],
    scratchWallW: [[-4, 0], [-4, -1]],
    tired: [[-3, -2]],
    sleeping: [[-2, 0], [-2, -1]],
    N: [[-1, -2], [-1, -3]],
    NE: [[0, -2], [0, -3]],
    E: [[-3, 0], [-3, -1]],
    SE: [[-5, -1], [-5, -2]],
    S: [[-6, -3], [-7, -2]],
    SW: [[-5, -3], [-6, -1]],
    W: [[-4, -2], [-4, -3]],
    NW: [[-1, 0], [-1, -1]],
  };

  function init() {
    let nekoFile = "/assets/oneko.gif";

    nekoEl.id = "oneko";
    nekoEl.ariaHidden = true;
    nekoEl.style.width = "32px";
    nekoEl.style.height = "32px";
    nekoEl.style.position = "fixed";
    nekoEl.style.pointerEvents = "auto";
    nekoEl.style.cursor = "pointer";
    nekoEl.style.imageRendering = "pixelated";
    nekoEl.style.left = `${nekoPosX - 16}px`;
    nekoEl.style.top = `${nekoPosY - 16}px`;
    nekoEl.style.zIndex = 2147483647;
    nekoEl.style.backgroundImage = `url(${nekoFile})`;
    
    // ORANGE CAT FILTER & SLIGHTLY BIGGER (Scale 1.4)
    // Stronger, warmer orange (more saturation, less wash-out)
    nekoEl.style.filter = "sepia(100%) saturate(1100%) hue-rotate(332deg) brightness(0.98) contrast(1.15)";
    nekoEl.style.transform = "scale(1.4)";
    nekoEl.style.transformOrigin = "center";
    
    glassesEl = document.createElement("div");
    glassesEl.innerHTML = "👓";
    glassesEl.style.position = "absolute";
    glassesEl.style.fontSize = "14px";
    glassesEl.style.top = "4px";
    glassesEl.style.left = "7px";
    glassesEl.style.pointerEvents = "none";
    glassesEl.style.display = "none";
    nekoEl.appendChild(glassesEl);

    document.body.appendChild(nekoEl);



    const engagePlay = function(e) {
        if (isBeingCarried) return;
        if (!e.target || !e.target.closest) return;
        const isSlider = e.target.tagName && e.target.tagName.toLowerCase() === 'input' && e.target.type === 'range';
        const isGraph = e.target.closest('.jxgbox') || e.target.closest('.js-plotly-plot');
        
        if (isSlider || isGraph) {
            isInteractingWithGraph = true;
            lastInteractedGraph = e.target;
            
            state = "chasing";
            nekoSpeed = 20; // Run excitedly toward the mouse
            targetElement = null;
            idleAnimation = null;
        }
    };

    const disengagePlay = function(e) {
        if (isInteractingWithGraph) {
            isInteractingWithGraph = false;
            
            // 55% chance for the cat to say "My turn!" and run over to play with the slider
            if (Math.random() < 0.55 && lastInteractedGraph) {
                state = "roaming";
                
                let grabTarget = lastInteractedGraph;
                let foundSliderNode = null;
                
                // If it's a JSXGraph, specifically find the slider's interactive handle DOM node!
                if (typeof JXG !== 'undefined' && JXG.boards) {
                    const boards = Object.values(JXG.boards);
                    for (let b of boards) {
                        if (b.containerObj && b.containerObj.id && grabTarget.closest && grabTarget.closest(`#${b.containerObj.id}`)) {
                            for (let id in b.objects) {
                                let obj = b.objects[id];
                                if ((obj.elType === 'slider' || obj.elType === 'glider') && obj.rendNode) {
                                    foundSliderNode = obj.rendNode;
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
                
                if (foundSliderNode) {
                    grabTarget = foundSliderNode;
                } else if (grabTarget.closest && (grabTarget.closest('.jxgbox') || grabTarget.closest('.js-plotly-plot'))) {
                    const graph = grabTarget.closest('.jxgbox') || grabTarget.closest('.js-plotly-plot');
                    const sliderInside = graph.querySelector('ellipse, circle, polygon, input');
                    if (sliderInside) grabTarget = sliderInside;
                    else grabTarget = graph;
                }
                
                targetElement = grabTarget;
                nekoSpeed = 18; // Run to it!
            } else {
                nekoSpeed = 10;
                state = "sleeping";
                stateTimer = 100 + Math.floor(Math.random() * 100);
            }
        }
        
        // Handle dropping the cat
        if (isBeingCarried) {
            isBeingCarried = false;
            
            // Check what the cat was dropped on!
            nekoEl.style.pointerEvents = "none";
            const droppedOn = document.elementFromPoint(e.clientX, e.clientY);
            nekoEl.style.pointerEvents = "auto";
            
            let isDraggable = false;
            let grabTarget = null;
            
            if (droppedOn) {
                const tName = droppedOn.tagName ? droppedOn.tagName.toLowerCase() : "";
                if (tName === 'input' || tName === 'ellipse' || tName === 'circle' || tName === 'polygon') {
                    isDraggable = true;
                    grabTarget = droppedOn;
                }
                if (!isDraggable && droppedOn.closest && (droppedOn.closest('.jxgbox') || droppedOn.closest('.js-plotly-plot'))) {
                    // Dropped on the graph background. Try to find a slider inside!
                    const graph = droppedOn.closest('.jxgbox') || droppedOn.closest('.js-plotly-plot');
                    const sliderInside = graph.querySelector('ellipse, circle, polygon');
                    if (sliderInside) {
                        isDraggable = true;
                        grabTarget = sliderInside;
                    } else {
                        isDraggable = true;
                        grabTarget = graph;
                    }
                }
            }
            
            if (isDraggable) {
                if (grabTarget !== droppedOn && grabTarget.tagName && ['ellipse', 'circle', 'polygon'].includes(grabTarget.tagName.toLowerCase())) {
                    // Run to the slider first!
                    state = "roaming";
                    targetElement = grabTarget;
                } else {
                    // Dropped directly on a slider or pan-able graph -> ACTIVATE DRAG!
                    state = "dragging";
                    stateTimer = 150;
                    dragTarget = grabTarget;
                    dragOriginX = nekoPosX;
                    dragOriginY = nekoPosY;
                    dragPhase = 0;
                    grabFromBelow = Math.random() < 0.4; // sometimes hold it from underneath!
                    
                    // Locate corresponding JSXGraph object to manipulate directly
                    if (typeof JXG !== 'undefined' && JXG.boards && grabTarget && grabTarget.closest && grabTarget.closest('.jxgbox')) {
                        const boards = Object.values(JXG.boards);
                        for (let b of boards) {
                            if (b.containerObj && b.containerObj.id && grabTarget.closest(`#${b.containerObj.id}`)) {
                                for (let id in b.objects) {
                                    if (b.objects[id].rendNode === grabTarget) {
                                        dragSliderObj = b.objects[id];
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                    }
                }
            } else {
                if (!wasDragged) {
                    // IT WAS JUST A CLICK! Wake up and run wildly!
                    state = "roaming";
                    stateTimer = 100;
                    nekoSpeed = 25; 
                    targetX = mousePosX + (Math.random() - 0.5) * 800;
                    targetY = mousePosY + (Math.random() - 0.5) * 800;
                    targetElement = null;
                } else {
                    // User shook/dragged the cat and dropped it somewhere empty! Wake up!
                    state = "roaming";
                    stateTimer = 100;
                    nekoSpeed = 25;
                    targetX = mousePosX + (Math.random() - 0.5) * 800;
                    targetY = mousePosY + (Math.random() - 0.5) * 800;
                    targetElement = null;
                }
            }
        }
    };

    // Use capture phase (true) to intercept the events BEFORE JSXGraph/Plotly block them with stopPropagation!
    document.addEventListener("mousedown", engagePlay, true);
    document.addEventListener("touchstart", engagePlay, true);
    document.addEventListener("pointerdown", engagePlay, true);

    document.addEventListener("mouseup", disengagePlay, true);
    document.addEventListener("touchend", disengagePlay, true);
    document.addEventListener("pointerup", disengagePlay, true);
    document.addEventListener("pointercancel", disengagePlay, true);
    
    document.addEventListener("mousemove", function (e) {
      mousePosX = e.clientX;
      mousePosY = e.clientY;
      
      if (isBeingCarried) {
          if (Math.abs(e.clientX - carryStartX) > 5 || Math.abs(e.clientY - carryStartY) > 5) {
              wasDragged = true;
          }
          nekoPosX = e.clientX;
          nekoPosY = e.clientY;
          nekoEl.style.left = `${nekoPosX - 16}px`;
          nekoEl.style.top = `${nekoPosY - 16}px`;
      } else {
          // If the user moves the mouse a lot, the cat should wake up!
          if (state === "sleeping" && Math.random() > 0.95) {
              state = "chasing";
          }
      }
    });
    
    // Curious cat: when you select some text, it trots over and "reads" along it!
    const clampX = x => Math.min(Math.max(x, 24), window.innerWidth - 24);
    const clampY = y => Math.min(Math.max(y, 24), window.innerHeight - 24);

    const inspectSelection = function() {
        if (isBeingCarried || isHidden || state === "fleeing") return;
        const sel = window.getSelection();
        if (!sel || sel.isCollapsed || sel.rangeCount === 0) return;
        if (sel.toString().trim().length < 2) return;

        const rect = sel.getRangeAt(0).getBoundingClientRect();
        if (!rect || (rect.width === 0 && rect.height === 0)) return;
        // Ignore selections scrolled out of view
        if (rect.bottom < 0 || rect.top > window.innerHeight) return;

        // Go check out what the human is reading — walk to the start, then along it
        inspectRect = {
            l: clampX(rect.left + 6),
            r: clampX(rect.right - 6),
            y: clampY(rect.top - 12),
            phase: 0
        };
        state = "roaming";
        targetElement = null;
        inspecting = true;
        wearingGlasses = Math.random() < 0.25;
        idleAnimation = null;
        nekoSpeed = 16;
        stateTimer = 250;
        targetX = inspectRect.l;
        targetY = inspectRect.y;
    };
    document.addEventListener("mouseup", inspectSelection);
    document.addEventListener("touchend", inspectSelection);
    // selectionchange is the reliable signal (mouseup can be missed); debounce it
    let selDebounce = null;
    document.addEventListener("selectionchange", function() {
        if (selDebounce) clearTimeout(selDebounce);
        selDebounce = setTimeout(inspectSelection, 350);
    });

    // Find the nearest decently-sized image that's on screen, to hide behind
    const pickHideImage = function() {
        const imgs = Array.from(document.querySelectorAll('img')).filter(im => {
            if (im === nekoEl) return false;
            const r = im.getBoundingClientRect();
            return r.width > 70 && r.height > 70 &&
                   r.top < window.innerHeight && r.bottom > 0 &&
                   r.left < window.innerWidth && r.right > 0;
        });
        if (!imgs.length) return null;
        imgs.sort((a, b) => {
            const ra = a.getBoundingClientRect(), rb = b.getBoundingClientRect();
            const da = Math.hypot(ra.left + ra.width/2 - nekoPosX, ra.top + ra.height/2 - nekoPosY);
            const db = Math.hypot(rb.left + rb.width/2 - nekoPosX, rb.top + rb.height/2 - nekoPosY);
            return da - db;
        });
        return imgs[0];
    };

    // Run off and hide when poked too many times in quick succession
    let clickTimes = [];
    const hideCat = function() {
        isBeingCarried = false;
        isHidden = true;
        inspecting = false;
        state = "fleeing";
        stateTimer = 0; // don't let a leftover timer flip us back to chasing
        nekoSpeed = 30; // bolt!
        if (zLow) { nekoEl.style.zIndex = Z_TOP; zLow = false; }

        hideImg = pickHideImage();
        if (hideImg) {
            // Run to the image, aiming low so it ducks behind the bottom edge
            const r = hideImg.getBoundingClientRect();
            targetX = Math.min(Math.max(r.left + r.width * 0.5, 16), window.innerWidth - 16);
            targetY = Math.min(r.bottom - 12, window.innerHeight - 16);
        } else {
            // No image around — fall back to a corner
            targetX = (nekoPosX < window.innerWidth / 2)  ? 16 : window.innerWidth - 16;
            targetY = (nekoPosY < window.innerHeight / 2) ? 16 : window.innerHeight - 16;
        }
    };

    // Pick up the cat!
    const pickUpCat = function(e) {
        e.preventDefault();

        // Count rapid clicks — 4 within 1.5s and the cat gets spooked and hides
        const now = Date.now();
        clickTimes.push(now);
        clickTimes = clickTimes.filter(t => now - t < 1500);
        if (clickTimes.length >= 4 && !isHidden) {
            clickTimes = [];
            hideCat();
            return; // flee instead of being picked up
        }

        carryStartX = e.clientX || (e.touches && e.touches[0] ? e.touches[0].clientX : 0);
        carryStartY = e.clientY || (e.touches && e.touches[0] ? e.touches[0].clientY : 0);
        isBeingCarried = true;
        wasDragged = false;
        state = "carried";
    };
    nekoEl.addEventListener("mousedown", pickUpCat);
    nekoEl.addEventListener("touchstart", pickUpCat, {passive: false});

    window.requestAnimationFrame(onAnimationFrame);
  }

  function pickRandomElementTarget() {
      // Prioritize the actual slider dots/handles
      let sliders = Array.from(document.querySelectorAll('.jxgbox ellipse, .jxgbox polygon, .jxgbox circle, input[type="range"]'));
      let general = Array.from(document.querySelectorAll('.js-plotly-plot, .jxgbox, .point, a, button, h1, h2, h3, p, img, li, .math-diagram, .cv-img'));
      
      // Filter for visibility (Only check top-left to avoid SVG width/height bugs)
      const isVisible = el => {
          const rect = el.getBoundingClientRect();
          return rect.top > 0 && rect.top < window.innerHeight && rect.left > 0 && rect.left < window.innerWidth;
      };
      
      sliders = sliders.filter(isVisible);
      general = general.filter(isVisible);
      
      // 55% chance to pick a specific slider dot if one is visible!
      if (sliders.length > 0 && Math.random() < 0.55) {
          targetElement = sliders[Math.floor(Math.random() * sliders.length)];
          return true;
      } else if (general.length > 0) {
          targetElement = general[Math.floor(Math.random() * general.length)];
          return true;
      }
      return false;
  }

  function setSprite(name, frame) {
    currentSprite = name;
    const sprite = spriteSets[name][frame % spriteSets[name].length];
    nekoEl.style.backgroundPosition = `${sprite[0] * 32}px ${sprite[1] * 32}px`;
  }

  // Glowing eyes in dark mode — two soft lime dots over the cat's eyes, shown
  // only for the front-facing, eyes-open poses (idle / alert), hidden when it
  // moves, sleeps, or hides. Kept as separate elements so the cat's orange
  // filter doesn't tint them.
  function ensureEyes() {
    if (eyeL) return;
    const mk = () => {
      const e = document.createElement("div");
      e.setAttribute("aria-hidden", "true");
      e.style.position = "fixed";
      e.style.width = "5px";
      e.style.height = "5px";
      e.style.borderRadius = "50%";
      e.style.background = "#d6ff66";
      e.style.boxShadow = "0 0 6px 2px rgba(190,255,90,0.95), 0 0 12px 4px rgba(150,255,40,0.5)";
      e.style.pointerEvents = "none";
      e.style.zIndex = Z_TOP.toString();
      e.style.display = "none";
      document.body.appendChild(e);
      return e;
    };
    eyeL = mk();
    eyeR = mk();
  }

  function updateEyes() {
    const dark = document.documentElement.classList.contains("dark-mode");
    const show = dark && !isHidden && (currentSprite === "idle" || currentSprite === "alert");
    if (!show) {
      if (eyeL) { eyeL.style.display = "none"; eyeR.style.display = "none"; }
      return;
    }
    ensureEyes();
    const s = baseScale;
    const lx = nekoPosX + (12 - 16) * s; // eyes ~4px left/right of center,
    const rx = nekoPosX + (20 - 16) * s; // ~5px above center (scaled)
    const ey = nekoPosY + (11 - 16) * s;
    eyeL.style.left = `${lx - 2.5}px`; eyeL.style.top = `${ey - 2.5}px`; eyeL.style.display = "block";
    eyeR.style.left = `${rx - 2.5}px`; eyeR.style.top = `${ey - 2.5}px`; eyeR.style.display = "block";
  }

  function resetIdleAnimation() {
    idleAnimation = null;
    idleAnimationFrame = 0;
  }

  // ---- Huntable critter (a rare little mouse) ----
  function ensureCritterEl() {
    if (critterEl) return;
    critterEl = document.createElement("div");
    critterEl.setAttribute("aria-hidden", "true");
    critterEl.style.position = "fixed";
    critterEl.style.pointerEvents = "none";
    critterEl.style.zIndex = (Z_TOP - 1).toString();
    critterEl.style.fontSize = "20px";
    critterEl.style.lineHeight = "20px";
    critterEl.style.userSelect = "none";
    critterEl.style.willChange = "left, top";
    critterEl.textContent = "🐭";
    critterEl.style.display = "none";
    document.body.appendChild(critterEl);
  }

  function pickCritterTarget() {
    critterTX = 40 + Math.random() * (window.innerWidth - 80);
    critterTY = 40 + Math.random() * (window.innerHeight - 80);
    critterStep = 6 + Math.floor(Math.random() * 8);
  }

  function spawnCritter() {
    ensureCritterEl();
    critterActive = true;
    critterLife = 120 + Math.floor(Math.random() * 100); // ~12-22s before it escapes
    const edge = Math.floor(Math.random() * 4);
    if (edge === 0)      { critterX = 10;                    critterY = Math.random() * window.innerHeight; }
    else if (edge === 1) { critterX = window.innerWidth-10;  critterY = Math.random() * window.innerHeight; }
    else if (edge === 2) { critterX = Math.random() * window.innerWidth; critterY = 10; }
    else                 { critterX = Math.random() * window.innerWidth; critterY = window.innerHeight - 10; }
    pickCritterTarget();
    critterEl.style.display = "block";
    critterEl.style.left = `${critterX - 10}px`;
    critterEl.style.top = `${critterY - 10}px`;
  }

  function despawnCritter() {
    critterActive = false;
    if (critterEl) critterEl.style.display = "none";
  }

  function updateCritter() {
    if (critterCooldown > 0) critterCooldown--;
    if (!critterActive) {
      // very rarely, a mouse scurries in
      if (critterCooldown <= 0 && Math.random() < 0.0001) spawnCritter();
      return;
    }
    critterLife--;
    critterStep--;
    if (critterLife <= 0) { despawnCritter(); critterCooldown = 600 + Math.floor(Math.random() * 600); return; }
    if (critterStep <= 0) pickCritterTarget();

    const dx = critterTX - critterX, dy = critterTY - critterY;
    const dd = Math.sqrt(dx*dx + dy*dy) || 1;
    const cspeed = 13;
    if (dd < cspeed) pickCritterTarget();
    critterX += (dx / dd) * cspeed;
    critterY += (dy / dd) * cspeed;
    critterX = Math.min(Math.max(10, critterX), window.innerWidth - 10);
    critterY = Math.min(Math.max(10, critterY), window.innerHeight - 10);
    critterEl.style.left = `${critterX - 10}px`;
    critterEl.style.top = `${critterY - 10}px`;
    critterEl.style.transform = (dx < 0) ? "scaleX(1)" : "scaleX(-1)"; // face travel
  }

  function catchCritter() {
    despawnCritter();
    critterCooldown = 800 + Math.floor(Math.random() * 600); // stays rare
    state = "disturbed";       // pounce + a moment of triumph
    idleAnimation = "scratchSelf";
    idleAnimationFrame = 0;
    stateTimer = 25 + Math.floor(Math.random() * 20);
  }

  // Tuck the cat against an image's bottom edge and CLIP away the overlapping
  // part, so it looks like it's hiding behind the photo — independent of any
  // z-index/stacking-context issues, and it re-aligns each frame (scroll-safe).
  function tuckBehindImage() {
    if (!hideImg) return;
    const r = hideImg.getBoundingClientRect();
    nekoPosX = Math.min(Math.max(r.left + r.width * 0.5, 26), window.innerWidth - 26);
    nekoPosY = Math.min(Math.max(r.bottom - 8, 26), window.innerHeight - 26);
    nekoEl.style.left = `${nekoPosX - 16}px`;
    nekoEl.style.top = `${nekoPosY - 16}px`;
    // screenY = nekoPosY + (yLocal - 16) * baseScale; clip where screenY < r.bottom
    let cut = 16 + (r.bottom - nekoPosY) / baseScale;
    cut = Math.max(0, Math.min(32, cut));
    const clip = `inset(${cut}px 0 0 0)`;
    nekoEl.style.clipPath = clip;
    nekoEl.style.webkitClipPath = clip;
  }

  function idle() {
    idleTime += 1;
    
    // Stand still for 2 seconds, then have a high chance of playing an animation so it feels alive!
    if (
      idleTime > 20 &&
      Math.random() < 0.05 &&
      idleAnimation == null
    ) {
      let availableIdleAnimations = ["scratchSelf", "scratchSelf", "scratchSelf"];
      if (nekoPosX < 32) availableIdleAnimations.push("scratchWallW");
      if (nekoPosY < 32) availableIdleAnimations.push("scratchWallN");
      if (nekoPosX > window.innerWidth - 32) availableIdleAnimations.push("scratchWallE");
      if (nekoPosY > window.innerHeight - 32) availableIdleAnimations.push("scratchWallS");
      idleAnimation =
        availableIdleAnimations[
          Math.floor(Math.random() * availableIdleAnimations.length)
        ];
    }

    switch (idleAnimation) {
      case "sleeping":
        if (idleAnimationFrame === 0) {
          // Decide ONCE per sleep whether this nap gets a purr
          purrThisSleep = Math.random() < 0.4;
        }
        if (idleAnimationFrame < 8) {
          setSprite("tired", 0);
          break;
        }
        setSprite("sleeping", Math.floor(idleAnimationFrame / 4));
        if (purrThisSleep) startPurr();
        else if (purrNodes) stopPurr();
        if (idleAnimationFrame > 192) {
          resetIdleAnimation();
        }
        break;
      case "scratchWallN":
      case "scratchWallS":
      case "scratchWallE":
      case "scratchWallW":
      case "scratchSelf":
        setSprite(idleAnimation, idleAnimationFrame);
        if (idleAnimationFrame > 9) {
          resetIdleAnimation();
        }
        break;
      default:
        setSprite("idle", 0);
        return;
    }
    idleAnimationFrame += 1;
  }

  function frame() {
    frameCount += 1;

    if (glassesEl) glassesEl.style.display = (inspecting && wearingGlasses) ? "block" : "none";

    // --- Tail-puff reaction (fake "bristling" via CSS, no sprite for it) ---
    if (puffCooldown > 0) puffCooldown--;
    if (puffTicks > 0) {
        puffTicks--;
        const jitter = (puffTicks % 2 === 0) ? 2 : -2;        // frightened shake
        // Arched back (taller) + slightly wider body = puffed-up look
        nekoEl.style.transform = `rotate(${jitter}deg) scale(${baseScale * 1.25}, ${baseScale * 1.55})`;
    } else {
        nekoEl.style.transform = `scale(${baseScale})`;
    }

    // --- Hiding behind page content: keep z-index lowered, then pop back ---
    if (zLow) {
        if (state !== "disturbed") { hideTicks = 0; }
        else if (hideTicks > 0) { hideTicks--; }
        if (hideTicks <= 0) { nekoEl.style.zIndex = Z_TOP; zLow = false; }
    }

    // Stop purring the moment we're not sleeping
    if (state !== "sleeping" && purrNodes) {
        stopPurr();
    }

    // Drive the huntable critter (spawn rarely, move it, let the cat chase)
    updateCritter();
    
    if (stateTimer > 0) {
        stateTimer--;
        if (stateTimer <= 0) {
            state = "chasing";
            nekoSpeed = 10;
        }
    }
    
    // AI State Transitions
    // Very rare chance to actually go to sleep deeply
    if (state === "chasing" && Math.random() < 0.001) {
        state = "sleeping";
        stateTimer = 50 + Math.floor(Math.random() * 100);
    }
    
    // Very frequent roaming/exploration!
    if (state === "chasing" && Math.random() < 0.05) {
        if (!pickRandomElementTarget()) {
            // Wander to a random spot on screen if there are no elements to inspect
            targetX = nekoPosX + (Math.random() - 0.5) * window.innerWidth;
            targetY = nekoPosY + (Math.random() - 0.5) * window.innerHeight;
            targetElement = null;
        }
        state = "roaming";
        stateTimer = 200 + Math.floor(Math.random() * 200);
        nekoSpeed = 8; // Walking speed
    }
    
    // If we've been standing completely still for a while, definitely go explore!
    const distToMouse = Math.sqrt((nekoPosX - mousePosX) ** 2 + (nekoPosY - mousePosY) ** 2);
    if (state === "chasing" && distToMouse < 32 && Math.random() < 0.2) {
        if (!pickRandomElementTarget()) {
            targetX = nekoPosX + (Math.random() - 0.5) * window.innerWidth;
            targetY = nekoPosY + (Math.random() - 0.5) * window.innerHeight;
            targetElement = null;
        }
        state = "roaming";
        stateTimer = 100 + Math.floor(Math.random() * 100);
        nekoSpeed = 8;
    }

    // A mouse is loose -> drop everything and HUNT it!
    if (critterActive && !isBeingCarried && !isHidden &&
        state !== "fleeing" && state !== "hidden" && state !== "dragging" && state !== "carried") {
        state = "hunting";
        targetElement = null;
        nekoSpeed = 17; // a touch faster than the critter so it can catch up
    }

    // Determine target based on state
    if (state === "roaming") {
        if (targetElement) {
            // If the target disappeared or was scrolled completely off-screen, give up!
            let container = targetElement.closest ? (targetElement.closest('.jxgbox') || targetElement.closest('.js-plotly-plot') || targetElement) : targetElement;
            let cRect = container.getBoundingClientRect();
            if (!document.body.contains(targetElement) || cRect.bottom < 0 || cRect.top > window.innerHeight) {
                targetElement = null;
                state = "sleeping";
                return;
            }
            
            const rect = targetElement.getBoundingClientRect();
            targetX = rect.left + rect.width / 2;
            // If it's a graph, aim for the absolute center. If it's a slider dot, sit ON TOP of it!
            if (targetElement.classList && (targetElement.classList.contains('jxgbox') || targetElement.classList.contains('js-plotly-plot'))) {
                targetY = rect.top + rect.height / 2;
            } else if (targetElement.tagName && ['ellipse', 'circle', 'polygon'].includes(targetElement.tagName.toLowerCase())) {
                targetY = rect.top - 16; // Sit perfectly on top of the slider
            } else if (targetElement.tagName && targetElement.tagName.toLowerCase() === 'img') {
                targetY = rect.bottom + 8; // Sit BELOW the picture so it doesn't block clicks!
            } else {
                targetY = rect.top - 8; // Sit on top of the text
            }
        }
    } else if (state === "hunting") {
        if (!critterActive) {
            state = "chasing";
            targetX = mousePosX; targetY = mousePosY;
        } else {
            targetX = critterX; targetY = critterY;
        }
    } else if (state === "chasing") {
        targetX = mousePosX;
        targetY = mousePosY;
    }

    // Sleeping Behavior
    if (state === "sleeping") {
        idleAnimation = "sleeping";
        idle();
        return;
    }
    
    // Disturbed/Playing Behavior
    if (state === "disturbed") {
        idle();
        return;
    }
    
    // Carried Behavior (Dangling!)
    if (state === "carried") {
        setSprite("tired", 0); // Use tired sprite to look like it's dangling when held
        return;
    }

    // Pestered too much -> dash to an image and duck behind it!
    if (state === "fleeing") {
        const fdx = nekoPosX - targetX, fdy = nekoPosY - targetY;
        const fd = Math.sqrt(fdx * fdx + fdy * fdy) || 1;
        setSprite("alert", 0); // startled, scampering off
        if (fd < 30) {
            if (hideImg && document.body.contains(hideImg)) {
                tuckBehindImage(); // clip the cat so it looks like it's behind the photo
            } else {
                // No image around — just fade out where it stopped
                nekoEl.style.transition = "opacity 0.3s";
                nekoEl.style.opacity = "0";
            }
            nekoEl.style.pointerEvents = "none";
            state = "hidden";
            hiddenTimer = 80 + Math.floor(Math.random() * 80); // ~8-16s at 10fps
            return;
        }
        nekoPosX -= (fdx / fd) * nekoSpeed;
        nekoPosY -= (fdy / fd) * nekoSpeed;
        nekoEl.style.left = `${nekoPosX - 16}px`;
        nekoEl.style.top = `${nekoPosY - 16}px`;
        return;
    }

    // Hiding behind the image: stay tucked (follows the photo on scroll), then come out
    if (state === "hidden") {
        if (hiddenTimer > 0) {
            if (hideImg && document.body.contains(hideImg)) tuckBehindImage();
            hiddenTimer--;
            return;
        }
        // Come back out
        nekoEl.style.clipPath = "";
        nekoEl.style.webkitClipPath = "";
        nekoEl.style.transition = "";
        nekoEl.style.opacity = "1";
        nekoEl.style.pointerEvents = "auto";
        hideImg = null;
        isHidden = false;
        state = "chasing";
        nekoSpeed = 10;
        return;
    }

    // AI state for physically dragging sliders
    if (state === "dragging") {
        // If the graph was scrolled out of bounds, let go of the slider!
        let container = dragTarget && dragTarget.closest ? (dragTarget.closest('.jxgbox') || dragTarget.closest('.js-plotly-plot') || dragTarget) : dragTarget;
        if (!container || !document.body.contains(container)) {
            state = "sleeping";
            return;
        }
        
        let cRect = container.getBoundingClientRect();
        if (cRect.bottom < 0 || cRect.top > window.innerHeight || cRect.right < 0 || cRect.left > window.innerWidth) {
            if (dragSliderObj) {
                delete dragSliderObj._baseX;
                delete dragSliderObj._baseY;
            }
            if (dragTarget) delete dragTarget._baseValue;
            
            dragTarget = null;
            dragSliderObj = null;
            state = "roaming";
            return;
        }
        
        // Dynamically update Y position so the cat stays attached when you scroll!
        if (dragTarget && dragTarget.getBoundingClientRect) {
            let hRect = dragTarget.getBoundingClientRect();
            dragOriginY = hRect.height === 0 ? hRect.top : (hRect.top + hRect.height / 2);
        }
        
        dragPhase += 0.10; // Speed of dragging back and forth
        // Move cat back and forth horizontally in a playful wave
        nekoPosX = dragOriginX + Math.sin(dragPhase) * 60; // 60px drag radius

        // Attach to the slider — above it normally, or hanging below it!
        const holdOffset = grabFromBelow ? 20 : -16;
        nekoPosY = dragOriginY + holdOffset;

        nekoEl.style.left = `${nekoPosX - 16}px`;
        nekoEl.style.top = `${nekoPosY - 16}px`;

        // Bat at it from above, or reach up at it from below
        setSprite(grabFromBelow ? "scratchWallN" : "scratchWallW", frameCount);
        
        // Hack the Graph Engine! Directly update the slider values!
        if (dragSliderObj && dragSliderObj.setPositionDirectly) {
            // PERFECTLY sync JSXGraph slider position with the Cat's screen pixels!
            if (dragSliderObj._baseX === undefined) dragSliderObj._baseX = dragSliderObj.X();
            if (dragSliderObj._baseY === undefined) dragSliderObj._baseY = dragSliderObj.Y();
            
            let board = dragSliderObj.board;
            let offsetUserX = (Math.sin(dragPhase) * 60) / board.unitX;
            
            dragSliderObj.setPositionDirectly(JXG.COORDS_BY_USER, [dragSliderObj._baseX + offsetUserX, dragSliderObj._baseY]);
            board.update();
        } else if (dragTarget && dragTarget.tagName) {
            const tName = dragTarget.tagName.toLowerCase();
            
            // Hack HTML Sliders
            if (tName === 'input') {
                if (dragTarget._baseValue === undefined) dragTarget._baseValue = parseFloat(dragTarget.value) || 0;
                const min = parseFloat(dragTarget.min) || 0;
                const max = parseFloat(dragTarget.max) || 100;
                const range = max - min;
                let offsetVal = Math.sin(dragPhase) * (range * 0.3); // Wave amplitude
                dragTarget.value = dragTarget._baseValue + offsetVal;
                dragTarget.dispatchEvent(new Event('input', { bubbles: true }));
                dragTarget.dispatchEvent(new Event('change', { bubbles: true }));
            }
        }
        
        if (stateTimer <= 0) {
            if (dragSliderObj) {
                delete dragSliderObj._baseX;
                delete dragSliderObj._baseY;
            }
            if (dragTarget) delete dragTarget._baseValue;
            
            dragTarget = null;
            dragSliderObj = null;
            state = "sleeping";
            stateTimer = 100 + Math.floor(Math.random() * 100);
        }
        return;
    }

    // Movement Behavior
    const diffX = nekoPosX - targetX;
    const diffY = nekoPosY - targetY;
    const distance = Math.sqrt(diffX ** 2 + diffY ** 2);

    // If close enough to target, interact!
    if (distance < nekoSpeed || distance < 32) {
      // Land any in-progress hop cleanly
      jumpTicks = 0;
      nekoEl.style.top = `${nekoPosY - 16}px`;
      // Pounced on the critter!
      if (state === "hunting") { catchCritter(); return; }
      if (state === "roaming") {
          let isDraggable = false;
          if (targetElement) {
              const tName = targetElement.tagName ? targetElement.tagName.toLowerCase() : "";
              if (['input', 'ellipse', 'circle', 'polygon'].includes(tName)) isDraggable = true;
              if (targetElement.classList && (targetElement.classList.contains('jxgbox') || targetElement.classList.contains('js-plotly-plot'))) {
                  isDraggable = true;
              }
          }
          
          if (isDraggable) {
              // GRAB THE SLIDER!
              state = "dragging";
              // Randomly drag between 4 and 8 seconds (40 to 80 frames)
              stateTimer = 40 + Math.floor(Math.random() * 40);
              dragTarget = targetElement;
              dragOriginX = nekoPosX;
              dragOriginY = nekoPosY;
              dragPhase = 0;
              grabFromBelow = Math.random() < 0.4; // sometimes hold it from underneath!
              
              // Identify JSXGraph object
              if (typeof JXG !== 'undefined' && JXG.boards && targetElement && targetElement.closest && targetElement.closest('.jxgbox')) {
                  const boards = Object.values(JXG.boards);
                  for (let b of boards) {
                      if (b.containerObj && b.containerObj.id && targetElement.closest(`#${b.containerObj.id}`)) {
                          for (let id in b.objects) {
                              if (b.objects[id].rendNode === targetElement) {
                                  dragSliderObj = b.objects[id];
                                  break;
                              }
                          }
                          break;
                      }
                  }
              }
          } else {
              if (targetElement === null) {
                  if (inspecting) {
                      if (inspectRect && inspectRect.phase === 0 && (inspectRect.r - inspectRect.l) > 40) {
                          // Reached the start of the selection — now stroll along it, "reading"
                          inspectRect.phase = 1;
                          targetX = inspectRect.r;
                          targetY = inspectRect.y;
                          nekoSpeed = 9;
                          return; // keep walking next frame
                      }
                      // Done reading — sit and study what you highlighted
                      inspecting = false;
                      inspectRect = null;
                      state = "disturbed";
                      stateTimer = 90 + Math.floor(Math.random() * 60);
                      idleAnimation = null;
                      setSprite("alert", 0); // a curious "what's this?" look
                  } else {
                      // Zoomies finished! Stop and look around!
                      state = "disturbed";
                      stateTimer = 40 + Math.floor(Math.random() * 40);
                      idleAnimation = null;
                  }
              } else {
                  // Reached a specific element. Investigate it most of the time!
                  const te = targetElement;
                  const hideable = te && (
                      (te.tagName && te.tagName.toLowerCase() === 'img') ||
                      (te.closest && te.closest('.content-card, .archive__item, .feature__item, .jxgbox, .colbox-blue, .poem-card'))
                  );

                  if (hideable && Math.random() < 0.5) {
                      // Duck BEHIND the content for a peekaboo, then pop back out!
                      state = "disturbed";
                      idleAnimation = null;
                      hideTicks = 18 + Math.floor(Math.random() * 14);
                      stateTimer = hideTicks;
                      nekoEl.style.zIndex = "1";
                      zLow = true;
                  } else {
                      if (Math.random() < 0.2) {
                          state = "sleeping";
                      } else {
                          state = "disturbed";
                          idleAnimation = null;
                      }
                      stateTimer = 60 + Math.floor(Math.random() * 100);
                  }
                  targetElement = null;
              }
          }
      }
      if (state !== "dragging") idle();
      return;
    }

    idleAnimation = null;
    idleAnimationFrame = 0;

    if (idleTime > 1) {
      setSprite("alert", 0);
      idleTime = Math.min(idleTime, 7);
      idleTime -= 1;
      return;
    }

    let direction;
    direction = diffY / distance > 0.5 ? "N" : "";
    direction += diffY / distance < -0.5 ? "S" : "";
    direction += diffX / distance > 0.5 ? "W" : "";
    direction += diffX / distance < -0.5 ? "E" : "";
    setSprite(direction, frameCount);

    nekoPosX -= (diffX / distance) * nekoSpeed;
    nekoPosY -= (diffY / distance) * nekoSpeed;

    // Keep the whole (1.4x-scaled) sprite inside the viewport so it never
    // clips through edges/borders.
    nekoPosX = Math.min(Math.max(26, nekoPosX), window.innerWidth - 26);
    nekoPosY = Math.min(Math.max(26, nekoPosY), window.innerHeight - 26);

    // Occasionally spring into a hop while wandering — looks like jumping over text
    if (jumpTicks <= 0 && state === "roaming" && Math.random() < 0.05) {
        jumpTicks = JUMP_LEN;
    }
    let jumpYOff = 0;
    if (jumpTicks > 0) {
        const p = (JUMP_LEN - jumpTicks) / JUMP_LEN; // 0 -> 1 through the arc
        jumpYOff = -Math.sin(p * Math.PI) * JUMP_HEIGHT;
        jumpTicks--;
    }

    nekoEl.style.left = `${nekoPosX - 16}px`;
    nekoEl.style.top = `${nekoPosY - 16 + jumpYOff}px`;

    // Interactive Trigger: Simulate a mouse hover underneath the cat!
    // We temporarily disable the cat's pointer events so we can "see" through it
    nekoEl.style.pointerEvents = "none";
    const elementUnderCat = document.elementFromPoint(nekoPosX, nekoPosY);
    nekoEl.style.pointerEvents = "auto";
    
    // Only bother simulating hover over things that actually react to it
    // (graphs / sliders). Dispatching events over plain text or background
    // every frame is wasted work and was a major source of slowdown.
    const reactsToHover = elementUnderCat && elementUnderCat.closest && (
        elementUnderCat.closest('.jxgbox') ||
        elementUnderCat.closest('.js-plotly-plot') ||
        (elementUnderCat.tagName && elementUnderCat.tagName.toLowerCase() === 'input')
    );

    if (elementUnderCat && reactsToHover) {
        // Modern graphs like JSXGraph and Plotly listen to PointerEvents as well as MouseEvents
        const evtOpts = {
            view: window,
            bubbles: true,
            cancelable: true,
            clientX: nekoPosX,
            clientY: nekoPosY,
            pointerId: 1,
            pointerType: "mouse"
        };
        
        try {
            if (typeof PointerEvent !== 'undefined') {
                elementUnderCat.dispatchEvent(new PointerEvent("pointermove", evtOpts));
                elementUnderCat.dispatchEvent(new PointerEvent("pointerover", evtOpts));
            }
            elementUnderCat.dispatchEvent(new MouseEvent("mousemove", evtOpts));
            elementUnderCat.dispatchEvent(new MouseEvent("mouseover", evtOpts));
        } catch (e) {
            // Ignore dispatch errors
        }
    }

    // Spotted a big, scary equation? Bristle up (puff) and skitter away!
    if (puffTicks <= 0 && puffCooldown <= 0 && elementUnderCat && elementUnderCat.closest) {
        const eq = elementUnderCat.closest('.katex-display, .katex');
        if (eq) {
            const w = eq.getBoundingClientRect().width;
            if (w > 240) { // long equation
                puffTicks = 14;       // ~1.4s of bristling
                puffCooldown = 80;    // don't re-spook on the same spot
                jumpTicks = JUMP_LEN; // startle hop
                nekoSpeed = 14;
                state = "roaming";
                targetElement = null;
                // dart away from the equation
                targetX = nekoPosX + (nekoPosX < window.innerWidth / 2 ? -140 : 140);
                targetY = nekoPosY + 40;
            }
        }
    }
  }

  let lastFrameTimestamp;

  function onAnimationFrame(timestamp) {
    if (!nekoEl.isConnected) {
      return;
    }
    if (!lastFrameTimestamp) {
      lastFrameTimestamp = timestamp;
    }
    if (timestamp - lastFrameTimestamp > 100) {
      lastFrameTimestamp = timestamp;
      try {
          frame();
      } catch (err) {
          console.error("Oneko crashed, recovering:", err);
          if (!document.getElementById("oneko-crash-log")) {
              let errDiv = document.createElement("div");
              errDiv.id = "oneko-crash-log";
              errDiv.style.cssText = "position:fixed; top:10px; left:10px; background:red; color:white; padding:10px; z-index:99999;";
              errDiv.innerText = "Cat Error: " + err.message + "\nLine: " + err.lineNumber;
              document.body.appendChild(errDiv);
          }
          state = "sleeping";
          stateTimer = 100;
          targetElement = null;
      }
      updateEyes(); // keep the dark-mode eye glow tracking the cat
    }
    window.requestAnimationFrame(onAnimationFrame);
  }

  init();
})();
