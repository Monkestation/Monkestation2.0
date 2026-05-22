/datum/action/cooldown/bloodling/swim
	name = "Meatspace Travel"
	desc = "Travel through meatspace to any flesh tile in range."
	cooldown_time = 5 SECONDS
	biomass_cost = 30
	shared_cooldown = NONE
	background_icon = 'monkestation/icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_bloodling"
	button_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	button_icon_state = "swim"

/datum/action/cooldown/bloodling/swim/PreActivate(atom/target)
	if(!istype(get_turf(target), /turf/open/misc/bloodling))
		owner.balloon_alert(owner, "no flesh at destination!")
		return FALSE
	return ..()

/datum/action/cooldown/bloodling/swim/Activate(atom/target)
	..()
	var/mob/living/basic/bloodling/our_mob = owner

	//Stay still for a moment and do an animation
	playsound(get_turf(owner), 'sound/effects/blobattack.ogg', 30)
	our_mob.Stun(5, ignore_canstun = TRUE)
	our_mob.density = FALSE
	our_mob.spawn_gibs()
	var/icon_was = our_mob.icon_state
	our_mob.icon_state = ""
	
	sleep(5)
	
	do_teleport(owner, get_turf(target), no_effects=TRUE, channel = TELEPORT_CHANNEL_QUANTUM)
	our_mob.spawn_gibs()
	playsound(get_turf(owner), 'sound/effects/blobattack.ogg', 30)
	our_mob.density = 1
	our_mob.icon_state = icon_was
	return TRUE
