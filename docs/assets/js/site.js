(() => {
  "use strict";

  // =========================================================
  // IIFE (Immediately Invoked Function Expression)
  // ---------------------------------------------------------
  // Le script est encapsulé dans une fonction exécutée
  // immédiatement :
  // - pas de pollution de l’espace global
  // - usage de "use strict"
  // - organisation plus propre du code
  // =========================================================

  console.log("[site.js] Wilde edition loaded");

  // =========================================================
  // RACCOURCIS DOM
  // ---------------------------------------------------------
  // $  = sélectionne le premier élément correspondant
  // $$ = sélectionne tous les éléments correspondants
  //      et renvoie un vrai tableau
  // =========================================================
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => Array.from(root.querySelectorAll(selector));

  // =========================================================
  // OVERLAYS (zones interactives sur les manuscrits)
  // ---------------------------------------------------------
  // Le site charge des fichiers JSON contenant soit :
  // - des "lines" (polygones)
  // - des "boxes" (rectangles)
  //
  // Ces données sont dessinées dans un SVG superposé à l’image.
  // Au survol, on affiche le texte correspondant.
  // =========================================================

  const SVG_NS = "http://www.w3.org/2000/svg";

  // Set pour éviter de dessiner deux fois le même overlay
  const drawnKeys = new Set();

  // Crée un élément SVG (<rect>, <polygon>, <text>…)
  const el = (name) => document.createElementNS(SVG_NS, name);

  // Vide complètement un nœud
  const clear = (node) => {
    while (node.firstChild) node.removeChild(node.firstChild);
  };

  // Limite une valeur entre un min et un max
  const clamp = (n, min, max) => Math.max(min, Math.min(max, n));

  // Convertit un tableau de points [[x,y], [x,y], ...]
  // en chaîne SVG "x1,y1 x2,y2 x3,y3"
  const pointsToAttr = (pts) =>
    pts.map(([x, y]) => `${x},${y}`).join(" ");

  // ---------------------------------------------------------
  // Calcule la médiane d’un tableau numérique
  // Sert ici à estimer une hauteur de ligne "typique"
  // ---------------------------------------------------------
  function median(arr) {
    if (!arr.length) return 0;

    const sorted = [...arr].sort((a, b) => a - b);
    const m = Math.floor(sorted.length / 2);

    return sorted.length % 2
      ? sorted[m]
      : (sorted[m - 1] + sorted[m]) / 2;
  }

  // ---------------------------------------------------------
  // Calcule la bounding box d’un polygone
  // Retour :
  // { x, y, w, h }
  // ---------------------------------------------------------
  function bboxFromPoints(pts) {
    let minX = Infinity;
    let minY = Infinity;
    let maxX = -Infinity;
    let maxY = -Infinity;

    for (const [x, y] of pts) {
      minX = Math.min(minX, x);
      minY = Math.min(minY, y);
      maxX = Math.max(maxX, x);
      maxY = Math.max(maxY, y);
    }

    return {
      x: minX,
      y: minY,
      w: maxX - minX,
      h: maxY - minY
    };
  }

  // ---------------------------------------------------------
  // Prépare le SVG :
  // - ajoute la classe
  // - définit le viewBox
  // - vide un ancien contenu
  // ---------------------------------------------------------
  function ensureSvgSetup(svg, width, height) {
    svg.classList.add("ms-svg");
    svg.setAttribute("viewBox", `0 0 ${width} ${height}`);
    svg.setAttribute("preserveAspectRatio", "xMidYMid meet");
    clear(svg);
  }

  // ---------------------------------------------------------
  // Charge le JSON d’overlay correspondant à une page
  // Exemple :
  // assets/overlays/lane_01.json
  // ---------------------------------------------------------
  async function fetchOverlay(key) {
    const url = new URL(`assets/overlays/${key}.json`, document.baseURI).toString();
    const res = await fetch(url, { cache: "no-store" });

    if (!res.ok) {
      throw new Error(`Overlay JSON ${url} -> HTTP ${res.status}`);
    }

    return res.json();
  }

  // ---------------------------------------------------------
  // Mesure la taille affichée réelle de l’image à l’écran
  // et calcule les ratios entre dimensions natives et rendues
  // ---------------------------------------------------------
  function getRenderedScale(img, width, height) {
    const rect = img.getBoundingClientRect();

    const renderedW = rect.width || img.clientWidth || 0;
    const renderedH = rect.height || img.clientHeight || 0;

    return {
      renderedW,
      renderedH,
      scaleX: renderedW > 0 ? renderedW / width : 0,
      scaleY: renderedH > 0 ? renderedH / height : 0
    };
  }

  // ---------------------------------------------------------
  // Taille idéale du texte overlay en pixels écran
  // ---------------------------------------------------------
  function desiredFontPxOnScreen(renderedH) {
    return clamp(renderedH * 0.04, 18, 34);
  }

  // ---------------------------------------------------------
  // Convertit des pixels écran en unités SVG
  // ---------------------------------------------------------
  function pxScreenToSvgUnits(px, scaleY) {
    return !scaleY ? px : px / scaleY;
  }

  // ---------------------------------------------------------
  // Style du texte overlay SVG
  // ---------------------------------------------------------
  function setOverlayTextStyle(textEl, fontSvgUnits) {
    const fs = clamp(fontSvgUnits, 16, 120);

    textEl.classList.add("ms-txt");
    textEl.setAttribute("font-size", String(fs));
    textEl.setAttribute("fill", "rgba(0,0,0,0.72)");
    textEl.setAttribute("font-weight", "600");
    textEl.setAttribute("paint-order", "stroke");
    textEl.setAttribute("stroke", "rgba(255,255,255,0.90)");
    textEl.setAttribute("stroke-linejoin", "round");
    textEl.setAttribute("stroke-width", String(clamp(fs * 0.18, 2.2, 7.5)));
  }

  // ---------------------------------------------------------
  // Calcule une taille de police cohérente pour toute une page
  // ---------------------------------------------------------
  function computeUniformFontUnitsForPage(img, width, height, hintMedianH) {
    const { renderedH, scaleY } = getRenderedScale(img, width, height);

    const basePx = desiredFontPxOnScreen(renderedH);
    let baseUnits = pxScreenToSvgUnits(basePx, scaleY);

    if (hintMedianH > 0) {
      baseUnits *= clamp(32 / hintMedianH, 0.85, 1.20);
    }

    return baseUnits;
  }

  // ---------------------------------------------------------
  // Place le texte SVG sur le premier point d’un polygone
  // ---------------------------------------------------------
  function placeTextAtFirstPoint(textEl, points) {
    const [x0, y0] = points[0];
    textEl.setAttribute("x", x0);
    textEl.setAttribute("y", y0);
    textEl.setAttribute("dominant-baseline", "hanging");
  }

  // ---------------------------------------------------------
  // Place le texte SVG dans une boîte rectangulaire
  // ---------------------------------------------------------
  function placeTextAtBox(textEl, box) {
    textEl.setAttribute("x", box.x);
    textEl.setAttribute("y", box.y);
    textEl.setAttribute("dominant-baseline", "hanging");
  }

  // ---------------------------------------------------------
  // Dessine les overlays de type "lines" (polygones)
  // ---------------------------------------------------------
  function drawFromLines(svg, data, key, width, height, img) {
    const lines = Array.isArray(data.lines) ? data.lines : [];

    const heights = lines
      .filter((line) => line && Array.isArray(line.points) && line.points.length >= 3)
      .map((line) => bboxFromPoints(line.points).h)
      .filter((h) => h > 0);

    const baseUnits = computeUniformFontUnitsForPage(img, width, height, median(heights));

    for (const line of lines) {
      if (!line || !Array.isArray(line.points) || line.points.length < 3) continue;

      // Zone interactive
      const poly = el("polygon");
      poly.setAttribute("points", pointsToAttr(line.points));
      poly.classList.add("ms-hit");
      poly.setAttribute("pointer-events", "all");

      if (line.id) poly.dataset.lineId = line.id;

      // Texte affiché au survol
      const txt = el("text");
      txt.textContent = line.text || "";

      setOverlayTextStyle(txt, baseUnits);
      placeTextAtFirstPoint(txt, line.points);

      poly.addEventListener("mouseenter", () => {
        poly.classList.add("is-hover");
        txt.classList.add("is-visible");
      });

      poly.addEventListener("mouseleave", () => {
        poly.classList.remove("is-hover");
        txt.classList.remove("is-visible");
      });

      svg.appendChild(poly);
      svg.appendChild(txt);
    }
  }

  // ---------------------------------------------------------
  // Dessine les overlays de type "boxes" (rectangles)
  // ---------------------------------------------------------
  function drawFromBoxes(svg, data, key, width, height, img) {
    const boxes = Array.isArray(data.boxes) ? data.boxes : [];

    const heights = boxes
      .map((b) => (b && typeof b.h === "number" ? b.h : 0))
      .filter((h) => h > 0);

    const baseUnits = computeUniformFontUnitsForPage(img, width, height, median(heights));

    for (const box of boxes) {
      if (!box || typeof box.x !== "number" || typeof box.y !== "number") continue;

      // Zone interactive
      const rect = el("rect");
      rect.setAttribute("x", box.x);
      rect.setAttribute("y", box.y);
      rect.setAttribute("width", typeof box.w === "number" ? box.w : 0);
      rect.setAttribute("height", typeof box.h === "number" ? box.h : 0);
      rect.classList.add("ms-hit");
      rect.setAttribute("pointer-events", "all");

      // Texte affiché au survol
      const txt = el("text");
      txt.textContent = box.t || "";

      setOverlayTextStyle(txt, baseUnits);
      placeTextAtBox(txt, box);

      rect.addEventListener("mouseenter", () => {
        rect.classList.add("is-hover");
        txt.classList.add("is-visible");
      });

      rect.addEventListener("mouseleave", () => {
        rect.classList.remove("is-hover");
        txt.classList.remove("is-visible");
      });

      svg.appendChild(rect);
      svg.appendChild(txt);
    }
  }

  // ---------------------------------------------------------
  // Attend que l’image ait une taille affichée non nulle
  // ---------------------------------------------------------
  async function waitForNonZeroSize(img, tries = 30) {
    for (let i = 0; i < tries; i++) {
      const rect = img.getBoundingClientRect();

      if (rect.width > 5 && rect.height > 5) {
        return true;
      }

      await new Promise((resolve) => setTimeout(resolve, 50));
    }

    return false;
  }

  // ---------------------------------------------------------
  // Initialise un wrapper manuscrit :
  // - attend l’image
  // - charge le JSON
  // - dessine l’overlay
  // ---------------------------------------------------------
  async function initWrap(wrap) {
    const key = wrap.dataset.overlay;
    const svg = wrap.querySelector("svg.ms-svg") || wrap.querySelector("svg");
    const img = wrap.querySelector("img");

    if (!key || !svg || !img || drawnKeys.has(key)) return;

    if (!img.complete) {
      await new Promise((resolve) => {
        img.addEventListener("load", resolve, { once: true });
        img.addEventListener("error", resolve, { once: true });
      });
    }

    await waitForNonZeroSize(img);

    let data;
    try {
      data = await fetchOverlay(key);
    } catch (e) {
      console.error("[overlays] fetch failed", key, e);
      return;
    }

    const width = data.width ?? data.nativeW;
    const height = data.height ?? data.nativeH;

    if (!width || !height) {
      console.error("[overlays] missing width/height in", key, data);
      return;
    }

    ensureSvgSetup(svg, width, height);

    if (Array.isArray(data.lines)) {
      drawFromLines(svg, data, key, width, height, img);
    } else if (Array.isArray(data.boxes)) {
      drawFromBoxes(svg, data, key, width, height, img);
    } else {
      console.warn("[overlays] no lines/boxes in", key);
    }

    drawnKeys.add(key);
  }

  // =========================================================
  // CARROUSEL + ZOOM
  // =========================================================

  // ---------------------------------------------------------
  // Initialise un carrousel de manuscrits
  // - active une slide à la fois
  // - gère prev/next
  // - gère clic sur miniatures
  // - initialise l’overlay de la slide active
  // ---------------------------------------------------------
  function initCarousel(carousel) {
    const slides = $$(".ms-slide", carousel);
    const thumbs = $$(".ms-thumb", carousel);
    const btnPrev = $(".ms-prev", carousel);
    const btnNext = $(".ms-next", carousel);

    if (!slides.length) return;

    let idx = 0;

    async function show(i) {
      idx = (i + slides.length) % slides.length;

      slides.forEach((slide) => {
        slide.classList.toggle("is-active", slide === slides[idx]);
      });

      thumbs.forEach((thumb, k) => {
        thumb.classList.toggle("is-active", k === idx);
      });

      const wrap = $(".ms-wrap[data-overlay]", slides[idx]);
      if (wrap) await initWrap(wrap);
    }

    btnPrev?.addEventListener("click", () => show(idx - 1));
    btnNext?.addEventListener("click", () => show(idx + 1));

    thumbs.forEach((thumb) => {
      thumb.addEventListener("click", () => {
        show(Number(thumb.dataset.slide) || 0);
      });
    });

    carousel.addEventListener("keydown", (e) => {
      if (e.key === "ArrowLeft") show(idx - 1);
      if (e.key === "ArrowRight") show(idx + 1);
    });

    show(0);
  }

  // ---------------------------------------------------------
  // Initialise tous les overlays / carrousels présents
  // ---------------------------------------------------------
  function initOverlays() {
    const carousels = $$(".ms-carousel");

    if (carousels.length) {
      return carousels.forEach(initCarousel);
    }

    $$(".ms-wrap[data-overlay]").forEach((wrap) => initWrap(wrap));
  }

  // ---------------------------------------------------------
  // Zoom des images :
  // ouvre l’image dans un nouvel onglet au clic
  // ---------------------------------------------------------
  function initImageZoom() {
    $$(".ms-wrap img, figure.viewer img, .fig img").forEach((img) => {
      img.addEventListener("click", () => {
        window.open(img.src, "_blank", "noopener");
      });
    });
  }

  // =========================================================
  // NAV ACTIVE
  // ---------------------------------------------------------
  // Ajoute la classe .nav-link--active au lien du menu
  // correspondant à la page courante
  // =========================================================
  function initActiveNav() {
    const current = (location.pathname.split("/").pop() || "index.html").toLowerCase();

    $$(".nav-link").forEach((a) => {
      const href = (a.getAttribute("href") || "").toLowerCase();
      if (href && href === current) {
        a.classList.add("nav-link--active");
      }
    });
  }

  // =========================================================
  // INDEX UX
  // ---------------------------------------------------------
  // Ajoute :
  // - une barre de recherche sur l’index des entités
  // - le filtrage dynamique des cartes
  // - l’état actif des pills (#persons, #places, etc.)
  // =========================================================
  function initIndexUX() {
    const isEntitiesPage = location.pathname.includes("index-entities");
    if (!isEntitiesPage) return;

    // Normalise les chaînes pour rendre la recherche plus souple
    // (minuscules + suppression des accents)
    const normalize = (s) =>
      (s || "")
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "");

    const topLinks = $(".index-toplinks");
    const firstCard = $(".card");

    // Si la barre de recherche n’existe pas encore, on l’injecte
    if (!$("#indexSearch")) {
      const searchWrap = document.createElement("div");
      searchWrap.className = "index-search";
      searchWrap.innerHTML = `
        <label class="index-search__label smallcaps" for="indexSearch">Recherche</label>
        <input class="index-search__input" id="indexSearch" type="search"
               placeholder="Tape un nom, un lieu, une œuvre…" autocomplete="off"/>
        <button class="index-search__clear" type="button" aria-label="Effacer">×</button>
      `;

      if (topLinks?.parentElement) {
        topLinks.parentElement.insertBefore(searchWrap, topLinks.nextSibling);
      } else if (firstCard?.parentElement) {
        firstCard.parentElement.insertBefore(searchWrap, firstCard.nextSibling);
      }
    }

    const input = $("#indexSearch");
    const clearBtn = $(".index-search__clear");
    const items = $$(".entity-item");

    // Pré-calcule le texte de recherche de chaque carte
    const cache = items.map((li) => {
      const title = normalize($(".entity-title", li)?.textContent);
      const note = normalize($(".entity-note", li)?.textContent);
      return {
        li,
        haystack: (title + " " + note).trim()
      };
    });

    function applyFilter(queryValue) {
      const query = normalize(queryValue);

      cache.forEach(({ li, haystack }) => {
        li.style.display = (!query || haystack.includes(query)) ? "" : "none";
      });
    }

    input?.addEventListener("input", () => applyFilter(input.value));

    clearBtn?.addEventListener("click", () => {
      if (!input) return;
      input.value = "";
      input.focus();
      applyFilter("");
    });

    // Gestion de la pill active selon le hash
    const pills = $$(".index-toplinks .pill");

    function setActivePill() {
      const hash = (location.hash || "#persons").toLowerCase();

      pills.forEach((a) => {
        const isActive = (a.getAttribute("href") || "").toLowerCase() === hash;
        if (isActive) {
          a.setAttribute("aria-current", "true");
        } else {
          a.removeAttribute("aria-current");
        }
      });
    }

    window.addEventListener("hashchange", setActivePill);
    setActivePill();
  }

  // =========================================================
  // PATCH LETTRINE
  // ---------------------------------------------------------
  // Ajoute .no-dropcap à certains paragraphes pour empêcher
  // l’apparition d’une lettrine sur des débuts indésirables :
  // - adresses qui commencent par un chiffre
  // - formulations spécifiques
  // =========================================================
  function initNoDropcap() {
    const paras = $$(".tei-text p");
    if (!paras.length) return;

    const exactStarts = ["My name is here,", "Hotel de la Plage"];

    paras.forEach((p) => {
      const text = (p.textContent || "").trim();
      if (!text) return;

      const isNumberAddress = /^\d+\s*,\s*/.test(text) || /^\d+\s+\w+/.test(text);
      const isExact = exactStarts.some((start) => text.startsWith(start));

      if (isNumberAddress || isExact) {
        p.classList.add("no-dropcap");
      }
    });
  }

  // =========================================================
  // DOM READY
  // ---------------------------------------------------------
  // Point d’entrée principal du script
  // =========================================================
  document.addEventListener("DOMContentLoaded", () => {
    initActiveNav();
    initIndexUX();
    initOverlays();
    initImageZoom();
    initNoDropcap();
  });

})();