/datum/species/monkey/simian
	name = "Simian"
	id = SPECIES_SIMIAN
	species_traits = list(
		NO_UNDERWEAR,
		SPECIES_FUR,
		SKINTONES,
	)
	inherent_traits = list(
		TRAIT_VAULTING,
		TRAIT_MONKEYFRIEND,
	)
	external_organs = list(
		/obj/item/organ/external/tail/monkey = "Chimp",
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey/simian,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey/simian,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/monkey/simian,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/monkey/simian,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/monkey/simian,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/monkey/simian,
	)

	no_equip_flags = NONE
	changesource_flags = parent_type::changesource_flags & ~(WABBAJACK | SLIME_EXTRACT)
	maxhealthmod = 0.85 //small = weak
	stunmod = 1.3
	speedmod = -0.1 //lil bit faster
	payday_modifier = 1

	give_monkey_species_effects = FALSE

/datum/species/monkey/simian/get_species_description()
	return "Monke."

/datum/species/monkey/simian/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Little Monke",
			SPECIES_PERK_DESC = "You are a weak being, and have less health than most.", // 0.85% health
		)
		,list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Thief",
			SPECIES_PERK_DESC = "Your monkey instincts force you to steal objects at random.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Agile",
			SPECIES_PERK_DESC = "Simians run slightly faster than other species, but are still outpaced by Goblins.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "running",
			SPECIES_PERK_NAME = "Vaulting",
			SPECIES_PERK_DESC = "Simians vault over tables instead of climbing them.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Easy to Keep Down",
			SPECIES_PERK_DESC = "You get back up slower from stuns.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "heart",
			SPECIES_PERK_NAME = "Ape Not Kill Ape",
			SPECIES_PERK_DESC = "Monkeys like you more.",
		),
	)

	return to_add

/datum/species/monkey/simian/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	human_who_gained_species.gain_trauma(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)
	handle_mutant_bodyparts(human_who_gained_species)

/datum/species/monkey/simian/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_simian_name(gender)

	var/randname = simian_name(gender)
	if(lastname)
		randname += " [lastname]"
	return randname

/datum/species/monkey/simian/after_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source = null)
	qdel(H.wear_neck)
	var/obj/item/clothing/mask/translator/T = new /obj/item/clothing/mask/translator
	H.equip_to_slot(T, ITEM_SLOT_NECK)
