(() => {
  "use strict";

  const dashboard = document.querySelector("[data-c19-demo-dashboard]");
  if (!dashboard) return;

  const one = (selector) => dashboard.querySelector(selector);
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const cadence = reducedMotion ? 5000 : 2500;
  const log = one("[data-c19-demo-log]");
  let phase = 0;
  let clockTimer = null;
  let telemetryTimer = null;

  const responses = {
    "nav --review": "course solution verified / deviation 0.04°",
    "cargo --inspect": "hold scan queued / operator route 03",
    "airlock --cycle": "A-01 cycle request accepted",
    "cold-bay --inspect": "C-04 inspection telemetry opened",
    "reactor --details": "R-02 advisory packet displayed"
  };

  function setText(selector, value) {
    const target = one(selector);
    if (target) target.textContent = value;
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

    while (log.children.length > 8) {
      log.firstElementChild?.remove();
    }
  }

  function updateClock() {
    const now = new Date();
    const shift = String(Math.floor(now.getUTCHours() / 6) + 1).padStart(2, "0");
    setText("[data-c19-demo-clock]", `UTC ${now.toISOString().slice(11, 19)} · SHIFT ${shift}`);
  }

  function updateTelemetry() {
    phase += 1;
    const atmosphere = 101.3 + Math.sin(phase / 2.8) * 0.18;
    const power = 92.4 + Math.sin(phase / 4.2) * 0.7;
    const humidity = 42 + Math.round(Math.sin(phase / 3.4) * 2);
    const heading = (281.4 + phase * 0.16) % 360;
    const load = 76 + Math.round(Math.sin(phase / 4.8));
    const radiation = 0.82 + Math.sin(phase / 2.2) * 0.03;

    setText("[data-c19-demo-atmosphere]", atmosphere.toFixed(1));
    setText("[data-c19-demo-power]", power.toFixed(1));
    setText("[data-c19-demo-humidity]", `RH ${humidity}%`);
    setText("[data-c19-demo-heading]", `HDG ${heading.toFixed(1)}°`);
    setText("[data-c19-demo-load]", `LOAD ${load}%`);
    setText("[data-c19-demo-pressure]", `${atmosphere.toFixed(1)} kPa`);
    setText("[data-c19-demo-radiation]", `${radiation.toFixed(2)} mSv`);
    one("[data-c19-demo-meter]")?.style.setProperty("--c19-value", `${82 + humidity % 5}%`);

    if (phase % 4 === 0) {
      addLog("telemetry --sample", `sample ${String(phase / 4).padStart(2, "0")} committed / all channels stable`);
    }
  }

  function start() {
    if (clockTimer || telemetryTimer) return;
    updateClock();
    updateTelemetry();
    clockTimer = window.setInterval(updateClock, 1000);
    telemetryTimer = window.setInterval(updateTelemetry, cadence);
  }

  function stop() {
    window.clearInterval(clockTimer);
    window.clearInterval(telemetryTimer);
    clockTimer = null;
    telemetryTimer = null;
  }

  document.addEventListener("visibilitychange", () => {
    if (document.hidden) stop();
    else start();
  });

  dashboard.addEventListener("click", (event) => {
    const button = event.target.closest("[data-c19-demo-command]");
    if (!button) return;
    const command = button.getAttribute("data-c19-demo-command");
    addLog(command, responses[command] || "command accepted");
  });

  start();
})();
