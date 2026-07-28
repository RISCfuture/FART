const tabList = document.querySelector('[role="tablist"]');

const tabs = () => [...tabList.querySelectorAll('[role="tab"]')];

const panelFor = tab => document.getElementById(tab.getAttribute("aria-controls"));

function select(tab, { focus = true } = {}) {
  for (const other of tabs()) {
    const selected = other === tab;
    other.setAttribute("aria-selected", String(selected));
    other.tabIndex = selected ? 0 : -1;
    panelFor(other).hidden = !selected;
  }
  if (focus) tab.focus();
}

function neighbor(offset) {
  const all = tabs();
  const current = all.findIndex(tab => tab.getAttribute("aria-selected") === "true");
  return all[(current + offset + all.length) % all.length];
}

const arrowKeys = {
  ArrowRight: () => neighbor(1),
  ArrowLeft: () => neighbor(-1),
  Home: () => tabs().at(0),
  End: () => tabs().at(-1)
};

tabList?.addEventListener("click", event => {
  const tab = event.target.closest('[role="tab"]');
  if (tab) select(tab, { focus: false });
});

tabList?.addEventListener("keydown", event => {
  const target = arrowKeys[event.key]?.();
  if (!target) return;
  event.preventDefault();
  select(target);
});

for (const year of document.querySelectorAll("[data-current-year]")) {
  year.textContent = String(new Date().getFullYear());
}

/* The hero tally deals its answers one at a time, so the running total climbs
   into the red and the last answer — a mitigation — pulls it back out. */

const tally = document.querySelector(".tally");

const thresholds = { moderate: 14, high: 20 };

const bandFor = score =>
  score > thresholds.high ? "high" : score > thresholds.moderate ? "moderate" : "low";

const bandNames = { low: "Low risk", moderate: "Moderate risk", high: "High risk" };

function showRunningTotal(score) {
  const band = bandFor(score);
  tally.dataset.band = band;
  tally.querySelector("[data-score]").textContent = String(score);
  tally.querySelector("[data-band-name]").textContent = bandNames[band];
  tally.querySelector("[data-marker]").style.setProperty("--at", String(score));
}

function runningTotals() {
  let total = 0;
  return [...tally.querySelectorAll(".tally-items li")].map(item => {
    total += Number(item.dataset.points);
    return total;
  });
}

const stillFrames = window.matchMedia("(prefers-reduced-motion: reduce)");

function dealTally() {
  const totals = runningTotals();
  if (stillFrames.matches) return showRunningTotal(totals.at(-1));

  showRunningTotal(0);
  totals.forEach((total, index) => {
    setTimeout(() => showRunningTotal(total), 550 + index * 360);
  });
}

if (tally) dealTally();
