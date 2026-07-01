/datum/action/cooldown/mob_cooldown/meteors
	name = "Meteors"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to rain meteors down around yourself."
	cooldown_time = 3 SECONDS
	/// Makes us stronger if true
	var/boosted = FALSE

/datum/action/cooldown/mob_cooldown/meteors/Activate(atom/target_atom)
	disable_cooldown_actions()
	create_meteors(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/meteors/proc/create_meteors(atom/target)
	if(!target)
		return
	target.visible_message(span_boldwarning("Fire rains from the sky!"))
	var/turf/targetturf = get_turf(target)
	if(boosted) // This could be a boosted ? prob(44) : prob(11), but this way we save a good bit on repeated checks
		for(var/turf/turf as anything in RANGE_TURFS(9, targetturf))
			if(prob(44))
				new /obj/effect/temp_visual/target(turf)
		return
	for(var/turf/turf as anything in RANGE_TURFS(9,targetturf))
		if(prob(11))
			new /obj/effect/temp_visual/target(turf)
