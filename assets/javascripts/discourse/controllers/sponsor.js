import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

export default class SponsorController extends Controller {
  @service siteSettings;

  @tracked amount = "";
  @tracked paymentMethod = "alipay";
  @tracked paymentStatus = "pending";
  @tracked qrCodeUrl = null;
  @tracked qrCodePayload = null;
  @tracked isCreating = false;

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
}
