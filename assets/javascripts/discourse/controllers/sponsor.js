import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import ajax from "discourse/lib/ajax";

export default class SponsorController extends Controller {
  @service siteSettings;

  @tracked amount = "";
  @tracked leaderboard = [];
  @tracked leaderboardLoading = true;
  @tracked record = null;
  @tracked isAnonymous = false;

  constructor() {
    super(...arguments);
    this.loadData();
  }

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
  async toggleAnonymous(event) {
    const nextValue = event.target.checked;
    this.isAnonymous = nextValue;

    if (!this.record) {
      return;
    }

    try {
      const response = await ajax("/sponsor/record", {
        type: "PUT",
        data: { id: this.record.id, anonymous: nextValue },
      });
      this.record = response.record;
    } catch (error) {
      this.isAnonymous = this.record?.anonymous ?? false;
    }
  }

  async loadData() {
    await Promise.all([this.fetchLeaderboard(), this.fetchRecord()]);
  }

  async fetchLeaderboard() {
    this.leaderboardLoading = true;
    try {
      const response = await ajax("/sponsor/leaderboard");
      this.leaderboard = response.records || [];
    } finally {
      this.leaderboardLoading = false;
    }
  }

  async fetchRecord() {
    try {
      const response = await ajax("/sponsor/record");
      this.record = response.record;
      this.isAnonymous = this.record?.anonymous ?? false;
    } catch (error) {
      this.record = null;
      this.isAnonymous = false;
    }
  }
}
