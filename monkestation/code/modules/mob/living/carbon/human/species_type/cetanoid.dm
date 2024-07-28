//Cetanoids from the Human Nature series by Cosmicartoons!

/datum/species/cetanoid
	name = "\improper Cetanoid"
	plural_form = "Cetanoids"
	id = SPECIES_CETANOID
	visual_gender = FALSE

	payday_modifier = 1

	species_traits = list(
		MUTCOLORS,
		NO_UNDERWEAR,
		EYECOLOR
	)

	inherent_traits = list(
		TRAIT_NIGHT_VISION,
	)

	liked_food = SEAFOOD
	disliked_food = RAW | GORE

	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 50) // about -50c
	mutantlungs = /obj/item/organ/internal/lungs/cetanoid
	mutanteyes = /obj/item/organ/internal/eyes/cetanoid

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/cetanoid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/cetanoid,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/cetanoid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/cetanoid,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/robot/digitigrade,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/robot/digitigrade
	)
	external_organs = list(
		/obj/item/organ/external/tail/cetanoid = "Default",
		/obj/item/organ/external/frills/cetanoid = "Aquatic",
		/obj/item/organ/external/snout = "Round",
		/obj/item/organ/external/cetanoid_fins = "Default",
	)
	digitigrade_customization = DIGITIGRADE_FORCED
	outfit_important_for_life = /datum/outfit/cetanoid

/datum/species/cetanoid/on_species_gain(mob/living/carbon/human/C, datum/species/old_species)
	. = ..()

	//no legs for you bozo
	for(var/obj/item/bodypart/leg/leg in C.bodyparts)
		QDEL_NULL(leg)

/datum/species/cetanoid/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	if(job?.cetanoid_outfit)
		equipping.equipOutfit(job.cetanoid_outfit, visuals_only)
	else
		give_important_for_life(equipping)

/datum/species/cetanoid/get_species_description()
	return "Space-fish people. Cetanoids give most people the impression that they live a wonderful \
			magical mermaid fantasy life, but life on Corallo is coldhearted and \
			hard. For these underwater dwellers, percieved success and intelligence \
			is everything when it comes to status, and in that fight you're on your \
			own. (Cetanoids are from the YouTube series Human Nature by Cosmicartoons!)"

/datum/species/cetanoid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "No Legs",
			SPECIES_PERK_DESC = "You don't have legs, but will start with a suit that allows you to walk.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "Gills",
			SPECIES_PERK_DESC = "You cannot breathe air without your cybernetic suit!",
		)
		)

	return to_add
