/obj/effect/spawner/random/food_or_drink/island_booze
	name = "island booze spawner"
	icon_state = "beer"
	loot = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/agua_fresca = 1,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/bahama_mama = 2,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/cuba_libre = 2,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/iced_tea = 4,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/long_island_iced_tea = 2,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/long_john_silver = 2,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/margarita = 3,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/mauna_loa = 1,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/painkiller = 2,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/pina_colada = 4,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/salt_and_swell = 2,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/sea_breeze = 3,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/tequila_sunrise = 3,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/tropical_storm = 2,
	)

//filled drinks to populate the spawner with (these are here because they aren't used anywhere else)
/obj/item/reagent_containers/cup/glass/drinkingglass/filled/agua_fresca
	name = "Agua Fresca"
	list_reagents = list(/datum/reagent/consumable/agua_fresca = 30)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/bahama_mama
	name = "Bahama Mama"
	list_reagents = list(/datum/reagent/consumable/ethanol/bahama_mama = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/cuba_libre
	name = "Cuba Libre"
	list_reagents = list(/datum/reagent/consumable/ethanol/cuba_libre = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/iced_tea
	name = "Iced Tea"
	list_reagents = list(/datum/reagent/consumable/icetea = 50)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/long_island_iced_tea
	name = "Long Island Iced Tea"
	list_reagents = list(/datum/reagent/consumable/ethanol/longislandicedtea = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/long_john_silver
	name = "Long John Silver"
	list_reagents = list(/datum/reagent/consumable/ethanol/long_john_silver = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/margarita
	name = "Margarita"
	list_reagents = list(/datum/reagent/consumable/ethanol/margarita = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/mauna_loa
	name = "Mauna Loa"
	list_reagents = list(/datum/reagent/consumable/ethanol/mauna_loa = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/painkiller
	name = "Painkiller"
	list_reagents = list(/datum/reagent/consumable/ethanol/painkiller = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/pina_colada
	name = "Pina Colada"
	list_reagents = list(/datum/reagent/consumable/ethanol/pina_colada = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/salt_and_swell
	name = "Salt and Swell"
	list_reagents = list(/datum/reagent/consumable/ethanol/salt_and_swell = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/sea_breeze
	name = "Sea Breeze"
	list_reagents = list(/datum/reagent/consumable/ethanol/sea_breeze = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/tequila_sunrise
	name = "Tequila Sunrise"
	list_reagents = list(/datum/reagent/consumable/ethanol/tequila_sunrise = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/tropical_storm
	name = "Tropical Storm"
	list_reagents = list(/datum/reagent/consumable/ethanol/tropical_storm = 25)

/obj/effect/spawner/random/clothing/island_time
	name = "island time clothing spawner"
	loot = list(
		/obj/item/clothing/suit/costume/hawaiian = 4,
		/obj/item/clothing/glasses/sunglasses/cheap = 3,
		/obj/item/clothing/shoes/sandal = 3,
		/obj/item/clothing/head/costume/scarecrow_hat = 2,
		/obj/item/clothing/under/dress/tango = 1,
		/obj/item/clothing/under/dress/sundress = 1,
		/obj/item/clothing/under/shorts/red = 1,
		/obj/item/clothing/under/shorts/green = 1,
		/obj/item/clothing/under/shorts/blue = 1,
		/obj/item/clothing/under/shorts/black = 1,
		/obj/item/clothing/under/shorts/purple = 1,
	)

//Because sunglasses of all things are a powerful and rare item, here's some cheap ones that don't do anything
/obj/item/clothing/glasses/sunglasses/cheap
	name = "cheap sunglasses"
	desc = "Cheap plastic eye lenses to protect you from harsh sunlight. These flimsy ones won't help against flashes."
	flash_protect = FLASH_PROTECTION_NONE
