/datum/brewing_recipe/melon_liquor
	reagent_to_brew = /datum/reagent/consumable/ethanol/melon_liquor
	display_name = "Melon Liquor"
	needed_items = list(/obj/item/grown/log = 1)
	needed_crops = list(/obj/item/food/grown/watermelon = 400, /obj/item/food/grown/herbs = 50)
	brewed_amount = 3

	cargo_valuation = 2000
	brew_time = 2.5 MINUTES

/datum/brewing_recipe/triple_sec
	reagent_to_brew = /datum/reagent/consumable/ethanol/triple_sec
	display_name = "Triple Sec"
	brewed_amount = 2
	needed_items = list(/obj/item/grown/orangepeel = 5)
	needed_crops = list(/obj/item/food/grown/whitebeet = 100)
	needed_reagents = list(/datum/reagent/consumable/sugar = 15)

	cargo_valuation = 1800
	brew_time = 3 MINUTES

/datum/brewing_recipe/red_candy_liquor
	reagent_to_brew = /datum/reagent/consumable/ethanol/candy_wine
	display_name = "Red Candy Liquor"
	pre_reqs = /datum/reagent/consumable/ethanol/triple_sec
	brewed_amount = 2
	needed_items = list(/obj/item/grown/log = 1)
	needed_crops = list(/obj/item/food/grown/cherries = 250, /obj/item/food/grown/apple = 250, /obj/item/food/grown/ginger = 50, /obj/item/food/grown/herbs = 50)
	needed_reagents = list(/datum/reagent/consumable/ethanol/wine = 100)

	cargo_valuation = 8000
	brew_time = 4 MINUTES

/datum/brewing_recipe/grappa
	reagent_to_brew = /datum/reagent/consumable/ethanol/grappa
	display_name = "Grappa"
	brewed_amount = 2
	needed_crops = list(/obj/item/food/grown/grapes = 100)
	needed_reagents = list(/datum/reagent/consumable/ethanol/wine = 50)
	cargo_valuation = 2200
	brew_time = 3 MINUTES
