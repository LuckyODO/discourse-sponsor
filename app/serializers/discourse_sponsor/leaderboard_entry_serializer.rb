# frozen_string_literal: true

module ::DiscourseSponsor
  class LeaderboardEntrySerializer < ::ApplicationSerializer
    attributes :amount, :anonymous, :created_at, :display_name

    def display_name
      return I18n.t("sponsor.anonymous_label") if object.anonymous?

      object.user&.name.presence || object.user&.username
    end
  end
end
