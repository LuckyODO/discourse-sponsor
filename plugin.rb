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
  LEGACY_MAPPINGS = {
    "discourse_sponsor_wechat_app_id" => ["wechat_pay_app_id"],
    "discourse_sponsor_wechat_merchant_id" => ["wechat_pay_merchant_id"],
    "discourse_sponsor_wechat_private_key" => ["wechat_pay_private_key", "discourse_sponsor_wechat_api_key"],
    "discourse_sponsor_wechat_public_key" => ["wechat_pay_public_key"],
    "discourse_sponsor_wechat_notify_url" => ["wechat_pay_notify_url"],
    "discourse_sponsor_alipay_app_id" => ["alipay_app_id"],
    "discourse_sponsor_alipay_merchant_id" => ["alipay_merchant_id"],
    "discourse_sponsor_alipay_private_key" => ["alipay_private_key"],
    "discourse_sponsor_alipay_public_key" => ["alipay_public_key"],
    "discourse_sponsor_alipay_notify_url" => ["alipay_notify_url"],
    "discourse_sponsor_rate_limit_per_minute" => ["sponsor_rate_limit_per_minute"],
    "discourse_sponsor_default_amounts" => ["sponsor_preset_amounts"],
  }.transform_values(&:freeze).freeze
end

gem "rest-client", "1.6.7", require: false
gem "mime-types", ">= 1.16", require: false
gem "mime-types-data", ">= 3.2015", require: false
gem "wechat_pay", "0.3.0", require: false
gem "alipay", "0.17.0", require: false

require "wechat_pay"
require "alipay"

require_relative "lib/discourse_sponsor/engine"

after_initialize do
  ::DiscourseSponsor::LEGACY_MAPPINGS.each do |new_setting, legacy_settings|
    next if SiteSetting.get(new_setting).present?

    legacy_settings.each do |old_setting|
      legacy_value = SiteSetting.get(old_setting)
      next if legacy_value.blank?

      SiteSetting.set(new_setting, legacy_value)
      break
    end
  end
end
