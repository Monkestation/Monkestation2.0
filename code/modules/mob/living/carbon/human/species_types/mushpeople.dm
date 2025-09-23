/datum/species/mush //mush mush codecuck
	name = "Mushroomperson"
	plural_form = "Mushroompeople"
	id = SPECIES_MUSHROOM
	mutant_bodyparts = list("caps" = "Round")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	fixed_mut_color = "#DBBF92"
	hair_color = "#FF4B19" //cap color, spot color uses eye color

	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_MUTANT_COLORS,
		TRAIT_NOBREATH,
		TRAIT_NOFLASH,
	)
	inherent_factions = list(FACTION_MUSHROOM)

	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING

	burnmod = 1.25
	heatmod = 1.5

	mutanttongue = /obj/item/organ/internal/tongue/mush
	mutanteyes = /obj/item/organ/internal/eyes/night_vision/mushroom
	mutantlungs = null
	var/datum/martial_art/mushpunch/mush
	species_language_holder = /datum/language_holder/mushroom

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mushroom,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mushroom,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mushroom,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mushroom,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mushroom,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mushroom,
	)

/datum/species/mush/check_roundstart_eligible()
	return TRUE //guess what we got stations that are on planets now 

/datum/species/mush/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!H.dna.features["caps"])
			H.dna.features["caps"] = "Round"
			handle_mutant_bodyparts(H)
		mush = new(null)
		mush.teach(H)

/datum/species/mush/on_species_loss(mob/living/carbon/C)
	. = ..()
	mush.remove(C)
	QDEL_NULL(mush)

/datum/species/mush/handle_chemical(datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
	. = ..()
	if(. & COMSIG_MOB_STOP_REAGENT_CHECK)
		return
	if(chem.type == /datum/reagent/toxin/plantbgone/weedkiller)
		affected.adjustToxLoss(3 * REM * seconds_per_tick)

/datum/species/mush/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	forced_colour = FALSE
	return ..()

/datum/species/mush/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "band-aid",
			SPECIES_PERK_NAME = "Thick Skin",
			SPECIES_PERK_DESC = "Your body is naturally more resillient, having more health then the average shmoe.", // an extra 10% health
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Big Fungus",
			SPECIES_PERK_DESC = "You can punch people with such immense strength that they go FLYING ACROSS THE ROOM! If they stand still for 2 and a half seconds...", // an extra 20% stun time.
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Big Fungus",
			SPECIES_PERK_DESC = "You're 25% slower than normal.", // 10% slower then normal.
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Steel Bones",
			SPECIES_PERK_DESC = "You're more resistant to being wounded, things like limb loss and lacerations are less likely to happen to you.", // TRAIT_HARDLY_INJURED
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-high",
			SPECIES_PERK_NAME = "Sterilization",
			SPECIES_PERK_DESC = "You're easily burnt away, taking 25% more burn damage overall and 50% more damage from high temperatures.", // higher cold damage thresholds, the opposite is also true
		),
	)

	return to_add
