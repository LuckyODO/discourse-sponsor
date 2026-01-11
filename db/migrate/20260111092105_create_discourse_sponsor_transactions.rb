# frozen_string_literal: true

class CreateDiscourseSponsorTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_sponsor_transactions do |t|
      t.integer :user_id, null: false
      t.integer :amount, null: false
      t.boolean :anonymous, null: false, default: false
      t.boolean :show_in_leaderboard, null: false, default: true
      t.timestamps
    end

    add_index :discourse_sponsor_transactions, :user_id
    add_index :discourse_sponsor_transactions, %i[show_in_leaderboard amount]
  end
end
