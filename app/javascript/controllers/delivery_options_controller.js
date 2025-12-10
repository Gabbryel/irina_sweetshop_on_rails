import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "methodSelect",
    "countyGroup",
    "countyField",
    "addressGroup",
    "addressField",
    "warning",
  ];
  static values = { method: String, itemsCount: Number };

  connect() {
    console.log("delivery options connected");
    this.syncMethodValue();
    this.toggle();
  }

  toggle() {
    const method = this.currentMethod;
    const isDelivery = method === "delivery";

    if (this.hasCountyGroupTarget) {
      this.toggleGroup(this.countyGroupTarget, isDelivery);
    }

    if (this.hasAddressGroupTarget) {
      this.toggleGroup(this.addressGroupTarget, isDelivery);
    }

    if (this.hasCountyFieldTarget) {
      this.countyFieldTarget.required = isDelivery;
      this.countyFieldTarget.disabled = !isDelivery;
    }

    if (this.hasAddressFieldTarget) {
      this.addressFieldTarget.required = isDelivery;
      this.addressFieldTarget.disabled = !isDelivery;
    }

    this.methodValue = method;

    this.toggleWarning(isDelivery);
  }

  syncMethodValue() {
    if (this.hasMethodSelectTarget) {
      if (!this.methodSelectTarget.value && this.hasMethodValue) {
        this.methodSelectTarget.value = this.methodValue;
      } else if (this.methodSelectTarget.value) {
        this.methodValue = this.methodSelectTarget.value;
      }
    }
  }

  get currentMethod() {
    if (this.hasMethodSelectTarget && this.methodSelectTarget.value) {
      return this.methodSelectTarget.value;
    }

    if (this.hasMethodValue) {
      return this.methodValue;
    }

    return "delivery";
  }

  toggleGroup(element, shouldShow) {
    element.classList.toggle("d-none", !shouldShow);
  }

  toggleWarning(isDelivery) {
    if (!this.hasWarningTarget) return;
    const tooFewItems = this.itemsCountValue <= 1;
    const shouldWarn = isDelivery && tooFewItems;
    this.warningTarget.classList.toggle("d-none", !shouldWarn);
  }
}
