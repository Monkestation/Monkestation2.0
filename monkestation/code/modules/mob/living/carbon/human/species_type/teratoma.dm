/datum/species/teratoma
	name = "Teratoma"
	id = SPECIES_TERATOMA
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_MONKEY
	mutanttongue = /obj/item/organ/internal/tongue/monkey
	mutantbrain = /obj/item/organ/internal/brain/primate

	species_traits = list(
		NO_UNDERWEAR,
		NOEYESPRITES,
		NOBLOODOVERLAY,
		NOTRANSSTING,
		NOZOMBIE,
		NO_DNA_COPY,
		NOAUGMENTS,
	)
	inherent_traits = list(
		TRAIT_BADDNA,
		TRAIT_CAN_STRIP,
		TRAIT_CHUNKYFINGERS,
		TRAIT_EASILY_WOUNDED,
		TRAIT_GENELESS,
		TRAIT_ILLITERATE,
		TRAIT_KLEPTOMANIAC,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_ZOMBIFY,
		TRAIT_PASSTABLE,
		TRAIT_PRIMITIVE,
		TRAIT_UNCONVERTABLE, // DEAR GOD NO
		TRAIT_VAULTING,
		TRAIT_VENTCRAWLER_ALWAYS,
		TRAIT_WEAK_SOUL,
	)

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/teratoma,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/teratoma,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/teratoma,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/teratoma,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/teratoma,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/teratoma,
	)

	maxhealthmod = 0.75
	stunmod = 1.4
	speedmod = -0.15 // stupid gremlins

	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN
	liked_food = MEAT | BUGS | GORE | GROSS | RAW
	disliked_food = CLOTH
	sexes = FALSE
	species_language_holder = /datum/language_holder/monkey

	fire_overlay = "monkey"
	dust_anim = "dust-m"
	gib_anim = "gibbed-m"

	var/datum/component/omen/teratoma/misfortune

/datum/species/teratoma/on_species_gain(mob/living/carbon/human/idiot, datum/species/old_species, pref_load)
	. = ..()
	misfortune = idiot.AddComponent(misfortune)

/datum/species/teratoma/on_species_loss(mob/living/carbon/human/idiot, datum/species/new_species, pref_load)
	. = ..()
	QDEL_NULL(misfortune)

/datum/species/teratoma/random_name(gender,unique,lastname)
	return "teratoma ([rand(1,999)])"

/datum/component/omen/teratoma
	permanent = TRUE
	luck_mod = 0.75
	damage_mod = 0.2

/mob/living/carbon/human/species/teratoma
	race = /datum/species/teratoma
