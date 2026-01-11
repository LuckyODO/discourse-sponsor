# frozen_string_literal: true

module ::DiscourseSponsor
  class OrderStore
    STORE_PREFIX = "sponsor-order".freeze

    def self.save(order_id, payload)
      PluginStore.set(PLUGIN_NAME, key(order_id), payload.deep_stringify_keys)
    end

    def self.fetch(order_id)
      PluginStore.get(PLUGIN_NAME, key(order_id))
    end

    def self.update(order_id, updates)
      existing = fetch(order_id) || {}
      save(order_id, existing.merge(updates.deep_stringify_keys))
    end

    def self.key(order_id)
      "#{STORE_PREFIX}:#{order_id}"
    end
  end
end
