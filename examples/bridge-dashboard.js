(() => {
  "use strict";

  const dashboard = document.querySelector("[data-c19-demo-dashboard]");
  if (!dashboard) return;

  const one = (selector) => document.querySelector(selector);
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const cadence = reducedMotion ? 5000 : 2000;
  const log = one("[data-c19-demo-log]");
  const streamToggle = one("[data-c19-demo-stream-toggle]");
  const auxToggle = one("[data-c19-demo-aux-toggle]");
  let phase = 0;
  let clockTimer = null;
  let telemetryTimer = null;
  let streamEnabled = streamToggle?.checked ?? true;
  let auxEnabled = auxToggle?.checked ?? true;

  const responses = {
    "status --all": "systems nominal / 01 advisory / telemetry synchronized",
    "nav --review": "course solution verified / deviation 0.04°",
    "cargo --inspect": "hold scan queued / operator route 03",
    "airlock --cycle": "A-01 cycle request accepted",
    "cold-bay --inspect": "C-04 inspection telemetry opened",
    "reactor --details": "R-02 advisory packet displayed",
    "power --balance": "load balancing complete / reserve path stable",
    "comms --resync": "uplink resynchronized / packet loss 0.00%"
  };

  const advisories = [
    {
      tone: "info",
      title: "Telemetry synchronized",
      message: "All bridge channels are reporting inside nominal tolerances."
    },
    {
      tone: "warning",
      title: "Thermal loop review",
      message: "Reactor exchange loop is approaching its preferred observation threshold."
    },
    {
      tone: "success",
      title: "Course solution verified",
      message: "Guidance, propulsion, and cargo compensation models agree."
    }
  ];

  function setText(selector, value) {
    const target = one(selector);
    if (target) target.textContent = value;
  }

  function setStatus(selector, tone, label) {
    const target = one(selector);
    if (!target) return;
    target.className = `c19-status c19-status--${tone}`;
    target.textContent = label;
  }

  function setProgress(selector, value, label) {
    const bar = one(selector);
    if (!bar) return;
    const safeValue = Math.max(0, Math.min(100, value));
    bar.style.setProperty("--c19-value", safeValue.toFixed(0));
    if (label) bar.parentElement?.setAttribute("aria-label", `${label} ${safeValue.toFixed(0)} percent`);
  }

  function setMeter(selector, value, label) {
    const meter = one(selector);
    if (!meter) return;
    const segments = [...meter.children];
    const active = Math.round(Math.max(0, Math.min(100, value)) / 100 * segments.length);
    segments.forEach((segment, index) => segment.toggleAttribute("data-active", index < active));
    meter.setAttribute("aria-label", `${label} ${Math.round(value)} percent`);
  }

  function addLog(command, response) {
    if (!log) return;

    const prompt = document.createElement("p");
    const mark = document.createElement("span");
    mark.className = "c19-terminal__prompt";
    mark.textContent = "SYS/";
    prompt.append(mark, ` ${command}`);

    const result = document.createElement("p");
    result.textContent = response;
    log.append(prompt, result);

    while (log.children.length > 10) {
      log.firstElementChild?.remove();
    }
  }

  function runCommand(command) {
    const normalized = command.trim().toLowerCase();
    if (!normalized) return;
    const response = responses[normalized] || `command queued / reference ${String(phase + 19).padStart(4, "0")}`;
    addLog(normalized, response);
  }

  function updateClock() {
    const now = new Date();
    const shift = String(Math.floor(now.getUTCHours() / 6) + 1).padStart(2, "0");
    setText("[data-c19-demo-clock]", `UTC ${now.toISOString().slice(11, 19)} · SHIFT ${shift}`);
  }

  function updateAdvisory() {
    const advisory = advisories[Math.floor(phase / 2) % advisories.length];
    const target = one("[data-c19-demo-advisory]");
    if (target) target.className = `c19-alert c19-alert--${advisory.tone}`;
    setText("[data-c19-demo-advisory-title]", advisory.title);
    setText("[data-c19-demo-advisory-message]", advisory.message);
  }

  function updateTelemetry() {
    phase += 1;

    const atmosphere = 101.3 + Math.sin(phase / 2.8) * 0.18;
    const power = 92.4 + Math.sin(phase / 4.2) * 0.7;
    const oxygen = 20.9 + Math.sin(phase / 5.1) * 0.04;
    const co2 = 0.04 + Math.sin(phase / 4.4) * 0.004;
    const humidity = 42 + Math.round(Math.sin(phase / 3.4) * 2);
    const temperature = 19.6 + Math.sin(phase / 3.8) * 0.35;
    const heading = (281.4 + phase * 0.16) % 360;
    const velocity = 0.82 + Math.sin(phase / 6.2) * 0.006;
    const courseError = 0.04 + Math.abs(Math.sin(phase / 3.7)) * 0.03;
    const thrust = 67 + Math.round(Math.sin(phase / 3.1) * 3);
    const load = 76 + Math.round(Math.sin(phase / 4.8) * 2);
    const mass = 182 + Math.sin(phase / 4.6) * 0.3;
    const seals = phase % 12 === 0 ? 17 : 18;
    const radiation = 0.82 + Math.sin(phase / 2.2) * 0.03;
    const cold = -142 + Math.sin(phase / 4.1) * 0.8;
    const busA = Math.round(power);
    const busB = 88 + Math.round(Math.sin(phase / 3.3) * 2);
    const aux = auxEnabled ? 64 + Math.round(Math.sin(phase / 4.7) * 3) : 0;
    const signal = 94 + Math.round(Math.sin(phase / 3.9) * 3);
    const latency = 18 + Math.round(Math.sin(phase / 2.6) * 4);
    const packets = 148 + Math.round(Math.sin(phase / 2.9) * 12);
    const tasks = 3 + (phase % 9 === 0 ? 1 : 0);
    const crew = 8 - (phase % 15 === 0 ? 1 : 0);
    const lifeReserve = 84 + Math.round(Math.sin(phase / 5.3) * 4);
    const eta = new Date(Date.now() + (42 - Math.min(phase, 18)) * 60_000);

    setText("[data-c19-demo-cycle]", `Cycle ${String(phase).padStart(4, "0")}`);
    setText("[data-c19-demo-atmosphere]", atmosphere.toFixed(1));
    setText("[data-c19-demo-power]", power.toFixed(1));
    setText("[data-c19-demo-crew]", String(crew).padStart(2, "0"));
    setText("[data-c19-demo-tasks]", String(tasks).padStart(2, "0"));
    setText("[data-c19-demo-packets]", String(packets));
    setText("[data-c19-demo-oxygen]", `O₂ ${oxygen.toFixed(2)}%`);
    setText("[data-c19-demo-co2]", `CO₂ ${co2.toFixed(3)}%`);
    setText("[data-c19-demo-humidity]", `RH ${humidity}%`);
    setText("[data-c19-demo-temperature]", `${temperature.toFixed(1)} °C`);
    setText("[data-c19-demo-heading]", `HDG ${heading.toFixed(1)}°`);
    setText("[data-c19-demo-velocity]", `VEL ${velocity.toFixed(3)} c`);
    setText("[data-c19-demo-eta]", `ETA ${eta.toISOString().slice(11, 16)}`);
    setText("[data-c19-demo-course-error]", `ERR ${courseError.toFixed(2)}°`);
    setText("[data-c19-demo-mass]", `MASS ${mass.toFixed(1)} t`);
    setText("[data-c19-demo-load]", `LOAD ${load}%`);
    setText("[data-c19-demo-seals]", `SEALS ${seals}/18`);
    setText("[data-c19-demo-pressure]", `${atmosphere.toFixed(1)} kPa`);
    setText("[data-c19-demo-cold]", `${cold.toFixed(1)} °C`);
    setText("[data-c19-demo-radiation]", `${radiation.toFixed(2)} mSv`);
    setText("[data-c19-demo-latency]", `${latency} ms`);
    setText("[data-c19-demo-bus-a]", `${busA}%`);
    setText("[data-c19-demo-bus-b]", `${busB}%`);
    setText("[data-c19-demo-aux]", `${aux}%`);
    setText("[data-c19-demo-signal]", `SIGNAL ${signal}%`);
    setText("[data-c19-demo-uplink-latency]", `LATENCY ${latency} ms`);
    setText("[data-c19-demo-tab-heading]", `HEADING ${heading.toFixed(1)}°`);
    setText("[data-c19-demo-tab-error]", `COURSE ERROR ${courseError.toFixed(2)}°`);
    setText("[data-c19-demo-tab-velocity]", `VELOCITY ${velocity.toFixed(3)} c`);
    setText("[data-c19-demo-thrust]", `THRUST ${thrust}%`);
    setText("[data-c19-demo-tab-load]", `CAPACITY ${load}%`);
    setText("[data-c19-demo-tab-seals]", `SEALS ${seals}/18`);

    setMeter("[data-c19-demo-meter]", lifeReserve, "Life-support reserve");
    setMeter("[data-c19-demo-signal-meter]", signal, "Uplink signal");
    setProgress("[data-c19-demo-cargo-bar]", load, "Cargo capacity");
    setProgress("[data-c19-demo-bus-a-bar]", busA, "Primary bus A");
    setProgress("[data-c19-demo-bus-b-bar]", busB, "Primary bus B");
    setProgress("[data-c19-demo-aux-bar]", aux, "Auxiliary reserve");

    setStatus("[data-c19-demo-life-status]", oxygen < 20.87 ? "warn" : "ok", oxygen < 20.87 ? "Review" : "Nominal");
    setStatus("[data-c19-demo-reactor-status]", radiation > 0.84 ? "warn" : "ok", radiation > 0.84 ? "Observe" : "Nominal");
    setStatus("[data-c19-demo-uplink-status]", signal < 93 ? "warn" : "ok", signal < 93 ? "Degraded" : "Locked");
    setStatus("[data-c19-demo-power-status]", auxEnabled ? "ok" : "warn", auxEnabled ? "Balanced" : "Aux offline");
    updateAdvisory();

    if (phase % 3 === 0) {
      addLog("telemetry --sample", `sample ${String(phase / 3).padStart(2, "0")} committed / ${packets} packets per minute`);
    }
  }

  function startClock() {
    if (clockTimer) return;
    updateClock();
    clockTimer = window.setInterval(updateClock, 1000);
  }

  function startTelemetry() {
    if (!streamEnabled || telemetryTimer) return;
    updateTelemetry();
    telemetryTimer = window.setInterval(updateTelemetry, cadence);
  }

  function stopClock() {
    window.clearInterval(clockTimer);
    clockTimer = null;
  }

  function stopTelemetry() {
    window.clearInterval(telemetryTimer);
    telemetryTimer = null;
  }

  function setStream(enabled) {
    streamEnabled = enabled;
    if (streamToggle) streamToggle.checked = enabled;
    setStatus("[data-c19-demo-stream-status]", enabled ? "ok" : "warn", enabled ? "Live" : "Paused");
    if (enabled && !document.hidden) startTelemetry();
    else stopTelemetry();
    addLog("telemetry --stream", enabled ? "stream resumed / live sampling active" : "stream paused / values held");
  }

  document.addEventListener("visibilitychange", () => {
    if (document.hidden) {
      stopClock();
      stopTelemetry();
    } else {
      startClock();
      startTelemetry();
    }
  });

  dashboard.addEventListener("click", (event) => {
    const button = event.target instanceof Element ? event.target.closest("[data-c19-demo-command]") : null;
    if (!button) return;
    runCommand(button.getAttribute("data-c19-demo-command") || "");
  });

  one("[data-c19-demo-command-form]")?.addEventListener("submit", (event) => {
    event.preventDefault();
    const input = one("[data-c19-demo-command-input]");
    if (!(input instanceof HTMLInputElement)) return;
    runCommand(input.value);
    input.value = "";
    input.focus();
  });

  streamToggle?.addEventListener("change", () => setStream(streamToggle.checked));
  auxToggle?.addEventListener("change", () => {
    auxEnabled = auxToggle.checked;
    setProgress("[data-c19-demo-aux-bar]", auxEnabled ? 64 : 0, "Auxiliary reserve");
    setText("[data-c19-demo-aux]", auxEnabled ? "64%" : "0%");
    setStatus("[data-c19-demo-power-status]", auxEnabled ? "ok" : "warn", auxEnabled ? "Balanced" : "Aux offline");
    addLog("power --aux", auxEnabled ? "auxiliary bus connected" : "auxiliary bus isolated");
  });

  startClock();
  startTelemetry();
})();
