(function () {
  "use strict";

  function initializeIndex(index) {
    var list = index.querySelector("[data-index-list]");
    var search = index.querySelector("[data-index-search]");
    var pagination = index.querySelector("[data-index-pagination]");
    var previous = index.querySelector("[data-index-previous]");
    var next = index.querySelector("[data-index-next]");
    var status = index.querySelector("[data-index-status]");
    var noResults = index.querySelector("[data-index-no-results]");
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

    function render() {
      var matches = matchingItems();
      var pageCount = Math.max(1, Math.ceil(matches.length / perPage));
      currentPage = Math.min(currentPage, pageCount);
      var first = (currentPage - 1) * perPage;
      var last = first + perPage;

      items.forEach(function (item) {
        item.hidden = matches.indexOf(item) < first || matches.indexOf(item) >= last;
      });

      noResults.hidden = matches.length !== 0;
      pagination.hidden = matches.length <= perPage;
      previous.disabled = currentPage === 1;
      next.disabled = currentPage === pageCount;
      status.textContent = matches.length === 0 ? "" : "Page " + currentPage + " of " + pageCount;
    }

    search.addEventListener("input", function () {
      currentPage = 1;
      render();
    });

    previous.addEventListener("click", function () {
      if (currentPage > 1) {
        currentPage -= 1;
        render();
      }
    });

    next.addEventListener("click", function () {
      var pageCount = Math.ceil(matchingItems().length / perPage);
      if (currentPage < pageCount) {
        currentPage += 1;
        render();
      }
    });

    render();
  }

  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll("[data-per-page]").forEach(initializeIndex);
  });
})();
