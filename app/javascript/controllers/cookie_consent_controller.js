import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["preferencesButton"];
  static values = {
    gaId: String,
    consent: String,
    policyUrl: String,
  };

  connect() {
    this.banner = this.element;
    this.updateStateFromConsent(this.consentValue || this.readConsent());

    // expose a global hook so footer link or modal buttons can reopen preferences
    window.cookieConsent = window.cookieConsent || {};
    window.cookieConsent.changeConsent = () => {
      // If the banner/controller isn't present, fall back to the full GDPR page
      if (!this.banner) {
        if (this.hasPolicyUrlValue) {
          window.location = this.policyUrlValue;
        }
        return;
      }

      this.openPreferences();
    };
  }

  accept() {
    this.storeConsent("accepted");
    this.applyConsent(true);
  }

  decline() {
    this.storeConsent("declined");
    this.applyConsent(false);
  }

  openPreferences() {
    this.closeOpenModal();
    this.showBanner();
    this.focusAcceptButton();
  }

  applyConsent(enableAnalytics) {
    this.hideBanner();
    this.showPreferencesButton();
    if (enableAnalytics) {
      this.loadAnalytics();
    }
  }

  updateStateFromConsent(consent) {
    if (consent === "accepted") {
      this.applyConsent(true);
    } else if (consent === "declined") {
      this.applyConsent(false);
    } else {
      this.showBanner();
    }
  }

  loadAnalytics() {
    if (!this.hasGaIdValue || window.__gaConsentLoaded) return;

    window.__gaConsentLoaded = true;
    window.dataLayer = window.dataLayer || [];
    window.gtag = function gtag() {
      window.dataLayer.push(arguments);
    };

    const script = document.createElement("script");
    script.async = true;
    script.src = `https://www.googletagmanager.com/gtag/js?id=${this.gaIdValue}`;
    script.onload = () => {
      window.gtag("js", new Date());
      window.gtag("config", this.gaIdValue);
    };

    document.head.appendChild(script);
  }

  storeConsent(value) {
    const maxAge = 60 * 60 * 24 * 180; // 6 months
    const secureFlag = window.location.protocol === "https:" ? " Secure;" : "";
    document.cookie = `cookie_consent=${value}; path=/; max-age=${maxAge}; SameSite=Lax;${secureFlag}`;
  }

  readConsent() {
    const match = document.cookie.match(/(?:^|; )cookie_consent=([^;]+)/);
    return match ? decodeURIComponent(match[1]) : null;
  }

  showBanner() {
    if (this.banner) {
      this.banner.style.display = "block";
      this.banner.setAttribute("aria-hidden", "false");
      // scroll into view if needed
      this.banner.scrollIntoView({ behavior: "smooth", block: "end" });
    }
    this.hidePreferencesButton();
  }

  hideBanner() {
    if (this.banner) {
      this.banner.style.display = "none";
      this.banner.setAttribute("aria-hidden", "true");
    }
  }

  showPreferencesButton() {
    if (this.hasPreferencesButtonTarget) {
      this.preferencesButtonTarget.style.display = "inline-flex";
    }
  }

  hidePreferencesButton() {
    if (this.hasPreferencesButtonTarget) {
      this.preferencesButtonTarget.style.display = "none";
    }
  }

  closeOpenModal() {
    const modalEl = document.querySelector(".modal.show");
    if (modalEl && window.bootstrap) {
      const instance = window.bootstrap.Modal.getInstance(modalEl) || new window.bootstrap.Modal(modalEl);
      instance.hide();
    }
  }

  focusAcceptButton() {
    const btn = this.banner?.querySelector('[data-action="cookie-consent#accept"]');
    if (btn) {
      setTimeout(() => btn.focus({ preventScroll: true }), 50);
    }
  }

  disconnect() {
    if (window.cookieConsent && window.cookieConsent.changeConsent) {
      delete window.cookieConsent.changeConsent;
    }
  }
}
