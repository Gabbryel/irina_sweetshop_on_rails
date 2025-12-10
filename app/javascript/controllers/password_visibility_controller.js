import { Controller } from "@hotwired/stimulus";

// Name is used by the dynamic loader in controllers/index.js
export const name = "password-visibility";

export default class extends Controller {
  static targets = ["input", "icon"];

  toggle(event) {
    event.preventDefault();

    const input = this.inputTarget;
    if (!input) return;

    const isPassword = input.type === "password";
    input.type = isPassword ? "text" : "password";

    if (this.hasIconTarget) {
      this.iconTarget.classList.toggle("fa-eye");
      this.iconTarget.classList.toggle("fa-eye-slash");
    }
  }
}
