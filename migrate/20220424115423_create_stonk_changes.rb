class CreateStonkChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :stonk_changes do |t|
      t.references :stonk, null: false, foreign_key: true
      t.string :old_value
      t.string :new_value

      t.timestamps
    end
  end
end
