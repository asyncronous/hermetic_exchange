# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Item.destroy_all
Rift.destroy_all
Exchange.destroy_all
Trader.destroy_all

Exchange.create!(name: "Exchange")

Trader.destroy_all

user = Trader.create!(username: "user", email: "a@b.com", password: "111111", password_confirmation: "111111", credits: 100, highest_rift_level: 0, rifts_closed: 0, items_traded: 0)

user.items.create
user.items.create
user.items.create
user.items.create

user.rifts.create
user.rifts.create
user.rifts.create
