/*
 * Keeps the login screens in the light/dark mode the manager picked in the
 * SoccerProject frontend.
 *
 * The app publishes its choice as the `sp_theme` cookie on the domain shared by
 * the app host and this auth host (see src/utils/themeCookie.ts). Without that
 * cookie nothing happens here and the parent theme's OS-preference logic stays
 * in charge — so this degrades cleanly for deep links, bookmarks and any host
 * that does not share the cookie domain.
 */
(function () {
  var DARK_MODE_CLASS = 'pf-v5-theme-dark';
  var COOKIE_PATTERN = /(?:^|;\s*)sp_theme=(light|dark)(?:;|$)/;

  function preferredMode() {
    var match = COOKIE_PATTERN.exec(document.cookie);
    return match ? match[1] : null;
  }

  function apply() {
    var mode = preferredMode();

    if (!mode) {
      return;
    }

    var classList = document.documentElement.classList;
    var wantsDark = mode === 'dark';

    // Only write when it actually differs, otherwise the MutationObserver below
    // would keep re-triggering itself.
    if (classList.contains(DARK_MODE_CLASS) !== wantsDark) {
      classList.toggle(DARK_MODE_CLASS, wantsDark);
    }
  }

  apply();

  // The parent theme sets the class from the OS preference in a module script,
  // which runs after this one. Re-assert on every class change so the manager's
  // choice wins, without a flash of the other mode.
  if (typeof MutationObserver === 'function') {
    new MutationObserver(apply).observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class'],
    });
  }

  document.addEventListener('DOMContentLoaded', apply);
})();
