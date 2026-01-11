# frozen_string_literal: true

module ::DiscourseSponsor
  class WechatPayClient
    def initialize
      @app_id = SiteSetting.discourse_sponsor_wechat_app_id
      @merchant_id = SiteSetting.discourse_sponsor_wechat_merchant_id
      @private_key = SiteSetting.discourse_sponsor_wechat_private_key
      @public_key = SiteSetting.discourse_sponsor_wechat_public_key
      @notify_url = SiteSetting.discourse_sponsor_wechat_notify_url
    end

    def create_order(order_id:, amount_cents:, description:)
      payload = {
        appid: @app_id,
        mchid: @merchant_id,
        out_trade_no: order_id,
        description: description,
        notify_url: @notify_url,
        amount: {
          total: amount_cents,
          currency: "CNY",
        },
      }

      response = client.post("/v3/pay/transactions/native", payload)
      parsed = response.is_a?(String) ? JSON.parse(response) : response
      code_url = parsed["code_url"]
      unless code_url.present?
        raise PaymentProviderError.new(
          provider: "wechat_pay",
          message: "wechat_pay_request_failed",
          details: parsed,
        )
      end

      {
        provider: "wechat_pay",
        order_id: order_id,
        amount_cents: amount_cents,
        code_url: code_url,
        raw: parsed,
      }
    rescue StandardError => e
      raise PaymentProviderError.new(
        provider: "wechat_pay",
        message: "wechat_pay_request_failed",
        details: e.message,
      )
    end

    private

    def client
      @client ||= WechatPay::Client.new(
        appid: @app_id,
        mchid: @merchant_id,
        private_key: @private_key,
        public_key: @public_key,
      )
    end
  end
end
