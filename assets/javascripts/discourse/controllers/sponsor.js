import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import ajax from "discourse/lib/ajax";

export default class SponsorController extends Controller {
  @service siteSettings;
  @service currentUser;

  @tracked amount = "";
  @tracked anonymous = false;
  @tracked showInLeaderboard = true;
  @tracked leaderboardEntries = [];
  @tracked leaderboardSort = "amount";

  get presetAmounts() {
    const raw = this.siteSettings.sponsor_preset_amounts || "";

    return raw
      .split("|")
      .map((value) => value.trim())
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

  @action
  updateAnonymous(event) {
    this.anonymous = event.target.checked;
  }

  @action
  updateShowInLeaderboard(event) {
    this.showInLeaderboard = event.target.checked;
  }

  @action
  updateLeaderboardSort(event) {
    this.leaderboardSort = event.target.value;
    this.loadLeaderboard();
  }

  @action
  async loadData() {
    await this.loadLeaderboard();
    if (this.currentUser) {
      await this.loadPreferences();
    }
  }

  async loadPreferences() {
    const response = await ajax("/sponsor/preferences");
    this.anonymous = response.anonymous;
    this.showInLeaderboard = response.show_in_leaderboard;
  }

  async loadLeaderboard() {
    const response = await ajax("/sponsor/leaderboard", {
      data: { sort: this.leaderboardSort },
    });
    this.leaderboardEntries = response;
  }

  @action
  async savePreferences() {
    if (!this.currentUser) {
      return;
    }

    await ajax("/sponsor/preferences", {
      type: "PUT",
      data: {
        anonymous: this.anonymous,
        show_in_leaderboard: this.showInLeaderboard,
      },
    });
  }
}
