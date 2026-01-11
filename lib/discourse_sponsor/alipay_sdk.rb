# frozen_string_literal: true

require "base64"
require "cgi"
require "json"

module ::DiscourseSponsor
  class AlipaySdk
    def initialize(app_id:, merchant_id:, private_key:, public_key:)
      @app_id = app_id
      @merchant_id = merchant_id
      @private_key = private_key
      @public_key = public_key
    end

    def create_qr_order(order_id:, amount_cents:, description:, notify_url:, produce_code:)
      payload = {
        app_id: @app_id,
        merchant_id: @merchant_id,
        order_id: order_id,
        amount_cents: amount_cents,
        description: description,
        notify_url: notify_url,
        produce_code: produce_code,
      }

      payment_url = build_payment_url(payload)

      {
        payment_url: payment_url,
        qr_code_url: build_qr_code_url(payment_url),
      }
    end

    private

    def build_payment_url(payload)
      encoded = Base64.urlsafe_encode64(payload.to_json)
      "https://openapi.alipay.com/gateway.do?payload=#{encoded}"
    end

    def build_qr_code_url(payment_url)
      encoded_payment_url = CGI.escape(payment_url)
      "https://api.qrserver.com/v1/create-qr-code/?size=280x280&data=#{encoded_payment_url}"
    end
  end
end
