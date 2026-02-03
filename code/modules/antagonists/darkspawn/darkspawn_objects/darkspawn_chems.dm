//////////////////////////////////////////////////////////////////////////
//--------------------------Used for icy veins--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/reagent/shadowfrost
	name = "Shadowfrost"
	description = "A dark liquid that seems to slow down anything that comes into contact with it."
	color = "#000000" //Complete black (RGB: 0, 0, 0)

/datum/reagent/shadowfrost/on_mob_metabolize(mob/living/exposed_mob)
	. = ..()
	exposed_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/shadowfrost)

/datum/reagent/shadowfrost/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/shadowfrost)
	return ..()

//////////////////////////////////////////////////////////////////////////
//-----------------------Used for darkness smoke------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/reagent/darkspawn_darkness_smoke
	name = "odd black liquid"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	taste_description = "stagnant air"
	color = "#000000" //Complete black (RGB: 0, 0, 0)

/datum/reagent/darkspawn_darkness_smoke/on_mob_add(mob/living/exposed_mob)
	. = ..()
	var/datum/antagonist/darkspawn/dude = IS_DARKSPAWN(exposed_mob)
	if(dude)
		ADD_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)

/datum/reagent/darkspawn_darkness_smoke/on_mob_delete(mob/living/exposed_mob)
	var/datum/antagonist/darkspawn/dude = IS_DARKSPAWN(exposed_mob)
	if(dude)
		REMOVE_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)
	return ..()

/datum/reagent/darkspawn_darkness_smoke/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection)
	. = ..()
	if(!ishuman(exposed_mob))
		return
	if(IS_TEAM_DARKSPAWN(exposed_mob)) //since darkspawns don't breathe, let's do this
		exposed_mob.reagents?.add_reagent(type, 5)

/datum/reagent/darkspawn_darkness_smoke/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(!IS_TEAM_DARKSPAWN(affected_mob))
		to_chat(affected_mob, span_warning("<b>The pitch black smoke irritates your eyes horribly!</b>"))

		affected_mob.adjust_temp_blindness_up_to(2 SECONDS * seconds_per_tick, 10 SECONDS)
		if(prob(25))
			affected_mob.visible_message(span_warning("<b>[affected_mob]</b> claws at [affected_mob.p_their()] eyes!"))
			affected_mob.Stun(3)

	holder.remove_reagent(type, 1)//tick down at 1u at a time
	volume = clamp(volume, 0, 2)//have at most 2u at any time
