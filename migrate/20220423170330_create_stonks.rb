class CreateStonks < ActiveRecord::Migration[7.0]
  def change
    create_table :stonks do |t|
      t.string :stonk_name
      t.string :keywords
      t.string :base_value
      t.string :volatility

      t.timestamps
    end
  end
end
