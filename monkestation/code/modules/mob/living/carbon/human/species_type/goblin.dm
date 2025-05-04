/datum/species/goblin
	name = "\improper Goblin"
	plural_form = "Goblins"
	id = SPECIES_GOBLIN
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	sexes = TRUE
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_DWARF,
		TRAIT_QUICK_BUILD,
		TRAIT_EASILY_WOUNDED,
		TRAIT_NIGHT_VISION,
		TRAIT_MAINTENANCE_DWELLER,
		// TRAIT_pickpocketing?
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	external_organs = list(
		/obj/item/organ/external/goblin_ears = "long",
		/obj/item/organ/external/goblin_nose = "small",
		)
	meat = /obj/item/food/meat/steak
	mutanttongue = /obj/item/organ/internal/tongue/goblin
	species_language_holder = /datum/language_holder/goblin
	maxhealthmod = 0.75
	stunmod = 1.2
	payday_modifier = 1
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/goblin,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/goblin,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/goblin,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/goblin,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/goblin,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/goblin,
	)

/mob/living/carbon/human/species/goblin
    race = /datum/species/goblin

/datum/species/goblin/get_species_description()
	return "A species of small green humanoids. Reknown for their stealth, they are also primarily known for their skill in tinkering and construction, which is on the level of dwarves."

/datum/species/goblin/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "trash-can",
			SPECIES_PERK_NAME = "Maintenance Native",
			SPECIES_PERK_DESC = "As a creature of filth, you feel right at home in maintenance and can see better!", //Mood boost when in maint? How to do?
		),
		// list(
		// 	SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		// 	SPECIES_PERK_ICON = "fist-raised",
		// 	SPECIES_PERK_NAME = "Swift Hands",
		// 	SPECIES_PERK_DESC = "Your small fingers allow you to pick pockets quieter than most.",		//I DON'T KNOW HOW TO DO THIS >:c
		// ),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Level One Goblin",
			SPECIES_PERK_DESC = "You are a weak being, and have less health than most.", // 0.75% health and Easily Wounded trait
		)
		,list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "ruler-vertical",
			SPECIES_PERK_NAME = "Short",
			SPECIES_PERK_DESC = "Goblins are short so they're harder to hit, you look funny though. haha.", //Dwarf trauma
		),
		,list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Small Hands",
			SPECIES_PERK_DESC = "Goblin's small hands allow them to construct machines faster.", //Quick Build trait
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Agile",
			SPECIES_PERK_DESC = "Goblins run faster than other species.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Easy to Keep Down",
			SPECIES_PERK_DESC = "You get back up from stuns slower.",
		),
	)

	return to_add

/obj/item/bodypart/head/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN
	is_dimorphic = FALSE
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/chest/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN
	is_dimorphic = TRUE
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/arm/left/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/arm/right/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/leg/left/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN
	speed_modifier = -0.125
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/leg/right/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN
	speed_modifier = -0.125
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/organ/internal/tongue/goblin
	name = "goblin tongue"
	disliked_foodtypes = VEGETABLES
	liked_foodtypes = GORE | MEAT | GROSS
