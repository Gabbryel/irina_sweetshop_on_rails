import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

export default class extends Controller {
  static targets = ["input", "message"];

  static values = {
    disabledDates: Array,
    minDate: String,
    maxDate: String,
  };

  connect() {
    if (!this.hasInputTarget) return;

    const disabled = this.parseBlockedAsIso();
    const defaultDate = this.inputTarget.value || null;

    this.picker = flatpickr(this.inputTarget, {
      dateFormat: "Y-m-d",
      altInput: true,
      altFormat: "d.m.Y",
      allowInput: true,
      disableMobile: true,
      minDate: this.hasMinDateValue ? this.minDateValue : null,
      maxDate: this.hasMaxDateValue ? this.maxDateValue : null,
      defaultDate,
      disable: disabled,
      onChange: this.handleChange.bind(this),
    });
  }

  disconnect() {
    if (this.picker) {
      this.picker.destroy();
      this.picker = null;
    }
  }

  handleChange(selectedDates, dateStr) {
    if (!dateStr) {
      this.hideMessage();
      return;
    }

    const iso = dateStr; // already Y-m-d from flatpickr
    const display = this.isoToDisplay(iso);

    if (this.blockedDisplay?.includes(display)) {
      this.picker.clear();
      this.showMessage(
        "Data selectată este blocată pentru livrare. Alege altă zi."
      );
      return;
    }

    this.hideMessage();
  }

  parseBlockedAsIso() {
    const raw = this.hasDisabledDatesValue ? this.disabledDatesValue : [];
    const list = Array.isArray(raw) ? raw.map(String) : [];

    this.blockedDisplay = list;

    return list
      .map((d) => {
        const parts = d.split(".");
        if (parts.length !== 3) return null;
        const [day, month, year] = parts;
        if (!day || !month || !year) return null;
        return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
      })
      .filter(Boolean);
  }

  isoToDisplay(isoDate) {
    if (!isoDate || typeof isoDate !== "string") return "";
    const [year, month, day] = isoDate.split("-");
    if (!year || !month || !day) return isoDate;
    return `${day.padStart(2, "0")}.${month.padStart(2, "0")}.${year}`;
  }

  showMessage(text) {
    if (this.hasMessageTarget) {
      this.messageTarget.textContent = text;
      this.messageTarget.classList.remove("d-none");
    }
  }

  hideMessage() {
    if (this.hasMessageTarget) {
      this.messageTarget.textContent = "";
      this.messageTarget.classList.add("d-none");
    }
  }
}
