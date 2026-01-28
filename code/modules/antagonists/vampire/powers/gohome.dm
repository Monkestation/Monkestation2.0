#define GOHOME_START 0
#define GOHOME_FLICKER_ONE 2
#define GOHOME_FLICKER_TWO 4
#define GOHOME_TELEPORT 6

/**
 * Given to Vampires if they have a Coffin claimed.
 * Teleports them to their Coffin on use.
 * Makes them drop everything if someone witnesses the act.
 */
/datum/action/cooldown/vampire/gohome
	name = "Vanishing Act"
	desc = "As dawn aproaches, disperse into mist and return directly to your lair.<br><b>WARNING:</b> You will drop <b>ALL</b> of your possessions if observed by mortals."
	button_icon_state = "power_gohome"
	power_explanation = "Activating Vanishing Act will, after a short delay, teleport you to your Claimed Coffin.\n\
		Immediately after activating, lights around the user will begin to flicker.\n\
		Once the user teleports to their coffin, in their place will be a Rat or Bat."
	vampire_power_flags = BP_AM_STATIC_COOLDOWN
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS | BP_CANT_USE_IN_FRENZY
	vitaecost = 100
	cooldown_time = 5 MINUTES
	///What stage of the teleportation are we in
	var/teleporting_stage = GOHOME_START
	/// The types of mobs that will drop post-teleportation.
	var/static/list/spawning_mobs = list(
		/mob/living/basic/mouse = 3,
		/mob/living/basic/bat = 1,
	)

/datum/action/cooldown/vampire/gohome/can_use()
	. = ..()
	if(!.)
		return FALSE

	/// Have No haven (NOTE: You only got this power if you had a haven, so this means it's destroyed)
	if(!vampiredatum_power?.coffin)
		owner.balloon_alert(owner, "coffin was destroyed!")
		return FALSE

	if(owner.loc == vampiredatum_power.coffin)
		owner.balloon_alert(owner, "you're already in your coffin!")
		return FALSE

	if(!check_teleport_valid(owner, vampiredatum_power.coffin, TELEPORT_CHANNEL_MAGIC))
		owner.balloon_alert(owner, "something holds you back!")
		return FALSE

	if((vampiredatum_power.current_vitae - vitaecost) <= vampiredatum_power.frenzy_threshold)
		owner.balloon_alert(owner, "using this would send you into a frenzy!")
		return FALSE

	if(!isturf(owner.loc))
		owner.balloon_alert(owner, "you cannot teleport right now!")
		return FALSE

/datum/action/cooldown/vampire/gohome/activate_power()
	. = ..()
	var/turf/old_turf = get_turf(owner)
	teleport_to_coffin(owner)
	flicker_lights(4, 60, old_turf)

/datum/action/cooldown/vampire/gohome/proc/flicker_lights(flicker_range, beat_volume)
	for(var/obj/machinery/light/nearby_lights in view(flicker_range, get_turf(owner)))
		nearby_lights.flicker(5)
	playsound(get_turf(owner), 'sound/effects/singlebeat.ogg', vol = beat_volume, vary = TRUE)

/datum/action/cooldown/vampire/gohome/proc/teleport_to_coffin(mob/living/carbon/user)
	var/turf/current_turf = get_turf(owner)
	// If we aren't in the dark, anyone watching us will cause us to drop out stuff
	if(GET_SIMPLE_LUMCOUNT(current_turf) >= 0.2)
		for(var/mob/living/watcher in viewers(world.view, get_turf(owner)) - owner)
			if(QDELETED(watcher.client) || watcher.client?.is_afk() || watcher.stat != CONSCIOUS)
				continue
			if(isanimal_or_basicmob(watcher))
				continue
			if(HAS_SILICON_ACCESS(watcher) || HAS_TRAIT(watcher, TRAIT_GHOST_CRITTER) || isdrone(watcher))
				continue
			if(watcher.is_blind() || watcher.is_nearsighted_currently())
				continue
			if(!HAS_MIND_TRAIT(watcher, TRAIT_VAMPIRE_ALIGNED))
				user.unequip_everything()
				break
	user.uncuff()

	playsound(current_turf, 'sound/magic/summon_karp.ogg', 60, 1)

	var/datum/effect_system/steam_spread/vampire/puff = new /datum/effect_system/steam_spread/vampire()
	puff.set_up(3, 0, current_turf)
	puff.start()

	/// STEP FIVE: Create animal at prev location
	var/mob/living/simple_animal/new_mob = pick_weight(spawning_mobs)
	new new_mob(current_turf)
	/// TELEPORT: Move to Coffin & Close it!
	user.set_resting(TRUE, TRUE, FALSE)
	do_teleport(owner, vampiredatum_power.coffin, channel = TELEPORT_CHANNEL_MAGIC, no_effects = TRUE)
	vampiredatum_power.coffin.close(owner)
	vampiredatum_power.coffin.take_contents()
	playsound(vampiredatum_power.coffin.loc, vampiredatum_power.coffin.close_sound, 15, TRUE, -3)

	deactivate_power()

/datum/effect_system/steam_spread/vampire
	effect_type = /obj/effect/particle_effect/fluid/smoke/vampsmoke

#undef GOHOME_START
#undef GOHOME_FLICKER_ONE
#undef GOHOME_FLICKER_TWO
#undef GOHOME_TELEPORT
