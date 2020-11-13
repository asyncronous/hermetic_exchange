class Trader < ApplicationRecord
  rolify
  attr_writer :login
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attribute :highest_rift_level, default: 0
  attribute :rifts_closed, default: 0
  attribute :items_traded, default: 0
  attribute :claimed_daily, default: false
  attribute :refresh_time, default: Time.new(2020,1,1)
  attribute :current_time, default: Time.now

  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

  has_many :items, dependent: :destroy
  has_many :rifts, dependent: :destroy
  has_one_attached :avatar

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
end
