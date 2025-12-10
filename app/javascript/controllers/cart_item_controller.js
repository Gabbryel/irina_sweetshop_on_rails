import { Controller } from "@hotwired/stimulus";

export const name = "cart-item";

export default class extends Controller {
  static values = { debounce: { type: Number, default: 300 } };

  submit() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
    this.timeout = setTimeout(() => {
      // requestSubmit preserves method/params; works with Turbo or full reload
      this.element.requestSubmit();
    }, this.debounceValue);
  }
}
