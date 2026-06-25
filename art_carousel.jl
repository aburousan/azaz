function hfun_art_carousel()
    dir = "_assets/art"
    if !isdir(dir)
        return "<p>No art directory found.</p>"
    end
    
    # Image scanning
    valid_exts = [".jpg", ".jpeg", ".png", ".webp", ".gif"]
    files = filter(f -> any(ext -> endswith(lowercase(f), ext), valid_exts), readdir(dir))
    
    if isempty(files)
        return "<p>No images found.</p>"
    end
    
    # 3D Model scanning
    valid_3d_exts = [".glb", ".gltf"]
    files_3d = filter(f -> any(ext -> endswith(lowercase(f), ext), valid_3d_exts), readdir(dir))
    
    # Build mapping from base name to 3d model path
    model_map_str = "{"
    for f3d in files_3d
        base_name = splitext(f3d)[1]
        model_map_str *= "\"$base_name\": \"/assets/art/$f3d\", "
    end
    model_map_str *= "}"

    # JS array of all gallery image URLs, for preloading
    art_files_js = "[" * join(["\"/assets/art/$f\"" for f in files], ", ") * "]"

    total = length(files)
    
    io = IOBuffer()
    write(io, """
    <style>
    /* Force the oneko cat to always stay on top of the 3D container */
    #oneko {
      z-index: 999999 !important;
    }
    
    .omnitrix-container {
      position: relative;
      width: 100%;
      height: 750px;
      overflow: hidden;
      background: radial-gradient(circle at center 60%, #1a2a1a, #000);
      border-radius: 20px;
      box-shadow: inset 0 0 80px rgba(0, 255, 0, 0.15);
      margin: 40px 0;
    }
    
    .omnitrix-base {
      position: absolute;
      bottom: -30px; 
      left: 50%;
      margin-left: -200px;
      width: 400px;
      height: 400px;
      transform-style: preserve-3d;
      transform: rotateX(75deg);
      z-index: 2;
    }
    
    .omnitrix-dial {
      position: absolute;
      top: 0; left: 0; width: 100%; height: 100%;
      transform-style: preserve-3d;
      transition: transform 0.6s cubic-bezier(0.2, 0.8, 0.2, 1);
      border-radius: 50%;
      border: 25px solid #111;
      box-shadow: 0 0 50px #000, inset 0 0 40px rgba(0,255,0,0.4);
      background: repeating-conic-gradient(from 0deg, #111 0deg 15deg, #1a1a1a 15deg 30deg);
    }
    
    .dial-item {
      position: absolute;
      top: 50%; left: 50%;
      width: 80px; height: 80px;
      margin-top: -40px; margin-left: -40px;
      transform: rotateZ(calc(var(--i) * (360deg / var(--total)))) translateY(-160px);
      cursor: pointer;
      opacity: 0.15;
      filter: grayscale(100%);
      transition: all 0.4s;
      border-radius: 10px;
      overflow: hidden;
      border: 2px solid #333;
    }
    
    /* The active item */
    .dial-item.active {
      opacity: 1;
      filter: grayscale(0%);
      border: 3px solid #0f0;
      box-shadow: 0 0 20px #0f0;
      transform: rotateZ(calc(var(--i) * (360deg / var(--total)))) translateY(-175px) scale(1.3);
    }
    
    /* The immediately adjacent items */
    .dial-item.adjacent {
      opacity: 0.7;
      filter: grayscale(40%);
      border: 2px solid #0a0;
      transform: rotateZ(calc(var(--i) * (360deg / var(--total)))) translateY(-165px) scale(1.1);
    }
    
    .dial-item img {
      width: 100%; height: 100%; object-fit: cover;
    }
    
    .projector-core {
      position: absolute;
      top: 50%; left: 50%;
      width: 100px; height: 100px;
      margin-top: -50px; margin-left: -50px;
      background: radial-gradient(circle, #fff, #0f0 40%, #004400 80%);
      border-radius: 50%;
      box-shadow: 0 0 60px #0f0, 0 0 100px #0f0, inset 0 0 20px #fff;
      border: 4px solid #050;
      animation: pulse-core 2s infinite alternate;
    }
    
    @keyframes pulse-core {
      0% { box-shadow: 0 0 40px #0f0, 0 0 80px #0f0; }
      100% { box-shadow: 0 0 70px #0f0, 0 0 140px #0f0; }
    }
    
    .hologram-beam {
      position: absolute;
      bottom: 170px; 
      left: 50%;
      margin-left: -200px; 
      width: 400px;
      height: 450px;
      clip-path: polygon(0% 0%, 100% 0%, 62.5% 100%, 37.5% 100%);
      background: linear-gradient(to top, rgba(0,255,0,0.8) 0%, rgba(0,255,0,0.3) 40%, rgba(0,255,0,0.05) 100%);
      pointer-events: none;
      z-index: 5;
      animation: flicker 0.15s infinite alternate;
      filter: drop-shadow(0 0 20px rgba(0,255,0,0.5));
    }
    
    @keyframes flicker {
      0% { opacity: 0.8; filter: brightness(1); }
      100% { opacity: 1; filter: brightness(1.2); }
    }
    
    .omnitrix-hologram {
      position: absolute;
      bottom: 190px;
      left: 50%;
      margin-left: -350px;
      width: 700px;
      height: 480px; 
      z-index: 10;
      display: flex;
      align-items: flex-end;
      justify-content: center;
      pointer-events: none;
      filter: drop-shadow(0 0 15px #0f0) drop-shadow(0 0 5px #fff);
    }
    
    .omnitrix-hologram img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain; 
      transition: opacity 0.3s;
      position: relative;
    }
    
    .omnitrix-hologram::after {
      content: "";
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      background: repeating-linear-gradient(
        0deg,
        rgba(0, 0, 0, 0.15),
        rgba(0, 0, 0, 0.15) 2px,
        transparent 2px,
        transparent 4px
      );
      pointer-events: none;
    }
    
    .omnitrix-controls {
      position: absolute;
      bottom: 20px;
      left: 50%;
      transform: translateX(-50%);
      z-index: 20;
      display: flex;
      gap: 30px;
    }
    
    .omnitrix-btn {
      background: rgba(0, 20, 0, 0.8);
      color: #0f0;
      border: 2px solid #0f0;
      padding: 12px 30px;
      border-radius: 30px;
      cursor: pointer;
      text-transform: uppercase;
      font-weight: 800;
      letter-spacing: 3px;
      transition: all 0.3s;
      box-shadow: 0 0 10px rgba(0,255,0,0.2);
    }
    
    .omnitrix-btn:hover {
      background: #0f0;
      color: #000;
      box-shadow: 0 0 25px #0f0;
      transform: scale(1.05);
    }
    
    /* 3D Viewer Container Styles */
    #model-viewer-wrapper {
      position: relative;
      width: 100%;
      height: 500px;
      margin-bottom: 40px;
      border-radius: 20px;
      overflow: hidden;
      background: radial-gradient(circle at center, #111, #000);
      box-shadow: 0 0 30px rgba(0,255,0,0.1);
      border: 2px solid #1a1a1a;
      transition: opacity 0.5s ease-in-out;
      opacity: 0;
      display: none;
    }
    
    #model-viewer-wrapper.visible {
      display: block;
      opacity: 1;
      animation: glow-border 2s infinite alternate;
    }
    
    @keyframes glow-border {
      0% { border-color: #050; box-shadow: 0 0 20px rgba(0,255,0,0.1); }
      100% { border-color: #0f0; box-shadow: 0 0 40px rgba(0,255,0,0.3); }
    }
    
    #art-model-viewer {
      width: 100%;
      height: 100%;
      --poster-color: transparent;
    }

    #relief-viewer { width: 100%; height: 100%; }
    #relief-viewer canvas { display: block; cursor: grab; }
    #relief-viewer canvas:active { cursor: grabbing; }
    #relief-hint {
      position: absolute;
      bottom: 12px; left: 0; right: 0;
      text-align: center;
      color: rgba(180, 255, 180, 0.55);
      font-size: 0.7rem;
      letter-spacing: 2px;
      text-transform: uppercase;
      pointer-events: none;
      font-family: 'Inter', sans-serif;
    }
    
    @media (max-width: 768px) {
      .omnitrix-container { height: 500px; }
      .omnitrix-base { width: 300px; height: 300px; bottom: -50px; margin-left: -150px; }
      .dial-item { width: 60px; height: 60px; margin-top: -30px; margin-left: -30px; transform: rotateZ(calc(var(--i) * (360deg / var(--total)))) translateY(-120px); }
      .dial-item.active { transform: rotateZ(calc(var(--i) * (360deg / var(--total)))) translateY(-135px) scale(1.3); }
      .dial-item.adjacent { transform: rotateZ(calc(var(--i) * (360deg / var(--total)))) translateY(-125px) scale(1.1); }
      .projector-core { width: 80px; height: 80px; margin-top: -40px; margin-left: -40px; }
      .hologram-beam { bottom: 100px; width: 300px; height: 300px; margin-left: -150px; clip-path: polygon(0% 0%, 100% 0%, 63.3% 100%, 36.6% 100%); }
      .omnitrix-hologram { height: 320px; bottom: 120px; width: 340px; margin-left: -170px; }
      #model-viewer-wrapper { height: 350px; }
    }
    </style>
    
    <!-- Google Model Viewer Library (used when a hand-made .glb exists) -->
    <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.4.0/model-viewer.min.js"></script>
    <!-- Three.js: auto-generates a 3D relief from any 2D artwork (no .glb needed) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>
    
    <div class="omnitrix-container" id="omnitrix">
      <div class="hologram-beam"></div>
      
      <div class="omnitrix-hologram">
        <img id="omnitrix-main-display" src="/assets/art/$(files[1])" alt="Holographic Art" fetchpriority="high" decoding="async" />
      </div>
      
      <div class="omnitrix-base">
        <div class="omnitrix-dial" id="omnitrix-dial" style="--total: $(total);">
          <div class="projector-core"></div>
    """)
    
    for (i, f) in enumerate(files)
        write(io, """
          <div class="dial-item $(i == 1 ? "active" : "")" style="--i: $(i-1);" data-src="/assets/art/$f" onclick="selectDialItem($(i-1), event)">
            <img src="/assets/art/$f" loading="lazy" alt="Art $i" />
          </div>
        """)
    end
    
    write(io, """
        </div>
      </div>
      
      <div class="omnitrix-controls">
        <button class="omnitrix-btn" onclick="rotateDial(-1)">&#9664; Prev</button>
        <button class="omnitrix-btn" onclick="rotateDial(1)">Next &#9654;</button>
      </div>
    </div>
    
    <!-- 3D Viewer Container -->
    <div id="model-viewer-wrapper">
      <model-viewer id="art-model-viewer"
                    alt="Interactive 3D Art Model"
                    auto-rotate
                    camera-controls
                    shadow-intensity="1"
                    style="display:none;">
      </model-viewer>
      <!-- Auto-generated relief (Three.js) for images without a .glb -->
      <div id="relief-viewer" style="width:100%;height:100%;"></div>
      <div id="relief-hint">drag to rotate &middot; scroll to zoom</div>
    </div>
    
    <script>
      let currentDialIndex = 0;
      const totalDialItems = $total;
      const dial = document.getElementById('omnitrix-dial');
      const items = document.querySelectorAll('.dial-item');
      const mainDisplay = document.getElementById('omnitrix-main-display');
      
      const modelViewerWrapper = document.getElementById('model-viewer-wrapper');
      const modelViewer = document.getElementById('art-model-viewer');
      
      // Inject the mapping of base names to 3D models generated by Julia
      const modelMap = $model_map_str;

      // Preload every gallery image AFTER the page is interactive, so image
      // swaps and the 3D relief build are instant (cache is already warm)
      // without slowing the initial paint.
      const artFiles = $art_files_js;
      window.addEventListener('load', function () {
        artFiles.forEach(function (s) { var im = new Image(); im.decoding = 'async'; im.src = s; });
      });

      // ---- Auto-generated 3D relief viewer (Three.js) -------------------
      // Turns any flat artwork into real geometry: a finely subdivided plane
      // displaced by the image's luminance (bright = raised), lit so ridges
      // catch highlights and grooves fall into shadow. No .glb required.
      var reliefState = null;
      var reliefToken = 0;   // guards against out-of-order image loads
      function initRelief() {
        if (reliefState) return reliefState;
        if (typeof THREE === 'undefined') return null;
        var el = document.getElementById('relief-viewer');
        var scene = new THREE.Scene();
        var camera = new THREE.PerspectiveCamera(40, el.clientWidth / (el.clientHeight || 1), 0.1, 100);
        camera.position.set(0, 0, 7);
        var renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        renderer.setSize(el.clientWidth, el.clientHeight);
        if (THREE.sRGBEncoding) renderer.outputEncoding = THREE.sRGBEncoding;
        el.appendChild(renderer.domElement);
        scene.add(new THREE.AmbientLight(0xffffff, 0.55));
        var key = new THREE.DirectionalLight(0xffffff, 1.15); key.position.set(-3, 4, 5); scene.add(key);
        var rim = new THREE.DirectionalLight(0x99bbff, 0.45); rim.position.set(4, -2, 3); scene.add(rim);
        var controls = new THREE.OrbitControls(camera, renderer.domElement);
        controls.enableDamping = true; controls.dampingFactor = 0.08; controls.enablePan = false;
        controls.minDistance = 4.5; controls.maxDistance = 11;
        controls.autoRotate = true; controls.autoRotateSpeed = 1.1;
        controls.minPolarAngle = Math.PI * 0.28; controls.maxPolarAngle = Math.PI * 0.72;
        reliefState = { scene: scene, camera: camera, renderer: renderer, controls: controls, mesh: null, el: el };
        function animate() { requestAnimationFrame(animate); controls.update(); renderer.render(scene, camera); }
        animate();
        window.addEventListener('resize', function () {
          if (!el.clientWidth) return;
          camera.aspect = el.clientWidth / el.clientHeight; camera.updateProjectionMatrix();
          renderer.setSize(el.clientWidth, el.clientHeight);
        });
        return reliefState;
      }
      function buildDisplacement(img) {
        var W = 256, H = Math.max(1, Math.round(256 * img.height / img.width));
        var c = document.createElement('canvas'); c.width = W; c.height = H;
        var ctx = c.getContext('2d'); ctx.drawImage(img, 0, 0, W, H);
        var d = ctx.getImageData(0, 0, W, H), p = d.data;
        for (var i = 0; i < p.length; i += 4) {
          var l = 0.299 * p[i] + 0.587 * p[i + 1] + 0.114 * p[i + 2];
          p[i] = p[i + 1] = p[i + 2] = l;
        }
        ctx.putImageData(d, 0, 0);
        return c;
      }
      function showRelief(url) {
        var S = initRelief();
        if (!S) return;
        var myToken = ++reliefToken;             // only the latest request wins
        var img = new Image(); img.crossOrigin = 'anonymous';
        img.onload = function () {
          if (myToken !== reliefToken) return;   // a newer image was requested; drop this one
          if (S.mesh) {
            S.scene.remove(S.mesh);
            S.mesh.geometry.dispose();
            if (S.mesh.material.map) S.mesh.material.map.dispose();
            if (S.mesh.material.displacementMap) S.mesh.material.displacementMap.dispose();
            S.mesh.material.dispose();
          }
          var aspect = img.width / img.height;
          var hh = 4.0, ww = hh * aspect;
          var segY = 200, segX = Math.max(40, Math.round(200 * aspect));
          var geo = new THREE.PlaneGeometry(ww, hh, segX, segY);
          var colorTex = new THREE.Texture(img); colorTex.needsUpdate = true;
          if (THREE.sRGBEncoding) colorTex.encoding = THREE.sRGBEncoding;
          var dispTex = new THREE.CanvasTexture(buildDisplacement(img));
          var mat = new THREE.MeshStandardMaterial({
            map: colorTex, displacementMap: dispTex,
            // displacementScale = how much the relief pops out; tune to taste
            displacementScale: 0.8, displacementBias: -0.3,
            roughness: 0.82, metalness: 0.0, side: THREE.DoubleSide
          });
          S.mesh = new THREE.Mesh(geo, mat);
          S.scene.add(S.mesh);
          S.renderer.setSize(S.el.clientWidth, S.el.clientHeight);
          S.camera.aspect = S.el.clientWidth / (S.el.clientHeight || 1);
          S.camera.updateProjectionMatrix();
        };
        img.src = url;
      }

      function updateDial() {
        const angle = currentDialIndex * (360 / totalDialItems);
        dial.style.transform = `rotateZ(\${angle}deg)`;

        // ONE source of truth for the active artwork, so the 2D hologram and
        // the 3D viewer can never disagree.
        const activeIndex = ((currentDialIndex % totalDialItems) + totalDialItems) % totalDialItems;
        const activeSrc = items[activeIndex].getAttribute('data-src');

        // dial highlight classes only
        items.forEach((item, index) => {
          let diff = (index - activeIndex) % totalDialItems;
          if (diff < 0) diff += totalDialItems;
          item.classList.remove('active', 'adjacent');
          if (diff === 0) item.classList.add('active');
          else if (diff === 1 || diff === totalDialItems - 1) item.classList.add('adjacent');
        });

        // fade the 2D hologram, then swap BOTH 2D and 3D to the same activeSrc
        mainDisplay.style.opacity = 0;
        setTimeout(() => {
          mainDisplay.src = activeSrc;
          mainDisplay.style.opacity = 1;

          const filename = activeSrc.split('/').pop();
          const baseName = filename.substring(0, filename.lastIndexOf('.'));
          const reliefViewer = document.getElementById('relief-viewer');
          const reliefHint = document.getElementById('relief-hint');
          modelViewerWrapper.classList.add('visible');
          if (modelMap[baseName]) {
            // hand-made model wins
            modelViewer.style.display = 'block';
            reliefViewer.style.display = 'none';
            if (reliefHint) reliefHint.style.display = 'none';
            modelViewer.src = modelMap[baseName];
          } else {
            // auto-generate a 3D relief straight from the 2D artwork
            modelViewer.style.display = 'none';
            modelViewer.src = '';
            reliefViewer.style.display = 'block';
            if (reliefHint) reliefHint.style.display = 'block';
            showRelief(activeSrc);
          }
        }, 300);
      }
      
      function rotateDial(direction) {
        currentDialIndex += direction;
        updateDial();
      }
      
      function selectDialItem(index, event) {
        if(event) event.stopPropagation();
        let diff = index - (currentDialIndex % totalDialItems);
        if (diff > totalDialItems / 2) diff -= totalDialItems;
        if (diff < -totalDialItems / 2) diff += totalDialItems;
        currentDialIndex += diff;
        updateDial();
      }
      
      let autoRotate = setInterval(() => rotateDial(1), 5000);
      const container = document.getElementById('omnitrix');
      container.addEventListener('mouseenter', () => clearInterval(autoRotate));
      container.addEventListener('mouseleave', () => {
        autoRotate = setInterval(() => rotateDial(1), 5000);
      });
      
      updateDial();
    </script>
    """)
    
    return String(take!(io))
end
