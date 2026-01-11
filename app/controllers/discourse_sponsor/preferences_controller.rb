# frozen_string_literal: true

module ::DiscourseSponsor
  class PreferencesController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in

    ANONYMOUS_FIELD = "sponsor_anonymous"
    SHOW_FIELD = "sponsor_show_in_leaderboard"

    def show
      render json: {
        anonymous: custom_field_value(ANONYMOUS_FIELD),
        show_in_leaderboard: custom_field_value(SHOW_FIELD, default: true),
      }
    end

    def update
      current_user.custom_fields[ANONYMOUS_FIELD] = to_bool(params.require(:anonymous))
      current_user.custom_fields[SHOW_FIELD] = to_bool(
        params.require(:show_in_leaderboard)
      )
      current_user.save_custom_fields

      render json: success_json
    end

    private

    def custom_field_value(field, default: false)
      value = current_user.custom_fields[field]
      return default if value.nil?

      to_bool(value)
    end

    def to_bool(value)
      ActiveModel::Type::Boolean.new.cast(value)
    end
  end
end
