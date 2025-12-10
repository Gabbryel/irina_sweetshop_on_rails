import { Controller } from "@hotwired/stimulus";

export const name = "nested-extras";

export default class extends Controller {
  static targets = ["list", "template"];

  // No auto-append on input; extras are added only via the button

  appendNewRow() {
    if (!this.templateTarget) return;
    const time = new Date().getTime();
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, time);
    this.listTarget.insertAdjacentHTML("beforeend", content);
  }

  // public action called from button
  addRow(event) {
    event && event.preventDefault();
    this.appendNewRow();
  }

  // Remove or mark a nested extra row for deletion
  removeRow(event) {
    event && event.preventDefault();
    const btn = event.target;
    const row = btn.closest(".nested-extra-row");
    if (!row) return;

    const destroyInput = row.querySelector('input[name*="[_destroy]"]');
    const idInput = row.querySelector('input[name*="[id]"]');

    // If the row corresponds to an existing record, mark it for destroy and hide it
    if (destroyInput && idInput) {
      destroyInput.value = "1";
      row.classList.add("d-none");
      return;
    }

    // Otherwise remove the row from the DOM entirely
    row.remove();
  }
}
