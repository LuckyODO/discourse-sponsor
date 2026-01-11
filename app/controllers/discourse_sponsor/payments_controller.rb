# frozen_string_literal: true

module ::DiscourseSponsor
  class PaymentsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    skip_before_action :verify_authenticity_token

    def callback
      order_id = params.require(:order_id)
      amount_cents = params.require(:amount_cents).to_i
      user = User.find(params.require(:user_id))
      anonymous = ActiveModel::Type::Boolean.new.cast(params[:anonymous])
      payment_status = params[:payment_status].presence || "paid"

      record = SponsorRecord.find_or_initialize_by(order_id: order_id)
      record.assign_attributes(
        user_id: user.id,
        amount_cents: amount_cents,
        anonymous: anonymous,
        payment_status: payment_status,
        payment_provider: params[:payment_provider].presence,
      )
      record.save!

      render json: success_json
    end
  end
end
