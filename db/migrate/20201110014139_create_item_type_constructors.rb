class CreateItemTypeConstructors < ActiveRecord::Migration[6.0]
  def change
    create_table :item_type_constructors do |t|
      t.string :item_type

      t.timestamps
    end
  end
end
