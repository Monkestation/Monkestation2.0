/// Tundra moths used to be their own species, now they're a limb style for moths.
/// This turns old tundra moths into moths with tundra fur, and moves the old
/// mutant colors toggle over to the limb style preference.
/datum/preferences/proc/migrate_tundra_moths(list/save_data)
	if(save_data["species"] == "tundra")
		save_data["species"] = SPECIES_MOTH
		save_data["limb_style"] = LIMB_STYLE_TUNDRA
	else if(save_data["greyscale_toggle"])
		save_data["limb_style"] = LIMB_STYLE_MUTANT_COLORS
	save_data -= "greyscale_toggle"
	// these got read before the migration ran
	value_cache -= list(/datum/preference/choiced/species, /datum/preference/choiced/limb_style)
