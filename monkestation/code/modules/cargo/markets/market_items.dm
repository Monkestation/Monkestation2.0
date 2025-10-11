/datum/market_item/weapon/smoothbore_disabler_prime
	name = "Elite Smoothbore Disabler"
	desc = "A rare and sought after disabler often used by Nanotrasen's high command, and historical LARPers."
	item = /obj/item/gun/energy/disabler/smoothbore/prime

	price_min = CARGO_CRATE_VALUE * 3
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 2
	availability_prob = 40

/datum/market_item/weapon/pipegun_recipe
	name = "Diary of a Dead Assistant"
	desc = "Found this book in my Archives, had some barely legible scrabblings about making 'The perfect pipegun'. Figured someone here would buy this."
	item = /obj/item/book/granter/crafting_recipe/maint_gun/pipegun_prime

	price_min = CARGO_CRATE_VALUE * 4
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 1
	availability_prob = 40

/datum/market_item/weapon/musket_recipe
	name = "Journal of a Space Ranger"
	desc = "An old banned book written by an eccentric space ranger, notable for its detailed description of how to make powerful improvised lasers."
	item = /obj/item/book/granter/crafting_recipe/maint_gun/laser_musket_prime

	price_min = CARGO_CRATE_VALUE * 4
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 1
	availability_prob = 5

/datum/market_item/weapon/smoothbore_recipe
	name = "Old Tome"
	desc = "Ahoy Maties, I, Captain Whitebeard, have plundered the ol' Nanotrasen station, among the booty retreived was this here tome about smoothbores. Alas, I have no use for its knowlege, so I am droppin it off here."
	item = /obj/item/book/granter/crafting_recipe/maint_gun/smoothbore_disabler_prime

	price_min = CARGO_CRATE_VALUE * 6
	price_max = CARGO_CRATE_VALUE * 8
	stock_max = 1
	availability_prob = 20

/datum/market_item/weapon/fss_disk
	name = "FSS-550 Design Disk"
	desc = "I HATE security, I HATE how security doesn't let the crew own guns. So I'm going to sell this disk here so EVERYONE can have a gun!"
	item = /obj/item/disk/design_disk/fss

	price_min = CARGO_CRATE_VALUE * 8
	price_max = CARGO_CRATE_VALUE * 10
	stock_max = 1
	availability_prob = 10

/datum/market_item/weapon/fss
	name = "FSS-550"
	desc = "A printed version of the venerable WT-550 Autorifle. This has led to the firearm being quite easy to make and distribute away from the prying eyes of security. Unfortunately the gun isn't that good."
	item = /obj/item/gun/ballistic/automatic/wt550/fss

	price_min = CARGO_CRATE_VALUE * 6
	price_max = CARGO_CRATE_VALUE * 8
	stock_max = 2
	availability_prob = 20
