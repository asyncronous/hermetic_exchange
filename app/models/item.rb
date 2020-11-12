class Item < ApplicationRecord
    before_create :set_random_attributes

    attribute :name, default: "Name"
    attribute :item_type, default: "Type"
    attribute :rarity, default: "Rarity"
    attribute :description, default: "Description"
    attribute :power, default: 1
    attribute :worth, default: 100
    attribute :listed_price, default: 100
    attribute :listed, default: false
    attribute :equipped, default: false

    belongs_to :rift, optional: true
    belongs_to :exchange, optional: true
    belongs_to :trader, optional: true

    has_one_attached :icon

    def set_random_attributes
        var_constructor = ItemVariantConstructor.first
        type_constructors = ItemTypeConstructor.all
        rand_type = type_constructors.sample
        self.name = rand_type.item_type + " of " + var_constructor.effects.sample

        image_io = rand_type.icon.download
        ct = rand_type.icon.content_type
        fn = rand_type.icon.filename.to_s
        ts = Time.now.to_i.to_s
      
        new_blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new(image_io),
          filename: ts + '_' + fn,
          content_type: ct,
        )

        self.icon.attach(new_blob)
        self.item_type = rand_type.item_type
        self.rarity = var_constructor.rarities.sample
        self.power = var_constructor.power.sample
        self.worth = self.power * 100
        self.listed_price = self.worth
    end
end
