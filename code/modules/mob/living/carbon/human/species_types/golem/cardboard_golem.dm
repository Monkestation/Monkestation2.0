/datum/species/golem/cardboard //Faster but weaker, can also make new shells on its own
	name = "Cardboard Golem"
	id = SPECIES_GOLEM_CARDBOARD
	prefix = "Cardboard"
	special_names = list("Box")
	info_text = "As a <span class='danger'>Cardboard Golem</span>, you aren't very strong, but you are a bit quicker and can easily create more brethren by using cardboard on yourself."
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	//mutanttongue = null
	fixed_mut_color = null
	armor = 25
	burnmod = 1.25
	heatmod = 2
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/cardboard,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/cardboard,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/cardboard,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/cardboard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/cardboard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/cardboard,
	)
	var/last_creation = 0
	var/brother_creation_cooldown = 300

/datum/species/golem/cardboard/proc/create_brother(mob/living/carbon/human/golem, atom/location)
	var/mob/living/master = golem.mind.enslaved_to?.resolve()
	if(master)
		new /obj/effect/mob_spawn/ghost_role/human/golem/servant(location, /datum/species/golem/cardboard, master)
	else
		new /obj/effect/mob_spawn/ghost_role/human/golem(location, /datum/species/golem/cardboard)

	last_creation = world.time
