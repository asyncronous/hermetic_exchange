class Rift < ApplicationRecord
  after_create :set_items
  before_create :set_name

  items = [
    Item.new,
    Item.new,
    Item.new
  ]

  attribute :credits, default: rand(100..200)
  attribute :name, default: BetterLorem.w(2,true,false)
  
  has_many :items
  belongs_to :trader

  def set_name 
    self.name = BetterLorem.w(2,true,false)
  end

  def set_items
    self.items.create!
    self.items.create!
    self.items.create!
    self.credits = rand(100..200)
  end
end
