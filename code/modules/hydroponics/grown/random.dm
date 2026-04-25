//Random seeds; stats, traits, and plant type are randomized for each seed.

/obj/item/seeds/random
	name = "pack of strange seeds"
	desc = "Mysterious seeds as strange as their name implies. Spooky."
	icon_state = "seed-x"
	species = "?????"
	plantname = "strange plant"
	product = /obj/item/food/grown/random
	icon_grow = "xpod-grow"
	icon_dead = "xpod-dead"
	icon_harvest = "xpod-harvest"
	growthstages = 4
	custom_premium_price = PAYCHECK_CREW * 2

/obj/item/seeds/random/Initialize(mapload)
	. = ..()
	randomize_stats()
	if(prob(60))
		add_random_reagents(1, 3)
	if(prob(50))
		add_random_traits(1, 2)
	add_random_plant_type(35)

/obj/item/food/grown/random
	seed = /obj/item/seeds/random
	name = "strange plant"
	desc = "What could this even be?"
	icon_state = "crunchy"

/obj/item/food/grown/random/Initialize(mapload)
	. = ..()
	wine_power = rand(10,150)
	if(prob(1))
		wine_power = 200

/obj/item/seeds/random/lesser
	name = "pack of lesser strange seeds"
	desc = "Mysterious seeds as strange as their name implies, albeit with less potential than their \"normal\" counterparts."
	/// Typecache of reagents forbidden from appearing.
	/// This is not an exhaustive list, as any reagent without REAGENT_CAN_BE_SYNTHESIZED is also blacklisted.
	var/static/list/reagent_blacklist = typecacheof(list(
		/datum/reagent/aslimetoxin,
		/datum/reagent/drug/blastoff,
		/datum/reagent/drug/demoneye,
		/datum/reagent/drug/twitch,
		/datum/reagent/magillitis,
		/datum/reagent/medicine/antipathogenic/changeling,
		/datum/reagent/medicine/changelinghaste,
		/datum/reagent/medicine/coagulant,
		/datum/reagent/medicine/regen_jelly,
		/datum/reagent/medicine/stimulants,
		/datum/reagent/medicine/syndicate_nanites,
		/datum/reagent/metalgen,
		/datum/reagent/mulligan,
		/datum/reagent/mutationtoxin,
		/datum/reagent/prefactor_a,
		/datum/reagent/prefactor_b,
		/datum/reagent/reaction_agent,
		/datum/reagent/spider_extract,
	))

/obj/item/seeds/random/lesser/pick_reagent()
	var/static/list/valid_reagent_list
	if(isnull(valid_reagent_list))
		LAZYINITLIST(valid_reagent_list)
		for(var/datum/reagent/reagent_path as anything in subtypesof(/datum/reagent))
			if(!(reagent_path::chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
				continue
			if(is_type_in_typecache(reagent_path, reagent_blacklist))
				continue
			valid_reagent_list += reagent_path
	return pick(valid_reagent_list)
