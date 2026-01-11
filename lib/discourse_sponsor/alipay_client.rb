# frozen_string_literal: true

module ::DiscourseSponsor
  class AlipayClient
    def initialize
      @app_id = SiteSetting.alipay_app_id
      @merchant_id = SiteSetting.alipay_merchant_id
      @private_key = SiteSetting.alipay_private_key
      @public_key = SiteSetting.alipay_public_key
      @notify_url = SiteSetting.alipay_notify_url
    end

    def create_order(order_id:, amount_cents:, description:)
      {
        provider: "alipay",
        app_id: @app_id,
        merchant_id: @merchant_id,
        notify_url: @notify_url,
        order_id: order_id,
        amount_cents: amount_cents,
        description: description,
        timestamp: Time.zone.now.to_i,
        signature: sign_payload(order_id: order_id, amount_cents: amount_cents),
      }
    end

    private

    def sign_payload(order_id:, amount_cents:)
      "signed:#{order_id}:#{amount_cents}:#{@private_key&.bytesize || 0}:#{@public_key&.bytesize || 0}"
    end
  end
end
