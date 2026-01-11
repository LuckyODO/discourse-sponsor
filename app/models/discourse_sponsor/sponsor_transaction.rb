# frozen_string_literal: true

module ::DiscourseSponsor
  class SponsorTransaction < ::ActiveRecord::Base
    self.table_name = "discourse_sponsor_transactions"

    belongs_to :user

    validates :user_id, presence: true
    validates :amount, presence: true, numericality: { greater_than: 0 }
  end
end
