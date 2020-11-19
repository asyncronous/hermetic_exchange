class Trader < ApplicationRecord
  rolify
  before_create :set_default_avatar
  after_create :generate_starter_inv

  before_destroy :purge_rift_items

  attr_writer :login
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attribute :highest_rift_level, default: 0
  attribute :rifts_closed, default: 0
  attribute :items_traded, default: 0
  attribute :credits, default: 100
  attribute :claimed_daily, default: false
  attribute :refresh_time, default: Time.new(2020,1,1)
  attribute :current_time, default: Time.now
  
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

  validates :username, presence: true
  validates :email, presence: true
  before_save :downcase_fields

  has_many :items, dependent: :destroy
  has_many :rifts, dependent: :destroy
  has_one_attached :avatar, dependent: :purge

  def purge_rift_items
    self.rifts.each do |rift|
      if rift.items
        rift.items.destroy_all
      end
    end
  end

  def downcase_fields
    self.username.downcase!
    self.email.downcase!
  end

  def login
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def set_default_avatar
    if !self.avatar.attached?
      self.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'skull_avatar.png')), filename: 'skull_avatar.png', content_type: 'image/png')
    end
  end

  def generate_starter_inv
    if !self.has_role?(:admin)
      self.items.create!(equipped: true)
      self.items.create!(equipped: true)
    end
  end
end
