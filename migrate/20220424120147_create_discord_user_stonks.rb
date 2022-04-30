class CreateDiscordUserStonks < ActiveRecord::Migration[7.0]
  def change
    create_table :discord_user_stonks do |t|
      t.references :stonk, null: false, foreign_key: true
      t.references :discord_user, null: false, foreign_key: true
      t.string :value_at_purchase
      t.integer :quantity

      t.timestamps
    end
  end
end
