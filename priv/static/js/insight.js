(() => {
  const script = document.currentScript;
  const siteId = script.getAttribute("data-site");
  const endpoint =
    script.getAttribute("data-endpoint") || "http://localhost:4000/api/collect";

  if (!siteId) {
    console.error("Lumen Analytics: Missing data-site attribute");
    return;
  }

  function trackPageview() {
    const data = {
      site_id: siteId,
      path: window.location.pathname,
      referrer: document.referrer || null,
    };

    fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
      keepalive: true,
    }).catch(() => { });
  }

  trackPageview();

  const history = window.history;
  if (history.pushState) {
    const originalPushState = history.pushState;
    history.pushState = function(...args) {
      originalPushState.apply(this, args);
      trackPageview();
    };
    window.addEventListener("popstate", trackPageview);
  }
})();
