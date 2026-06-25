// oneko.js: Modified for custom Orange Cat AI (No Text, Slightly Bigger, Roaming)

(function oneko() {
  const isReducedMotion =
    window.matchMedia(`(prefers-reduced-motion: reduce)`).matches === true;

  if (isReducedMotion) return;

  const nekoEl = document.createElement("div");
  let glassesEl = null;
  let hatEl = null;             // mortarboard for "scholar Schrödinger" mode
  let bookEl = null;            // little book shown while reading
  let heartEl = null;           // heart shown while admiring art
  let wearingGlasses = false;
  let quantumCat = false;       // page is about quantum physics -> scholar look
  let magicCat = false;         // page mentions witch/magic -> can teleport
  let artPage = false;          // art gallery page -> cat admires & purrs
  let sparkleEl = null;         // puff of magic shown on a teleport
  let speechEl = null;          // little speech bubble for reactions
  let speechTicks = 0;          // frames the speech bubble stays up
  let glassesProgress = 0;      // 0..1 slide-on animation for the glasses

  // --- Fake 3D depth: the cat can "run into the distance" and back ---
  let depthScale = 1;           // 1 = near (full size), <1 = far away (smaller)
  let farPhase = 0;             // 0 none, 1 receding, 2 returning
  let vanishX = 0, vanishY = 0; // the far-away point it runs toward
  let behindText = false;       // when far away, the cat slips BEHIND the text
  const Z_BEHIND = "-1";        // negative z: behind text, above page background
  
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

  // --- Dark-mode fireflies (glowing, uncatchable, the cat chases them) ---
  let fireflies = [];          // {el, x, y, px, py, gp}
  let firefliesOn = false;

  // --- Rare cup pushing mechanic ---
  let cupEl = null;
  let cupActive = false;
  let cupX = 0, cupY = 0;
  let cupPhase = 0; // 0 = sitting, 1 = falling
  let cupCooldown = 50; // VERY FREQUENT FOR TESTING
  let cupTargetImg = null;
  let cupTargetX = 0, cupTargetY = 0;
  let cupSide = "left";

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

  // Where the HEAD sits inside the 32x32 sprite for each pose (local coords,
  // center = 16,16). Used to place the glasses/hat on the head no matter which
  // way the cat faces — front-facing the head is up-center, but while running
  // it leads in the travel direction. Poses not listed (sleeping/scratch/tired)
  // hide the accessories.
  const HEAD = {
    idle:  { x: 16, y: 9 },  alert: { x: 16, y: 9 },
    N:  { x: 16, y: 8 },  NE: { x: 20, y: 9 },
    E:  { x: 22, y: 12 }, SE: { x: 20, y: 15 },
    S:  { x: 16, y: 16 }, SW: { x: 12, y: 15 },
    W:  { x: 10, y: 12 }, NW: { x: 12, y: 9 },
    // sitting / scratching / sleeping poses so the scholar look never vanishes
    tired:       { x: 16, y: 11 }, sleeping: { x: 13, y: 13 },
    scratchSelf: { x: 16, y: 10 },
    scratchWallN:{ x: 16, y: 7 },  scratchWallS: { x: 16, y: 14 },
    scratchWallE:{ x: 20, y: 10 }, scratchWallW: { x: 12, y: 10 },
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
    
    document.body.appendChild(nekoEl);

    // Accessories live at body level (appended AFTER the cat so they render on
    // top of it) instead of as children — that way the cat's orange `filter`
    // doesn't tint them, and they can animate independently. They're positioned
    // over the cat every frame in updateAccessories().
    const mkAccessory = (emoji, px) => {
      const e = document.createElement("div");
      e.setAttribute("aria-hidden", "true");
      e.innerHTML = emoji;
      e.style.position = "fixed";
      e.style.fontSize = px + "px";
      e.style.lineHeight = px + "px";
      e.style.pointerEvents = "none";
      e.style.userSelect = "none";
      e.style.zIndex = Z_TOP.toString();
      e.style.display = "none";
      e.style.willChange = "left, top, opacity";
      document.body.appendChild(e);
      return e;
    };
    glassesEl = mkAccessory("👓", 16);
    hatEl = mkAccessory("🎓", 17);
    bookEl = mkAccessory("📖", 15);
    heartEl = mkAccessory("😻", 16);
    sparkleEl = mkAccessory("✨", 22);

    // A small speech bubble for the cat's reactions (e.g. on seeing Gino)
    speechEl = document.createElement("div");
    speechEl.setAttribute("aria-hidden", "true");
    speechEl.style.position = "fixed";
    speechEl.style.pointerEvents = "none";
    speechEl.style.zIndex = Z_TOP.toString();
    speechEl.style.background = "#fffef7";
    speechEl.style.color = "#2c2c2c";
    speechEl.style.border = "2px solid #d8b46a";
    speechEl.style.borderRadius = "12px";
    speechEl.style.padding = "5px 11px";
    speechEl.style.fontSize = "12.5px";
    speechEl.style.fontFamily = "'Lora', Georgia, serif";
    speechEl.style.fontStyle = "italic";
    speechEl.style.whiteSpace = "nowrap";
    speechEl.style.boxShadow = "0 4px 14px rgba(0,0,0,0.20)";
    speechEl.style.display = "none";
    document.body.appendChild(speechEl);

    // Detect a quantum-physics page once: the cat puts on a scholar look.
    const contentEl = document.querySelector(".franklin-content, .page__content, main");
    const sampleText = ((document.title || "") + " " + (location.pathname || "") + " " +
                        (contentEl ? contentEl.textContent.slice(0, 4000) : "")).toLowerCase();
    quantumCat = /quantum|schr[öo]dinger|\bqft\b|wave\s?function|hilbert space|qubit|entangl|superposition|quantum field/.test(sampleText);

    // Detect "witch magic" / quantum weirdness -> the cat can rarely teleport.
    magicCat = quantumCat || /witch|magic|spell|wizard|sorcer|enchant|wand|potion/.test(sampleText);

    // Detect the art page: the cat sits and admires the artwork (and purrs).
    artPage = /\/art\b|\bart\b/.test((location.pathname || "").toLowerCase()) ||
              /\bart\b|gallery|painting|sketch/.test((document.title || "").toLowerCase());



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

    // Scrolling carries the cat with the page (so it can drift out of view off
    // the top/bottom), instead of staying glued to the viewport. Its normal
    // chase-the-cursor behaviour then walks it back into view.
    let lastScrollY = window.scrollY || window.pageYOffset || 0;
    window.addEventListener("scroll", function () {
      const sy = window.scrollY || window.pageYOffset || 0;
      const dy = sy - lastScrollY;
      lastScrollY = sy;
      // Skip when the cat is pinned to something that already tracks scroll
      // (being held, dragging a slider, ducked behind/into an image).
      if (isBeingCarried || state === "dragging" || state === "hidden" ||
          state === "fleeing") return;
      nekoPosY -= dy;
      const h = window.innerHeight;
      nekoPosY = Math.min(Math.max(-h, nekoPosY), 2 * h); // bound the drift
      nekoEl.style.top = `${nekoPosY - 16}px`;
    }, { passive: true });

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

  // Only TRUE draggable controls: HTML range inputs + JSXGraph slider/glider
  // knobs. NOT every ellipse/circle in a board — those also include fixed curve
  // markers, which is why the cat used to sit on a graph point in the wrong spot.
  function realSliderNodes() {
      let nodes = Array.from(document.querySelectorAll('input[type="range"]'));
      if (typeof JXG !== 'undefined' && JXG.boards) {
          for (const k in JXG.boards) {
              const b = JXG.boards[k];
              if (!b || !b.objects) continue;
              for (const id in b.objects) {
                  const o = b.objects[id];
                  if (o && (o.elType === 'slider' || o.elType === 'glider') && o.rendNode) {
                      nodes.push(o.rendNode);
                  }
              }
          }
      }
      return nodes;
  }

  function pickRandomElementTarget() {
      // Prioritize the actual slider dots/handles (real controls only)
      let sliders = realSliderNodes();
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

  // Place an accessory so its CENTER lands on (cx, cy) screen coords.
  function placeAcc(el, cx, cy, fs) {
    el.style.left = `${cx - fs / 2}px`;
    el.style.top = `${cy - fs / 2}px`;
  }

  // Glasses / mortarboard / book / heart, drawn over the cat each frame. The
  // glasses slide down onto its face (animated via glassesProgress) rather than
  // snapping on. The mortarboard is permanent on quantum-topic pages.
  //
  // Geometry: the cat sprite is 32px scaled by baseScale, centered on
  // (nekoPosX, nekoPosY). On the front-facing pose the eyes sit ~7px above
  // center and the top of the head ~22px above center.
  function updateAccessories() {
    const reading = (idleAnimation === "reading");
    const admiring = (idleAnimation === "admire");
    const head = HEAD[currentSprite];
    // Place accessories on any pose we know the head position for. While the
    // cat runs into the distance (depthScale<1) we SHRINK them with it instead
    // of hiding, so the scholar look is consistent everywhere.
    const visible = !!head && !isHidden &&
                    state !== "carried" && state !== "fleeing" && state !== "hidden";

    const dsc = depthScale;            // shrink accessories with distance
    const s = baseScale * dsc;
    // Head centre in screen coords for the current pose
    const hx = visible ? nekoPosX + (head.x - 16) * s : 0;
    const hy = visible ? nekoPosY + (head.y - 16) * s : 0;
    const scaleStr = `scale(${dsc.toFixed(3)})`;
    const accZ = behindText ? Z_BEHIND : Z_TOP.toString();
    if (hatEl) hatEl.style.zIndex = accZ;
    if (glassesEl) glassesEl.style.zIndex = accZ;
    if (bookEl) bookEl.style.zIndex = accZ;
    if (heartEl) heartEl.style.zIndex = accZ;

    // Mortarboard: only in quantum-scholar mode, perched on top of the head
    if (hatEl) {
      if (quantumCat && visible) {
        hatEl.style.display = "block";
        hatEl.style.transform = scaleStr;
        // +1 x: the 🎓 tassel hangs right, so the cap reads left-of-center
        placeAcc(hatEl, hx + 1 * dsc, hy - 8 * dsc, 17);
      } else {
        hatEl.style.display = "none";
      }
    }

    // Glasses: when reading selected text, doing a scholar read, or quantum mode
    const wantGlasses = visible && ((inspecting && wearingGlasses) || reading || quantumCat);
    glassesProgress += wantGlasses ? 0.2 : -0.34;
    glassesProgress = Math.min(1, Math.max(0, glassesProgress));
    if (glassesEl) {
      if (glassesProgress > 0.02 && visible) {
        glassesEl.style.display = "block";
        glassesEl.style.transform = scaleStr;
        const drop = (1 - glassesProgress) * 12 * dsc; // slide down onto the eyes
        glassesEl.style.opacity = glassesProgress.toFixed(2);
        placeAcc(glassesEl, hx, hy + 1 * dsc - drop, 16);
      } else {
        glassesEl.style.display = "none";
      }
    }

    // Book: only while actively doing a scholar read, once glasses are settled
    if (bookEl) {
      if (reading && glassesProgress > 0.6 && visible) {
        bookEl.style.display = "block";
        bookEl.style.transform = scaleStr;
        placeAcc(bookEl, nekoPosX, nekoPosY + 16 * dsc, 15);
      } else {
        bookEl.style.display = "none";
      }
    }

    // Heart: floats up over the cat while it admires art, with a gentle bob
    if (heartEl) {
      if (admiring && visible) {
        heartEl.style.display = "block";
        const bob = Math.sin(frameCount / 3) * 3;
        placeAcc(heartEl, hx, hy - 14 * dsc + bob, 16);
      } else {
        heartEl.style.display = "none";
      }
    }
  }

  // Pop a small speech bubble above the cat for a few seconds
  function showSpeech(text, ticks) {
    if (!speechEl) return;
    speechEl.textContent = text;
    speechTicks = ticks || 45;
  }

  function updateSpeech() {
    if (!speechEl) return;
    if (speechTicks > 0) {
      speechTicks--;
      speechEl.style.display = "block";
      const w = speechEl.offsetWidth || 90;
      let x = nekoPosX - w / 2;
      x = Math.min(Math.max(4, x), window.innerWidth - w - 4);
      let y = nekoPosY - 26 - speechEl.offsetHeight;   // float above the head
      if (y < 4) y = nekoPosY + 26;                    // flip below if no room
      speechEl.style.left = `${x}px`;
      speechEl.style.top = `${y}px`;
      speechEl.style.opacity = (speechTicks < 6) ? (speechTicks / 6).toFixed(2) : "1";
    } else if (speechEl.style.display !== "none") {
      speechEl.style.display = "none";
    }
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
      if (critterCooldown <= 0 && Math.random() < 0.0002) spawnCritter();
      return;
    }
    critterLife--;
    critterStep--;
    if (critterLife <= 0) { despawnCritter(); critterCooldown = 2000; return; }
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

  // ---- Dark-mode fireflies ----
  const FLY_COUNT = 3;
  function ensureFireflies() {
    if (fireflies.length) return;
    for (let i = 0; i < FLY_COUNT; i++) {
      const el = document.createElement("div");
      el.setAttribute("aria-hidden", "true");
      el.style.position = "fixed";
      el.style.width = "7px";
      el.style.height = "7px";
      el.style.borderRadius = "50%";
      el.style.pointerEvents = "none";
      el.style.zIndex = (Z_TOP - 2).toString();
      // a warm core that fades to nothing = the diffuse glow body
      el.style.background = "radial-gradient(circle, #fffdf0 0%, #ffe96b 45%, rgba(255,220,80,0) 72%)";
      el.style.willChange = "left, top, opacity, box-shadow";
      el.style.display = "none";
      document.body.appendChild(el);
      fireflies.push({ el, x: 0, y: 0, px: Math.random() * 6.28, py: Math.random() * 6.28, gp: Math.random() * 6.28 });
    }
  }

  function spawnFireflies() {
    ensureFireflies();
    for (const f of fireflies) {
      f.x = 40 + Math.random() * Math.max(80, window.innerWidth - 80);
      f.y = 80 + Math.random() * Math.max(80, window.innerHeight - 160);
      f.px = Math.random() * 6.28; f.py = Math.random() * 6.28; f.gp = Math.random() * 6.28;
      f.el.style.display = "block";
    }
    firefliesOn = true;
  }

  function despawnFireflies() {
    for (const f of fireflies) f.el.style.display = "none";
    firefliesOn = false;
    if (state === "chasefly") state = "chasing";
  }

  function updateFireflies() {
    const dark = document.documentElement.classList.contains("dark-mode");
    if (!dark) { if (firefliesOn) despawnFireflies(); return; }
    if (!firefliesOn) { if (Math.random() < 0.01) spawnFireflies(); return; }

    for (const f of fireflies) {
      f.px += 0.05 + Math.random() * 0.02;
      f.py += 0.045 + Math.random() * 0.02;
      f.gp += 0.2;
      // gentle two-frequency wander
      let nx = f.x + Math.cos(f.px) * 2.2 + Math.cos(f.px * 0.5) * 0.8;
      let ny = f.y + Math.sin(f.py) * 2.0 + Math.sin(f.py * 0.7) * 0.8;
      // evade the cat: bolt away when it gets close, so it is never caught
      const dx = nx - nekoPosX, dy = ny - nekoPosY;
      const d = Math.sqrt(dx * dx + dy * dy) || 1;
      if (d < 110) {
        const push = (d < 45) ? 16 : ((110 - d) / 110) * 10;
        nx += (dx / d) * push;
        ny += (dy / d) * push;
      }
      nx = Math.min(Math.max(20, nx), window.innerWidth - 20);
      ny = Math.min(Math.max(40, ny), window.innerHeight - 20);
      f.x = nx; f.y = ny;
      f.el.style.left = `${nx - 3.5}px`;
      f.el.style.top = `${ny - 3.5}px`;
      // pulsing brightness + a diffuse halo that breathes with it
      const pulse = Math.abs(Math.sin(f.gp));
      f.el.style.opacity = (0.5 + 0.5 * pulse).toFixed(2);
      const r = 6 + 5 * pulse;
      f.el.style.boxShadow =
        `0 0 ${r}px ${r * 0.45}px rgba(255,235,120,0.85), ` +
        `0 0 ${r * 2.2}px ${r * 1.1}px rgba(255,210,70,0.35)`;
    }
  }

  function nearestFirefly() {
    let best = null, bd = Infinity;
    for (const f of fireflies) {
      if (f.el.style.display === "none") continue;
      const d = Math.hypot(f.x - nekoPosX, f.y - nekoPosY);
      if (d < bd) { bd = d; best = f; }
    }
    return best;
  }

  function ensureCupEl() {
    if (cupEl) return;
    cupEl = document.createElement("div");
    cupEl.setAttribute("aria-hidden", "true");
    cupEl.style.position = "fixed";
    cupEl.style.pointerEvents = "none";
    cupEl.style.zIndex = (Z_TOP + 1).toString();
    cupEl.style.fontSize = "24px";
    cupEl.style.lineHeight = "24px";
    cupEl.style.userSelect = "none";
    cupEl.style.willChange = "left, top, transform";
    cupEl.textContent = "🥛";
    cupEl.style.display = "none";
    document.body.appendChild(cupEl);
  }

  function spawnCup() {
    ensureCupEl();
    const imgs = Array.from(document.querySelectorAll('.content-card img, .archive__item img, .feature__item img, .poem-card img, img.cv-img, .page__content img, .author__avatar img')).filter(el => {
        const r = el.getBoundingClientRect();
        return r.width > 50 && r.height > 50 && r.top > 50 && r.bottom < window.innerHeight && r.left > 0 && r.right < window.innerWidth;
    });
    if (imgs.length === 0) return;
    cupTargetImg = imgs[Math.floor(Math.random() * imgs.length)];
    const rect = cupTargetImg.getBoundingClientRect();
    
    cupActive = true;
    cupPhase = 0; // Sitting
    cupEl.style.display = "block";
    cupEl.style.transform = "rotate(0deg)";
    
    const isOnRight = Math.random() < 0.5;
    cupSide = isOnRight ? "right" : "left";
    cupX = isOnRight ? rect.right - 20 : rect.left + 5;
    cupY = rect.top - 20; 
    cupEl.style.left = `${cupX}px`;
    cupEl.style.top = `${cupY}px`;
    
    // Target coordinates for the cat
    cupTargetX = isOnRight ? cupX - 10 : cupX + 35;
    cupTargetY = cupY + 10;
  }

  function despawnCup() {
    cupActive = false;
    cupTargetImg = null;
    if (cupEl) cupEl.style.display = "none";
  }

  function updateCup() {
    if (cupCooldown > 0) cupCooldown--;
    if (!cupActive) {
      if (cupCooldown <= 0 && Math.random() < 0.0002) spawnCup(); // Rare event
      return;
    }
    
    if (cupPhase === 1) {
        // Falling!
        cupY += 12;
        cupX += cupSide === "right" ? 2 : -2;
        cupEl.style.top = `${cupY}px`;
        cupEl.style.left = `${cupX}px`;
        cupEl.style.transform = `rotate(${(cupY * 4) % 360}deg)`;
        if (cupY > window.innerHeight + 50) {
            despawnCup();
            cupCooldown = 2000; 
        }
    } else {
        // Ensure cup stays aligned with image if scrolled
        if (cupTargetImg && document.body.contains(cupTargetImg)) {
            const rect = cupTargetImg.getBoundingClientRect();
            if (rect.bottom < 0 || rect.top > window.innerHeight) {
                despawnCup();
                if (state === "hunting_cup") state = "roaming";
                return;
            }
            cupY = rect.top - 20;
            cupX = cupSide === "right" ? rect.right - 20 : rect.left + 5;
            cupEl.style.left = `${cupX}px`;
            cupEl.style.top = `${cupY}px`;
            cupTargetX = cupSide === "right" ? cupX - 10 : cupX + 35;
            cupTargetY = cupY + 10;
        } else {
            despawnCup();
            if (state === "hunting_cup") state = "roaming";
        }
    }
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

  // Swat a single word so it tumbles off, then springs back into place. Purely
  // cosmetic and self-healing: the word is wrapped in an inline-block span,
  // animated with a CSS transform, then released — the page text is never lost.
  // Skips links, code, and math so nothing important gets disturbed.
  function breakWordNear(preferredEl) {
    let candidates = [];
    if (preferredEl && preferredEl.getBoundingClientRect) {
      candidates = [preferredEl];
    } else {
      const roots = document.querySelectorAll(
        ".franklin-content p, .page__content p, .franklin-content li, .page__content li, article p");
      for (const el of roots) {
        const r = el.getBoundingClientRect();
        if (r.width < 40 || r.height < 8) continue;
        if (r.bottom < 0 || r.top > window.innerHeight) continue;
        if (Math.abs((r.top + r.bottom) / 2 - nekoPosY) > 130) continue;
        candidates.push(el);
      }
    }
    if (!candidates.length) return false;
    const el = candidates[Math.floor(Math.random() * candidates.length)];

    const walker = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, {
      acceptNode(n) {
        if (!n.nodeValue || !/[A-Za-z]{3,}/.test(n.nodeValue)) return NodeFilter.FILTER_REJECT;
        let p = n.parentElement;
        while (p && p !== el.parentElement) {
          const tag = p.tagName ? p.tagName.toLowerCase() : "";
          if (["a", "code", "pre", "script", "style", "button"].includes(tag)) return NodeFilter.FILTER_REJECT;
          if (p.classList && (p.classList.contains("katex") || p.classList.contains("katex-display") ||
                              p.classList.contains("cat-smacked"))) return NodeFilter.FILTER_REJECT;
          p = p.parentElement;
        }
        return NodeFilter.FILTER_ACCEPT;
      },
    });
    const nodes = [];
    let tn;
    while ((tn = walker.nextNode())) nodes.push(tn);
    if (!nodes.length) return false;

    const node = nodes[Math.floor(Math.random() * nodes.length)];
    const text = node.nodeValue;
    const matches = [];
    const re = /[A-Za-z][A-Za-z'’-]{2,}/g;
    let m;
    while ((m = re.exec(text))) matches.push({ word: m[0], idx: m.index });
    if (!matches.length) return false;

    const pick = matches[Math.floor(Math.random() * matches.length)];
    const before = text.slice(0, pick.idx);
    const after = text.slice(pick.idx + pick.word.length);
    const parent = node.parentNode;
    if (!parent) return false;

    const span = document.createElement("span");
    span.className = "cat-smacked";
    span.textContent = pick.word;
    span.style.display = "inline-block";
    span.style.transition = "transform 0.85s cubic-bezier(.34,.6,.45,1.4), opacity 0.85s";
    span.style.willChange = "transform, opacity";

    const beforeNode = document.createTextNode(before);
    const afterNode = document.createTextNode(after);
    parent.replaceChild(afterNode, node);
    parent.insertBefore(span, afterNode);
    parent.insertBefore(beforeNode, span);

    void span.offsetWidth; // force reflow so the transition runs
    const dir = Math.random() < 0.5 ? -1 : 1;
    // Keep it clearly a falling WORD: mostly a downward drop with a slight tip,
    // staying legible (not a rotated, near-invisible blur).
    span.style.transform = `translateY(34px) translateX(${dir * 6}px) rotate(${dir * 14}deg)`;
    span.style.opacity = "0.45";

    // Spring it back, then merge the text nodes again to keep the DOM tidy
    setTimeout(() => {
      span.style.transform = "";
      span.style.opacity = "";
      setTimeout(() => {
        try {
          const restored = document.createTextNode(before + pick.word + after);
          if (span.parentNode) {
            span.parentNode.replaceChild(restored, span);
            if (beforeNode.parentNode) beforeNode.parentNode.removeChild(beforeNode);
            if (afterNode.parentNode) afterNode.parentNode.removeChild(afterNode);
            if (restored.parentNode) restored.parentNode.normalize();
          }
        } catch (e) { /* leave it; text is intact either way */ }
      }, 950);
    }, 1100);
    return true;
  }

  // A quick puff of magic sparkle that fades out where the cat appears/vanishes
  function showSparkle(x, y) {
    if (!sparkleEl) return;
    sparkleEl.style.transition = "";
    sparkleEl.style.opacity = "1";
    sparkleEl.style.display = "block";
    sparkleEl.style.left = `${x - 11}px`;
    sparkleEl.style.top = `${y - 11}px`;
    void sparkleEl.offsetWidth; // reflow so the fade runs
    sparkleEl.style.transition = "opacity 0.6s";
    sparkleEl.style.opacity = "0";
    clearTimeout(sparkleEl._t);
    sparkleEl._t = setTimeout(() => { sparkleEl.style.display = "none"; }, 650);
  }

  // Witch-magic / quantum teleport: poof out here, reappear somewhere else.
  function teleport() {
    showSparkle(nekoPosX, nekoPosY);          // poof at the old spot
    nekoEl.style.transition = "opacity 0.15s";
    nekoEl.style.opacity = "0";

    // jump to a fresh random place on screen
    nekoPosX = 40 + Math.random() * Math.max(80, window.innerWidth - 80);
    nekoPosY = 70 + Math.random() * Math.max(80, window.innerHeight - 140);
    nekoEl.style.left = `${nekoPosX - 16}px`;
    nekoEl.style.top = `${nekoPosY - 16}px`;

    setTimeout(() => {
      showSparkle(nekoPosX, nekoPosY);        // reappear at the new spot
      nekoEl.style.opacity = "1";
      setTimeout(() => { nekoEl.style.transition = ""; }, 220);
    }, 160);

    // settle into a calm state at the new location
    state = "chasing";
    farPhase = 0;
    depthScale = 1;
    idleAnimation = null;
    targetElement = null;
  }

  function idle() {
    idleTime += 1;
    
    // Stand still for 2 seconds, then have a high chance of playing an animation so it feels alive!
    if (
      idleTime > 20 &&
      Math.random() < 0.05 &&
      idleAnimation == null
    ) {
      let availableIdleAnimations = [
        "scratchSelf", "grooming", "grooming",
        "tailChase", "lookAround", "stretch", "playPounce", "sit", "reading",
      ];
      // On a quantum page the scholar cat reads more often
      if (quantumCat) availableIdleAnimations.push("reading", "reading");
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
      case "grooming":
        setSprite("scratchSelf", idleAnimationFrame); // Face washing!
        if (idleAnimationFrame > 18) {
          resetIdleAnimation();
        }
        break;
      case "rubbing":
        // Rub head by alternating NW and W frames
        setSprite(Math.floor(idleAnimationFrame / 4) % 2 === 0 ? "W" : "NW", 0);
        if (idleAnimationFrame > 25) {
          resetIdleAnimation();
        }
        break;
      case "tailChase": {
        // Turn in place, glancing back at its tail: a slow curl one way, a
        // pause, then back. Cycling the walk sprites too fast looked glitchy,
        // so this holds each pose and only sweeps a short arc.
        const arc = ["S", "SW", "W", "NW", "N", "NW", "W", "SW", "S"];
        setSprite(arc[Math.min(Math.floor(idleAnimationFrame / 3), arc.length - 1)], 0);
        if (idleAnimationFrame > arc.length * 3 + 2) {
          resetIdleAnimation();
        }
        break;
      }
      case "lookAround": {
        // Curious head-turning: glance left, center, right, up
        const seq = ["W", "alert", "E", "alert", "N", "alert"];
        setSprite(seq[Math.floor(idleAnimationFrame / 4) % seq.length], 0);
        if (idleAnimationFrame > 24) {
          resetIdleAnimation();
        }
        break;
      }
      case "stretch":
        // A long forward stretch, then a yawn, then settle
        if (idleAnimationFrame < 6) {
          setSprite("scratchWallN", idleAnimationFrame);
        } else if (idleAnimationFrame < 12) {
          setSprite("tired", 0);
        } else {
          setSprite("scratchSelf", idleAnimationFrame);
        }
        if (idleAnimationFrame > 20) {
          resetIdleAnimation();
        }
        break;
      case "playPounce":
        // Crouch low and wiggle, then a little pounce-hop in place
        if (idleAnimationFrame < 8) {
          setSprite("tired", 0);
          nekoEl.style.top = `${nekoPosY - 16 + (idleAnimationFrame % 2 === 0 ? 1 : -1)}px`;
        } else {
          const ph = Math.min((idleAnimationFrame - 8) / 6, 1);
          const off = -Math.sin(ph * Math.PI) * 18;
          setSprite("alert", 0);
          nekoEl.style.top = `${nekoPosY - 16 + off}px`;
        }
        if (idleAnimationFrame > 15) {
          nekoEl.style.top = `${nekoPosY - 16}px`;
          resetIdleAnimation();
        }
        break;
      case "sit":
        // Just sit and calmly watch the page for a beat
        setSprite("alert", 0);
        if (idleAnimationFrame > 22) {
          resetIdleAnimation();
        }
        break;
      case "reading":
        // Settle in and read like a scholar: glasses slide on (handled in
        // updateAccessories) and the cat alternates looking up (alert) and
        // down at its book (S), a slow studious nod.
        setSprite(Math.floor(idleAnimationFrame / 6) % 2 === 0 ? "S" : "alert", 0);
        if (idleAnimationFrame > 64) {
          resetIdleAnimation();
        }
        break;
      case "admire":
        // Sit in front of the artwork, gaze at it, and purr (heart floats up,
        // handled in updateAccessories).
        setSprite("alert", 0);
        startPurr();
        if (idleAnimationFrame > 70) {
          stopPurr();
          resetIdleAnimation();
        }
        break;
      case "smacking":
        // Paw at a word: a quick swat (the word tumbles via breakWordNear)
        setSprite("scratchWallW", idleAnimationFrame);
        if (idleAnimationFrame > 8) {
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

    // --- Tail-puff reaction (fake "bristling" via CSS, no sprite for it) ---
    if (puffCooldown > 0) puffCooldown--;
    if (puffTicks > 0) {
        puffTicks--;
        const jitter = (puffTicks % 2 === 0) ? 2 : -2;        // frightened shake
        // Arched back (taller) + slightly wider body = puffed-up look
        nekoEl.style.transformOrigin = "center";
        nekoEl.style.transform = `rotate(${jitter}deg) scale(${baseScale * 1.25}, ${baseScale * 1.55})`;
    } else {
        nekoEl.style.transformOrigin = "center";
        nekoEl.style.transform = `scale(${baseScale * depthScale})`;
    }

    // --- Hiding behind page content: keep z-index lowered, then pop back ---
    if (zLow) {
        if (state !== "disturbed") { hideTicks = 0; }
        else if (hideTicks > 0) { hideTicks--; }
        if (hideTicks <= 0) { nekoEl.style.zIndex = Z_TOP; zLow = false; }
    }

    // Stop purring the moment we're not sleeping (or actively admiring art)
    const admiringNow = (idleAnimation === "admire" && state === "disturbed");
    if (state !== "sleeping" && !admiringNow && purrNodes) {
        stopPurr();
    }

    // Ease depth back to full size whenever we're not doing a distance-run
    if (state !== "farrun" && depthScale !== 1) {
        depthScale += (1 - depthScale) * 0.12;
        if (Math.abs(depthScale - 1) < 0.01) depthScale = 1;
    }
    // Safety: if anything pulled us out of a far-run, come back in front of text
    if (state !== "farrun" && behindText) {
        behindText = false;
        nekoEl.style.zIndex = Z_TOP;
    }

    // Extremely rare witch-magic / quantum teleport (~once every ~1.5h of viewing)
    if (magicCat && !isBeingCarried && !isHidden &&
        state !== "dragging" && state !== "farrun" && state !== "fleeing" &&
        Math.random() < 0.0002) {
        teleport();
        return;
    }

    // Drive the huntable critter (spawn rarely, move it, let the cat chase)
    updateCritter();

    // Drive the dark-mode fireflies (glow + drift + evade the cat)
    updateFireflies();

    // Drive the cup pushing mechanic
    updateCup();
    
    if (stateTimer > 0) {
        stateTimer--;
        if (stateTimer <= 0) {
            if (state === "pushing_cup") {
                cupPhase = 1; // start falling!
                state = "roaming";
                targetElement = null;
            } else {
                state = "chasing";
            }
            nekoSpeed = 10;
        }
    }
    
    // AI State Transitions
    // Very rare chance to actually go to sleep deeply
    if (state === "chasing" && Math.random() < 0.001) {
        state = "sleeping";
        stateTimer = 50 + Math.floor(Math.random() * 100);
    }
    
    // Roaming/exploration (kept fairly calm so it rests more than it wanders)
    if (state === "chasing" && Math.random() < 0.018) {
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
    if (state === "chasing" && distToMouse < 32 && Math.random() < 0.07) {
        if (!pickRandomElementTarget()) {
            targetX = nekoPosX + (Math.random() - 0.5) * window.innerWidth;
            targetY = nekoPosY + (Math.random() - 0.5) * window.innerHeight;
            targetElement = null;
        }
        state = "roaming";
        stateTimer = 100 + Math.floor(Math.random() * 100);
        nekoSpeed = 8;
    }

    // Occasionally take off running "into the distance" (shrinking away from
    // the camera) and then come sprinting back — a fake-3D depth dash.
    if ((state === "chasing" || state === "roaming") && farPhase === 0 &&
        !isBeingCarried && !isHidden && Math.random() < 0.0022) {
        state = "farrun";
        farPhase = 1;
        stateTimer = 0;
        targetElement = null;
        vanishX = window.innerWidth * 0.5 + (Math.random() - 0.5) * window.innerWidth * 0.25;
        vanishY = window.innerHeight * 0.20;
        targetX = vanishX;
        targetY = vanishY;
        nekoSpeed = 18;
    }

    // Fireflies are out (dark mode) -> now and then give a playful chase
    if (firefliesOn && !isBeingCarried && !isHidden &&
        (state === "chasing" || state === "roaming") && Math.random() < 0.02) {
        state = "chasefly";
        targetElement = null;
        nekoSpeed = 13;
        stateTimer = 70 + Math.floor(Math.random() * 70);
    }

    // A mouse is loose -> drop everything and HUNT it!
    if (critterActive && !isBeingCarried && !isHidden &&
        state !== "fleeing" && state !== "hidden" && state !== "dragging" && state !== "carried" && state !== "farrun") {
        state = "hunting";
        targetElement = null;
        nekoSpeed = 17; // a touch faster than the critter so it can catch up
    }

    // A cup is spawned -> drop everything and go push it!
    if (cupActive && cupPhase === 0 && !isBeingCarried && !isHidden &&
        state !== "fleeing" && state !== "hidden" && state !== "dragging" && state !== "carried" && state !== "hunting" && state !== "pushing_cup" && state !== "farrun") {
        state = "hunting_cup";
        targetElement = null;
        nekoSpeed = 12;
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
    } else if (state === "chasefly") {
        const f = firefliesOn ? nearestFirefly() : null;
        if (!f) {
            state = "chasing";
            targetX = mousePosX; targetY = mousePosY;
        } else {
            targetX = f.x; targetY = f.y; // firefly evades, so never reached
        }
    } else if (state === "hunting_cup") {
        if (!cupActive || cupPhase !== 0) {
            state = "chasing";
            targetX = mousePosX; targetY = mousePosY;
        } else {
            targetX = cupTargetX; targetY = cupTargetY;
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

    // Pushing Cup Behavior
    if (state === "pushing_cup") {
        if (stateTimer > 15) {
            setSprite("idle", 0); // Sit beside it playfully
        } else {
            // Swat at it!
            setSprite(cupSide === "right" ? "scratchWallE" : "scratchWallW", Math.floor((15 - stateTimer) / 3));
        }
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
        let direction = "";
        direction += fdy / fd > 0.5 ? "N" : "";
        direction += fdy / fd < -0.5 ? "S" : "";
        direction += fdx / fd > 0.5 ? "W" : "";
        direction += fdx / fd < -0.5 ? "E" : "";
        setSprite(direction, frameCount); // scampering off properly!
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

    // Fake-3D distance dash: run toward a far point shrinking, then sprint back
    if (state === "farrun") {
        const td = (farPhase === 1) ? 0.42 : 1;
        depthScale += (td - depthScale) * 0.08;

        // Once it has shrunk into the distance, slip BEHIND the page text;
        // pop back in front as it returns toward the camera.
        const wantBehind = depthScale < 0.8;
        if (wantBehind !== behindText) {
            behindText = wantBehind;
            nekoEl.style.zIndex = wantBehind ? Z_BEHIND : Z_TOP;
        }

        const diffX = nekoPosX - targetX;
        const diffY = nekoPosY - targetY;
        const dist = Math.sqrt(diffX ** 2 + diffY ** 2) || 1;

        let dir = "";
        dir += diffY / dist > 0.5 ? "N" : "";
        dir += diffY / dist < -0.5 ? "S" : "";
        dir += diffX / dist > 0.5 ? "W" : "";
        dir += diffX / dist < -0.5 ? "E" : "";
        setSprite(dir === "" ? "idle" : dir, frameCount);

        if (dist < nekoSpeed * 1.5) {
            if (farPhase === 1) {
                // Reached the distance — turn around and come running back
                farPhase = 2;
                targetX = Math.min(Math.max(mousePosX, 40), window.innerWidth - 40);
                targetY = Math.min(Math.max(mousePosY, window.innerHeight * 0.5), window.innerHeight - 40);
                nekoSpeed = 16;
            } else {
                // Back near the camera — resume normal life
                depthScale = 1;
                farPhase = 0;
                state = "chasing";
                nekoSpeed = 10;
                behindText = false;
                nekoEl.style.zIndex = Z_TOP;
            }
            return;
        }

        nekoPosX -= (diffX / dist) * nekoSpeed;
        nekoPosY -= (diffY / dist) * nekoSpeed;
        nekoPosX = Math.min(Math.max(26, nekoPosX), window.innerWidth - 26);
        nekoPosY = Math.min(Math.max(26, nekoPosY), window.innerHeight - 26);
        nekoEl.style.left = `${nekoPosX - 16}px`;
        nekoEl.style.top = `${nekoPosY - 16}px`;
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
    // Always aim INTO the viewport, so the cat only ever leaves the screen by
    // being scrolled away (handled on the scroll event) — never by wandering
    // off on its own.
    targetY = Math.min(Math.max(30, targetY), window.innerHeight - 30);
    const diffX = nekoPosX - targetX;
    const diffY = nekoPosY - targetY;
    const distance = Math.sqrt(diffX ** 2 + diffY ** 2);

    // If close enough to target, interact!
    if (distance < nekoSpeed || (state !== "hunting_cup" && distance < 32)) {
      // Land any in-progress hop cleanly
      jumpTicks = 0;
      nekoEl.style.top = `${nekoPosY - 16}px`;
      // Pounced on the critter!
      if (state === "hunting") { catchCritter(); return; }
      if (state === "hunting_cup") {
          nekoPosX = targetX;
          nekoPosY = targetY;
          nekoEl.style.left = `${nekoPosX - 16}px`;
          nekoEl.style.top = `${nekoPosY - 16}px`;
          state = "pushing_cup";
          stateTimer = 40; // 25 frames sitting, 15 frames swatting
          return;
      }
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
                  const teTag = te && te.tagName ? te.tagName.toLowerCase() : "";
                  const isAvatar = te && te.closest && te.closest('.author__avatar');
                  const isImg = teTag === 'img';
                  const isText = ['p', 'li', 'h1', 'h2', 'h3'].includes(teTag);
                  const teSrc = (isImg && te.src) ? te.src.toLowerCase() : "";
                  const hideable = te && (
                      isImg ||
                      (te.closest && te.closest('.content-card, .archive__item, .feature__item, .jxgbox, .colbox-blue, .poem-card'))
                  );

                  if (isImg && teSrc.includes('gino')) {
                      // Spotted a fellow feline (Gino) — sit, gaze, and proudly claim it
                      state = "disturbed";
                      idleAnimation = "admire";   // sit, heart, purr
                      idleAnimationFrame = 0;
                      stateTimer = 85 + Math.floor(Math.random() * 30);
                      showSpeech("Behold — my beautiful real self!", 48);
                  } else if (artPage && isImg && Math.random() < 0.65) {
                      // On the art page: sit, admire the piece, and purr
                      state = "disturbed";
                      idleAnimation = "admire";
                      idleAnimationFrame = 0;
                      stateTimer = 75 + Math.floor(Math.random() * 40);
                  } else if (isAvatar && Math.random() < 0.40) {
                      // Found the owner! Rub head!
                      state = "disturbed";
                      idleAnimation = "rubbing";
                      idleAnimationFrame = 0;
                      stateTimer = 40 + Math.floor(Math.random() * 40);
                  } else if (isText && Math.random() < 0.4) {
                      // Pounce on a word — it tumbles off and springs back!
                      state = "disturbed";
                      idleAnimation = "smacking";
                      idleAnimationFrame = 0;
                      stateTimer = 14 + Math.floor(Math.random() * 10);
                      breakWordNear(te);
                  } else if (hideable && Math.random() < 0.22) {
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

    // Keep the sprite within the viewport horizontally; vertically allow it to
    // sit out of bounds (so a scroll can carry it off the top/bottom and it can
    // walk smoothly back in, instead of snapping to the edge).
    nekoPosX = Math.min(Math.max(26, nekoPosX), window.innerWidth - 26);
    const _vh = window.innerHeight;
    nekoPosY = Math.min(Math.max(-_vh, nekoPosY), 2 * _vh);

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
      updateAccessories(); // glasses / mortarboard / book over the cat
      updateSpeech(); // reaction speech bubble
    }
    window.requestAnimationFrame(onAnimationFrame);
  }

  init();
})();
