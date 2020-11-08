class Rift < ApplicationRecord
  has_many :items
  belongs_to :trader
end
