# frozen_string_literal: true

module ::DiscourseSponsor
  class LeaderboardController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      per_page = params[:per_page].to_i
      per_page = 10 if per_page <= 0
      per_page = [per_page, 100].min
      page = params[:page].to_i
      page = 1 if page <= 0
      sort = params[:sort].presence_in(%w[amount_cents created_at]) || "amount_cents"
      direction = params[:direction] == "asc" ? :asc : :desc

      records =
        SponsorRecord
          .where(payment_status: "paid")
          .includes(:user)
          .order(sort => direction)
          .offset((page - 1) * per_page)
          .limit(per_page)

      render json: {
        page: page,
        per_page: per_page,
        total: SponsorRecord.where(payment_status: "paid").count,
        records: records.map { |record| serialize_record(record) },
      }
    end

    private

    def serialize_record(record)
      user = record.user
      display_name = record.anonymous ? I18n.t("discourse_sponsor.anonymous_label") : user&.username

      {
        id: record.id,
        amount_cents: record.amount_cents,
        anonymous: record.anonymous,
        created_at: record.created_at,
        display_name: display_name,
        user: record.anonymous ? nil : { id: user&.id, username: user&.username, name: user&.name },
      }
    end
  end
end
