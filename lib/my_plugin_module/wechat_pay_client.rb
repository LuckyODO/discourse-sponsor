# frozen_string_literal: true

module ::MyPluginModule
  class WechatPayClient
    def initialize
      @app_id = SiteSetting.wechat_pay_app_id
      @merchant_id = SiteSetting.wechat_pay_merchant_id
      @private_key = SiteSetting.wechat_pay_private_key
      @public_key = SiteSetting.wechat_pay_public_key
      @notify_url = SiteSetting.wechat_pay_notify_url
    end

    def create_order(order_id:, amount_cents:, description:)
      {
        provider: "wechat_pay",
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
