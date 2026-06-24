// oneko.js: Modified for custom Orange Cat AI (No Text, Slightly Bigger, Roaming)

(function oneko() {
  const isReducedMotion =
    window.matchMedia(`(prefers-reduced-motion: reduce)`).matches === true;

  if (isReducedMotion) return;

  const nekoEl = document.createElement("div");
  
  let nekoPosX = 32;
  let nekoPosY = 32;
  let mousePosX = 0;
  let mousePosY = 0;
  let targetX = 0;
  let targetY = 0;
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
    // Tweak to be a bit more orange/warmer!
    nekoEl.style.filter = "sepia(100%) saturate(700%) hue-rotate(350deg) brightness(1.1) contrast(1.2)";
    nekoEl.style.transform = "scale(1.4)";
    nekoEl.style.transformOrigin = "center";

    document.body.appendChild(nekoEl);

    let isInteractingWithGraph = false;
    let isBeingCarried = false;
    let wasDragged = false;
    let carryStartX = 0;
    let carryStartY = 0;
    let lastInteractedGraph = null;

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
            
            // 70% chance for the cat to say "My turn!" and run over to play with the slider
            if (Math.random() < 0.70 && lastInteractedGraph) {
                state = "roaming";
                
                let grabTarget = lastInteractedGraph;
                let foundSliderNode = null;
                
                // If it's a JSXGraph, specifically find the slider's interactive handle DOM node!
                if (typeof JXG !== 'undefined' && JXG.boards) {
                    const boards = Object.values(JXG.boards);
                    for (let b of boards) {
                        if (grabTarget.closest && grabTarget.closest(`#${b.containerObj.id}`)) {
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
            
            if (!wasDragged) return; // Just a click, let the click listener handle it
            
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
                    
                    // Identify JSXGraph object
                    if (typeof JXG !== 'undefined' && JXG.boards && grabTarget && grabTarget.closest && grabTarget.closest('.jxgbox')) {
                        const boards = Object.values(JXG.boards);
                        for (let b of boards) {
                            if (grabTarget.closest(`#${b.containerObj.id}`)) {
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
                // Dropped on normal text or image -> Go to sleep on it
                state = "sleeping";
                stateTimer = 100 + Math.floor(Math.random() * 200);
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
          if (state === "sleeping" && Math.random() > 0.95) {
              state = "chasing";
          }
      }
    });
    
    // Pick up the cat!
    nekoEl.addEventListener("mousedown", function(e) {
        e.preventDefault();
        carryStartX = e.clientX;
        carryStartY = e.clientY;
        isBeingCarried = true;
        wasDragged = false;
        state = "carried";
    });
    
    // Click to disturb/play
    nekoEl.addEventListener("click", function() {
        if (wasDragged) return; // Don't trigger if the user just dropped the cat!
        const actions = ["rub", "hit", "run"];
        const chosen = actions[Math.floor(Math.random() * actions.length)];
        
        if (chosen === "rub") {
            state = "disturbed";
            stateTimer = 30; // Shorter so it resumes faster
            idleAnimation = "scratchSelf";
            idleAnimationFrame = 0;
        } else if (chosen === "hit") {
            state = "disturbed";
            stateTimer = 30;
            const hitAnims = ["scratchWallN", "scratchWallS", "scratchWallE", "scratchWallW"];
            idleAnimation = hitAnims[Math.floor(Math.random() * hitAnims.length)];
            idleAnimationFrame = 0;
        } else {
            // run and play (Zoomies!)
            state = "roaming";
            stateTimer = 100;
            nekoSpeed = 25; // Run fast
            targetX = mousePosX + (Math.random() - 0.5) * 800;
            targetY = mousePosY + (Math.random() - 0.5) * 800;
            targetElement = null; // Ignore elements during zoomies
        }
    });

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
      
      // 85% chance to pick a specific slider dot if one is visible!
      if (sliders.length > 0 && Math.random() < 0.85) {
          targetElement = sliders[Math.floor(Math.random() * sliders.length)];
          return true;
      } else if (general.length > 0) {
          targetElement = general[Math.floor(Math.random() * general.length)];
          return true;
      }
      return false;
  }

  function setSprite(name, frame) {
    const sprite = spriteSets[name][frame % spriteSets[name].length];
    nekoEl.style.backgroundPosition = `${sprite[0] * 32}px ${sprite[1] * 32}px`;
  }

  function resetIdleAnimation() {
    idleAnimation = null;
    idleAnimationFrame = 0;
  }

  function idle() {
    idleTime += 1;
    
    if (
      idleTime > 150 &&
      Math.random() < 0.01 &&
      idleAnimation == null
    ) {
      let availableIdleAnimations = ["sleeping", "scratchSelf"];
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
        if (idleAnimationFrame < 8) {
          setSprite("tired", 0);
          break;
        }
        setSprite("sleeping", Math.floor(idleAnimationFrame / 4));
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
    
    if (stateTimer > 0) {
        stateTimer--;
        if (stateTimer <= 0) {
            state = "chasing";
            nekoSpeed = 10;
        }
    }
    
    // AI State Transitions
    if (state === "chasing" && Math.random() < 0.005) {
        state = "sleeping";
        stateTimer = 50 + Math.floor(Math.random() * 100);
    }
    
    // Very frequent roaming!
    if (state === "chasing" && Math.random() < 0.1) {
        if (pickRandomElementTarget()) {
            state = "roaming";
            stateTimer = 200 + Math.floor(Math.random() * 200);
        }
    }

    // Determine target based on state
    if (state === "roaming" && targetElement) {
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
        // If it's a graph, aim for the absolute center. If it's a slider dot, aim for exact point.
        if (targetElement.classList && (targetElement.classList.contains('jxgbox') || targetElement.classList.contains('js-plotly-plot'))) {
            targetY = rect.top + rect.height / 2;
        } else if (targetElement.tagName && ['ellipse', 'circle', 'polygon'].includes(targetElement.tagName.toLowerCase())) {
            targetY = rect.top + rect.height / 2;
        } else {
            targetY = rect.top - 8; // Sit on top of the text
        }
    } else {
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
        
        nekoEl.style.left = `${nekoPosX - 16}px`;
        nekoEl.style.top = `${nekoPosY - 16}px`;
        
        // Simulate "batting" animation while hacking the graph
        setSprite("scratchWallW", frameCount);
        
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
              stateTimer = 150; // Drag it around for a while
              dragTarget = targetElement;
              dragOriginX = nekoPosX;
              dragOriginY = nekoPosY;
              dragPhase = 0;
              
              // Identify JSXGraph object
              if (typeof JXG !== 'undefined' && JXG.boards && targetElement && targetElement.closest && targetElement.closest('.jxgbox')) {
                  const boards = Object.values(JXG.boards);
                  for (let b of boards) {
                      if (targetElement.closest(`#${b.containerObj.id}`)) {
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
              // If roaming and reached target, go to sleep on it
              state = "sleeping";
              stateTimer = 100 + Math.floor(Math.random() * 200);
              targetElement = null;
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

    nekoPosX = Math.min(Math.max(16, nekoPosX), window.innerWidth - 16);
    nekoPosY = Math.min(Math.max(16, nekoPosY), window.innerHeight - 16);

    nekoEl.style.left = `${nekoPosX - 16}px`;
    nekoEl.style.top = `${nekoPosY - 16}px`;

    // Interactive Trigger: Simulate a mouse hover underneath the cat!
    // We temporarily disable the cat's pointer events so we can "see" through it
    nekoEl.style.pointerEvents = "none";
    const elementUnderCat = document.elementFromPoint(nekoPosX, nekoPosY);
    nekoEl.style.pointerEvents = "auto";
    
    if (elementUnderCat) {
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
        
        if (typeof PointerEvent !== 'undefined') {
            elementUnderCat.dispatchEvent(new PointerEvent("pointermove", evtOpts));
            elementUnderCat.dispatchEvent(new PointerEvent("pointerover", evtOpts));
        }
        elementUnderCat.dispatchEvent(new MouseEvent("mousemove", evtOpts));
        elementUnderCat.dispatchEvent(new MouseEvent("mouseover", evtOpts));
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
      frame();
    }
    window.requestAnimationFrame(onAnimationFrame);
  }

  init();
})();
