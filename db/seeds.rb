# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
ItemTypeConstructor.destroy_all
ItemVariantConstructor.destroy_all
Rift.destroy_all
Item.destroy_all
Exchange.destroy_all
Trader.destroy_all

constructors = [
    {item_type: "dagger"},
    {item_type: "sword"},
    {item_type: "staff"},
    {item_type: "wand"},
    {item_type: "amulet"},
    {item_type: "line"},
    {item_type: "ring"},
    {item_type: "orb"},
    {item_type: "tome"},
    {item_type: "elixir"}
]

ItemTypeConstructor.create!(constructors)

ItemVariantConstructor.create!(
    effects: [
        "lightning",
        "corrupton",
        "divinity",
        "agony",
        "wisdom",
        "petrification",
        "banishment",
        "sealing",
        "fortune",
        "fire",
        "seeking",
        "life"
    ],
    rarities: [
        "common",
        "rare",
        "mythic"
    ],
    power: [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10
    ]
)

Exchange.create!(name: "Exchange")

user = Trader.create!(username: "user", email: "a@b.com", password: "111111", password_confirmation: "111111", credits: 100, highest_rift_level: 0, rifts_closed: 0, items_traded: 0)

user.items.create
user.items.create
user.items.create
user.items.create

user.rifts.create
user.rifts.create
user.rifts.create

admin = Trader.create!(username: "admin", email: "admin@exchange.com", password: "password", password_confirmation: "password", credits: 1000000, highest_rift_level: 666, rifts_closed: 666, items_traded: 666)

admin.add_role(:admin)
