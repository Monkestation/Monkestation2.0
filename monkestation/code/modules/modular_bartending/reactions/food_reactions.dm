/datum/chemical_reaction/saltsolidification
	required_reagents = list(/datum/reagent/consumable/salt = 10)
	required_temp = 600

/datum/chemical_reaction/saltsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/garnish/salt(location)

/datum/chemical_reaction/ashsolidification
	required_reagents = list(/datum/reagent/ash = 10)
	required_temp = 600

/datum/chemical_reaction/ashsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/garnish/ash(location)

/datum/chemical_reaction/greybull
	results = list(/datum/reagent/consumable/grey_bull = 2)
	required_reagents = list(/datum/reagent/consumable/liquidelectricity = 2, /datum/reagent/copper = 1, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY
