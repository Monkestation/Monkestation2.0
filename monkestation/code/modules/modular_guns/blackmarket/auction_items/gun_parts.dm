/datum/market_item/auction/gun_part
	markets = list(/datum/market/auction/guns)
	stock_max = 1
	availability_prob = 100
	category = "Gun Part"
	auction_weight = 5

/datum/market_item/auction/gun_part/makarov //Funny guns that fit the shoddy gun bidding market.
	name = "Old Makarov"
	desc = "Especially Illegal, functionality not guaranteed."
	item = /obj/item/gun/ballistic/automatic/pistol/damaged

	price_min = CARGO_CRATE_VALUE * 6
	price_max = CARGO_CRATE_VALUE * 8
	auction_weight = 4

/datum/market_item/auction/gun_part/evil_wespe //Funny guns that fit the shoddy gun bidding market.
	name = "Modified Wespe"
	desc = "Super Illegal."
	item = /obj/item/gun/ballistic/automatic/pistol/sol/evil/unrestricted

	price_min = CARGO_CRATE_VALUE * 6
	price_max = CARGO_CRATE_VALUE * 8
	auction_weight = 4

/datum/market_item/auction/gun_part/evil_eland
	name = "Eland Revolver"
	desc = "Super Illegal... and weak."
	item = /obj/item/gun/ballistic/revolver/sol

	price_min = CARGO_CRATE_VALUE * 4
	price_max = CARGO_CRATE_VALUE * 6.25
	auction_weight = 4

/datum/market_item/auction/gun_part/evil_skild
	name = "Skild Pistol"
	desc = "Super Illegal, favoured by frontiermen."
	item = /obj/item/gun/ballistic/automatic/pistol/trappiste/damaged

	price_min = CARGO_CRATE_VALUE * 6
	price_max = CARGO_CRATE_VALUE * 8
	auction_weight = 4

/datum/market_item/auction/gun_part/evil_sindano
	name = "Modified Sindano"
	desc = "Super Duper Illegal, goodluck hitting your target!"
	item = /obj/item/gun/ballistic/automatic/sol_smg/evil/unrestricted/damaged

	price_min = CARGO_CRATE_VALUE * 8
	price_max = CARGO_CRATE_VALUE * 12
	auction_weight = 4
