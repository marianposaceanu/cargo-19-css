(() => {
  "use strict";

  const all = (selector, root = document) => [...root.querySelectorAll(selector)];
  const THEME_KEY = "c19-theme";
  const darkThemeQuery = window.matchMedia?.("(prefers-color-scheme: dark)");

  function getTheme() {
    return document.documentElement.getAttribute("data-c19-theme") || "paper";
  }

  function getEffectiveTheme(theme = getTheme()) {
    if (theme !== "auto") return theme;
    return darkThemeQuery?.matches ? "bridge" : "paper";
  }

  function setTheme(theme, persist = true) {
    const safeTheme = ["paper", "bridge", "auto"].includes(theme) ? theme : "paper";
    const effectiveTheme = getEffectiveTheme(safeTheme);
    document.documentElement.setAttribute("data-c19-theme", safeTheme);
    if (persist) {
      try { localStorage.setItem(THEME_KEY, safeTheme); } catch (_) { /* Storage can be unavailable. */ }
    }
    all("[data-c19-theme-toggle]").forEach((button) => {
      const next = effectiveTheme === "bridge" ? "paper" : "bridge";
      button.setAttribute("aria-label", `Switch to ${next} theme`);
      button.setAttribute("aria-pressed", String(effectiveTheme === "bridge"));
      const label = button.querySelector("[data-c19-theme-label]");
      if (label) label.textContent = effectiveTheme === "bridge" ? "Bridge" : "Paper";
    });
  }

  function restoreTheme() {
    let saved = null;
    try { saved = localStorage.getItem(THEME_KEY); } catch (_) { /* Ignore. */ }
    if (saved) setTheme(saved, false);
    else setTheme(getTheme(), false);
  }

  function activateTab(tab, moveFocus = false) {
    const list = tab.closest('[role="tablist"]');
    if (!list) return;
    const tabs = all('[role="tab"]', list);
    const root = list.closest("[data-c19-tabs]") || document;

    tabs.forEach((item) => {
      const selected = item === tab;
      item.setAttribute("aria-selected", String(selected));
      item.tabIndex = selected ? 0 : -1;
      const panelId = item.getAttribute("aria-controls");
      const panel = panelId ? root.querySelector(`#${CSS.escape(panelId)}`) : null;
      if (panel) panel.hidden = !selected;
    });

    if (moveFocus) tab.focus();
  }

  function closeMobileNav(restoreFocus = false) {
    const panel = document.querySelector("[data-c19-mobile-nav]");
    const toggle = document.querySelector("[data-c19-nav-toggle]");
    if (!panel || !toggle) return;
    const wasOpen = !panel.hidden;
    panel.hidden = true;
    toggle.setAttribute("aria-expanded", "false");
    if (restoreFocus && wasOpen) toggle.focus();
  }

  function toggleMobileNav(button) {
    const controls = button.getAttribute("aria-controls");
    const panel = controls ? document.getElementById(controls) : document.querySelector("[data-c19-mobile-nav]");
    if (!panel) return;
    const opening = panel.hidden;
    panel.hidden = !opening;
    button.setAttribute("aria-expanded", String(opening));
    if (opening) panel.querySelector("a, button")?.focus();
  }

  async function copyCode(button) {
    const selector = button.getAttribute("data-c19-copy");
    const target = selector ? document.querySelector(selector) : button.closest(".c19-doc-code-wrap")?.querySelector("code, pre");
    if (!target) return;
    const text = target.textContent || "";
    let copied = false;

    try {
      await navigator.clipboard.writeText(text);
      copied = true;
    } catch (_) {
      const area = document.createElement("textarea");
      area.value = text;
      area.setAttribute("readonly", "");
      area.style.position = "fixed";
      area.style.opacity = "0";
      document.body.append(area);
      area.select();
      copied = document.execCommand("copy");
      area.remove();
    }

    const label = button.querySelector("[data-c19-copy-label]") || button;
    const original = label.dataset.c19OriginalLabel || label.textContent || "Copy";
    label.dataset.c19OriginalLabel = original;
    label.textContent = copied ? "Copied" : "Copy failed";
    window.setTimeout(() => { label.textContent = original; }, 1400);
  }

  function filterIcons(input) {
    const query = input.value.trim().toLowerCase();
    const cards = all("[data-c19-icon-card]");
    let visible = 0;

    cards.forEach((card) => {
      const haystack = (card.getAttribute("data-c19-search") || card.textContent || "").toLowerCase();
      const match = !query || haystack.includes(query);
      card.hidden = !match;
      if (match) visible += 1;
    });

    all("[data-c19-icon-count]").forEach((count) => {
      count.textContent = `${visible} / ${cards.length}`;
    });
    all("[data-c19-icon-empty]").forEach((empty) => { empty.hidden = visible !== 0; });
  }

  restoreTheme();
  darkThemeQuery?.addEventListener?.("change", () => {
    if (getTheme() === "auto") setTheme("auto", false);
  });

  all("[data-c19-tabs]").forEach((tabsRoot) => {
    const selected = tabsRoot.querySelector('[role="tab"][aria-selected="true"]') || tabsRoot.querySelector('[role="tab"]');
    if (selected) activateTab(selected);
  });

  all("[data-c19-icon-filter]").forEach(filterIcons);

  document.addEventListener("click", (event) => {
    const tab = event.target.closest('[role="tab"]');
    if (tab) activateTab(tab);

    const dismiss = event.target.closest("[data-c19-dismiss]");
    if (dismiss) dismiss.closest("[data-c19-dismissible]")?.remove();

    const opener = event.target.closest("[data-c19-dialog-open]");
    if (opener) {
      const dialog = document.getElementById(opener.getAttribute("data-c19-dialog-open"));
      if (dialog?.showModal) dialog.showModal();
    }

    const closer = event.target.closest("[data-c19-dialog-close]");
    if (closer) closer.closest("dialog")?.close();

    const themeToggle = event.target.closest("[data-c19-theme-toggle]");
    if (themeToggle) setTheme(getEffectiveTheme() === "bridge" ? "paper" : "bridge");

    const navToggle = event.target.closest("[data-c19-nav-toggle]");
    if (navToggle) toggleMobileNav(navToggle);

    const mobileNavLink = event.target.closest("[data-c19-mobile-nav] a");
    if (mobileNavLink) closeMobileNav();

    const copy = event.target.closest("[data-c19-copy]");
    if (copy) copyCode(copy);
  });

  document.addEventListener("input", (event) => {
    const filter = event.target.closest("[data-c19-icon-filter]");
    if (filter) filterIcons(filter);
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") closeMobileNav(true);

    const tab = event.target.closest('[role="tab"]');
    if (!tab) return;
    const list = tab.closest('[role="tablist"]');
    if (!list) return;
    const tabs = all('[role="tab"]', list);
    const index = tabs.indexOf(tab);
    let next = null;

    if (event.key === "ArrowRight" || event.key === "ArrowDown") next = tabs[(index + 1) % tabs.length];
    if (event.key === "ArrowLeft" || event.key === "ArrowUp") next = tabs[(index - 1 + tabs.length) % tabs.length];
    if (event.key === "Home") next = tabs[0];
    if (event.key === "End") next = tabs[tabs.length - 1];

    if (next) {
      event.preventDefault();
      activateTab(next, true);
    }
  });
})();
