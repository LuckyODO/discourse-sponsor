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
      sdk_response =
        sdk.create_qr_order(
          order_id: order_id,
          amount_cents: amount_cents,
          description: description,
          notify_url: @notify_url,
          produce_code: "QR_CODE_OFFLINE",
        )

      {
        provider: "alipay",
        app_id: @app_id,
        merchant_id: @merchant_id,
        notify_url: @notify_url,
        order_id: order_id,
        amount_cents: amount_cents,
        description: description,
        produce_code: "QR_CODE_OFFLINE",
        timestamp: Time.zone.now.to_i,
        signature: sign_payload(order_id: order_id, amount_cents: amount_cents),
        payment_url: sdk_response[:payment_url],
        qr_code_url: sdk_response[:qr_code_url],
      }
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
  end
end
