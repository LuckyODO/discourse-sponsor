# frozen_string_literal: true

module ::DiscourseSponsor
  class SponsorOrdersController < ::ApplicationController
    requires_plugin DiscourseSponsor::PLUGIN_NAME

    before_action :ensure_logged_in

    def create
      RateLimiter.new(
        current_user,
        "sponsor-order",
        SiteSetting.sponsor_rate_limit_per_minute,
        1.minute
      ).performed!

      render json: success_json
    rescue RateLimiter::LimitExceeded
      render_json_error(I18n.t("sponsor.rate_limited"), status: 429)
    end
  end
end
