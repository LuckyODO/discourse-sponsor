# frozen_string_literal: true

module ::DiscourseSponsor
  class SponsorRecordsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in

    def show
      record =
        SponsorRecord
          .where(user_id: current_user.id, payment_status: "paid")
          .order(created_at: :desc)
          .first

      render json: { record: record ? serialize_record(record) : nil }
    end

    def update
      record = SponsorRecord.where(user_id: current_user.id).find(params.require(:id))
      anonymous = ActiveModel::Type::Boolean.new.cast(params.require(:anonymous))

      record.update!(anonymous: anonymous)

      render json: { record: serialize_record(record) }
    end

    private

    def serialize_record(record)
      {
        id: record.id,
        amount_cents: record.amount_cents,
        anonymous: record.anonymous,
        created_at: record.created_at,
      }
    end
  end
end
