import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["kg", "soldBy", "weight"];

  connect() {
    this.update();
  }

  handleChange() {
    this.update();
  }

  update() {
    const kgValue = this.hasKgTarget ? this.kgTarget.value.toLowerCase() : "";
    const soldByValue = this.hasSoldByTarget
      ? this.soldByTarget.value.toLowerCase()
      : "";
    const shouldEnable = kgValue === "kg" && soldByValue === "buc";

    if (!this.hasWeightTarget) return;

    const weightField = this.weightTarget;
    weightField.disabled = !shouldEnable;
    weightField.required = shouldEnable;

    if (!shouldEnable) {
      weightField.value = "";
    }
  }
}
