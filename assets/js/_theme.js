(function() {
    "use strict";
    const initTheme = (state) => {
      document.documentElement.setAttribute("color-scheme", state);
    };

    window.addEventListener("DOMContentLoaded", () => {
      initTheme("dark");
      requestAnimationFrame(() => document.body.classList.remove("notransition"))
    });
})();
