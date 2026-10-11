// Tests for assets/js/content-index.js (search + pagination of the index pages).
//
// The HTML under test is the real output of _includes/content-index.html, rendered by Jekyll through
// test/support/render_include.rb, so a change to the include that breaks the script's hooks
// (data-index-* attributes, data-search text, ...) is caught here. Run with `npm test`
// (needs `npm ci` once, and `bundle install`).

import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { describe, test } from "node:test";
import { fileURLToPath } from "node:url";
import { JSDOM } from "jsdom";

const root = join(dirname(fileURLToPath(import.meta.url)), "..", "..");
const script = readFileSync(join(root, "assets", "js", "content-index.js"), "utf8");

function renderIndex(items) {
  return execFileSync(
    "bundle",
    ["exec", "ruby", "test/support/render_include.rb", "content-index.html", JSON.stringify({ id: "test", items })],
    { cwd: root, encoding: "utf8" },
  );
}

const pad = (n) => String(n).padStart(2, "0");

// 25 items: "Item 01" ... "Item 25"; odd positions are Mathematics, every 5th is tagged Special.
const items = (count) =>
  Array.from({ length: count }, (_, i) => ({
    title: `Item ${pad(i + 1)}`,
    url: `/items/${i + 1}/`,
    date: `2026-01-${pad(i + 1)}`,
    categories: [i % 2 === 1 ? "Mathematics" : "Programming"],
    tags: [i % 5 === 0 ? "Special" : "Regular"],
  }));

const html25 = renderIndex(items(25));
const html3 = renderIndex(items(3));
const html0 = renderIndex([]);

// Loads `html` in jsdom, evaluates the script and fires DOMContentLoaded, as a browser would.
async function mount(html, { perPage } = {}) {
  const dom = new JSDOM(`<!doctype html><html><body>${html}</body></html>`, { runScripts: "outside-only" });
  const { window } = dom;
  const { document } = window;
  if (document.readyState !== "complete") {
    await new Promise((resolve) => window.addEventListener("load", resolve));
  }
  if (perPage) document.querySelector("[data-per-page]").dataset.perPage = String(perPage);

  window.eval(script);
  const start = () => document.dispatchEvent(new window.Event("DOMContentLoaded"));
  start();

  const one = (selector) => document.querySelector(selector);
  return {
    start,
    search: one("[data-index-search]"),
    previous: one("[data-index-previous]"),
    next: one("[data-index-next]"),
    status: one("[data-index-status]"),
    pagination: one("[data-index-pagination]"),
    noResults: one("[data-index-no-results]"),
    visible: () =>
      [...document.querySelectorAll("[data-index-item]")]
        .filter((li) => !li.hidden)
        .map((li) => li.querySelector("a").textContent),
    type(text) {
      this.search.value = text;
      this.search.dispatchEvent(new window.Event("input", { bubbles: true }));
    },
  };
}

const titles = (from, to) => Array.from({ length: to - from + 1 }, (_, i) => `Item ${pad(from + i)}`);

