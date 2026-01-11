# frozen_string_literal: true

# name: Discourse newsponsor
# about: Adds Discourse newsponsor support with configurable payment providers.
# meta_topic_id: TODO
# version: 0.1.0
# authors: Discourse Sponsor Team
# url: https://github.com/discourse/discourse-sponsor
# required_version: 2.7.0

enabled_site_setting :discourse_sponsor_enabled

module ::DiscourseSponsor
  PLUGIN_NAME = "discourse-newsponsor"
end

require_relative "lib/discourse_sponsor/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
