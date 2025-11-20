/datum/species/oni
	name = "\improper Oni"
	plural_form = "Onis"
	id = SPECIES_ONI
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	sexes = TRUE
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/oni,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/oni,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/oni,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/oni,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/oni,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/oni,
	)
	external_organs = list(
		/obj/item/organ/external/goblin_ears = "Long",
		/obj/item/organ/external/oni_horns = "Oni",
		/obj/item/organ/external/oni_wings = "Normal",
		/obj/item/organ/external/oni_tail = "Spade",
	)
	mutantlungs = /obj/item/organ/internal/lungs/oni
	mutanttongue = /obj/item/organ/internal/tongue/oni
	maxhealthmod = 1.1
	stunmod = 1.2
	heatmod = 0.8
	coldmod = 2
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_DAMAGE_LIMIT + 10 CELCIUS
	bodytemp_cold_damage_limit = BODYTEMP_COLD_DAMAGE_LIMIT + 15 CELCIUS

/mob/living/carbon/human/species/oni
	race = /datum/species/oni

/datum/species/oni/get_species_description()
	return "A species of slightly larger then average humanoids, with vibrant skin and features not too dissimilair from the oni of folklore."

/datum/species/oni/prepare_human_for_preview(mob/living/carbon/human/oni)
	oni.dna.features["oni_horns"] = "Oni"
	oni.dna.features["oni_wings"] = "Normal"
	oni.dna.features["oni_tail"] = "Spade"
	var/datum/color_palette/generic_colors/colors = oni.dna.color_palettes[/datum/color_palette/generic_colors]
	colors.mutant_color = "#2D80CC"
	oni.update_body(TRUE)

/datum/species/oni/create_pref_unique_perks()
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
			SPECIES_PERK_DESC = "Your lungs aren't used to filtering cold air, and are very sensitive to it. On the flipside, your lungs like hot air much more! Your skin however, is just as susceptible to heat as anybody.", // higher cold damage thresholds, the opposite is also true
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Pyromancy",
			SPECIES_PERK_DESC = "Your lungs can build up and then expel flames.", // fire ball!
		),
	)

	return to_add
