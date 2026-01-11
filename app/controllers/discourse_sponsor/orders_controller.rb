# frozen_string_literal: true

module ::DiscourseSponsor
  class OrdersController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def create
      payment_method = params.require(:payment_method)
      amount_cents = params.require(:amount_cents).to_i
      order_id = params[:order_id].presence || SecureRandom.uuid
      description = params[:description].presence || "Order #{order_id}"

      client = payment_client_for(payment_method)
      payment_params =
        client.create_order(
          order_id: order_id,
          amount_cents: amount_cents,
          description: description,
        )

      render json: { payment_method: payment_method, payment_params: payment_params }
    rescue DiscourseSponsor::PaymentProviderError => e
      render json: {
        error: "payment_provider_error",
        provider: e.provider,
        message: e.message,
        details: e.details,
      }, status: :bad_gateway
    rescue StandardError => e
      render json: {
        error: "payment_provider_error",
        provider: payment_method,
        message: e.message,
      }, status: :bad_gateway
    end

    private

    def payment_client_for(payment_method)
      case payment_method
      when "wechat_pay"
        WechatPayClient.new
      when "alipay"
        AlipayClient.new
      else
        raise Discourse::InvalidParameters.new(:payment_method)
      end
    end
  end
end
