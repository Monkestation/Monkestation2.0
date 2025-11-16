
//sets you on fire, does burn damage, explodes into flame when burnt, weak to water
/datum/blobstrain/reagent/blazing_oil
	name = "Blazing Oil"
	description = "will do medium-high burn damage ignoring armor, and set targets on fire."
	effectdesc = "will also release bursts of flame when burnt, but takes damage from water."
	analyzerdescdamage = "Does medium-high burn damage and sets targets on fire."
	analyzerdesceffect = "Releases fire when burnt, but takes damage from water and other extinguishing liquids."
	color = "#B68D00"
	complementary_color = "#BE5532"
	blobbernaut_message = "splashes"
	message = "The blob splashes you with burning oil"
	message_living = ", and you feel your skin char and melt"
	reagent = /datum/reagent/blob/blazing_oil

/datum/blobstrain/reagent/blazing_oil/extinguish_reaction(obj/structure/blob/extinguished, coefficient)
	extinguished.take_damage(4.5, BURN, ENERGY)

/datum/blobstrain/reagent/blazing_oil/damage_reaction(obj/structure/blob/damaged, damage, damage_type, damage_flag)
	if(damage_type == BURN && damage_flag != ENERGY)
		for(var/turf/open/close_turf in RANGE_TURFS(1, damaged))
			var/obj/structure/blob/close_blob = locate() in close_turf
			if(close_blob?.blob_team?.blobstrain.type != src.type && prob(80))
				new /obj/effect/hotspot(close_turf)
	if(damage_flag == FIRE)
		return 0
	return ..()

/datum/reagent/blob/blazing_oil
	name = "Blazing Oil"
	taste_description = "burning oil"
	color = "#B68D00"

/datum/reagent/blob/blazing_oil/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.adjust_fire_stacks(round(reac_volume/10))
	exposed_mob.ignite_mob()
	if(exposed_mob)
		exposed_mob.apply_damage(0.8*reac_volume, BURN, wound_bonus=CANT_WOUND)
	if(iscarbon(exposed_mob))
		exposed_mob.emote("scream")
