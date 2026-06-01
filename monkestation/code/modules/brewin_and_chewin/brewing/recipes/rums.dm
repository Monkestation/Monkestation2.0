/datum/brewing_recipe/rum
	reagent_to_brew = /datum/reagent/consumable/ethanol/rum
	display_name = "Rum"
	brewed_amount = 2
	needed_items  = list(/obj/item/grown/log = 1)
	needed_crops = list(/obj/item/food/grown/sugarcane = 100)
	needed_reagents = list(/datum/reagent/water = 50, /datum/reagent/consumable/salt = 5)

	cargo_valuation = 2000
	brew_time = 3 MINUTES
	helpful_hints = "Further brewing can be done when finished."

/datum/brewing_recipe/kahlua
	reagent_to_brew = /datum/reagent/consumable/ethanol/kahlua
	pre_reqs = /datum/reagent/consumable/ethanol/rum
	display_name = "Kahlua"

	brewed_amount = 2
	needed_reagents = list(/datum/reagent/consumable/sugar = 15, /datum/reagent/consumable/coffee = 15)

	cargo_valuation = 3000
	brew_time = 1 MINUTES
	helpful_hints = "Further brewing can be done when finished."

/datum/brewing_recipe/dark_and_stormy
	reagent_to_brew = /datum/reagent/consumable/ethanol/dark_and_stormy
	pre_reqs = /datum/reagent/consumable/ethanol/rum
	display_name = "Dark and Stormy"
	needed_reagents = list(/datum/reagent/consumable/sol_dry = 200)
	brewed_amount = 4

	cargo_valuation = 3000
	brew_time = 2 MINUTES
	helpful_hints = "Further brewing can be done when finished."
