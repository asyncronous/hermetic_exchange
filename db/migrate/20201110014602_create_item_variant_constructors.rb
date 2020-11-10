class CreateItemVariantConstructors < ActiveRecord::Migration[6.0]
  def change
    create_table :item_variant_constructors do |t|
      t.text :effects, array: true, default: []
      t.text :rarities, array: true, default: []
      t.integer :power, array: true, default: []

      t.timestamps
    end
  end
end
