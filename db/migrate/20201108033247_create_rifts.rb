class CreateRifts < ActiveRecord::Migration[6.0]
  def change
    create_table :rifts do |t|
      t.string :name
      t.integer :credits
      t.references :trader, foreign_key: true

      t.timestamps
    end
  end
end
