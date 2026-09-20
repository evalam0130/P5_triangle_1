!DOCTYPE html>
<html lang="zh-Hant">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>三角形的底和高 - 互動探索與隨堂挑戰</title>
  <!-- Tailwind CSS CDN -->
  <script src="https://cdn.tailwindcss.com"></script>
  <!-- FontAwesome Icons -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Fredoka:wght@400;600;700&family=Noto+Sans+TC:wght@400;500;700;900&display=swap');
    
    body {
      font-family: 'Noto Sans TC', 'Fredoka', sans-serif;
      background-color: #f0f7ff;
      user-select: none;
    }

    .canvas-container {
      position: relative;
      touch-action: none;
    }

    canvas {
      border-radius: 1rem;
      background: #ffffff;
      box-shadow: inset 0 0 10px rgba(0, 0, 0, 0.03);
    }

    .tab-btn {
      transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .tab-btn.active {
      background-color: #2563eb;
      color: white;
      box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
    }

    .range-slider {
      accent-color: #2563eb;
    }

    .pulse-glow {
      animation: pulseGlow 2s infinite;
    }

    @keyframes pulseGlow {
      0%, 100% { box-shadow: 0 0 0 0 rgba(37, 99, 235, 0.4); }
      50% { box-shadow: 0 0 0 10px rgba(37, 99, 235, 0); }
    }
  </style>
</head>
<body class="min-h-screen text-slate-800 pb-12">

  <!-- Top Navigation Header -->
  <header class="bg-white border-b border-blue-100 sticky top-0 z-30 shadow-sm">
    <div class="max-w-6xl mx-auto px-4 py-3 flex flex-wrap items-center justify-between gap-3">
      <div class="flex items-center space-x-3">
        <div class="bg-gradient-to-tr from-blue-600 to-indigo-500 text-white w-10 h-10 rounded-xl flex items-center justify-center text-xl shadow-md">
          🔺
        </div>
        <div>
          <h1 class="text-xl font-black text-slate-800 leading-tight">三角形的底和高</h1>
          <p class="text-xs text-blue-600 font-medium">小學數學幾何動態學習平台</p>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <nav class="flex bg-slate-100 p-1.5 rounded-xl border border-slate-200 text-sm font-bold">
        <button onclick="switchTab('explore')" id="tab-explore" class="tab-btn active px-4 py-2 rounded-lg flex items-center gap-2">
          <i class="fa-solid fa-hand-pointer"></i> 自由探索
        </button>
        <button onclick="switchTab('tutorial')" id="tab-tutorial" class="tab-btn px-4 py-2 rounded-lg text-slate-600 hover:text-blue-600 flex items-center gap-2">
          <i class="fa-solid fa-book-open"></i> 觀念教室
        </button>
        <button onclick="switchTab('quiz')" id="tab-quiz" class="tab-btn px-4 py-2 rounded-lg text-slate-600 hover:text-blue-600 flex items-center gap-2">
          <i class="fa-solid fa-gamepad"></i> 隨堂挑戰
        </button>
      </nav>
    </div>
  </header>

  <main class="max-w-6xl mx-auto px-4 mt-6">

    <!-- ==================== SECTION 1: EXPLORE / SANDBOX MODE ==================== -->
    <section id="view-explore" class="grid grid-cols-1 lg:grid-cols-12 gap-6">
      
      <!-- Canvas Column (Left/Top) -->
      <div class="lg:col-span-8 space-y-4">
        <div class="bg-white p-4 sm:p-5 rounded-2xl shadow-sm border border-slate-200">
          <div class="flex flex-wrap items-center justify-between gap-2 mb-3">
            <div class="flex items-center gap-2">
              <span class="inline-block w-3 h-3 rounded-full bg-blue-600"></span>
              <span class="font-bold text-slate-700 text-sm">拖曳頂點 (A, B, C) 改變形狀，或調整下方旋轉角度</span>
            </div>
            <button onclick="resetSandbox()" class="text-xs text-slate-500 hover:text-blue-600 bg-slate-100 px-3 py-1.5 rounded-lg border border-slate-200 flex items-center gap-1 transition">
              <i class="fa-solid fa-rotate-left"></i> 重置圖形
            </button>
          </div>

          <!-- Canvas Screen -->
          <div class="canvas-container w-full overflow-hidden flex justify-center items-center">
            <canvas id="sandboxCanvas" width="700" height="420" class="w-full h-auto cursor-grab active:cursor-grabbing border-2 border-blue-100 rounded-xl"></canvas>
          </div>

          <!-- Rotation Controller Bar -->
          <div class="mt-4 p-3 bg-slate-50 border border-slate-200 rounded-xl flex flex-wrap items-center justify-between gap-4">
            <div class="flex items-center gap-2 text-sm font-bold text-slate-700">
              <i class="fa-solid fa-arrows-spin text-blue-600 text-base"></i>
              <span>旋轉三角形方向：</span>
              <span id="rotDegLabel" class="text-blue-600 font-mono text-base w-12">0°</span>
            </div>
            <div class="flex items-center gap-3 flex-1 min-w-[200px]">
              <input type="range" id="rotSlider" min="0" max="360" value="0" oninput="onRotateSliderChange(this.value)" class="w-full h-2 bg-slate-200 rounded-lg appearance-none cursor-pointer range-slider">
            </div>
            <div class="flex items-center gap-1 text-xs">
              <button onclick="stepRotation(-45)" class="px-2.5 py-1 bg-white hover:bg-slate-100 border border-slate-300 rounded-lg font-bold">-45°</button>
              <button onclick="stepRotation(45)" class="px-2.5 py-1 bg-white hover:bg-slate-100 border border-slate-300 rounded-lg font-bold">+45°</button>
              <button onclick="stepRotation(90)" class="px-2.5 py-1 bg-white hover:bg-slate-100 border border-slate-300 rounded-lg font-bold">+90°</button>
            </div>
          </div>

          <!-- Quick Tip Banner -->
          <div id="sandboxTip" class="mt-3 p-3 bg-amber-50 border-l-4 border-amber-400 rounded-r-xl text-sm text-amber-900 flex items-start gap-3">
            <i class="fa-solid fa-lightbulb text-amber-500 text-lg mt-0.5"></i>
            <div>
              <strong class="font-bold">核心觀念：</strong>
              <span id="sandboxTipText">無論三角形如何旋轉或擺放，「高」始終垂直於「底」（夾角 90° 直角）！</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Control Panel (Right Column) -->
      <div class="lg:col-span-4 space-y-5">
        
        <!-- Base Selector -->
        <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200">
          <h2 class="text-base font-bold text-slate-800 mb-3 flex items-center gap-2">
            <i class="fa-solid fa-ruler-horizontal text-blue-600"></i> 指定選擇哪一條邊作為「底」
          </h2>
          <div class="grid grid-cols-3 gap-2">
            <button onclick="setBaseIndex(0)" id="base-btn-0" class="base-select-btn bg-blue-50 border-2 border-blue-600 text-blue-700 font-bold py-2.5 rounded-xl text-center text-sm shadow-sm">
              底：邊 BC
            </button>
            <button onclick="setBaseIndex(1)" id="base-btn-1" class="base-select-btn bg-slate-50 border-2 border-slate-200 text-slate-600 font-bold py-2.5 rounded-xl text-center text-sm hover:border-slate-300">
              底：邊 CA
            </button>
            <button onclick="setBaseIndex(2)" id="base-btn-2" class="base-select-btn bg-slate-50 border-2 border-slate-200 text-slate-600 font-bold py-2.5 rounded-xl text-center text-sm hover:border-slate-300">
              底：邊 AB
            </button>
          </div>
        </div>

        <!-- Quick Shape Templates -->
        <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200">
          <h2 class="text-base font-bold text-slate-800 mb-3 flex items-center gap-2">
            <i class="fa-solid fa-shapes text-indigo-600"></i> 快速切換三角形類型
          </h2>
          <div class="grid grid-cols-2 gap-2 text-sm">
            <button onclick="loadTemplate('acute')" class="p-2.5 bg-slate-50 border border-slate-200 hover:bg-indigo-50 hover:border-indigo-300 rounded-xl font-medium text-slate-700 text-left transition flex items-center gap-2">
              <span>🔺</span> 銳角三角形
            </button>
            <button onclick="loadTemplate('right')" class="p-2.5 bg-slate-50 border border-slate-200 hover:bg-indigo-50 hover:border-indigo-300 rounded-xl font-medium text-slate-700 text-left transition flex items-center gap-2">
              <span>📐</span> 直角三角形
            </button>
            <button onclick="loadTemplate('obtuse_in')" class="p-2.5 bg-slate-50 border border-slate-200 hover:bg-indigo-50 hover:border-indigo-300 rounded-xl font-medium text-slate-700 text-left transition flex items-center gap-2">
              <span>📐</span> 鈍角(高在內)
            </button>
            <button onclick="loadTemplate('obtuse_out')" class="p-2.5 bg-slate-50 border border-slate-200 hover:bg-indigo-50 hover:border-indigo-300 rounded-xl font-medium text-slate-700 text-left transition flex items-center gap-2">
              <span>⚠️</span> 鈍角(高在外)
            </button>
          </div>
        </div>

      </div>
    </section>

    <!-- ==================== SECTION 2: CONCEPT TUTORIAL ==================== -->
    <section id="view-tutorial" class="hidden space-y-6">
      
      <!-- Tutorial Navigation Banner -->
      <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
        <h2 class="text-2xl font-black text-slate-800 mb-2 flex items-center gap-2">
          <i class="fa-solid fa-graduation-cap text-blue-600"></i> 三角形「底和高」圖解觀念教室
        </h2>
        <p class="text-slate-600 text-sm">深入理解底與高的垂直關係、3組底高對應，以及直角與鈍角三角形特例！</p>
      </div>

      <!-- Tutorial Cards Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        
        <!-- Card 1: Standard Concept -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5 space-y-3">
          <div class="inline-block px-3 py-1 bg-blue-100 text-blue-700 text-xs font-bold rounded-full">重點 1</div>
          <h3 class="text-lg font-bold text-slate-800">什麼是「底」和「高」？</h3>
          <p class="text-sm text-slate-600 leading-relaxed">
            從三角形的一個<strong>頂點</strong>向對面<strong>「底」</strong>所在的直線畫出一條<strong>垂直線段</strong>，這條線段就是這個底對應的<strong>「高」</strong>。
          </p>
          <div class="p-3 bg-amber-50 rounded-xl text-amber-800 text-xs font-bold flex items-center gap-2">
            <i class="fa-solid fa-star text-amber-500"></i> ⭐ 底和高一定要互相垂直（夾角為 90° 直角）。
          </div>
          <canvas id="tutCanvas1" width="450" height="230" class="w-full border border-slate-100 rounded-xl"></canvas>
        </div>

        <!-- Card 2: 3 Pairs of Base & Height (REVISED TO 3 SEPARATE IDENTICAL TRIANGLES) -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5 space-y-3 col-span-1 md:col-span-2">
          <div class="inline-block px-3 py-1 bg-indigo-100 text-indigo-700 text-xs font-bold rounded-full">重點 2</div>
          <h3 class="text-lg font-bold text-slate-800">每個三角形都有 3 組「底和高」</h3>
          <p class="text-sm text-slate-600 leading-relaxed">
            三角形有 3 條邊，每一條邊都可以當作底。<strong>選定不同的邊作為底，就會有對應的高！</strong>
          </p>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 pt-2">
            <!-- Triangle 1: Base BC -->
            <div class="bg-slate-50 p-3 rounded-xl border border-slate-200 text-center space-y-2">
              <div class="text-xs font-bold text-blue-700 bg-blue-100 py-1 px-2 rounded-lg inline-block">
                第 1 組：以邊 BC 為底
              </div>
              <canvas id="tutCanvas2_1" width="300" height="190" class="w-full bg-white border border-slate-100 rounded-lg"></canvas>
            </div>

            <!-- Triangle 2: Base CA -->
            <div class="bg-slate-50 p-3 rounded-xl border border-slate-200 text-center space-y-2">
              <div class="text-xs font-bold text-emerald-700 bg-emerald-100 py-1 px-2 rounded-lg inline-block">
                第 2 組：以邊 CA 為底
              </div>
              <canvas id="tutCanvas2_2" width="300" height="190" class="w-full bg-white border border-slate-100 rounded-lg"></canvas>
            </div>

            <!-- Triangle 3: Base AB -->
            <div class="bg-slate-50 p-3 rounded-xl border border-slate-200 text-center space-y-2">
              <div class="text-xs font-bold text-amber-700 bg-amber-100 py-1 px-2 rounded-lg inline-block">
                第 3 組：以邊 AB 為底
              </div>
              <canvas id="tutCanvas2_3" width="300" height="190" class="w-full bg-white border border-slate-100 rounded-lg"></canvas>
            </div>
          </div>
        </div>

        <!-- Card 3: Right Triangle (REVISED FOR CLEAR 90 DEGREE MARK WITHOUT TEXT) -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5 space-y-3">
          <div class="inline-block px-3 py-1 bg-emerald-100 text-emerald-700 text-xs font-bold rounded-full">特例 1</div>
          <h3 class="text-lg font-bold text-slate-800">直角三角形：兩條直角邊互為「底和高」</h3>
          <p class="text-sm text-slate-600 leading-relaxed">
            直角三角形的兩條直角邊本身就互相垂直。因此，<strong>以其中一條直角邊為底時，另一條直角邊就是對應的高！</strong>
          </p>
          <canvas id="tutCanvas3" width="450" height="230" class="w-full border border-slate-100 rounded-xl"></canvas>
        </div>

        <!-- Card 4: Obtuse Triangle Outer Height -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5 space-y-3">
          <div class="inline-block px-3 py-1 bg-rose-100 text-rose-700 text-xs font-bold rounded-full">特例 2</div>
          <h3 class="text-lg font-bold text-slate-800">鈍角三角形：高可能落在三角形外部</h3>
          <p class="text-sm text-slate-600 leading-relaxed">
            當頂點無法直接垂直落在底邊上時，必須將底邊向外延伸成<strong>「延長線」</strong>。此時高會落在三角形外部！
          </p>
          <canvas id="tutCanvas4" width="450" height="230" class="w-full border border-slate-100 rounded-xl"></canvas>
        </div>

      </div>
    </section>

    <!-- ==================== SECTION 3: QUIZ / CHALLENGE MODE ==================== -->
    <section id="view-quiz" class="hidden space-y-6">
      
      <!-- Quiz Header & Scoreboard -->
      <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 class="text-2xl font-black text-slate-800 flex items-center gap-2">
            <i class="fa-solid fa-bullseye text-rose-500"></i> 隨堂挑戰：找出對應的「高」
          </h2>
          <p class="text-slate-600 text-sm">觀察標示藍色的「底」，選出哪一條線才是它正確對應的 90° 垂直高！</p>
        </div>

        <!-- Scoreboard Badges -->
        <div class="flex items-center gap-3">
          <div class="bg-blue-50 border border-blue-200 px-4 py-2 rounded-xl text-center">
            <div class="text-xs text-blue-600 font-bold">答對題數</div>
            <div id="quizScore" class="text-xl font-black text-blue-700">0</div>
          </div>
          <div class="bg-amber-50 border border-amber-200 px-4 py-2 rounded-xl text-center">
            <div class="text-xs text-amber-600 font-bold">連勝 Combo</div>
            <div id="quizStreak" class="text-xl font-black text-amber-600">0 🔥</div>
          </div>
        </div>
      </div>

      <!-- Quiz Main Area -->
      <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
        
        <!-- Quiz Canvas Display -->
        <div class="lg:col-span-7 bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col items-center justify-center">
          <div class="w-full text-center font-bold text-slate-800 text-base mb-3 flex items-center justify-center gap-2">
            <span class="inline-block w-3 h-3 rounded-full bg-blue-600"></span>
            <span id="quizQuestionPrompt">圖中的藍色線段是指定的「底」，哪一條顏色線段是它對應的「高」？</span>
          </div>

          <div class="canvas-container w-full overflow-hidden flex justify-center">
            <canvas id="quizCanvas" width="600" height="380" class="w-full h-auto border-2 border-slate-200 rounded-xl"></canvas>
          </div>
        </div>

        <!-- Options & Feedback Sidebar -->
        <div class="lg:col-span-5 space-y-4 flex flex-col justify-between">
          
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 space-y-4">
            <div class="flex items-center justify-between">
              <h3 class="font-bold text-slate-800 text-sm uppercase tracking-wider">請選擇正確線段：</h3>
              <span id="quizTypeBadge" class="text-xs font-bold px-2.5 py-1 rounded-full bg-blue-100 text-blue-700">三線辨識題</span>
            </div>

            <!-- Choice Buttons Grid -->
            <div id="quizOptionsContainer" class="grid grid-cols-1 gap-3">
              <!-- Choices generated dynamically via JS -->
            </div>
          </div>

          <!-- Answer Explanation Card -->
          <div id="quizFeedback" class="hidden p-5 rounded-2xl border transition-all duration-300">
            <div id="quizFeedbackTitle" class="font-black text-lg mb-1 flex items-center gap-2"></div>
            <p id="quizFeedbackBody" class="text-sm leading-relaxed mb-4"></p>
            <button onclick="generateNewQuizQuestion()" class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow-md transition flex items-center justify-center gap-2">
              <i class="fa-solid fa-arrow-right"></i> 下一題 🎯
            </button>
          </div>

        </div>

      </div>

    </section>

  </main>

  <script>
    /* =========================================================================
       GEOMETRY MATH & TRANSFORM HELPERS
       ========================================================================= */

    // Distance between 2 points
    function dist(p1, p2) {
      return Math.hypot(p2.x - p1.x, p2.y - p1.y);
    }

    // Perpendicular foot of P onto line through A and B
    function getPerpendicularFoot(P, A, B) {
      const dx = B.x - A.x;
      const dy = B.y - A.y;
      const lenSq = dx * dx + dy * dy;
      if (lenSq === 0) return { x: A.x, y: A.y, t: 0 };

      const t = ((P.x - A.x) * dx + (P.y - A.y) * dy) / lenSq;
      return {
        x: A.x + t * dx,
        y: A.y + t * dy,
        t: t // t in [0, 1] means foot is directly on segment AB
      };
    }

    // Rotate point P around center C by angleDeg
    function rotatePoint(P, C, angleDeg) {
      const rad = (angleDeg * Math.PI) / 180;
      const cos = Math.cos(rad);
      const sin = Math.sin(rad);
      const dx = P.x - C.x;
      const dy = P.y - C.y;
      return {
        x: C.x + dx * cos - dy * sin,
        y: C.y + dx * sin + dy * cos
      };
    }

    // Draw clean 90° Right Angle symbol at foot H along segment AB towards point P
    function drawRightAngleSymbol(ctx, H, A, B, P, size = 16, color = '#9333ea') {
      const vAB = { x: B.x - A.x, y: B.y - A.y };
      const lenAB = Math.hypot(vAB.x, vAB.y);
      if (lenAB === 0) return;
      const uAB = { x: vAB.x / lenAB, y: vAB.y / lenAB };

      const vHP = { x: P.x - H.x, y: P.y - H.y };
      const lenHP = Math.hypot(vHP.x, vHP.y);
      if (lenHP === 0) return;
      const uHP = { x: vHP.x / lenHP, y: vHP.y / lenHP };

      // Determine clean orientation along AB
      let dirAB = -1;
      if (H.t !== undefined && H.t < 0.5) dirAB = 1;

      const p1 = { x: H.x + uAB.x * size * dirAB, y: H.y + uAB.y * size * dirAB };
      const p2 = { x: p1.x + uHP.x * size, y: p1.y + uHP.y * size };
      const p3 = { x: H.x + uHP.x * size, y: H.y + uHP.y * size };

      ctx.save();
      ctx.beginPath();
      ctx.moveTo(p1.x, p1.y);
      ctx.lineTo(p2.x, p2.y);
      ctx.lineTo(p3.x, p3.y);
      ctx.strokeStyle = color;
      ctx.lineWidth = 3;
      ctx.stroke();
      ctx.restore();
    }

    // Background Grid
    function drawGrid(ctx, width, height, gridSize = 30) {
      ctx.save();
      ctx.strokeStyle = '#f1f5f9';
      ctx.lineWidth = 1;
      for (let x = 0; x <= width; x += gridSize) {
        ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke();
      }
      for (let y = 0; y <= height; y += gridSize) {
        ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
      }
      ctx.restore();
    }


    /* =========================================================================
       1. SANDBOX / EXPLORER MODULE (WITH ROTATION CONTROLS)
       ========================================================================= */

    const sbCanvas = document.getElementById('sandboxCanvas');
    const sbCtx = sbCanvas.getContext('2d');

    // Base triangle vertices in local coordinate space (Unrotated)
    let rawVertices = [
      { x: 350, y: 90, label: 'A' },
      { x: 180, y: 320, label: 'B' },
      { x: 530, y: 320, label: 'C' }
    ];

    let currentRotation = 0; // Rotation angle in degrees
    let currentBaseIndex = 0; // 0: BC, 1: CA, 2: AB
    let draggedVertexIndex = -1;

    // Center of canvas for rotation transformation
    const canvasCenter = { x: 350, y: 210 };

    // Get current rotated vertices
    function getRotatedVertices() {
      return rawVertices.map(v => {
        const rotated = rotatePoint(v, canvasCenter, currentRotation);
        return { x: rotated.x, y: rotated.y, label: v.label };
      });
    }

    function setBaseIndex(idx) {
      currentBaseIndex = idx;
      for (let i = 0; i < 3; i++) {
        const btn = document.getElementById(`base-btn-${i}`);
        if (i === idx) {
          btn.className = 'base-select-btn bg-blue-50 border-2 border-blue-600 text-blue-700 font-bold py-2.5 rounded-xl text-center text-sm shadow-sm';
        } else {
          btn.className = 'base-select-btn bg-slate-50 border-2 border-slate-200 text-slate-600 font-bold py-2.5 rounded-xl text-center text-sm hover:border-slate-300';
        }
      }
      renderSandbox();
    }

    function onRotateSliderChange(val) {
      currentRotation = parseInt(val, 10);
      document.getElementById('rotDegLabel').innerText = `${currentRotation}°`;
      renderSandbox();
    }

    function stepRotation(delta) {
      currentRotation = (currentRotation + delta + 360) % 360;
      document.getElementById('rotSlider').value = currentRotation;
      document.getElementById('rotDegLabel').innerText = `${currentRotation}°`;
      renderSandbox();
    }

    function loadTemplate(type) {
      if (type === 'acute') {
        rawVertices = [
          { x: 350, y: 90, label: 'A' },
          { x: 180, y: 320, label: 'B' },
          { x: 530, y: 320, label: 'C' }
        ];
        setBaseIndex(0);
      } else if (type === 'right') {
        rawVertices = [
          { x: 200, y: 90, label: 'A' },
          { x: 200, y: 320, label: 'B' },
          { x: 520, y: 320, label: 'C' }
        ];
        setBaseIndex(0);
      } else if (type === 'obtuse_in') {
        rawVertices = [
          { x: 420, y: 100, label: 'A' },
          { x: 150, y: 320, label: 'B' },
          { x: 560, y: 320, label: 'C' }
        ];
        setBaseIndex(0);
      } else if (type === 'obtuse_out') {
        rawVertices = [
          { x: 120, y: 110, label: 'A' },
          { x: 280, y: 320, label: 'B' },
          { x: 550, y: 320, label: 'C' }
        ];
        setBaseIndex(0);
      }
      renderSandbox();
    }

    function resetSandbox() {
      currentRotation = 0;
      document.getElementById('rotSlider').value = 0;
      document.getElementById('rotDegLabel').innerText = '0°';
      loadTemplate('acute');
    }

    function renderSandbox() {
      const width = sbCanvas.width;
      const height = sbCanvas.height;
      sbCtx.clearRect(0, 0, width, height);

      drawGrid(sbCtx, width, height);

      const rotVerts = getRotatedVertices();
      const A = rotVerts[0], B = rotVerts[1], C = rotVerts[2];

      const basePairs = [
        { base1: B, base2: C, top: A, baseName: 'BC', topName: 'A' },
        { base1: C, base2: A, top: B, baseName: 'CA', topName: 'B' },
        { base1: A, base2: B, top: C, baseName: 'AB', topName: 'C' }
      ];

      const currentPair = basePairs[currentBaseIndex];

      // Draw Triangle Fill & Perimeter
      sbCtx.beginPath();
      sbCtx.moveTo(A.x, A.y);
      sbCtx.lineTo(B.x, B.y);
      sbCtx.lineTo(C.x, C.y);
      sbCtx.closePath();
      sbCtx.fillStyle = 'rgba(239, 246, 255, 0.6)';
      sbCtx.fill();
      sbCtx.strokeStyle = '#64748b';
      sbCtx.lineWidth = 3;
      sbCtx.stroke();

      // Function to draw height and extended base
      function drawHeightForPair(pair, isPrimary = false, colorOverride = null) {
        const foot = getPerpendicularFoot(pair.top, pair.base1, pair.base2);

        // Extended Base dashed line if foot is outside segment
        if (foot.t < 0 || foot.t > 1) {
          const nearestBasePoint = (foot.t < 0) ? pair.base1 : pair.base2;
          sbCtx.save();
          sbCtx.beginPath();
          sbCtx.moveTo(nearestBasePoint.x, nearestBasePoint.y);
          sbCtx.lineTo(foot.x, foot.y);
          sbCtx.strokeStyle = isPrimary ? '#2563eb' : '#94a3b8';
          sbCtx.lineWidth = isPrimary ? 3 : 2;
          sbCtx.setLineDash([6, 4]);
          sbCtx.stroke();
          sbCtx.restore();
        }

        // Height Line
        const hColor = colorOverride || (isPrimary ? '#ef4444' : '#f87171');
        sbCtx.save();
        sbCtx.beginPath();
        sbCtx.moveTo(pair.top.x, pair.top.y);
        sbCtx.lineTo(foot.x, foot.y);
        sbCtx.strokeStyle = hColor;
        sbCtx.lineWidth = isPrimary ? 4 : 2;
        sbCtx.setLineDash([8, 4]);
        sbCtx.stroke();
        sbCtx.restore();

        // Right Angle Mark
        drawRightAngleSymbol(sbCtx, foot, pair.base1, pair.base2, pair.top, isPrimary ? 18 : 12, isPrimary ? '#9333ea' : '#c084fc');

        if (isPrimary) {
          // Label High
          const midH = { x: (pair.top.x + foot.x) / 2, y: (pair.top.y + foot.y) / 2 };
          sbCtx.fillStyle = '#dc2626';
          sbCtx.font = 'bold 18px "Noto Sans TC"';
          sbCtx.fillText('高', midH.x + 10, midH.y);
        }

        return { foot, heightLen: dist(pair.top, foot), baseLen: dist(pair.base1, pair.base2) };
      }

      // Highlight Selected Base Line
      sbCtx.save();
      sbCtx.beginPath();
      sbCtx.moveTo(currentPair.base1.x, currentPair.base1.y);
      sbCtx.lineTo(currentPair.base2.x, currentPair.base2.y);
      sbCtx.strokeStyle = '#2563eb';
      sbCtx.lineWidth = 7;
      sbCtx.stroke();
      sbCtx.restore();

      // Label Base
      const midB = { x: (currentPair.base1.x + currentPair.base2.x) / 2, y: (currentPair.base1.y + currentPair.base2.y) / 2 };
      sbCtx.fillStyle = '#1d4ed8';
      sbCtx.font = 'bold 18px "Noto Sans TC"';
      sbCtx.fillText('底', midB.x - 8, midB.y - 10);

      // Draw Primary Height
      const primaryMetrics = drawHeightForPair(currentPair, true);

      // Draw Draggable Vertex Handles
      rotVerts.forEach((v, idx) => {
        sbCtx.beginPath();
        sbCtx.arc(v.x, v.y, 11, 0, Math.PI * 2);
        sbCtx.fillStyle = (idx === draggedVertexIndex) ? '#3b82f6' : '#ffffff';
        sbCtx.fill();
        sbCtx.strokeStyle = '#1d4ed8';
        sbCtx.lineWidth = 3;
        sbCtx.stroke();

        sbCtx.fillStyle = '#0f172a';
        sbCtx.font = 'bold 18px "Noto Sans TC"';
        sbCtx.fillText(v.label, v.x - 6, v.y - 15);
      });

      // Dynamic Tip Message
      const isOuter = (primaryMetrics.foot.t < 0 || primaryMetrics.foot.t > 1);
      const tipText = document.getElementById('sandboxTipText');
      if (tipText) {
        if (isOuter) {
          tipText.innerHTML = `<span class="text-rose-600 font-bold">這是鈍角三角形！</span> 頂點無法直達底邊，因此底邊需向外延伸（虛線），高落在三角形外部！`;
        } else {
          tipText.innerHTML = `無論三角形轉動什麼角度，選定的「底」與對應的「高」始終維持 90° 垂直關係！`;
        }
      }
    }

    // Touch & Mouse Dragging handling with un-rotation calculation
    function getCanvasCoordinates(e, canvas) {
      const rect = canvas.getBoundingClientRect();
      const clientX = e.touches ? e.touches[0].clientX : e.clientX;
      const clientY = e.touches ? e.touches[0].clientY : e.clientY;
      const scaleX = canvas.width / rect.width;
      const scaleY = canvas.height / rect.height;
      return {
        x: (clientX - rect.left) * scaleX,
        y: (clientY - rect.top) * scaleY
      };
    }

    function handleStart(e) {
      const pt = getCanvasCoordinates(e, sbCanvas);
      const rotVerts = getRotatedVertices();

      for (let i = 0; i < rotVerts.length; i++) {
        if (Math.hypot(rotVerts[i].x - pt.x, rotVerts[i].y - pt.y) < 28) {
          draggedVertexIndex = i;
          renderSandbox();
          break;
        }
      }
    }

    function handleMove(e) {
      if (draggedVertexIndex === -1) return;
      e.preventDefault();
      const pt = getCanvasCoordinates(e, sbCanvas);

      // Unrotate screen point back to local coordinate space
      const unrotatedPt = rotatePoint(pt, canvasCenter, -currentRotation);

      // Clamp within limits
      rawVertices[draggedVertexIndex].x = Math.max(30, Math.min(sbCanvas.width - 30, unrotatedPt.x));
      rawVertices[draggedVertexIndex].y = Math.max(30, Math.min(sbCanvas.height - 30, unrotatedPt.y));

      renderSandbox();
    }

    function handleEnd() {
      draggedVertexIndex = -1;
      renderSandbox();
    }

    sbCanvas.addEventListener('mousedown', handleStart);
    sbCanvas.addEventListener('mousemove', handleMove);
    window.addEventListener('mouseup', handleEnd);

    sbCanvas.addEventListener('touchstart', handleStart, { passive: false });
    sbCanvas.addEventListener('touchmove', handleMove, { passive: false });
    window.addEventListener('touchend', handleEnd);


    /* =========================================================================
       2. CONCEPT TUTORIAL DRAWINGS (REVISED ACCORDING TO USER FEEDBACK)
       ========================================================================= */

    let currentTut2PairIdx = 0;

    function setTut2Pair(idx) {
      currentTut2PairIdx = idx;
      for (let i = 0; i < 4; i++) {
        const btn = document.getElementById(`tut2-btn-${i}`);
        if (i === idx) {
          btn.className = 'px-2 py-1 rounded-md bg-blue-600 text-white font-bold';
        } else {
          btn.className = 'px-2 py-1 rounded-md bg-slate-100 text-slate-700 font-bold hover:bg-slate-200';
        }
      }
      
      const descs = [
        "第一組：以邊 BC 為「底 1」(藍色)，頂點 A 到底的垂直線為「高 1」(紅色)。",
        "第二組：以邊 CA 為「底 2」(綠色)，頂點 B 到底的垂直线為「高 2」(綠色)。",
        "第三組：以邊 AB 為「底 3」(橘色)，頂點 C 到底的垂直線為「高 3」(橘色)。",
        "全顯模式：一個三角形同時擁有 3 組相對應的底和高！"
      ];
      document.getElementById('tut2Desc').innerText = descs[idx];

      drawTutCanvas2();
    }

    function drawTutorials() {
      // Tutorial Canvas 1: Basic Concept
      const c1 = document.getElementById('tutCanvas1');
      if (c1) {
        const ctx = c1.getContext('2d');
        ctx.clearRect(0, 0, 450, 230);
        drawGrid(ctx, 450, 230);

        const A = { x: 220, y: 40 }, B = { x: 80, y: 190 }, C = { x: 380, y: 190 };
        const H = getPerpendicularFoot(A, B, C);

        // Triangle
        ctx.beginPath(); ctx.moveTo(A.x, A.y); ctx.lineTo(B.x, B.y); ctx.lineTo(C.x, C.y); ctx.closePath();
        ctx.fillStyle = '#f0f7ff'; ctx.fill(); ctx.strokeStyle = '#64748b'; ctx.lineWidth = 2; ctx.stroke();

        // Base BC
        ctx.beginPath(); ctx.moveTo(B.x, B.y); ctx.lineTo(C.x, C.y);
        ctx.strokeStyle = '#2563eb'; ctx.lineWidth = 6; ctx.stroke();

        // Height AH
        ctx.save();
        ctx.beginPath(); ctx.moveTo(A.x, A.y); ctx.lineTo(H.x, H.y);
        ctx.strokeStyle = '#ef4444'; ctx.lineWidth = 4;
        ctx.setLineDash([6, 4]);
        ctx.stroke();
        ctx.restore();

        drawRightAngleSymbol(ctx, H, B, C, A, 16, '#9333ea');

        ctx.fillStyle = '#2563eb'; ctx.font = 'bold 16px "Noto Sans TC"'; ctx.fillText('底', 220, 215);
        ctx.fillStyle = '#ef4444'; ctx.font = 'bold 16px "Noto Sans TC"'; ctx.fillText('高', 230, 115);
      }

      drawTutCanvas2();

      // Tutorial Canvas 3: Right Triangle (REVISED FOR CLEAR 90° SYMBOL WITHOUT "90°" TEXT)
      const c3 = document.getElementById('tutCanvas3');
      if (c3) {
        const ctx = c3.getContext('2d');
        ctx.clearRect(0, 0, 450, 230);
        drawGrid(ctx, 450, 230);

        const A = { x: 120, y: 50 }, B = { x: 120, y: 180 }, C = { x: 360, y: 180 };

        // Triangle
        ctx.beginPath(); ctx.moveTo(A.x, A.y); ctx.lineTo(B.x, B.y); ctx.lineTo(C.x, C.y); ctx.closePath();
        ctx.fillStyle = '#f0f7ff'; ctx.fill(); ctx.strokeStyle = '#64748b'; ctx.lineWidth = 2; ctx.stroke();

        // Base BC (Blue)
        ctx.beginPath(); ctx.moveTo(B.x, B.y); ctx.lineTo(C.x, C.y);
        ctx.strokeStyle = '#2563eb'; ctx.lineWidth = 6; ctx.stroke();

        // Height AB (Red)
        ctx.save();
        ctx.beginPath(); ctx.moveTo(A.x, A.y); ctx.lineTo(B.x, B.y);
        ctx.strokeStyle = '#ef4444'; ctx.lineWidth = 6;
        ctx.setLineDash([6, 4]);
        ctx.stroke();
        ctx.restore();

        // Distinct Right Angle Box inside vertex B (No text added)
        ctx.fillStyle = 'rgba(147, 51, 234, 0.15)';
        ctx.fillRect(B.x, B.y - 22, 22, 22);
        ctx.strokeStyle = '#9333ea'; ctx.lineWidth = 3;
        ctx.strokeRect(B.x, B.y - 22, 22, 22);

        // Text Labels
        ctx.fillStyle = '#2563eb'; ctx.font = 'bold 16px "Noto Sans TC"'; ctx.fillText('底 (直角邊)', 220, 210);
        ctx.fillStyle = '#ef4444'; ctx.font = 'bold 16px "Noto Sans TC"'; ctx.fillText('高 (直角邊)', 15, 115);
      }

      // Tutorial Canvas 4: Obtuse Outer Height
      const c4 = document.getElementById('tutCanvas4');
      if (c4) {
        const ctx = c4.getContext('2d');
        ctx.clearRect(0, 0, 450, 230);
        drawGrid(ctx, 450, 230);

        const A = { x: 90, y: 50 }, B = { x: 220, y: 180 }, C = { x: 390, y: 180 };
        const H = getPerpendicularFoot(A, B, C);

        // Extended Base line
        ctx.beginPath(); ctx.moveTo(B.x, B.y); ctx.lineTo(H.x, H.y);
        ctx.strokeStyle = '#2563eb'; ctx.lineWidth = 3; ctx.setLineDash([5, 4]); ctx.stroke(); ctx.setLineDash([]);

        // Triangle
        ctx.beginPath(); ctx.moveTo(A.x, A.y); ctx.lineTo(B.x, B.y); ctx.lineTo(C.x, C.y); ctx.closePath();
        ctx.fillStyle = '#f0f7ff'; ctx.fill(); ctx.strokeStyle = '#64748b'; ctx.lineWidth = 2; ctx.stroke();

        // Base BC
        ctx.beginPath(); ctx.moveTo(B.x, B.y); ctx.lineTo(C.x, C.y);
        ctx.strokeStyle = '#2563eb'; ctx.lineWidth = 6; ctx.stroke();

        // Outer Height
        ctx.beginPath(); ctx.moveTo(A.x, A.y); ctx.lineTo(H.x, H.y);
        ctx.strokeStyle = '#ef4444'; ctx.lineWidth = 4; ctx.setLineDash([6, 4]); ctx.stroke(); ctx.setLineDash([]);

        drawRightAngleSymbol(ctx, H, B, C, A, 16, '#9333ea');

        ctx.fillStyle = '#2563eb'; ctx.font = 'bold 16px "Noto Sans TC"'; ctx.fillText('底', 290, 205);
        ctx.fillStyle = '#ef4444'; ctx.font = 'bold 16px "Noto Sans TC"'; ctx.fillText('高 (在外部)', 20, 120);
        ctx.fillStyle = '#2563eb'; ctx.font = '13px "Noto Sans TC"'; ctx.fillText('底邊延長線', 130, 200);
      }
    }

    // DRAW 3 INDIVIDUAL IDENTICAL TRIANGLES FOR KEY POINT 2
    function drawTutCanvas2() {
      const A = { x: 150, y: 35 }, B = { x: 40, y: 150 }, C = { x: 260, y: 150 };

      const configs = [
        {
          canvasId: 'tutCanvas2_1',
          base1: B, base2: C, top: A,
          baseColor: '#2563eb', heightColor: '#ef4444',
          baseText: '底 (BC)', heightText: '高 1',
          textPos: { b: { x: 135, y: 175 }, h: { x: 160, y: 95 } }
        },
        {
          canvasId: 'tutCanvas2_2',
          base1: C, base2: A, top: B,
          baseColor: '#059669', heightColor: '#10b981',
          baseText: '底 (CA)', heightText: '高 2',
          textPos: { b: { x: 215, y: 85 }, h: { x: 80, y: 125 } }
        },
        {
          canvasId: 'tutCanvas2_3',
          base1: A, base2: B, top: C,
          baseColor: '#d97706', heightColor: '#f59e0b',
          baseText: '底 (AB)', heightText: '高 3',
          textPos: { b: { x: 60, y: 85 }, h: { x: 190, y: 110 } }
        }
      ];

      configs.forEach(cfg => {
        const c = document.getElementById(cfg.canvasId);
        if (!c) return;
        const ctx = c.getContext('2d');
        ctx.clearRect(0, 0, c.width, c.height);
        drawGrid(ctx, c.width, c.height);

        // Fill & Outer Border
        ctx.beginPath(); ctx.moveTo(A.x, A.y); ctx.lineTo(B.x, B.y); ctx.lineTo(C.x, C.y); ctx.closePath();
        ctx.fillStyle = '#f8fafc'; ctx.fill(); ctx.strokeStyle = '#94a3b8'; ctx.lineWidth = 2; ctx.stroke();

        // Highlight Base
        ctx.beginPath(); ctx.moveTo(cfg.base1.x, cfg.base1.y); ctx.lineTo(cfg.base2.x, cfg.base2.y);
        ctx.strokeStyle = cfg.baseColor; ctx.lineWidth = 6; ctx.stroke();

        // Foot & Height
        const foot = getPerpendicularFoot(cfg.top, cfg.base1, cfg.base2);
        ctx.save();
        ctx.beginPath(); ctx.moveTo(cfg.top.x, cfg.top.y); ctx.lineTo(foot.x, foot.y);
        ctx.strokeStyle = cfg.heightColor; ctx.lineWidth = 4;
        ctx.setLineDash([6, 4]);
        ctx.stroke();
        ctx.restore();

        drawRightAngleSymbol(ctx, foot, cfg.base1, cfg.base2, cfg.top, 12, cfg.heightColor);

        // Labels
        ctx.fillStyle = cfg.baseColor;
        ctx.font = 'bold 14px "Noto Sans TC"';
        ctx.fillText(cfg.baseText, cfg.textPos.b.x, cfg.textPos.b.y);

        ctx.fillStyle = cfg.heightColor;
        ctx.font = 'bold 14px "Noto Sans TC"';
        ctx.fillText(cfg.heightText, cfg.textPos.h.x, cfg.textPos.h.y);
      });
    }

    /* =========================================================================
       3. NAVIGATION TABS CONTROLLER
       ========================================================================= */

    function switchTab(tabName) {
      const tabs = ['explore', 'tutorial', 'quiz'];
      tabs.forEach(t => {
        const view = document.getElementById(`view-${t}`);
        const btn = document.getElementById(`tab-${t}`);
        if (t === tabName) {
          if (view) view.classList.remove('hidden');
          if (btn) {
            btn.classList.add('active');
            btn.classList.remove('text-slate-600');
          }
        } else {
          if (view) view.classList.add('hidden');
          if (btn) {
            btn.classList.remove('active');
            btn.classList.add('text-slate-600');
          }
        }
      });

      if (tabName === 'explore') {
        renderSandbox();
      } else if (tabName === 'tutorial') {
        drawTutorials();
      } else if (tabName === 'quiz') {
        if (!currentQuestionData) {
          generateNewQuizQuestion();
        } else {
          drawQuizQuestion();
        }
      }
    }


    /* =========================================================================
       4. QUIZ / CHALLENGE GAME ENGINE
       ========================================================================= */

    const qCanvas = document.getElementById('quizCanvas');
    const qCtx = qCanvas.getContext('2d');

    let quizScore = 0;
    let quizStreak = 0;
    let currentQuestionData = null;
    let lastFailedType = null; // 紀錄學生答錯的三角形類型，用於產生相似加強題型

    function generateNewQuizQuestion() {
      // Reset Feedback UI
      const fb = document.getElementById('quizFeedback');
      fb.classList.add('hidden');

      // Triangle Type selection: use last failed type if available for targeted practice
      const types = ['acute', 'right', 'obtuse'];
      const qType = lastFailedType ? lastFailedType : types[Math.floor(Math.random() * types.length)];
      const baseIdx = Math.floor(Math.random() * 3); // 0: BC, 1: CA, 2: AB
      const rotAngle = Math.floor(Math.random() * 8) * 45; // 0, 45, 90, ..., 315 deg

      let rawVerts = [];
      if (qType === 'acute') {
        rawVerts = [
          { x: 300, y: 80 },  // A
          { x: 140, y: 300 }, // B
          { x: 460, y: 300 }  // C
        ];
      } else if (qType === 'right') {
        rawVerts = [
          { x: 160, y: 80 },  // A
          { x: 160, y: 300 }, // B
          { x: 440, y: 300 }  // C
        ];
      } else {
        // obtuse
        rawVerts = [
          { x: 100, y: 90 },  // A
          { x: 250, y: 300 }, // B
          { x: 480, y: 300 }  // C
        ];
      }

      // Rotate Vertices
      const center = { x: 300, y: 190 };
      const verts = rawVerts.map(v => rotatePoint(v, center, rotAngle));

      // Base pairs
      const basePairs = [
        { b1: verts[1], b2: verts[2], top: verts[0] }, // Base BC, Top A
        { b1: verts[2], b2: verts[0], top: verts[1] }, // Base CA, Top B
        { b1: verts[0], b2: verts[1], top: verts[2] }  // Base AB, Top C
      ];
      const curBase = basePairs[baseIdx];

      // True Height Foot
      const trueFoot = getPerpendicularFoot(curBase.top, curBase.b1, curBase.b2);

      // Create 3 Choices from Top Vertex
      // 1. True Height Line
      const choiceTrue = {
        type: 'true',
        start: curBase.top,
        end: trueFoot,
        isCorrect: true,
        desc: "這條線從頂點出發，並與「底」成 90° 垂直，是正確的高！"
      };

      // 2. Slanted Distractor 1 (to midpoint or off-target)
      const midPoint = { x: (curBase.b1.x + curBase.b2.x) / 2, y: (curBase.b1.y + curBase.b2.y) / 2 };
      const dist1Foot = (dist(trueFoot, midPoint) > 25) ? midPoint : { x: curBase.b1.x * 0.3 + curBase.b2.x * 0.7, y: curBase.b1.y * 0.3 + curBase.b2.y * 0.7 };
      const choiceDist1 = {
        type: 'dist1',
        start: curBase.top,
        end: dist1Foot,
        isCorrect: false,
        desc: "這條線沒有與底邊垂直（角度不是 90°），所以不是高。"
      };

      // 3. Off-target / Side Distractor 2
      const dist2Foot = { x: curBase.b1.x * 0.8 + curBase.b2.x * 0.2, y: curBase.b1.y * 0.8 + curBase.b2.y * 0.2 };
      const choiceDist2 = {
        type: 'dist2',
        start: curBase.top,
        end: dist2Foot,
        isCorrect: false,
        desc: "這條線是斜線，沒有與底邊互相垂直。"
      };

      // Shuffle Choices & Assign Colors/Labels A, B, C
      const rawChoices = [choiceTrue, choiceDist1, choiceDist2].sort(() => Math.random() - 0.5);
      const labels = ['A', 'B', 'C'];
      const colors = ['#ef4444', '#f59e0b', '#10b981'];

      const choices = rawChoices.map((c, i) => ({
        ...c,
        label: labels[i],
        color: colors[i]
      }));

      const correctChoice = choices.find(c => c.isCorrect);

      currentQuestionData = {
        vertices: verts,
        baseIdx,
        qType,
        rotAngle,
        choices,
        correctLabel: correctChoice.label,
        correctDesc: correctChoice.desc,
        answered: false
      };

      // Render Options Buttons
      const optsContainer = document.getElementById('quizOptionsContainer');
      optsContainer.innerHTML = '';

      choices.forEach(c => {
        const btn = document.createElement('button');
        btn.onclick = () => submitQuizAnswer(c.label);
        btn.className = 'w-full py-3.5 px-4 rounded-xl border-2 font-bold text-left text-base transition flex items-center justify-between hover:scale-[1.01] active:scale-[0.99]';
        btn.style.borderColor = c.color;
        btn.style.color = '#1e293b';
        btn.style.backgroundColor = '#ffffff';

        btn.innerHTML = `
          <div class="flex items-center gap-3">
            <span class="w-8 h-8 rounded-lg flex items-center justify-center font-black text-white text-sm" style="background-color: ${c.color}">${c.label}</span>
            <span>線段 ${c.label}</span>
          </div>
          <i class="fa-solid fa-chevron-right text-slate-400"></i>
        `;
        optsContainer.appendChild(btn);
      });

      // Update Question Type Badge
      const typeBadge = document.getElementById('quizTypeBadge');
      const typeNames = { acute: '銳角三角形', right: '直角三角形', obtuse: '鈍角三角形' };

      if (lastFailedType) {
        typeBadge.innerText = `加強練習：${typeNames[qType]}`;
        typeBadge.className = 'text-xs font-bold px-2.5 py-1 rounded-full bg-amber-100 text-amber-800 border border-amber-300';
      } else if (rotAngle !== 0) {
        typeBadge.innerText = `多角度旋轉題 (${rotAngle}°)`;
        typeBadge.className = 'text-xs font-bold px-2.5 py-1 rounded-full bg-purple-100 text-purple-700';
      } else {
        typeBadge.innerText = `標準辨識題`;
        typeBadge.className = 'text-xs font-bold px-2.5 py-1 rounded-full bg-blue-100 text-blue-700';
      }

      drawQuizQuestion();
    }

    function drawQuizQuestion() {
      qCtx.clearRect(0, 0, qCanvas.width, qCanvas.height);
      drawGrid(qCtx, qCanvas.width, qCanvas.height);

      const v = currentQuestionData.vertices;
      const baseIdx = currentQuestionData.baseIdx;

      const basePairs = [
        { b1: v[1], b2: v[2], top: v[0] }, // Base BC
        { b1: v[2], b2: v[0], top: v[1] }, // Base CA
        { b1: v[0], b2: v[1], top: v[2] }  // Base AB
      ];
      const curBase = basePairs[baseIdx];

      // Extension line if foot is outside
      const foot = getPerpendicularFoot(curBase.top, curBase.b1, curBase.b2);
      if (foot.t < 0 || foot.t > 1) {
        const nearest = foot.t < 0 ? curBase.b1 : curBase.b2;
        qCtx.save();
        qCtx.beginPath(); qCtx.moveTo(nearest.x, nearest.y); qCtx.lineTo(foot.x, foot.y);
        qCtx.strokeStyle = '#94a3b8'; qCtx.lineWidth = 2; qCtx.setLineDash([5, 4]); qCtx.stroke();
        qCtx.restore();
      }

      // Draw Triangle
      qCtx.beginPath();
      qCtx.moveTo(v[0].x, v[0].y);
      qCtx.lineTo(v[1].x, v[1].y);
      qCtx.lineTo(v[2].x, v[2].y);
      qCtx.closePath();
      qCtx.fillStyle = 'rgba(241, 245, 249, 0.5)';
      qCtx.fill();
      qCtx.strokeStyle = '#475569';
      qCtx.lineWidth = 3;
      qCtx.stroke();

      // Highlight Selected Base Line in Blue
      qCtx.beginPath();
      qCtx.moveTo(curBase.b1.x, curBase.b1.y);
      qCtx.lineTo(curBase.b2.x, curBase.b2.y);
      qCtx.strokeStyle = '#2563eb';
      qCtx.lineWidth = 8;
      qCtx.stroke();

      // Base Label - SIMPLIFIED TO JUST "底"
      const midB = { x: (curBase.b1.x + curBase.b2.x)/2, y: (curBase.b1.y + curBase.b2.y)/2 };
      qCtx.fillStyle = '#1d4ed8';
      qCtx.font = 'bold 20px "Noto Sans TC"';
      qCtx.fillText('底', midB.x - 10, midB.y - 12);

      // Draw Candidate Height Lines A, B, C
      currentQuestionData.choices.forEach(c => {
        qCtx.save();
        qCtx.beginPath();
        qCtx.moveTo(c.start.x, c.start.y);
        qCtx.lineTo(c.end.x, c.end.y);
        qCtx.strokeStyle = c.color;
        qCtx.lineWidth = 5;
        qCtx.setLineDash([8, 4]);
        qCtx.stroke();
        qCtx.restore();

        // Choice Label
        const midX = (c.start.x + c.end.x) / 2;
        const midY = (c.start.y + c.end.y) / 2;

        qCtx.fillStyle = c.color;
        qCtx.font = 'black 22px "Noto Sans TC"';
        qCtx.fillText(c.label, midX + 10, midY);
      });

      // Reveal Right Angle symbol when answered
      if (currentQuestionData.answered) {
        drawRightAngleSymbol(qCtx, foot, curBase.b1, curBase.b2, curBase.top, 18, '#9333ea');
      }
    }

    function submitQuizAnswer(selectedLabel) {
      if (currentQuestionData.answered) return;

      currentQuestionData.answered = true;
      const isCorrect = (selectedLabel === currentQuestionData.correctLabel);

      const fb = document.getElementById('quizFeedback');
      const fbTitle = document.getElementById('quizFeedbackTitle');
      const fbBody = document.getElementById('quizFeedbackBody');

      fb.classList.remove('hidden');

      if (isCorrect) {
        quizScore += 1;
        quizStreak += 1;
        lastFailedType = null; // 答對時清除答錯紀錄，恢復隨機出題
        fb.className = 'p-5 rounded-2xl border transition-all duration-300 bg-emerald-50 border-emerald-300 text-emerald-900';
        fbTitle.innerHTML = `<i class="fa-solid fa-circle-check text-emerald-600"></i> 答對了！非常棒！`;
        fbBody.innerHTML = `正確答案是 <strong>線段 ${selectedLabel}</strong>。<br>${currentQuestionData.correctDesc}`;
      } else {
        quizStreak = 0;
        lastFailedType = currentQuestionData.qType; // 答錯時記錄此題型，下一題將推出相似題型
        fb.className = 'p-5 rounded-2xl border transition-all duration-300 bg-rose-50 border-rose-300 text-rose-900';
        fbTitle.innerHTML = `<i class="fa-solid fa-circle-xmark text-rose-600"></i> 再想一想喔！`;
        fbBody.innerHTML = `正確答案應該是 <strong>線段 ${currentQuestionData.correctLabel}</strong>。<br>${currentQuestionData.correctDesc}<br><span class="text-xs font-bold text-amber-800 bg-amber-100 px-2.5 py-1 rounded-lg inline-flex items-center gap-1.5 mt-2 border border-amber-200"><i class="fa-solid fa-rotate-right text-amber-600"></i> 下一題將推出相似題型為你加強練習！</span>`;
      }

      document.getElementById('quizScore').innerText = quizScore;
      document.getElementById('quizStreak').innerText = `${quizStreak} 🔥`;

      drawQuizQuestion();
    }

    // Initialize application on page load
    window.onload = function() {
      renderSandbox();
      drawTutorials();
    };
  </script>
</body>
</html>
