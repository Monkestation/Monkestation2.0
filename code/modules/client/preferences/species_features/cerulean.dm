/// The color given to people with a fish tail, the selection is exclusive to Ceruleans
/datum/preference/color/fish_tail_color
	savefile_key = "feature_fish_tail_color"
	relevant_external_organ = /obj/item/organ/external/tail/fish
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/fish_tail_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["fish_tail_color"] = value

/datum/preference/color/fish_tail_color/create_default_value()
	return pick(GLOB.carp_colors - COLOR_CARP_SILVER)

/// cerulean frills. not a choice like lizard frills. just a toggle for yes or no, the accessory is aquatic
/datum/preference/toggle/cerulean_frills
	savefile_key = "feature_cerulean_frills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODYPARTS
	randomize_by_default = FALSE
	default_value = TRUE

/datum/preference/toggle/cerulean_frills/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return
	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	return (savefile_key in species.get_features())

/datum/preference/toggle/cerulean_frills/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if(iscerulean(target) && value)
		target.dna.features["frills"] = /datum/sprite_accessory/frills/aquatic::name
		target.dna.species.external_organs[/obj/item/organ/external/frills] = /datum/sprite_accessory/frills/aquatic::name
	target.dna.species.regenerate_organs(target, GLOB.species_prototypes[target.dna.species.type], visual_only = FALSE)
