//////////////////////////////////////////////////////////////////////////
//--------------------------Used for icy veins--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/reagent/shadowfrost
	name = "Shadowfrost"
	description = "A dark liquid that seems to slow down anything that comes into contact with it."
	color = "#000000" //Complete black (RGB: 0, 0, 0)

/datum/reagent/shadowfrost/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(name, 2)

/datum/reagent/shadowfrost/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(name)
	return ..()

//////////////////////////////////////////////////////////////////////////
//-----------------------Used for darkness smoke------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/reagent/darkspawn_darkness_smoke
	name = "odd black liquid"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)

/datum/reagent/darkspawn_darkness_smoke/on_mob_add(mob/living/L)
	. = ..()
	var/datum/antagonist/darkspawn/dude = IS_DARKSPAWN(L)
	if(dude)
		ADD_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)

/datum/reagent/darkspawn_darkness_smoke/on_mob_delete(mob/living/L)
	var/datum/antagonist/darkspawn/dude = IS_DARKSPAWN(L)
	if(dude)
		REMOVE_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)
	return ..()

/datum/reagent/darkspawn_darkness_smoke/expose_mob(mob/living/M, methods, reac_volume, show_message, touch_protection)
	. = ..()
	if(IS_TEAM_DARKSPAWN(M) && M.reagents) //since darkspawns don't breathe, let's do this
		M.reagents.add_reagent(type, 5)

/datum/reagent/darkspawn_darkness_smoke/on_mob_life(mob/living/M)
	if(!IS_TEAM_DARKSPAWN(M))
		to_chat(M, span_warning("<b>The pitch black smoke irritates your eyes horribly!</b>"))

		M.adjust_temp_blindness(2 SECONDS)
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at their eyes!")
			M.Stun(3)

	holder.remove_reagent(type, 1)//tick down at 1u at a time
	volume = clamp(volume, 0, 2)//have at most 2u at any time
