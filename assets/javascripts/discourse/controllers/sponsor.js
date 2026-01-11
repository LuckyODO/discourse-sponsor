import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class SponsorController extends Controller {
  @service siteSettings;

  @tracked amount = "";

  get presetAmounts() {
    const raw = this.siteSettings.discourse_sponsor_default_amounts || "";
    const values = Array.isArray(raw) ? raw : raw.split("|");

    return values
      .map((value) => value.toString().trim())
      .filter((value) => value.length > 0);
  }

  @action
  selectPreset(amount) {
    this.amount = amount;
  }

  @action
  updateAmount(event) {
    this.amount = event.target.value;
  }
}
