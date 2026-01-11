# frozen_string_literal: true

# name: discourse-sponsor
# about: Adds sponsorship support with configurable payment providers.
# meta_topic_id: TODO
# version: 0.1.0
# authors: Discourse Sponsor Team
# url: https://github.com/discourse/discourse-sponsor
# required_version: 2.7.0

enabled_site_setting :discourse_sponsor_enabled

module ::MyPluginModule
  PLUGIN_NAME = "discourse-sponsor"
end

require_relative "lib/my_plugin_module/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
