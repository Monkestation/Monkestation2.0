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
	inherent_traits = list(
		TRAIT_HARDLY_WOUNDED,
	)
	external_organs = list(
		/obj/item/organ/external/oni_tail = "normal",
		/obj/item/organ/external/oni_horns = "normal",
		/obj/item/organ/external/goblin_ears = "long",
		)
	mutantlungs = /obj/item/organ/internal/lungs/oni
	disliked_food = VEGETABLES | GROSS
	liked_food = GORE | MEAT | SEAFOOD
	maxhealthmod = 0.75
	stunmod = 1.2
	speedmod = 1.1
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
			SPECIES_PERK_ICON = "band-aid",
			SPECIES_PERK_NAME = "Thick Skin",
			SPECIES_PERK_DESC = "Your body is naturally more resillient, having more health then the average shmoe.", // an extra 25% health
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Weak Nerves",
			SPECIES_PERK_DESC = "You're stunned for longer then most.", // an extra 20% stun time.
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Heavy Footed",
			SPECIES_PERK_DESC = "You're a tad slower then the normal norman.", // 10% slower then normal.
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Steel Bones",
			SPECIES_PERK_DESC = "You're more resistant to being wounded, things like limb loss and lacerations are less likely to happen to you.", // TRAIT_HARDLY_INJURED
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Heat-Acclimated",
			SPECIES_PERK_DESC = "Your lungs aren't used to filtering cold air, and are very sensitive to it. On the flipside, your lungs like hot air much more! Your skin however, is just as susceptible to heat as anybody elses.", // higher cold damage thresholds, the opposite is also true
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Pyromancy",
			SPECIES_PERK_DESC = "Your lungs can build up and then expel flames.", // fire ball!
		),
	)

	return to_add
