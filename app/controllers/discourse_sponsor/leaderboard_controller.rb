# frozen_string_literal: true

module ::DiscourseSponsor
  class LeaderboardController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      render json:
               leaderboard_entries.map do |entry|
                 LeaderboardEntrySerializer.new(entry, root: false).as_json
               end
    end

    private

    def leaderboard_entries
      scope = SponsorTransaction.includes(:user).where(show_in_leaderboard: true)

      case params[:sort]
      when "amount"
        scope.order(amount: :desc, created_at: :desc)
      else
        scope.order(created_at: :desc)
      end.limit(5)
    end
  end
end
