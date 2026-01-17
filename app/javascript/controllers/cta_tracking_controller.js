import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  trackPrimary() {
    this.track("cta_order_online_primary_click");
  }

  trackSecondary() {
    this.track("cta_order_online_secondary_click");
  }

  track(eventName) {
    if (window.analytics && typeof window.analytics.track === "function") {
      window.analytics.track(eventName);
      return;
    }

    if (typeof window.track === "function") {
      window.track(eventName);
      return;
    }

    if (typeof window.gtag === "function") {
      window.gtag("event", eventName);
    }
  }
}
