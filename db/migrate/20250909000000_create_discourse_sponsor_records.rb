# frozen_string_literal: true

class CreateDiscourseSponsorRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_sponsor_records do |t|
      t.integer :user_id, null: false
      t.integer :amount_cents, null: false
      t.boolean :anonymous, null: false, default: false
      t.string :payment_status, null: false, default: "pending"
      t.string :order_id, null: false
      t.string :payment_provider
      t.timestamps
    end

    add_index :discourse_sponsor_records, :user_id
    add_index :discourse_sponsor_records, :order_id, unique: true
    add_index :discourse_sponsor_records, :payment_status
  end
end
