import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import ajax from "discourse/lib/ajax";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";

export default class SponsorController extends Controller {
  @service siteSettings;
  @service currentUser;

  @tracked amount = "";
  @tracked paymentMethod = "alipay";
  @tracked paymentStatus = "pending";
  @tracked qrCodeUrl = null;
  @tracked qrCodePayload = null;
  @tracked isCreating = false;
  @tracked anonymous = false;
  @tracked showInLeaderboard = true;
  @tracked leaderboardEntries = [];
  @tracked leaderboardSort = "amount";
  @tracked orderId = null;
  @tracked qrCodeUrl = null;
  @tracked paymentUrl = null;
  @tracked orderStatus = null;
  @tracked isLoading = false;
  @tracked errorMessage = null;
  @tracked showThankYou = false;

  pollingTimer = null;

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

  @action
  async selectPayment(method) {
    this.paymentMethod = method;
    await this.createOrder();
  }

  @action
  async createOrder() {
    if (this.isCreating) {
      return;
    }

    this.isCreating = true;
    this.paymentStatus = "pending";
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
  async createOrder(paymentMethod) {
    const amountValue = Number.parseFloat(this.amount);

    if (!amountValue || amountValue <= 0) {
      this.errorMessage = I18n.t(
        "discourse_plugin_name.sponsor.invalid_amount"
      );
      return;
    }

    this.isLoading = true;
    this.errorMessage = null;
    this.showThankYou = false;

    try {
      const response = await ajax("/sponsor/orders", {
        type: "POST",
        data: {
          amount: this.amount,
          payment_method: this.paymentMethod,
        },
      });

      this.qrCodeUrl = response?.qr_code_url || null;
      this.qrCodePayload =
        response?.qr_code_text || response?.qr_code_payload || null;

      if (response?.paid || response?.status === "paid") {
        this.paymentStatus = "paid";
      }
    } finally {
      this.isCreating = false;
    }
  }
          payment_method: paymentMethod,
          amount_cents: Math.round(amountValue * 100),
        },
      });

      this.orderId = response.order_id || response.payment_params?.order_id;
      this.qrCodeUrl = response.qr_code_url || response.payment_params?.qr_code_url;
      this.paymentUrl =
        response.payment_url || response.payment_params?.payment_url;
      this.orderStatus = response.status || "pending";
      this.startPolling();
    } catch (error) {
      this.errorMessage = error?.jqXHR?.responseJSON?.error
        ? error.jqXHR.responseJSON.error
        : I18n.t("discourse_plugin_name.sponsor.order_failed");
    } finally {
      this.isLoading = false;
    }
  }

  @action
  async fetchOrderStatus() {
    if (!this.orderId) {
      return;
    }

    try {
      const response = await ajax(`/sponsor/orders/${this.orderId}/status`);
      this.orderStatus = response.status;
      if (response.status === "paid") {
        this.showThankYou = true;
        this.stopPolling();
      }
    } catch (error) {
      this.stopPolling();
    }
  }

  startPolling() {
    this.stopPolling();
    this.pollingTimer = window.setInterval(() => {
      this.fetchOrderStatus();
    }, 3000);
  }

  stopPolling() {
    if (this.pollingTimer) {
      window.clearInterval(this.pollingTimer);
      this.pollingTimer = null;
    }
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.stopPolling();
  }
}
