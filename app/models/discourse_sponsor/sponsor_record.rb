# frozen_string_literal: true

module ::DiscourseSponsor
  class SponsorRecord < ActiveRecord::Base
    self.table_name = "discourse_sponsor_records"

    belongs_to :user

    validates :user_id, presence: true
    validates :amount_cents, presence: true
    validates :order_id, presence: true, uniqueness: true
    validates :payment_status, presence: true
  end
end
