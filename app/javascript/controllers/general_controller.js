import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["title", "container"];
  show() {
    var containers = this.containerTargets;
    var titles = this.titleTargets;
    containers.forEach((c, i) => {
      titles[i].style.opacity = 0;
    })
  }
  hide() {
    var containers = this.containerTargets;
    var titles = this.titleTargets;
    containers.forEach((c, i) => {
      titles[i].style.opacity = 1;
    })
  }

}