class Item < ApplicationRecord

    attribute :name, default: "Name"
    attribute :item_type, default: "Type"
    attribute :rarity, default: "Rarity"
    attribute :description, default: "Description"
    attribute :power, default: 1
    attribute :worth, default: 100
    attribute :listed_price, default: 100
    attribute :listed, default: false
    attribute :equipped, default: false

    belongs_to :rift
    belongs_to :exchange
    belongs_to :trader
end
