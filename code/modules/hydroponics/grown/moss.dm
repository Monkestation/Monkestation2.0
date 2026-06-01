// Maintenance moss. Probably originally grew in Moffic fleet ships.
/obj/item/seeds/maintenancemoss
	name = "maintenance moss pods"
	desc = "A pack full of fungal spores that'll fester into maintenance moss. Don't breathe it in!"
	icon_state = "mycelium-maintenancemoss"
	species = "maintenancemoss"
	plantname = "Maintenance Moss"
	product = /obj/item/food/grown/maintenancemoss
	maturation = 30
	potency = 25
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	icon_grow = "maintenancemoss-grow"
	icon_dead = "maintenancemoss-dead"
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	possible_mutations = list()
	reagents_add = list (/datum/reagent/toxin/bad_food = 0.1, /datum/reagent/consumable/mold = 0.05, /datum/reagent/drug/maint/milk = 0.05)

/obj/item/food/grown/maintenancemoss
	seed = /obj/item/seeds/maintenancemoss
	name = "maintenance moss"
	desc = "The scooped out and dried mush of freshly rotting maintenance moss, full of strange space bacteria."
	icon_state = "maintenancemoss"
	foodtypes = TOXIC | GROSS
	tastes = list ("rotten cat liver" = 1, "rotten clown cartilage" = 1, "rotten gas mask" = 1, "goblin sweat" = 1, "fingernails and glue" = 1, "moth fuzz" = 1, "a milky zest with notes of stomach acid" = 1)
	distill_reagent = /datum/reagent/drug/maint/milk
