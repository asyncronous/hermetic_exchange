class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :name
      t.string :item_type
      t.string :rarity
      t.string :description
      t.integer :power
      t.integer :worth
      t.integer :listed_price
      t.boolean :listed
      t.boolean :equipped
      t.references :trader, foreign_key: true

      t.timestamps
    end
  end
end
