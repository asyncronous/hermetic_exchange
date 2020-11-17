class Rift < ApplicationRecord
  after_create :set_items

  items = [
    Item.new,
    Item.new,
    Item.new
  ]

  attribute :credits, default: rand(100..200)
  
  has_many :items
  belongs_to :trader

  def set_items
    self.items.create!
    self.items.create!
    self.items.create!
    self.credits = rand(100..200)
  end
end
