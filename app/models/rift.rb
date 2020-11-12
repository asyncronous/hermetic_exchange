class Rift < ApplicationRecord
  after_create :set_items

  items = [
    Item.new,
    Item.new,
    Item.new
  ]

  attribute :credits, default: 100
  
  has_many :items, dependent: :destroy
  belongs_to :trader

  def set_items
    self.items.create
    self.items.create
    self.items.create
    self.credits = rand()
  end
end
