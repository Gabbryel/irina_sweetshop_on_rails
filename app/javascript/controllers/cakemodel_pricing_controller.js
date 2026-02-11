import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "recipe",
    "design",
    "weight",
    "pricePerKg",
    "pricePerPiece",
    "finalPrice",
  ];

  static values = {
    recipePrices: Object,
    designPrices: Object,
    selectedRecipe: String,
  };

  connect() {
    this.refresh();
  }

  refresh() {
    const recipeId = this.currentRecipeId();
    const designId = this.currentDesignId();
    const weightKg = this.currentWeightKg();

    if (!recipeId || !designId || weightKg <= 0) return;

    const recipePrice = this.lookupPrice(this.recipePricesValue, recipeId);
    const designPrice = this.lookupPrice(this.designPricesValue, designId);
    if (recipePrice === null || designPrice === null) return;

    const derivedPerKg = this.roundTo2(recipePrice + designPrice);
    const derivedPerPiece = this.roundTo2(derivedPerKg * weightKg);

    if (this.hasPricePerKgTarget) {
      this.pricePerKgTarget.value = derivedPerKg.toFixed(2);
    }

    if (this.hasPricePerPieceTarget) {
      this.pricePerPieceTarget.value = derivedPerPiece.toFixed(2);
    }

    if (!this.hasFinalPriceTarget) return;

    const manual = this.finalPriceTarget.dataset.manual === "true";
    const currentValue = this.finalPriceTarget.value.trim();
    if (!manual || currentValue === "") {
      this.finalPriceTarget.value = derivedPerPiece.toFixed(2);
      this.finalPriceTarget.dataset.manual = "false";
    }
  }

  markFinalPriceManual() {
    if (!this.hasFinalPriceTarget) return;

    this.finalPriceTarget.dataset.manual = this.finalPriceTarget.value.trim() === "" ? "false" : "true";
  }

  currentRecipeId() {
    if (this.hasRecipeTarget && this.recipeTarget.value) return this.recipeTarget.value;
    return this.selectedRecipeValue || "";
  }

  currentDesignId() {
    return this.hasDesignTarget ? this.designTarget.value : "";
  }

  currentWeightKg() {
    if (!this.hasWeightTarget) return 0;
    const grams = parseFloat(this.weightTarget.value || "0");
    if (Number.isNaN(grams) || grams <= 0) return 0;

    return grams / 1000.0;
  }

  lookupPrice(priceMap, id) {
    if (!priceMap || !id) return null;

    const raw = priceMap[id] ?? priceMap[String(id)];
    const parsed = parseFloat(raw);
    return Number.isNaN(parsed) ? null : parsed;
  }

  roundTo2(value) {
    return Math.round((value + Number.EPSILON) * 100) / 100;
  }
}
