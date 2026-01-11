# frozen_string_literal: true

module ::DiscourseSponsor
  class PaymentProviderError < StandardError
    attr_reader :provider, :details

    def initialize(provider:, message:, details: nil)
      super(message)
      @provider = provider
      @details = details
    end
  end
end
