/datum/quirk/anime
	name = "Anime"
	desc = "You are an anime enjoyer! Show your enthusiasm with some fashionable attire."
	mob_trait = TRAIT_ANIME
	value = 0
	icon = FA_ICON_PAW
	quirk_flags = QUIRK_CHANGES_APPEARANCE

	var/list/anime_list = list(
		/obj/item/organ/external/anime_head,
		/obj/item/organ/external/anime_middle,
		/obj/item/organ/external/anime_bottom,
	)

/datum/quirk/anime/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_SPECIES_GAIN_PRE, PROC_REF(on_species_gain))

	var/datum/species/species = quirk_holder.has_dna()?.species
	if(species)
		for(var/obj/item/organ/external/organ_path as anything in anime_list)
			//Load a persons preferences from DNA
			var/obj/item/organ/external/new_organ = SSwardrobe.provide_type(organ_path)
			new_organ.Insert(quirk_holder, special = TRUE, drop_if_replaced = FALSE)
			species.external_organs |= organ_path

/datum/quirk/anime/remove()
	UnregisterSignal(quirk_holder, COMSIG_SPECIES_GAIN_PRE)
	var/datum/species/species = quirk_holder.has_dna()?.species
	if(species)
		for(var/obj/item/organ/external/organ_path as anything in anime_list)
			species.external_organs -= organ_path

/datum/quirk/anime/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	for(var/obj/item/organ/external/organ_path as anything in anime_list)
		new_species.external_organs |= organ_path
