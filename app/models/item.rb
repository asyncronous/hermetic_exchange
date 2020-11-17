class Item < ApplicationRecord
    before_validation :set_random_attributes

    validates_format_of :name, with: /^[a-zA-Z0-9_\. ]*$/, :multiline => true
    validates_format_of :item_type, with: /^[a-zA-Z0-9_\. ]*$/, :multiline => true
    validates_format_of :rarity, with: /^[a-zA-Z0-9_\. ]*$/, :multiline => true

    validates :name, presence: true
    validates :item_type, presence: true
    validates :rarity, presence: true

    attribute :description, default: BetterLorem.w(4,true,false)
    attribute :listed, default: false
    attribute :equipped, default: false

    belongs_to :rift, optional: true
    belongs_to :exchange, optional: true
    belongs_to :trader, optional: true

    scope :equipped, -> {where(equipped: true)}
    scope :orphan, -> {where(trader: nil)}

    has_one_attached :icon, dependent: :purge

    def set_random_attributes
        trader_inst = nil

        if self.trader
            trader_inst = self.trader
        end

        if self.rift
            trader_inst = rift.trader
        end

        type_constructors = ItemTypeConstructor.all

        if !trader_inst.has_role?(:admin)
            var_constructor = ItemVariantConstructor.first
            # type_constructors = ItemTypeConstructor.all
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
            self.description = BetterLorem.w(4,true,false)
        else
            if type_constructors.exists?(item_type: self.item_type)
                type = type_constructors.find_by item_type: self.item_type
                image_io = type.icon.download
                ct = type.icon.content_type
                fn = type.icon.filename.to_s
                ts = Time.now.to_i.to_s
            
                new_blob = ActiveStorage::Blob.create_and_upload!(
                io: StringIO.new(image_io),
                filename: ts + '_' + fn,
                content_type: ct,
                )

                self.icon.attach(new_blob)
            end

            self.exchange = Exchange.first
            self.listed = true

            self.name.downcase!
            self.rarity.downcase!
            self.item_type.downcase!
        end
    end
end