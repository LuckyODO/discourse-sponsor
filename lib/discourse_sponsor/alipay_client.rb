# frozen_string_literal: true

module ::DiscourseSponsor
  class AlipayClient
    def initialize
      @app_id = SiteSetting.discourse_sponsor_alipay_app_id
      @merchant_id = SiteSetting.discourse_sponsor_alipay_merchant_id
      @private_key = SiteSetting.discourse_sponsor_alipay_private_key
      @public_key = SiteSetting.discourse_sponsor_alipay_public_key
      @notify_url = SiteSetting.discourse_sponsor_alipay_notify_url
    end

    def create_order(order_id:, amount_cents:, description:)
      sdk_response =
        sdk.create_qr_order(
          order_id: order_id,
          amount_cents: amount_cents,
          description: description,
          notify_url: @notify_url,
          produce_code: "QR_CODE_OFFLINE",
        )
      response = client.execute(
        method: "alipay.trade.precreate",
        notify_url: @notify_url,
        biz_content: {
          out_trade_no: order_id,
          total_amount: format("%.2f", amount_cents / 100.0),
          subject: description,
          seller_id: @merchant_id,
        },
      )
      parsed = response.is_a?(String) ? JSON.parse(response) : response
      result = parsed["alipay_trade_precreate_response"] || {}
      qr_code = result["qr_code"]
      unless result["code"] == "10000" && qr_code.present?
        raise PaymentProviderError.new(
          provider: "alipay",
          message: "alipay_request_failed",
          details: result.presence || parsed,
        )
      end

      {
        provider: "alipay",
        order_id: order_id,
        amount_cents: amount_cents,
        description: description,
        produce_code: "QR_CODE_OFFLINE",
        timestamp: Time.zone.now.to_i,
        signature: sign_payload(order_id: order_id, amount_cents: amount_cents),
        payment_url: sdk_response[:payment_url],
        qr_code_url: sdk_response[:qr_code_url],
        trade_no: result["trade_no"],
        qr_code: qr_code,
        raw: result,
      }
    rescue StandardError => e
      raise PaymentProviderError.new(
        provider: "alipay",
        message: "alipay_request_failed",
        details: e.message,
      )
    end

    private

    def sdk
      @sdk ||=
        AlipaySdk.new(
          app_id: @app_id,
          merchant_id: @merchant_id,
          private_key: @private_key,
          public_key: @public_key,
        )
    end

    def sign_payload(order_id:, amount_cents:)
      "signed:#{order_id}:#{amount_cents}:#{@private_key&.bytesize || 0}:#{@public_key&.bytesize || 0}"
    end

    def client
      @client ||= Alipay::Client.new(
        app_id: @app_id,
        private_key: @private_key,
        alipay_public_key: @public_key,
      )
    end
  end
end
