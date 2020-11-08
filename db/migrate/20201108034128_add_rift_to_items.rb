class AddRiftToItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :items, :rift, foreign_key: true
  end
end
