# frozen_string_literal: true

module ::DiscourseSponsor
  class SponsorsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def show
      render json: success_json
    end
  end
end
