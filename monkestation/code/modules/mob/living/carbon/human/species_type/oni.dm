/datum/species/oni
	name = "\improper Oni"
	plural_form = "Onis"
	id = SPECIES_ONI
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	sexes = TRUE
	species_traits = list(
		MUTCOLORS,
		LIPS,
		EYECOLOR,
		HAIR,
		FACEHAIR
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	external_organs = list(
		/obj/item/organ/external/oni_tail = "normal",
		/obj/item/organ/external/oni_horns = "normal",
		/obj/item/organ/external/goblin_ears = "long",
		)
	disliked_food = VEGETABLES | GROSS
	liked_food = GORE | MEAT | SEAFOOD
	maxhealthmod = 0.75
	stunmod = 1.2
	speedmod = -0.25
	payday_modifier = 1

/mob/living/carbon/human/species/oni
    race = /datum/species/oni

/datum/species/oni/get_scream_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		if(prob(1))
			return 'sound/voice/human/wilhelm_scream.ogg'
		return pick(
			'sound/voice/human/malescream_1.ogg',
			'sound/voice/human/malescream_2.ogg',
			'sound/voice/human/malescream_3.ogg',
			'sound/voice/human/malescream_4.ogg',
			'sound/voice/human/malescream_5.ogg',
			'sound/voice/human/malescream_6.ogg',
		)

	return pick(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		'sound/voice/human/femalescream_5.ogg',
	)

/datum/species/oni/get_laugh_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		return pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg')
	else
		return 'sound/voice/human/womanlaugh.ogg'

/datum/species/oni/get_species_description()
	return "A species of slightly larger then average humanoids, with vibrant skin and features not too dissimilair from demons from folklore."

/datum/species/oni/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "",
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
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "Short",
			SPECIES_PERK_DESC = "Short, haha.", //Dwarf trauma
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
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Hard to Keep Down",
			SPECIES_PERK_DESC = "You get back up quicker from stuns.",
		),
	)

	return to_add
