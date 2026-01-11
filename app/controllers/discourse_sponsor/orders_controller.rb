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
      payment_params = client.create_order(
        order_id: order_id,
        amount_cents: amount_cents,
        description: description,
      )
      order_payload = {
        order_id: order_id,
        payment_method: payment_method,
        amount_cents: amount_cents,
        description: description,
        status: "pending",
        payment_url: payment_params[:payment_url],
        qr_code_url: payment_params[:qr_code_url],
        created_at: Time.zone.now,
      }
      OrderStore.save(order_id, order_payload)
      payment_params =
        client.create_order(
          order_id: order_id,
          amount_cents: amount_cents,
          description: description,
        )

      render json: { payment_method: payment_method, payment_params: payment_params }
    rescue DiscourseSponsor::PaymentProviderError => e
      render json: {
        payment_method: payment_method,
        order_id: order_id,
        status: order_payload[:status],
        payment_url: order_payload[:payment_url],
        qr_code_url: order_payload[:qr_code_url],
        payment_params: payment_params,
      }
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

    def status
      order_id = params.require(:id)
      order = OrderStore.fetch(order_id)

      return render_json_error(I18n.t("sponsor.order_not_found"), status: 404) if order.blank?

      render json: {
        order_id: order_id,
        status: order["status"],
        payment_method: order["payment_method"],
        payment_url: order["payment_url"],
        qr_code_url: order["qr_code_url"],
        paid_at: order["paid_at"],
      }
    end

    def update_status
      order_id = params.require(:id)
      status = params.require(:status)
      order = OrderStore.fetch(order_id)

      return render_json_error(I18n.t("sponsor.order_not_found"), status: 404) if order.blank?

      update_payload = {
        status: status,
      }
      update_payload[:paid_at] = Time.zone.now if status == "paid"

      OrderStore.update(order_id, update_payload)

      render json: success_json.merge(order_id: order_id, status: status)
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
