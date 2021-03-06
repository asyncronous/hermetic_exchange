class ItemTypeConstructor < ApplicationRecord
  before_save :downcase_fields
  before_create :set_icons
  has_one_attached :icon, dependent: :purge

  validates_format_of :item_type, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
  validates :item_type, uniqueness: true, presence: true

  def set_icons
    path = "app/assets/images/Icons/#{self.item_type.downcase}.png"
    if !self.icon.attached?
      self.icon.attach(io: File.open(Rails.root.join(path)), filename: "#{self.item_type.downcase}.png", content_type: "image/jpg")
    end
  end

  def downcase_fields
    self.item_type.downcase!
  end
end
