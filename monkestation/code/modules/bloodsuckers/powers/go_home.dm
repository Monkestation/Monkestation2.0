
/**
 * Given to Bloodsuckers if they have a Coffin claimed.
 * Teleports them to their Coffin on use.
 * Makes them drop everything if someone witnesses the act.
 */
/datum/action/cooldown/bloodsucker/gohome
	name = "Vanishing Act"
	desc = "Disperse into mist and return directly to your Lair.<br><b>WARNING:</b> You will drop <b>ALL</b> of your possessions if observed by mortals."
	button_icon_state = "power_gohome"
	active_background_icon_state = "vamp_power_off_oneshot"
	base_background_icon_state = "vamp_power_off_oneshot"
	power_explanation = "Vanishing Act: \n\
		Activating Vanishing Act will, after a short delay, teleport the user to their Claimed Coffin. \n\
		Immediately after activating, lights around the user will temporarily flicker. \n\
		Once the user teleports to their coffin, in their place will be a Rat or Bat."
	power_flags = BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS | BP_CANT_USE_IN_FRENZY
	purchase_flags = NONE
	bloodcost = 100
	cooldown_time = 5 MINUTES

	///The types of mobs that will drop post-teleportation.
	var/static/list/spawning_mobs = list(
		/mob/living/basic/mouse = 3,
		/mob/living/basic/bat = 1,
	)

/datum/action/cooldown/bloodsucker/gohome/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	/// Have No Lair (NOTE: You only got this power if you had a lair, so this means it's destroyed)
	if(!istype(bloodsuckerdatum_power) || QDELETED(bloodsuckerdatum_power.coffin))
		owner.balloon_alert(owner, "coffin was destroyed!")
		return FALSE

	if (!check_teleport_valid(owner, bloodsuckerdatum_power.coffin, TELEPORT_CHANNEL_MAGIC))
		owner.balloon_alert(owner, "something holds you back!")
		return FALSE

	if((bloodsuckerdatum_power.bloodsucker_blood_volume-get_blood_cost()) <= bloodsuckerdatum_power.frenzy_threshold)
		owner.balloon_alert(owner, "using this would send you into a frenzy!")
		return FALSE

	if(!isturf(owner.loc))
		owner.balloon_alert(owner, "you cannot teleport right now!")
		return FALSE

	return TRUE

/datum/action/cooldown/bloodsucker/gohome/ActivatePower(trigger_flags)
	. = ..()

	var/turf/old_turf = get_turf(owner)

	teleport_to_coffin(owner)
	flicker_lights(4, 60, old_turf)

/datum/action/cooldown/bloodsucker/gohome/proc/flicker_lights(flicker_range, beat_volume, turf/source_turf)
	for(var/obj/machinery/light/nearby_lights in view(flicker_range, source_turf))
		nearby_lights.flicker(5)
	playsound(source_turf, 'sound/effects/singlebeat.ogg', beat_volume, 1)

/datum/action/cooldown/bloodsucker/gohome/proc/teleport_to_coffin(mob/living/carbon/user)
	var/drop_item = FALSE
	var/turf/current_turf = get_turf(owner)
	// If we aren't in the dark, anyone watching us will cause us to drop out stuff
	if(!QDELETED(current_turf?.lighting_object) && current_turf.get_lumcount() >= 0.2)
		for(var/mob/living/watchers in viewers(world.view, get_turf(owner)) - owner)
			if(QDELETED(watchers.client) || watchers.client?.is_afk() || watchers.stat != CONSCIOUS)
				continue
			if(HAS_SILICON_ACCESS(watchers))
				continue
			if(watchers.is_blind())
				continue
			if(!HAS_MIND_TRAIT(watchers, TRAIT_BLOODSUCKER_ALIGNED) && !HAS_TRAIT(watchers, TRAIT_GHOST_CRITTER))
				drop_item = TRUE
				break
	// Drop all necessary items (handcuffs, legcuffs, items if seen)
	user.uncuff()
	if(drop_item)
		user.unequip_everything()

	playsound(current_turf, 'sound/magic/summon_karp.ogg', vol = 60, vary = TRUE)

	var/datum/effect_system/steam_spread/bloodsucker/puff = new /datum/effect_system/steam_spread/bloodsucker()
	puff.set_up(3, 0, current_turf)
	puff.start()

	/// STEP FIVE: Create animal at prev location
	var/mob/living/simple_animal/new_mob = pick_weight(spawning_mobs)
	new new_mob(current_turf)
	/// TELEPORT: Move to Coffin & Close it!
	user.set_resting(TRUE, TRUE, FALSE)
	do_teleport(owner, bloodsuckerdatum_power.coffin, no_effects = TRUE, forced = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	bloodsuckerdatum_power.coffin.open(owner, TRUE)
	bloodsuckerdatum_power.coffin.close(owner)
	bloodsuckerdatum_power.coffin.take_contents()
	playsound(bloodsuckerdatum_power.coffin.loc, bloodsuckerdatum_power.coffin.close_sound, vol = 15, vary = TRUE, extrarange = -3)

	DeactivatePower()

/datum/effect_system/steam_spread/bloodsucker
	effect_type = /obj/effect/particle_effect/fluid/smoke/vampsmoke
