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
