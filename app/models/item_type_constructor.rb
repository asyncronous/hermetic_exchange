class ItemTypeConstructor < ApplicationRecord
    before_create :set_icons

    has_one_attached :icon, dependent: :destroy

    def set_icons
        path = "app/assets/images/Icons/#{self.item_type}.png"
        begin
        self.icon.attach(io: File.open(Rails.root.join(path)), filename: "#{self.item_type}.png", content_type: 'image/jpg')
        rescue
        end
    end
end