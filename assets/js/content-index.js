(function () {
  "use strict";

  function initializeIndex(index) {
    // The include may load this script more than once; never wire an index twice.
    if (index.dataset.indexReady === "true") return;
    index.dataset.indexReady = "true";

    var list = index.querySelector("[data-index-list]");
    var search = index.querySelector("[data-index-search]");
    var pagination = index.querySelector("[data-index-pagination]");
    var previous = index.querySelector("[data-index-previous]");
    var next = index.querySelector("[data-index-next]");
    var status = index.querySelector("[data-index-status]");
    var noResults = index.querySelector("[data-index-no-results]");
    var announcer = index.querySelector("[data-index-announcer]");
    var items = Array.prototype.slice.call(list.querySelectorAll("[data-index-item]"));
    var perPage = Number(index.dataset.perPage) || 10;
    var currentPage = 1;

    function matchingItems() {
      var query = search.value.trim().toLocaleLowerCase();
      if (!query) return items;
      return items.filter(function (item) {
        return item.dataset.search.indexOf(query) !== -1;
      });
    }

    // Tells screen readers what changed (the visible list updates silently). Only called after user actions,
    // so nothing is announced when the page loads.
    function announce(matches, pageCount) {
      if (!announcer) return;
      if (matches.length === 0) {
        announcer.textContent = "No matching items found.";
        return;
      }
      var found = matches.length + (matches.length === 1 ? " item" : " items");
      announcer.textContent = pageCount > 1 ? found + ", page " + currentPage + " of " + pageCount + "." : found + ".";
    }

    function render(userAction) {
      var matches = matchingItems();
      var pageCount = Math.max(1, Math.ceil(matches.length / perPage));
      currentPage = Math.min(currentPage, pageCount);
      var first = (currentPage - 1) * perPage;
      var last = first + perPage;

      items.forEach(function (item) {
        item.hidden = matches.indexOf(item) < first || matches.indexOf(item) >= last;
      });

      // An empty index already shows its own "nothing yet" message; "no matches" is only for searches.
      noResults.hidden = items.length === 0 || matches.length !== 0;
      pagination.hidden = matches.length <= perPage;
      previous.disabled = currentPage === 1;
      next.disabled = currentPage === pageCount;
      status.textContent = matches.length === 0 ? "" : "Page " + currentPage + " of " + pageCount;
      if (userAction) announce(matches, pageCount);
    }

    search.addEventListener("input", function () {
      currentPage = 1;
      render(true);
    });

    previous.addEventListener("click", function () {
      if (currentPage > 1) {
        currentPage -= 1;
        render(true);
        // The button may now be disabled; continue from the top of the new page.
        list.focus();
      }
    });

    next.addEventListener("click", function () {
      var pageCount = Math.ceil(matchingItems().length / perPage);
      if (currentPage < pageCount) {
        currentPage += 1;
        render(true);
        // The button may now be disabled; continue from the top of the new page.
        list.focus();
      }
    });

    render();
  }

  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll("[data-per-page]").forEach(initializeIndex);
  });
})();
