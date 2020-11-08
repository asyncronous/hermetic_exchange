class AddExchangeToItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :items, :exchange, foreign_key: true
  end
end
