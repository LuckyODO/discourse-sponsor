# frozen_string_literal: true

module ::DiscourseSponsor
  class WechatPayClient
    def initialize
      @app_id = SiteSetting.wechat_pay_app_id
      @merchant_id = SiteSetting.wechat_pay_merchant_id
      @private_key = pem_from_setting(SiteSetting.wechat_pay_private_key)
      @public_key = pem_from_setting(SiteSetting.wechat_pay_public_key)
      @notify_url = SiteSetting.wechat_pay_notify_url
    end

    def create_order(order_id:, amount_cents:, description:)
      {
        provider: "wechat_pay",
        app_id: @app_id,
        merchant_id: @merchant_id,
        notify_url: @notify_url,
        order_id: order_id,
        amount_cents: amount_cents,
        description: description,
        timestamp: Time.zone.now.to_i,
        signature: sign_payload(order_id: order_id, amount_cents: amount_cents),
      }
    end

    private

    def pem_from_setting(setting_value)
      return "" if setting_value.blank?
      return setting_value if setting_value.include?("BEGIN")

      upload = Upload.find_by(id: setting_value.to_i)
      return "" unless upload

      read_upload_contents(upload)
    end

    def read_upload_contents(upload)
      path = Discourse.store.path_for(upload)
      return File.read(path) if path && File.exist?(path)

      downloaded = Discourse.store.download(upload)
      return "" unless downloaded

      downloaded.rewind
      downloaded.read
    ensure
      downloaded.close! if downloaded.respond_to?(:close!)
    end

    def sign_payload(order_id:, amount_cents:)
      "signed:#{order_id}:#{amount_cents}:#{@private_key&.bytesize || 0}:#{@public_key&.bytesize || 0}"
    end
  end
end
