/datum/species/shadekin
	name = "\improper Shadekin"
	plural_form = "Shadekin"
	id = SPECIES_SHADEKIN
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutantbrain = /obj/item/organ/internal/brain/shadekin
	mutanteyes = /obj/item/organ/internal/eyes/shadekin
	mutantears = /obj/item/organ/internal/ears/shadekin
	mutanttongue = /obj/item/organ/internal/tongue/shadekin
	mutantlungs = null
	species_language_holder = /datum/language_holder/shadekin

	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
		TRAIT_NIGHT_VISION,
		TRAIT_NOBREATH,
	)

	external_organs = list(
		/obj/item/organ/external/tail/shadekin = "Shadekin Classic", /obj/item/organ/external/ears/shadekin = "Shadekin Classic Ears"
	)

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadekin,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadekin,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadekin,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadekin,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadekin,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadekin,
	)


/datum/species/shadekin/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "lightbulb",
		SPECIES_PERK_NAME = "Dark Regeneration",
		SPECIES_PERK_DESC = "Shadekin slowly regenerate their physical wounds while in the darkness.",
	),
	list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "wind",
		SPECIES_PERK_NAME = "Auto Respiration",
		SPECIES_PERK_DESC = "Shadekin do not need to breathe, but this does not protect them from the dangers of space.",
	),
	list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "band-aid",
		SPECIES_PERK_NAME = "Damage Vulnerability",
		SPECIES_PERK_DESC = "Shadekin are more vulnerable to physical injury, and will take 20% more brute and burn damage.",
	),
	list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "sun",
		SPECIES_PERK_NAME = "Darkness Adapted Eyes",
		SPECIES_PERK_DESC = "Shadekin are adapted to darkness, and see better in the dark, however their eyes are sensitive to bright lights, and they will suffer from flashbangs and flashes.",
		)
	)
	return to_add

/datum/species/shadekin/get_species_description()
	return "Shadekin first came about like dust bunnies under a bed, in a collective consciousness that whispered \
		\"Welcome, sibling,\" and guided them toward their first connection. They do not respirate, and their bodies \
		are reformed in the darkness, though they are fragile and vulnerable to the light."

/obj/item/organ/internal/brain/shadekin
	name = "shadekin brain"
	desc = "The brain of a shadekin. It leaves a weird tar residue on the hands when touched."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "brain-x-d"

/obj/item/organ/internal/brain/shadekin/on_life(seconds_per_tick, times_fired)
	. = ..()
	var/turf/owner_turf = owner.loc
	if(!isturf(owner_turf))
		return

	var/lumcount = GET_SIMPLE_LUMCOUNT(owner_turf)
	if(lumcount < SHADOW_SPECIES_DIM_LIGHT)
		owner.apply_status_effect(/datum/status_effect/shadekin_regeneration)
		owner.clear_mood_event("shadekin_light")

	else if(lumcount > SHADOW_SPECIES_DIM_LIGHT)
		owner.remove_status_effect(/datum/status_effect/shadekin_regeneration)
		owner.add_mood_event("shadekin_light", /datum/mood_event/shadekin_light)

/datum/mood_event/shadekin_light
	description = "The light is uncomfortable..."
	mood_change = -3
	timeout = 5 SECONDS

/datum/status_effect/shadekin_regeneration
	id = "shadekin_regeneration"
	duration = 5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/shadekin_regeneration

/datum/status_effect/shadekin_regeneration/tick(seconds_per_tick)
	owner.heal_overall_damage(brute = 0.8 * seconds_per_tick, burn = 0.8 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)

/atom/movable/screen/alert/status_effect/shadekin_regeneration
	name = "Dark Regeneration"
	desc = "Darkness passes through your body, slowly healing your wounds!"
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "shaderegen"
	var/datum/status_effect/shadekin_regeneration

/obj/item/organ/external/ears/shadekin
	name = "Protruding shadekin ears"
	desc = "The external, protruding part of the shadekin's ears. doesn't seem to affect their hearing."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "shadekin-visual-ears"
	preference = "feature_shadekin_ears"
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears/shadekin

/datum/bodypart_overlay/mutant/ears/shadekin
	feature_key = "ears_shadekin"

/datum/bodypart_overlay/mutant/ears/shadekin/get_global_feature_list()
	return GLOB.ears_list_shadekin
