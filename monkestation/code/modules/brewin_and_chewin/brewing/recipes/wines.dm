/datum/brewing_recipe/lizard_wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/lizardwine
	display_name = "Lizard Wine"
	needed_items  = list(/obj/item/organ/external/tail/lizard = 1)
	needed_crops = list(/obj/item/food/grown/herbs = 100)
	needed_reagents = list(/datum/reagent/consumable/ethanol = 200)
	brewed_amount = 4

	cargo_valuation = 10000
	brew_time = 10 MINUTES

/datum/brewing_recipe/vermouth
	reagent_to_brew = /datum/reagent/consumable/ethanol/vermouth
	display_name = "Vermouth"
	needed_crops = list(/obj/item/food/grown/herbs = 100)
	needed_reagents = list(/datum/reagent/consumable/ethanol/wine = 100)
	brewed_amount = 2

	cargo_valuation = 1800
	brew_time = 2 MINUTES

/datum/brewing_recipe/poison_wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/poison_wine
	display_name = "Fungal Wine (poison)"
	brewed_amount = 1
	needed_items  = list(/obj/item/grown/log = 1)
	needed_crops = list(/obj/item/food/grown/mushroom/plumphelmet = 5)
	needed_reagents = list(/datum/reagent/consumable/ethanol/wine = 100)

	cargo_valuation = 9000
	brew_time = 10 MINUTES


/datum/brewing_recipe/dry_vermouth
	reagent_to_brew = /datum/reagent/consumable/ethanol/dry_vermouth
	pre_reqs = /datum/reagent/consumable/ethanol/vermouth
	display_name = "Dry Vermouth"
	needed_crops = list(/obj/item/food/grown/ginger = 100, /obj/item/food/grown/harebell = 100)
	brewed_amount = 2

	cargo_valuation = 5000
	brew_time = 4 MINUTES

/datum/brewing_recipe/sweet_vermouth
	reagent_to_brew = /datum/reagent/consumable/ethanol/sweet_vermouth
	pre_reqs = /datum/reagent/consumable/ethanol/vermouth
	display_name = "Sweet Vermouth"
	needed_items  = list(/obj/item/grown/orangepeel = 3)
	needed_crops = list(/obj/item/food/grown/cherries = 100)
	brewed_amount = 2

	cargo_valuation = 5000
	brew_time = 4 MINUTES

/datum/brewing_recipe/voltaic_yellow_wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/wine_voltaic
	display_name = "Voltaic Yellow Wine"
	brewed_amount = 2
	needed_reagents = list(/datum/reagent/consumable/ethanol/wine = 100, /datum/reagent/consumable/liquidelectricity = 50)

	cargo_valuation = 3000
	brew_time = 3 MINUTES
	helpful_hints = "Further brewing can be done when finished."

/datum/brewing_recipe/dry_voltaic_yellow
	reagent_to_brew = /datum/reagent/consumable/ethanol/dry_voltaic_yellow
	pre_reqs = /datum/reagent/consumable/ethanol/wine_voltaic
	display_name = "Dry Voltaic Yellow"
	brewed_amount = 2
	needed_items  = list(/obj/item/grown/log = 1)
	needed_crops = list(/obj/item/food/grown/herbs = 100, /obj/item/food/grown/ginger = 100, /obj/item/food/grown/lanternfruit = 100)

	cargo_valuation = 7000
	brew_time = 4 MINUTES
