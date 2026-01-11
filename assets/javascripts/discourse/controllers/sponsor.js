import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";

export default class SponsorController extends Controller {
  @service siteSettings;

  @tracked amount = "";
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
