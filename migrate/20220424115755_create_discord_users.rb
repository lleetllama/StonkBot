class CreateDiscordUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :discord_users do |t|
      t.string :wallet_value
      t.string :buy_count
      t.string :sell_count
      t.boolean :is_vip
      t.string :debt
      t.timestamps
    end
  end
end
