(() => {
  "use strict";

  // =========================================================
  // IIFE (Immediately Invoked Function Expression)
  // ---------------------------------------------------------
  // Ce script est encapsulé dans une fonction anonyme
  // exécutée immédiatement.
  //
  // Avantages :
  // - évite de polluer l’espace global (window)
  // - permet d’utiliser "use strict"
  // - organise le code comme un module
  // =========================================================

  console.log("[site.js] Wilde edition loaded");

  // =========================================================
  // Raccourcis utilitaires pour sélectionner des éléments DOM
  // ---------------------------------------------------------
  // $  = querySelector (1 élément)
  // $$ = querySelectorAll (liste convertie en tableau)
  // =========================================================

  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));


  // =========================================================
  // THEME (mode nuit / jour)
  // =========================================================

  const THEME_KEY = "ow_theme";     // clé utilisée dans localStorage
  const root = document.documentElement; // <html>

  // récupère le thème sauvegardé
  function getSavedTheme() {
    try { return localStorage.getItem(THEME_KEY); }
    catch { return null; }
  }

  // sauvegarde le thème choisi
  function saveTheme(v) {
    try { localStorage.setItem(THEME_KEY, v); }
    catch {}
  }

  // vérifie si le site est actuellement en mode nuit
  function isNight() {
    return root.getAttribute("data-theme") === "night";
  }

  // met à jour le texte du bouton (Mode nuit / Mode jour)
  function updateThemeToggleLabel() {
    const label = $(".theme-toggle .label");
    if (label) label.textContent = isNight() ? "Mode jour" : "Mode nuit";
  }

  // applique un thème
  function setTheme(theme) {
    if (theme === "night")
      root.setAttribute("data-theme", "night");
    else
      root.removeAttribute("data-theme");

    saveTheme(theme === "night" ? "night" : "day");
    updateThemeToggleLabel();
  }

  // bascule entre les deux
  function toggleTheme() {
    setTheme(isNight() ? "day" : "night");
  }

  // injecte le bouton toggle dans le header
  function injectThemeToggle() {
    const header = $(".site-header");
    if (!header || header.querySelector(".theme-toggle")) return;

    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "theme-toggle";
    btn.setAttribute("aria-label", "Basculer le mode nuit");

    btn.innerHTML = `
      <span class="dot" aria-hidden="true"></span>
      <span class="label">Mode nuit</span>
    `;

    btn.addEventListener("click", toggleTheme);
    header.appendChild(btn);
  }

  // initialise le système de thème
  function initTheme() {
    injectThemeToggle();

    // applique le thème sauvegardé
    setTheme(getSavedTheme() === "night" ? "night" : "day");

    // raccourci clavier : touche N
    document.addEventListener("keydown", (e) => {
      if (e.key.toLowerCase() !== "n" || e.metaKey || e.ctrlKey || e.altKey) return;

      const t = e.target;
      const isField =
        t && (t.tagName === "INPUT" || t.tagName === "TEXTAREA" || t.isContentEditable);

      if (!isField) toggleTheme();
    });
  }


  // =========================================================
  // OVERLAYS (zones interactives sur les manuscrits)
  // =========================================================

  const SVG_NS = "http://www.w3.org/2000/svg";

  // évite de dessiner deux fois le même overlay
  const drawnKeys = new Set();

  // crée un élément SVG
  const el = (name) => document.createElementNS(SVG_NS, name);

  // vide un élément
  const clear = (node) => {
    while (node.firstChild) node.removeChild(node.firstChild);
  };

  // clamp = limite une valeur entre min et max
  const clamp = (n, a, b) => Math.max(a, Math.min(b, n));

  // convertit tableau de points → attribut SVG
  const pointsToAttr = (pts) =>
    pts.map(([x, y]) => `${x},${y}`).join(" ");

  // médiane d'un tableau
  function median(arr) {
    if (!arr.length) return 0;
    const a = [...arr].sort((x, y) => x - y);
    const m = Math.floor(a.length / 2);
    return a.length % 2 ? a[m] : (a[m - 1] + a[m]) / 2;
  }

  // calcule bounding box d’un polygone
  function bboxFromPoints(pts) {
    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;

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

  // configure le SVG overlay
  function ensureSvgSetup(svg, W, H) {
    svg.classList.add("ms-svg");

    svg.setAttribute("viewBox", `0 0 ${W} ${H}`);
    svg.setAttribute("preserveAspectRatio", "xMidYMid meet");

    clear(svg);
  }

  // récupère le JSON overlay
  async function fetchOverlay(key) {
    const url = new URL(
      `assets/overlays/${key}.json`,
      document.baseURI
    ).toString();

    const res = await fetch(url, { cache: "no-store" });

    if (!res.ok)
      throw new Error(`Overlay JSON ${url} -> HTTP ${res.status}`);

    return res.json();
  }

  // calcule l'échelle réelle d'affichage de l'image
  function getRenderedScale(img, W, H) {
    const r = img.getBoundingClientRect();

    const rw = r.width || img.clientWidth || 0;
    const rh = r.height || img.clientHeight || 0;

    return {
      renderedW: rw,
      renderedH: rh,
      scaleX: rw > 0 ? rw / W : 0,
      scaleY: rh > 0 ? rh / H : 0
    };
  }

  // taille idéale du texte sur l’écran
  function desiredFontPxOnScreen(renderedH) {
    return clamp(renderedH * 0.04, 18, 34);
  }

  // conversion px écran → unités SVG
  function pxScreenToSvgUnits(px, scaleY) {
    return !scaleY ? px : px / scaleY;
  }

  // style du texte overlay
  function setOverlayTextStyle(txt, fontSvgUnits) {
    const fs = clamp(fontSvgUnits, 16, 120);

    txt.classList.add("ms-txt");

    txt.setAttribute("font-size", String(fs));
    txt.setAttribute("fill", "rgba(0,0,0,0.72)");
    txt.setAttribute("font-weight", "600");

    txt.setAttribute("paint-order", "stroke");
    txt.setAttribute("stroke", "rgba(255,255,255,0.90)");
    txt.setAttribute("stroke-linejoin", "round");

    txt.setAttribute(
      "stroke-width",
      String(clamp(fs * 0.18, 2.2, 7.5))
    );
  }

  // calcule taille uniforme du texte
  function computeUniformFontUnitsForPage(img, W, H, hintMedianH) {
    const { renderedH, scaleY } = getRenderedScale(img, W, H);

    const basePx = desiredFontPxOnScreen(renderedH);
    let baseUnits = pxScreenToSvgUnits(basePx, scaleY);

    if (hintMedianH > 0)
      baseUnits *= clamp(32 / hintMedianH, 0.85, 1.20);

    return baseUnits;
  }

  // place texte sur premier point du polygone
  function placeTextAtFirstPoint(textEl, points) {
    const [x0, y0] = points[0];

    textEl.setAttribute("x", x0);
    textEl.setAttribute("y", y0);
    textEl.setAttribute("dominant-baseline", "hanging");
  }

  // place texte dans une boîte
  function placeTextAtBox(textEl, box) {
    textEl.setAttribute("x", box.x);
    textEl.setAttribute("y", box.y);
    textEl.setAttribute("dominant-baseline", "hanging");
  }

  // dessine overlays à partir de polygones
  function drawFromLines(svg, data, key, W, H, img) {

    const lines = Array.isArray(data.lines) ? data.lines : [];

    const heights = lines
      .filter((ln) => ln && Array.isArray(ln.points) && ln.points.length >= 3)
      .map((ln) => bboxFromPoints(ln.points).h)
      .filter((h) => h > 0);

    const baseUnits =
      computeUniformFontUnitsForPage(img, W, H, median(heights));

    for (const ln of lines) {

      if (!ln || !Array.isArray(ln.points) || ln.points.length < 3)
        continue;

      // polygone interactif
      const poly = el("polygon");

      poly.setAttribute("points", pointsToAttr(ln.points));
      poly.classList.add("ms-hit");

      poly.setAttribute("pointer-events", "all");

      if (ln.id) poly.dataset.lineId = ln.id;

      // texte overlay
      const txt = el("text");
      txt.textContent = ln.text || "";

      setOverlayTextStyle(txt, baseUnits);
      placeTextAtFirstPoint(txt, ln.points);

      // interaction hover
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

  // dessine overlays à partir de rectangles
  function drawFromBoxes(svg, data, key, W, H, img) {

    const boxes = Array.isArray(data.boxes) ? data.boxes : [];

    const heights = boxes
      .map((b) => (b && typeof b.h === "number" ? b.h : 0))
      .filter((h) => h > 0);

    const baseUnits =
      computeUniformFontUnitsForPage(img, W, H, median(heights));

    for (const b of boxes) {

      if (!b || typeof b.x !== "number" || typeof b.y !== "number")
        continue;

      // rectangle interactif
      const rect = el("rect");

      rect.setAttribute("x", b.x);
      rect.setAttribute("y", b.y);
      rect.setAttribute("width", typeof b.w === "number" ? b.w : 0);
      rect.setAttribute("height", typeof b.h === "number" ? b.h : 0);

      rect.classList.add("ms-hit");
      rect.setAttribute("pointer-events", "all");

      const txt = el("text");
      txt.textContent = b.t || "";

      setOverlayTextStyle(txt, baseUnits);
      placeTextAtBox(txt, b);

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

  // attend que l'image ait une taille non nulle
  async function waitForNonZeroSize(img, tries = 30) {

    for (let i = 0; i < tries; i++) {

      const r = img.getBoundingClientRect();

      if (r.width > 5 && r.height > 5)
        return true;

      await new Promise((res) => setTimeout(res, 50));
    }

    return false;
  }

  // initialise un overlay
  async function initWrap(wrap) {

    const key = wrap.dataset.overlay;

    const svg = wrap.querySelector("svg.ms-svg") || wrap.querySelector("svg");
    const img = wrap.querySelector("img");

    if (!key || !svg || !img || drawnKeys.has(key))
      return;

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
    }
    catch (e) {
      console.error("[overlays] fetch failed", key, e);
      return;
    }

    const W = data.width ?? data.nativeW;
    const H = data.height ?? data.nativeH;

    if (!W || !H) {
      console.error("[overlays] missing width/height in", key, data);
      return;
    }

    ensureSvgSetup(svg, W, H);

    if (Array.isArray(data.lines))
      drawFromLines(svg, data, key, W, H, img);
    else if (Array.isArray(data.boxes))
      drawFromBoxes(svg, data, key, W, H, img);
    else
      console.warn("[overlays] no lines/boxes in", key);

    drawnKeys.add(key);
  }


  // =========================================================
  // CARROUSEL + ZOOM
  // =========================================================

  function initCarousel(carousel) {

    const slides = $$(".ms-slide", carousel);
    const thumbs = $$(".ms-thumb", carousel);

    const btnPrev = $(".ms-prev", carousel);
    const btnNext = $(".ms-next", carousel);

    if (!slides.length) return;

    let idx = 0;

    async function show(i) {

      idx = (i + slides.length) % slides.length;

      slides.forEach((s) =>
        s.classList.toggle("is-active", s === slides[idx])
      );

      thumbs.forEach((t, k) =>
        t.classList.toggle("is-active", k === idx)
      );

      const wrap = $(".ms-wrap[data-overlay]", slides[idx]);

      if (wrap) await initWrap(wrap);
    }

    btnPrev?.addEventListener("click", () => show(idx - 1));
    btnNext?.addEventListener("click", () => show(idx + 1));

    thumbs.forEach((t) =>
      t.addEventListener("click", () =>
        show(Number(t.dataset.slide) || 0)
      )
    );

    carousel.addEventListener("keydown", (e) => {
      if (e.key === "ArrowLeft") show(idx - 1);
      if (e.key === "ArrowRight") show(idx + 1);
    });

    show(0);
  }

  // initialise overlays
  function initOverlays() {
    const carousels = $$(".ms-carousel");

    if (carousels.length)
      return carousels.forEach(initCarousel);

    $$(".ms-wrap[data-overlay]").forEach((w) => initWrap(w));
  }

  // zoom image (ouvre dans nouvel onglet)
  function initImageZoom() {
    $$(".ms-wrap img, figure.viewer img, .fig img")
      .forEach((img) => {
        img.addEventListener("click", () =>
          window.open(img.src, "_blank", "noopener")
        );
      });
  }


  // =========================================================
  // ✅ AJOUTS (sans rien supprimer) : fonctions manquantes
  // =========================================================

  // =========================
  // ACTIVE NAV (global exact match)
  // -------------------------
  // Ajoute la classe .nav-link--active au lien du menu principal
  // correspondant à la page en cours.
  // =========================
  function initActiveNav() {
    const current = (location.pathname.split("/").pop() || "index.html").toLowerCase();
    $$(".nav-link").forEach((a) => {
      const href = (a.getAttribute("href") || "").toLowerCase();
      if (href && href === current) a.classList.add("nav-link--active");
    });
  }

  // =========================
  // INDEX UX (recherche + état actif)
  // -------------------------
  // Active la recherche dynamique uniquement sur la page index-entities.
  // Ton HTML (XSLT) injecte déjà la structure .entity-item / .entity-title / .entity-note.
  // =========================
  function initIndexUX() {
    const isEntities = location.pathname.includes("index-entities");
    if (!isEntities) return;

    const normalize = (s) =>
      (s || "").toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

    // barre de recherche : si elle existe déjà, on la réutilise.
    // sinon, on l’injecte juste après .index-toplinks ou après la première carte.
    const topLinks = $(".index-toplinks");
    const firstCard = $(".card");

    if (!$("#indexSearch")) {
      const searchWrap = document.createElement("div");
      searchWrap.className = "index-search";
      searchWrap.innerHTML = `
        <label class="index-search__label smallcaps" for="indexSearch">Recherche</label>
        <input class="index-search__input" id="indexSearch" type="search"
               placeholder="Tape un nom, un lieu, une œuvre…" autocomplete="off"/>
        <button class="index-search__clear" type="button" aria-label="Effacer">×</button>
      `;

      if (topLinks?.parentElement) topLinks.parentElement.insertBefore(searchWrap, topLinks.nextSibling);
      else if (firstCard?.parentElement) firstCard.parentElement.insertBefore(searchWrap, firstCard.nextSibling);
    }

    const input = $("#indexSearch");
    const clearBtn = $(".index-search__clear");
    const items = $$(".entity-item");

    // cache = pré-calcul des textes à chercher (titre + note)
    const cache = items.map((li) => {
      const title = normalize($(".entity-title", li)?.textContent);
      const note  = normalize($(".entity-note", li)?.textContent);
      return { li, haystack: (title + " " + note).trim() };
    });

    const applyFilter = (q) => {
      const query = normalize(q);
      cache.forEach(({ li, haystack }) => {
        li.style.display = (!query || haystack.includes(query)) ? "" : "none";
      });
    };

    input?.addEventListener("input", () => applyFilter(input.value));
    clearBtn?.addEventListener("click", () => {
      if (!input) return;
      input.value = "";
      input.focus();
      applyFilter("");
    });

    // pills active (hash : #persons / #places / #orgs / #works)
    const pills = $$(".index-toplinks .pill");
    const setActivePill = () => {
      const hash = (location.hash || "#persons").toLowerCase();
      pills.forEach((a) => {
        const isActive = (a.getAttribute("href") || "").toLowerCase() === hash;
        if (isActive) a.setAttribute("aria-current", "true");
        else a.removeAttribute("aria-current");
      });
    };
    window.addEventListener("hashchange", setActivePill);
    setActivePill();
  }

  // =========================
  // DROP CAP PATCH (JS -> .no-dropcap)
  // -------------------------
  // Ajoute la classe .no-dropcap sur certains paragraphes
  // pour empêcher une lettrine sur :
  // - une adresse qui commence par un nombre
  // - quelques débuts exacts (si besoin)
  // =========================
  function initNoDropcap() {
    const paras = $$(".tei-text p");
    if (!paras.length) return;

    const exactStarts = ["My name is here,", "Hotel de la Plage"];

    paras.forEach((p) => {
      const t = (p.textContent || "").trim();
      if (!t) return;

      const isNumberAddress = /^\d+\s*,\s*/.test(t) || /^\d+\s+\w+/.test(t);
      const isExact = exactStarts.some((s) => t.startsWith(s));

      if (isNumberAddress || isExact) p.classList.add("no-dropcap");
    });
  }


  // =========================================================
  // DOM READY
  // =========================================================

  document.addEventListener("DOMContentLoaded", () => {

    // initialise toutes les fonctionnalités du site
    initTheme();
    initActiveNav();
    initIndexUX();
    initOverlays();
    initImageZoom();
    initNoDropcap();

  });

})();