describe("content-index.js", () => {
  test("shows the first page and a disabled Previous button", async () => {
    const ui = await mount(html25);

    assert.deepEqual(ui.visible(), titles(1, 10));
    assert.equal(ui.pagination.hidden, false);
    assert.equal(ui.status.textContent, "Page 1 of 3");
    assert.equal(ui.previous.disabled, true);
    assert.equal(ui.next.disabled, false);
    assert.equal(ui.noResults.hidden, true);
  });

  test("Next and Previous move between pages", async () => {
    const ui = await mount(html25);

    ui.next.click();
    assert.deepEqual(ui.visible(), titles(11, 20));
    assert.equal(ui.status.textContent, "Page 2 of 3");
    assert.equal(ui.previous.disabled, false);

    ui.next.click();
    assert.deepEqual(ui.visible(), titles(21, 25));
    assert.equal(ui.status.textContent, "Page 3 of 3");
    assert.equal(ui.next.disabled, true);

    ui.previous.click();
    ui.previous.click();
    assert.deepEqual(ui.visible(), titles(1, 10));
    assert.equal(ui.previous.disabled, true);
  });

  test("never goes past the last page", async () => {
    const ui = await mount(html25);

    for (let i = 0; i < 5; i += 1) ui.next.click();

    assert.equal(ui.status.textContent, "Page 3 of 3");
    assert.deepEqual(ui.visible(), titles(21, 25));
  });

  test("search matches the title, ignoring case", async () => {
    const ui = await mount(html25);

    ui.type("ITEM 07");

    assert.deepEqual(ui.visible(), ["Item 07"]);
    assert.equal(ui.pagination.hidden, true);
    assert.equal(ui.noResults.hidden, true);
  });

  test("search matches the date text", async () => {
    const ui = await mount(html25);

    ui.type("january 05, 2026");

    assert.deepEqual(ui.visible(), ["Item 05"]);
  });

  test("search can span several fields (title, date, category, tag)", async () => {
    const ui = await mount(html25);

    ui.type("item 07 january 07, 2026 programming regular");

    assert.deepEqual(ui.visible(), ["Item 07"]);
  });

  test("search matches tags", async () => {
    const ui = await mount(html25);

    ui.type("special");

    assert.deepEqual(ui.visible(), ["Item 01", "Item 06", "Item 11", "Item 16", "Item 21"]);
  });

  test("search matches categories and paginates the matches", async () => {
    const ui = await mount(html25);

    ui.type("mathematics");

    assert.deepEqual(ui.visible(), ["02", "04", "06", "08", "10", "12", "14", "16", "18", "20"].map((n) => `Item ${n}`));
    assert.equal(ui.status.textContent, "Page 1 of 2");
    assert.equal(ui.pagination.hidden, false);

    ui.next.click();
    assert.deepEqual(ui.visible(), ["Item 22", "Item 24"]);
    assert.equal(ui.next.disabled, true);
  });

  test("a new search goes back to the first page", async () => {
    const ui = await mount(html25);
    ui.next.click();
    ui.next.click();

    ui.type("item");

    assert.equal(ui.status.textContent, "Page 1 of 3");
    assert.deepEqual(ui.visible(), titles(1, 10));
  });

  test("shows the no-results message when nothing matches, and recovers when the query is cleared", async () => {
    const ui = await mount(html25);

    ui.type("zzz");
    assert.deepEqual(ui.visible(), []);
    assert.equal(ui.noResults.hidden, false);
    assert.equal(ui.pagination.hidden, true);
    assert.equal(ui.status.textContent, "");

    ui.type("");
    assert.deepEqual(ui.visible(), titles(1, 10));
    assert.equal(ui.noResults.hidden, true);
    assert.equal(ui.status.textContent, "Page 1 of 3");
  });

  test("surrounding whitespace in the query is ignored", async () => {
    const ui = await mount(html25);

    ui.type("   item 07  ");

    assert.deepEqual(ui.visible(), ["Item 07"]);
  });

  test("hides the pagination when everything fits in one page", async () => {
    const ui = await mount(html3);

    assert.deepEqual(ui.visible(), titles(1, 3));
    assert.equal(ui.pagination.hidden, true);
  });

  test("an empty index shows only its own message, not 'no matching items'", async () => {
    const ui = await mount(html0);

    assert.deepEqual(ui.visible(), []);
    assert.equal(ui.noResults.hidden, true);
    assert.equal(ui.pagination.hidden, true);
    assert.equal(ui.status.textContent, "");
  });

  test("honours data-per-page", async () => {
    const ui = await mount(html25, { perPage: 5 });

    assert.deepEqual(ui.visible(), titles(1, 5));
    assert.equal(ui.status.textContent, "Page 1 of 5");
  });

  test("is wired only once even if the page initialises it again", async () => {
    const ui = await mount(html25);
    ui.start();

    ui.next.click();

    assert.equal(ui.status.textContent, "Page 2 of 3");
  });
});
